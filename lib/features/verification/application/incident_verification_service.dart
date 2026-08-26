import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_incident_report_repository.dart';
import 'package:taarak/core/database/repositories/local_incident_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/fusion/application/ground_truth_fusion_engine.dart';
import 'package:taarak/features/verification/application/incident_verification_engine.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';

const _uuid = Uuid();

/// Orchestrates M13: turns an unlinked citizen report into a tracked
/// incident — via M14's fusion engine, so a report that matches an
/// already-tracked incident joins it instead of spawning a duplicate —
/// and moves incidents through the verification lifecycle, writing a real
/// audit entry to [[AuditLogDao]] for every state change, which is the
/// acceptance criterion itself, not an afterthought.
class IncidentVerificationService {
  final LocalIncidentReportRepository _reportRepository;
  final LocalIncidentRepository _incidentRepository;
  final AuditLogDao _auditLogDao;
  final IncidentVerificationEngine _engine;
  final GroundTruthFusionEngine _fusionEngine;
  final SyncQueueDao? _syncQueueDao;

  IncidentVerificationService({
    required LocalIncidentReportRepository reportRepository,
    required LocalIncidentRepository incidentRepository,
    required AuditLogDao auditLogDao,
    IncidentVerificationEngine? engine,
    GroundTruthFusionEngine? fusionEngine,
    SyncQueueDao? syncQueueDao,
  }) : _reportRepository = reportRepository,
       _incidentRepository = incidentRepository,
       _auditLogDao = auditLogDao,
       _engine = engine ?? IncidentVerificationEngine(),
       _fusionEngine = fusionEngine ?? GroundTruthFusionEngine(),
       _syncQueueDao = syncQueueDao;

