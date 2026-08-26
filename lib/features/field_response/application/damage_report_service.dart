import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_damage_report_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/repository/result.dart';

const _uuid = Uuid();

/// A Field Responder's ([Permission.submitDamageReport]) on-site
/// assessment for an incident they're assigned to.
class DamageReportService {
  final LocalDamageReportRepository _repository;
  final SyncQueueDao? _syncQueueDao;

  DamageReportService({
    required LocalDamageReportRepository repository,
    SyncQueueDao? syncQueueDao,
  }) : _repository = repository,
       _syncQueueDao = syncQueueDao;

  Future<void> _enqueueSync(LocalDamageReport report) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    await syncQueueDao.enqueue(
      entityTable: 'local_damage_reports',
      entityId: report.id,
      operation: 'create',
      payloadJson: jsonEncode({
        'incidentId': report.incidentId,
        'responderId': report.responderId,
        'description': report.description,
        'severity': report.severity,
        'submittedAt': report.submittedAt.toIso8601String(),
        'version': report.version,
      }),
    );
  }

  Future<Result<LocalDamageReport>> submit({
    required String incidentId,
    required String responderId,
    required String description,
    required String severity,
    DateTime? now,
  }) async {
    final report = LocalDamageReport(
      id: _uuid.v4(),
      incidentId: incidentId,
      responderId: responderId,
      description: description,
      severity: severity,
      submittedAt: now ?? DateTime.now(),
      version: 1,
    );

    final saveResult = await _repository.save(report);
    if (saveResult case Failed<LocalDamageReport>()) return saveResult;
    await _enqueueSync(report);
    return saveResult;
  }

  Future<Result<List<LocalDamageReport>>> forIncident(String incidentId) =>
      _repository.getForIncident(incidentId);
}
