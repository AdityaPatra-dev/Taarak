import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'package:taarak/core/database/alert_acknowledgement_dao.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_alert_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/location/geo_tag.dart';
import 'package:taarak/core/location/geo_tag_service.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/alerts/application/alert_engine.dart';

const _uuid = Uuid();

/// Orchestrates M16: an official broadcasting to a selected hazard zone
/// (the acceptance criterion), a citizen checking which active alerts
/// apply to their current location, and the acknowledgement/history trail
/// the spec calls out alongside severity and validity.
class AlertBroadcastService {
  final LocalAlertRepository _alertRepository;
  final LocalHazardZoneRepository _hazardZoneRepository;
  final AlertAcknowledgementDao _acknowledgementDao;
  final AuditLogDao _auditLogDao;
  final AlertEngine _engine;
  final GeoTagService _geoTagService;
  final SyncQueueDao? _syncQueueDao;

  AlertBroadcastService({
    required LocalAlertRepository alertRepository,
    required LocalHazardZoneRepository hazardZoneRepository,
    required AlertAcknowledgementDao acknowledgementDao,
    required AuditLogDao auditLogDao,
    required GeoTagService geoTagService,
    AlertEngine? engine,
    SyncQueueDao? syncQueueDao,
  }) : _alertRepository = alertRepository,
       _hazardZoneRepository = hazardZoneRepository,
       _acknowledgementDao = acknowledgementDao,
       _auditLogDao = auditLogDao,
       _geoTagService = geoTagService,
       _engine = engine ?? AlertEngine(),
       _syncQueueDao = syncQueueDao;

  Future<void> _enqueueAlertSync(LocalAlert alert) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    await syncQueueDao.enqueue(
      entityTable: 'local_alerts',
      entityId: alert.id,
      operation: 'create',
      payloadJson: jsonEncode({
        'title': alert.title,
        'message': alert.message,
        'severity': alert.severity,
        'zoneId': alert.zoneId,
        'zoneLabel': alert.zoneLabel,
        'geometryJson': alert.geometryJson,
        'issuedBy': alert.issuedBy,
        'issuedAt': alert.issuedAt.toIso8601String(),
        'validUntil': alert.validUntil.toIso8601String(),
        'cancelledAt': alert.cancelledAt?.toIso8601String(),
        'version': alert.version,
      }),
    );
  }

  /// Broadcasts to the given zone — the acceptance criterion itself.
  /// `zoneId` must be an already-ingested [LocalHazardZones] row; the
  /// alert snapshots that zone's geometry/label at broadcast time.
  Future<Result<LocalAlert>> broadcastToZone({
    required String zoneId,
    required String title,
    required String message,
    required String severity,
    required Duration validFor,
    required String officialId,
    DateTime? now,
  }) async {
    final zoneResult = await _hazardZoneRepository.getById(zoneId);
    if (zoneResult case Failed<LocalHazardZone>(:final failure)) {
      return Result.failure(failure);
    }
    final zone = zoneResult.dataOrNull!;
    final occurredAt = now ?? DateTime.now();

    final alert = LocalAlert(
      id: _uuid.v4(),
      title: title,
      message: message,
      severity: severity,
      zoneId: zone.id,
      zoneLabel: '${zone.hazardType} zone',
      geometryJson: zone.geometryJson,
      issuedBy: officialId,
      issuedAt: occurredAt,
      validUntil: occurredAt.add(validFor),
      version: 1,
    );

    final saveResult = await _alertRepository.save(alert);
    if (saveResult case Failed<LocalAlert>(:final failure)) {
      return Result.failure(failure);
    }
    await _enqueueAlertSync(alert);

    await _auditLogDao.record(
      actorId: officialId,
      action: 'alert.broadcast',
      objectType: 'alert',
      objectId: alert.id,
      newValue: jsonEncode({
        'zoneId': zoneId,
        'severity': severity,
        'validUntil': alert.validUntil.toIso8601String(),
      }),
      now: occurredAt,
    );

    return Result.success(alert);
  }

  Future<Result<LocalAlert>> cancelAlert({
    required String alertId,
    required String officialId,
    String? reason,
    DateTime? now,
  }) async {
    final existingResult = await _alertRepository.getById(alertId);
    if (existingResult case Failed<LocalAlert>(:final failure)) {
      return Result.failure(failure);
    }
    final existing = existingResult.dataOrNull!;
    final occurredAt = now ?? DateTime.now();

    final cancelled = existing.copyWith(
      cancelledAt: Value(occurredAt),
      version: existing.version + 1,
    );

    final saveResult = await _alertRepository.save(cancelled);
    if (saveResult case Failed<LocalAlert>(:final failure)) {
      return Result.failure(failure);
    }
    await _enqueueAlertSync(cancelled);

    await _auditLogDao.record(
      actorId: officialId,
      action: 'alert.cancelled',
      objectType: 'alert',
      objectId: alertId,
      reason: reason,
      now: occurredAt,
    );

    return Result.success(cancelled);
  }

  Future<Result<void>> acknowledge({
    required String alertId,
    required String userId,
    DateTime? now,
  }) => _acknowledgementDao.acknowledge(alertId: alertId, userId: userId, now: now);

  Future<Result<List<LocalAlertAcknowledgement>>> acknowledgementsFor(
    String alertId,
  ) => _acknowledgementDao.listForAlert(alertId);

  /// All alerts ever broadcast, most recent first — the "history" the
  /// spec asks for alongside severity/validity/acknowledgement.
  Future<Result<List<LocalAlert>>> history() async {
    final result = await _alertRepository.getAll();
    return result.when(
      success: (alerts) => Result.success(
        alerts.toList()..sort((a, b) => b.issuedAt.compareTo(a.issuedAt)),
      ),
      failure: (failure) => Result.failure(failure),
    );
  }

  /// Active alerts whose target zone contains the citizen's current
  /// location. Fails with a [LocationFailure]-derived error via
  /// [GeoTagService] when a fix can't be captured, rather than silently
  /// returning an empty (and misleadingly reassuring) list.
  Future<Result<List<LocalAlert>>> activeAlertsForCurrentLocation({
    DateTime? now,
  }) async {
    final fixResult = await _geoTagService.captureGeoTag();
    if (fixResult case Failed<GeoTag>(:final failure)) {
      return Result.failure(failure);
    }
    final fix = fixResult.dataOrNull!.fix;

    final alertsResult = await _alertRepository.getAll();
    if (alertsResult case Failed<List<LocalAlert>>(:final failure)) {
      return Result.failure(failure);
    }

    final matches = _engine.activeAlertsForLocation(
      alerts: alertsResult.dataOrNull!,
      point: LatLng(fix.latitude, fix.longitude),
      now: now ?? DateTime.now(),
    );
    return Result.success(matches);
  }
}
