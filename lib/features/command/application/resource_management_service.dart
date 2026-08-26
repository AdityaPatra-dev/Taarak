import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_resource_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/repository/result.dart';

const _uuid = Uuid();

/// District/Command's ([Permission.manageResources]) write path for
/// tracked response resources — same create-or-update-by-omitted-id shape
/// as [ShelterManagementService.upsertShelter], since both are managed
/// from the same kind of list+dialog screen.
class ResourceManagementService {
  final LocalResourceRepository _repository;
  final AuditLogDao _auditLogDao;
  final SyncQueueDao? _syncQueueDao;

  ResourceManagementService({
    required LocalResourceRepository repository,
    required AuditLogDao auditLogDao,
    SyncQueueDao? syncQueueDao,
  }) : _repository = repository,
       _auditLogDao = auditLogDao,
       _syncQueueDao = syncQueueDao;

  Future<void> _enqueueSync(LocalResource resource) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    await syncQueueDao.enqueue(
      entityTable: 'local_resources',
      entityId: resource.id,
      operation: 'create',
      payloadJson: jsonEncode({
        'name': resource.name,
        'type': resource.type,
        'quantity': resource.quantity,
        'shelterId': resource.shelterId,
        'version': resource.version,
      }),
    );
  }

  Future<Result<List<LocalResource>>> listResources() =>
      _repository.getAll();

  Future<Result<LocalResource>> upsertResource({
    String? id,
    required String name,
    required String type,
    required int quantity,
    String? shelterId,
    required String officialId,
    DateTime? now,
  }) async {
    final occurredAt = now ?? DateTime.now();
    final isNew = id == null;

    LocalResource? previous;
    if (!isNew) {
      final existingResult = await _repository.getById(id);
      previous = existingResult.dataOrNull;
    }

    final resource = LocalResource(
      id: id ?? _uuid.v4(),
      name: name,
      type: type,
      quantity: quantity,
      shelterId: shelterId,
      updatedAt: occurredAt,
      version: (previous?.version ?? 0) + 1,
    );

    final saveResult = await _repository.save(resource);
    if (saveResult case Failed<LocalResource>()) return saveResult;
    await _enqueueSync(resource);

    await _auditLogDao.record(
      actorId: officialId,
      action: isNew ? 'resource.created' : 'resource.updated',
      objectType: 'resource',
      objectId: resource.id,
      newValue: jsonEncode({'quantity': resource.quantity}),
      now: occurredAt,
    );

    return Result.success(resource);
  }
}
