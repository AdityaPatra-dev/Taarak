import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/repository/result.dart';

const _uuid = Uuid();

/// The front door for getting a vulnerable habitation into the local
/// cache — the PS's own subject ("Vulnerable Habitations"). Until this
/// existed, [LocalHabitation] rows only ever came from a demo seeder;
/// M07/M09/M10's engines were real but had nothing an official actually
/// registered to run against. Mirrors [HazardIngestionService]'s shape.
class HabitationRegistrationService {
  final LocalHabitationRepository _repository;
  final SyncQueueDao? _syncQueueDao;
  final AuditLogDao? _auditLogDao;

  HabitationRegistrationService({
    required LocalHabitationRepository repository,
    SyncQueueDao? syncQueueDao,
    AuditLogDao? auditLogDao,
  }) : _repository = repository,
       _syncQueueDao = syncQueueDao,
       _auditLogDao = auditLogDao;

  Future<Result<LocalHabitation>> register({
    String? id,
    required String name,
    required double latitude,
    required double longitude,
    required int population,
    String? administrativeRegionName,
    double? infrastructureQuality,
    double? accessQuality,
    required String officialId,
    DateTime? now,
  }) async {
    final habitationId = id ?? _uuid.v4();
    final existing = await _repository.getById(habitationId);
    final nextVersion = (existing.dataOrNull?.version ?? 0) + 1;
    final occurredAt = now ?? DateTime.now();

    final row = LocalHabitation(
      id: habitationId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      population: population,
      administrativeRegionName: administrativeRegionName,
      infrastructureQuality: infrastructureQuality,
      accessQuality: accessQuality,
      updatedAt: occurredAt,
      version: nextVersion,
    );

    final saveResult = await _repository.save(row);
    if (saveResult case Failed<LocalHabitation>(:final failure)) {
      return Result.failure(failure);
    }

    await _syncQueueDao?.enqueue(
      entityTable: 'local_habitations',
      entityId: row.id,
      operation: existing.dataOrNull == null ? 'create' : 'update',
      payloadJson: jsonEncode({
        'name': row.name,
        'latitude': row.latitude,
        'longitude': row.longitude,
        'population': row.population,
        'administrativeRegionName': row.administrativeRegionName,
        'infrastructureQuality': row.infrastructureQuality,
        'accessQuality': row.accessQuality,
        'version': row.version,
      }),
    );

    await _auditLogDao?.record(
      actorId: officialId,
      action: existing.dataOrNull == null
          ? 'habitation.registered'
          : 'habitation.updated',
      objectType: 'habitation',
      objectId: habitationId,
      newValue: jsonEncode({'name': name, 'population': population}),
      now: occurredAt,
    );

    return Result.success(row);
  }

  Future<Result<List<LocalHabitation>>> listAll() => _repository.getAll();
}
