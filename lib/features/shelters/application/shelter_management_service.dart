import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/shelters/domain/shelter_facility_type.dart';

const _uuid = Uuid();

/// M15: the write path a Local Official uses to keep [LocalShelters] rows
/// current — the read path (capacity/facilities feeding M09's capacity gap
/// and M10's relocation ranking) already existed before this module. Every
/// change is audited, matching M13's established pattern of a real audit
/// entry for every state-affecting action rather than silent writes.
class ShelterManagementService {
  final LocalShelterRepository _shelterRepository;
  final AuditLogDao _auditLogDao;
  final SyncQueueDao? _syncQueueDao;

  ShelterManagementService({
    required LocalShelterRepository shelterRepository,
    required AuditLogDao auditLogDao,
    SyncQueueDao? syncQueueDao,
  }) : _shelterRepository = shelterRepository,
       _auditLogDao = auditLogDao,
       _syncQueueDao = syncQueueDao;

  Future<void> _enqueueShelterSync(LocalShelter shelter) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    await syncQueueDao.enqueue(
      entityTable: 'local_shelters',
      entityId: shelter.id,
      operation: 'create',
      payloadJson: jsonEncode({
        'name': shelter.name,
        'latitude': shelter.latitude,
        'longitude': shelter.longitude,
        'capacityTotal': shelter.capacityTotal,
        'occupancy': shelter.occupancy,
        'facilitiesJson': shelter.facilitiesJson,
        'accessQuality': shelter.accessQuality,
        'version': shelter.version,
      }),
    );
  }

  Future<Result<List<LocalShelter>>> listShelters() =>
      _shelterRepository.getAll();

  /// Creates a new shelter (when [id] is omitted) or updates an existing
  /// one — the same entry point either way, since a Local Official manages
  /// both from the same screen.
  Future<Result<LocalShelter>> upsertShelter({
    String? id,
    required String name,
    required double latitude,
    required double longitude,
    required int capacityTotal,
    int? occupancy,
    double? accessQuality,
    Set<ShelterFacilityType> facilities = const {},
    required String officialId,
    DateTime? now,
  }) async {
    final occurredAt = now ?? DateTime.now();
    final isNew = id == null;

    LocalShelter? previous;
    if (!isNew) {
      final existingResult = await _shelterRepository.getById(id);
      previous = existingResult.dataOrNull;
    }

    final shelter = LocalShelter(
      id: id ?? _uuid.v4(),
      name: name,
      latitude: latitude,
      longitude: longitude,
      capacityTotal: capacityTotal,
      occupancy: occupancy ?? previous?.occupancy ?? 0,
      facilitiesJson: jsonEncode(
        facilities.map((f) => f.storageValue).toList(),
      ),
      accessQuality: accessQuality ?? previous?.accessQuality,
      updatedAt: occurredAt,
      version: (previous?.version ?? 0) + 1,
    );

    final saveResult = await _shelterRepository.save(shelter);
    if (saveResult case Failed<LocalShelter>(:final failure)) {
      return Result.failure(failure);
    }
    await _enqueueShelterSync(shelter);

    await _auditLogDao.record(
      actorId: officialId,
      action: isNew ? 'shelter.created' : 'shelter.updated',
      objectType: 'shelter',
      objectId: shelter.id,
      oldValue: previous == null
          ? null
          : jsonEncode({
              'capacityTotal': previous.capacityTotal,
              'occupancy': previous.occupancy,
            }),
      newValue: jsonEncode({
        'capacityTotal': shelter.capacityTotal,
        'occupancy': shelter.occupancy,
        'facilities': facilities.map((f) => f.storageValue).toList(),
      }),
      now: occurredAt,
    );

    return Result.success(shelter);
  }

  /// A dedicated, lighter-weight path for the one field that changes most
  /// often during an active response — occupancy — without requiring the
  /// official to re-enter every other field just to log a headcount.
  Future<Result<LocalShelter>> updateOccupancy({
    required String shelterId,
    required int occupancy,
    required String officialId,
    DateTime? now,
  }) async {
    final existingResult = await _shelterRepository.getById(shelterId);
    if (existingResult case Failed<LocalShelter>(:final failure)) {
      return Result.failure(failure);
    }
    final existing = existingResult.dataOrNull!;
    final occurredAt = now ?? DateTime.now();

    final updated = existing.copyWith(
      occupancy: occupancy,
      updatedAt: occurredAt,
      version: existing.version + 1,
    );

    final saveResult = await _shelterRepository.save(updated);
    if (saveResult case Failed<LocalShelter>(:final failure)) {
      return Result.failure(failure);
    }
    await _enqueueShelterSync(updated);

    await _auditLogDao.record(
      actorId: officialId,
      action: 'shelter.occupancy_updated',
      objectType: 'shelter',
      objectId: shelterId,
      oldValue: jsonEncode({'occupancy': existing.occupancy}),
      newValue: jsonEncode({'occupancy': occupancy}),
      now: occurredAt,
    );

    return Result.success(updated);
  }

  /// An actual delete, both locally and (once synced) in Firestore — a
  /// shelter that's closed or was entered in error shouldn't keep showing
  /// up as a relocation candidate. Matches [HazardIngestionService.remove]'s
  /// pattern: confirm it exists, delete, enqueue the sync, then audit it.
  Future<Result<void>> removeShelter({
    required String shelterId,
    required String officialId,
    String? reason,
    DateTime? now,
  }) async {
    final existingResult = await _shelterRepository.getById(shelterId);
    if (existingResult case Failed<LocalShelter>(:final failure)) {
      return Result.failure(failure);
    }
    final occurredAt = now ?? DateTime.now();

    final deleteResult = await _shelterRepository.delete(shelterId);
    if (deleteResult case Failed<void>(:final failure)) {
      return Result.failure(failure);
    }

    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao != null) {
      await syncQueueDao.enqueue(
        entityTable: 'local_shelters',
        entityId: shelterId,
        operation: 'delete',
        payloadJson: '{}',
      );
    }

    await _auditLogDao.record(
      actorId: officialId,
      action: 'shelter.removed',
      objectType: 'shelter',
      objectId: shelterId,
      reason: reason,
      now: occurredAt,
    );

    return const Result.success(null);
  }

  Set<ShelterFacilityType> facilitiesOf(LocalShelter shelter) {
    try {
      final decoded = jsonDecode(shelter.facilitiesJson);
      if (decoded is! List) return const {};
      return decoded
          .map((v) => ShelterFacilityType.fromStorageValue(v.toString()))
          .whereType<ShelterFacilityType>()
          .toSet();
    } on FormatException {
      return const {};
    }
  }
}