  Future<void> _enqueueIncidentSync(LocalIncident incident) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    await syncQueueDao.enqueue(
      entityTable: 'local_incidents',
      entityId: incident.id,
      operation: 'create',
      payloadJson: jsonEncode({
        'type': incident.type,
        'status': incident.status,
        'latitude': incident.latitude,
        'longitude': incident.longitude,
        'description': incident.description,
        'severity': incident.severity,
        'independentSourceCount': incident.independentSourceCount,
        'confidence': incident.confidence,
        'createdAt': incident.createdAt.toIso8601String(),
        'version': incident.version,
        'assignedResponderId': incident.assignedResponderId,
      }),
    );
  }

  /// Either merges the report into a matching existing incident (M14) or
  /// creates a new one in the "acknowledged" state — the report has been
  /// seen by an official either way, even if not yet confirmed true.
  Future<Result<LocalIncident>> acknowledgeReport({
    required String reportId,
    required String officialId,
    String? reason,
    DateTime? now,
  }) async {
    final reportResult = await _reportRepository.getById(reportId);
    if (reportResult case Failed<LocalIncidentReport>(:final failure)) {
      return Result.failure(failure);
    }
    final report = reportResult.dataOrNull!;

    final incidentsResult = await _incidentRepository.getAll();
    final existingIncidents = incidentsResult.dataOrNull ?? const [];

    final allReportsResult = await _reportRepository.getAll();
    final reportsByIncidentId = <String, List<LocalIncidentReport>>{};
    for (final existingReport in allReportsResult.dataOrNull ?? const []) {
      final incidentId = existingReport.incidentId;
      if (incidentId != null) {
        reportsByIncidentId.putIfAbsent(incidentId, () => []).add(existingReport);
      }
    }

    final match = _fusionEngine.evaluate(
      newReport: report,
      existingIncidents: existingIncidents,
      reportsByIncidentId: reportsByIncidentId,
    );

    final occurredAt = now ?? DateTime.now();
    final LocalIncident incident;

    if (match.isNewIncident) {
      incident = LocalIncident(
        id: _uuid.v4(),
        type: report.reportType,
        status: IncidentVerificationStatus.acknowledged.storageValue,
        latitude: report.latitude,
        longitude: report.longitude,
        description: report.description,
        severity: match.severity,
        independentSourceCount: match.independentSourceCount,
        confidence: match.confidence,
        createdAt: occurredAt,
        updatedAt: occurredAt,
        version: 1,
        isSynced: false,
      );
    } else {
      final existingResult = await _incidentRepository.getById(
        match.matchedIncidentId!,
      );
      if (existingResult case Failed<LocalIncident>(:final failure)) {
        return Result.failure(failure);
      }
      final existing = existingResult.dataOrNull!;
      incident = existing.copyWith(
        severity: match.severity,
        independentSourceCount: match.independentSourceCount,
        confidence: match.confidence,
        updatedAt: occurredAt,
        version: existing.version + 1,
      );
    }

    final saveResult = await _incidentRepository.save(incident);
    if (saveResult case Failed<LocalIncident>(:final failure)) {
      return Result.failure(failure);
    }
    await _enqueueIncidentSync(incident);

    await _reportRepository.save(
      report.copyWith(incidentId: Value(incident.id), updatedAt: occurredAt),
    );

    await _auditLogDao.record(
      actorId: officialId,
      action: match.isNewIncident ? 'incident.acknowledged' : 'incident.report_merged',
      objectType: 'incident',
      objectId: incident.id,
      newValue: jsonEncode({
        'status': incident.status,
        'fromReportId': reportId,
        'independentSourceCount': match.independentSourceCount,
        'confidence': match.confidence,
      }),
      reason: reason,
      now: occurredAt,
    );

    return Result.success(incident);
  }

  Future<Result<LocalIncident>> transitionIncident({
    required String incidentId,
    required IncidentVerificationStatus to,
    required String officialId,
    String? reason,
    String? evidence,
    DateTime? now,
  }) async {
    final incidentResult = await _incidentRepository.getById(incidentId);
    if (incidentResult case Failed<LocalIncident>(:final failure)) {
      return Result.failure(failure);
    }
    final incident = incidentResult.dataOrNull!;

    final currentStatus =
        IncidentVerificationStatus.fromStorageValue(incident.status) ??
        IncidentVerificationStatus.reported;

    final transitionResult = _engine.validateTransition(
      from: currentStatus,
      to: to,
    );
    if (transitionResult case Failed<IncidentVerificationStatus>(:final failure)) {
      return Result.failure(failure);
    }

    final occurredAt = now ?? DateTime.now();
    final updated = incident.copyWith(
      status: to.storageValue,
      updatedAt: occurredAt,
      version: incident.version + 1,
    );

    final saveResult = await _incidentRepository.save(updated);
    if (saveResult case Failed<LocalIncident>(:final failure)) {
      return Result.failure(failure);
    }
    await _enqueueIncidentSync(updated);

    await _auditLogDao.record(
      actorId: officialId,
      action: 'incident.status_changed',
      objectType: 'incident',
      objectId: incident.id,
      oldValue: jsonEncode({'status': currentStatus.storageValue}),
      newValue: jsonEncode({'status': to.storageValue, 'evidence': ?evidence}),
      reason: reason,
      now: occurredAt,
    );

    return Result.success(updated);
  }

  /// District/Command's responder-assignment action. `responderId: null`
  /// unassigns — an incident that no longer needs someone sent to it.
  Future<Result<LocalIncident>> assignResponder({
    required String incidentId,
    required String? responderId,
    required String officialId,
    DateTime? now,
  }) async {
    final incidentResult = await _incidentRepository.getById(incidentId);
    if (incidentResult case Failed<LocalIncident>(:final failure)) {
      return Result.failure(failure);
    }
    final incident = incidentResult.dataOrNull!;
    final occurredAt = now ?? DateTime.now();

    final updated = incident.copyWith(
      assignedResponderId: Value(responderId),
      updatedAt: occurredAt,
      version: incident.version + 1,
    );

    final saveResult = await _incidentRepository.save(updated);
    if (saveResult case Failed<LocalIncident>(:final failure)) {
      return Result.failure(failure);
    }
    await _enqueueIncidentSync(updated);

    await _auditLogDao.record(
      actorId: officialId,
      action: responderId == null
          ? 'incident.responder_unassigned'
          : 'incident.responder_assigned',
      objectType: 'incident',
      objectId: incident.id,
      newValue: jsonEncode({'assignedResponderId': responderId}),
      now: occurredAt,
    );

    return Result.success(updated);
  }

  /// The reports an official still needs to look at — created (M12) but
  /// not yet turned into a tracked incident.
  Future<Result<List<LocalIncidentReport>>> pendingReports() async {
    final result = await _reportRepository.getAll();
    return result.when(
      success: (reports) => Result.success(
        reports.where((report) => report.incidentId == null).toList(),
      ),
      failure: (failure) => Result.failure(failure),
    );
  }

  Future<Result<List<LocalAuditEvent>>> auditTrailFor(String incidentId) =>
      _auditLogDao.listForObject('incident', incidentId);
}
