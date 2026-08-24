import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_incident_report_repository.dart';
import 'package:taarak/core/database/repositories/local_incident_repository.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/verification/application/incident_verification_engine.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';

const _uuid = Uuid();

/// Orchestrates M13: turns an unlinked citizen report into a tracked
/// incident, and moves incidents through the verification lifecycle —
/// writing a real audit entry to [[AuditLogDao]] for every state change,
/// which is the acceptance criterion itself, not an afterthought.
class IncidentVerificationService {
  final LocalIncidentReportRepository _reportRepository;
  final LocalIncidentRepository _incidentRepository;
  final AuditLogDao _auditLogDao;
  final IncidentVerificationEngine _engine;

  IncidentVerificationService({
    required LocalIncidentReportRepository reportRepository,
    required LocalIncidentRepository incidentRepository,
    required AuditLogDao auditLogDao,
    IncidentVerificationEngine? engine,
  }) : _reportRepository = reportRepository,
       _incidentRepository = incidentRepository,
       _auditLogDao = auditLogDao,
       _engine = engine ?? IncidentVerificationEngine();

  /// Creates a tracked incident from an unlinked report, in the
  /// "acknowledged" state — the report has been seen by an official, even
  /// if not yet confirmed true.
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

    final occurredAt = now ?? DateTime.now();
    final incident = LocalIncident(
      id: _uuid.v4(),
      type: report.reportType,
      status: IncidentVerificationStatus.acknowledged.storageValue,
      latitude: report.latitude,
      longitude: report.longitude,
      description: report.description,
      severity: report.severity,
      createdAt: occurredAt,
      updatedAt: occurredAt,
      version: 1,
      isSynced: false,
    );

    final saveResult = await _incidentRepository.save(incident);
    if (saveResult case Failed<LocalIncident>(:final failure)) {
      return Result.failure(failure);
    }

    await _reportRepository.save(
      report.copyWith(incidentId: Value(incident.id), updatedAt: occurredAt),
    );

    await _auditLogDao.record(
      actorId: officialId,
      action: 'incident.acknowledged',
      objectType: 'incident',
      objectId: incident.id,
      newValue: jsonEncode({
        'status': incident.status,
        'fromReportId': reportId,
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
