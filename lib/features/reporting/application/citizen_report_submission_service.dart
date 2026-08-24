import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_incident_report_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/location/geo_tag.dart';
import 'package:taarak/core/location/geo_tag_service.dart';
import 'package:taarak/core/logging/app_logger.dart';
import 'package:taarak/core/media/image_compressor.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/reporting/domain/citizen_report_draft.dart';
import 'package:taarak/features/reporting/domain/citizen_report_type.dart';
import 'package:taarak/features/sync/application/sync_engine.dart';

const _uuid = Uuid();

/// Orchestrates M12: captures a fresh GPS fix, writes the report to the
/// local cache, and enqueues it on the sync outbox — always, regardless of
/// current connectivity. There's no "submit straight to the backend" path
/// here: every report is saved locally and queued first (the acceptance
/// criterion), and draining that queue when connectivity is available is
/// M17's job, not this one's.
///
/// M21 extends this with an attached photo's compress/queue step: the
/// report's own sync entry never carries image bytes, only a reference —
/// a separate, lower-priority queue entry (see [[SyncEngine]]) carries the
/// compressed photo, so a slow connection or a compression failure never
/// blocks the critical text/GPS data from syncing.
class CitizenReportSubmissionService {
  final LocalIncidentReportRepository _reportRepository;
  final SyncQueueDao _syncQueueDao;
  final GeoTagService _geoTagService;
  final ImageCompressor? _imageCompressor;

  CitizenReportSubmissionService({
    required LocalIncidentReportRepository reportRepository,
    required SyncQueueDao syncQueueDao,
    required GeoTagService geoTagService,
    ImageCompressor? imageCompressor,
  }) : _reportRepository = reportRepository,
       _syncQueueDao = syncQueueDao,
       _geoTagService = geoTagService,
       _imageCompressor = imageCompressor;

  Future<Result<LocalIncidentReport>> submitReport(
    CitizenReportDraft draft, {
    required String reporterId,
    DateTime? now,
  }) async {
    final geoTagResult = await _geoTagService.captureGeoTag();
    if (geoTagResult case Failed<GeoTag>(:final failure)) {
      return Result.failure(failure);
    }
    final geoTag = geoTagResult.dataOrNull!;
    final submittedAt = now ?? DateTime.now();

    final report = LocalIncidentReport(
      id: _uuid.v4(),
      incidentId: null,
      reporterId: reporterId,
      latitude: geoTag.fix.latitude,
      longitude: geoTag.fix.longitude,
      reportType: draft.type.storageValue,
      description: draft.description,
      severity: draft.severity,
      affectedPeopleCount: draft.affectedPeopleCount,
      mediaPath: draft.mediaPath,
      createdAt: submittedAt,
      updatedAt: submittedAt,
      version: 1,
      isSynced: false,
    );

    final saveResult = await _reportRepository.save(report);
    if (saveResult case Failed<LocalIncidentReport>(:final failure)) {
      return Result.failure(failure);
    }

    await _syncQueueDao.enqueue(
      entityTable: 'local_incident_reports',
      entityId: report.id,
      operation: 'create',
      payloadJson: jsonEncode({
        'id': report.id,
        'reporterId': report.reporterId,
        'latitude': report.latitude,
        'longitude': report.longitude,
        'reportType': report.reportType,
        'description': report.description,
        'severity': report.severity,
        'affectedPeopleCount': report.affectedPeopleCount,
        'mediaPath': report.mediaPath,
        'createdAt': report.createdAt.toIso8601String(),
        'version': report.version,
      }),
    );

    if (report.mediaPath != null) {
      await _enqueueMedia(report);
    }

    return Result.success(report);
  }

  /// Best-effort: a photo that fails to compress (unreadable file, an
  /// unsupported format, a web blob URL `dart:io` can't open) is logged
  /// and dropped, never allowed to fail — or even delay — the report
  /// submission above, which has already completed by the time this runs.
  Future<void> _enqueueMedia(LocalIncidentReport report) async {
    final compressor = _imageCompressor;
    if (compressor == null) return;

    try {
      final compressed = await compressor.compress(report.mediaPath!);
      await _syncQueueDao.enqueue(
        entityTable: SyncEngine.mediaAttachmentsTable,
        entityId: '${report.id}-media',
        operation: 'create',
        payloadJson: jsonEncode({
          'reportId': report.id,
          'path': compressed.path,
          'originalSizeBytes': compressed.originalSizeBytes,
          'compressedSizeBytes': compressed.compressedSizeBytes,
        }),
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Skipping media attachment for report ${report.id}: could not compress '
        '${report.mediaPath} ($error)',
      );
      AppLogger.debug(stackTrace.toString());
    }
  }

  /// SOS is a full report under the hood, just with minimal required
  /// input — "high-priority location-linked request" per the blueprint.
  Future<Result<LocalIncidentReport>> submitSos({
    String note = '',
    required String reporterId,
    DateTime? now,
  }) => submitReport(
    CitizenReportDraft(
      type: CitizenReportType.sos,
      description: note,
      severity: 'critical',
    ),
    reporterId: reporterId,
    now: now,
  );

  /// "I am safe" is a status ping, not a hazard report — no severity.
  Future<Result<LocalIncidentReport>> submitSafeStatus({
    String note = '',
    required String reporterId,
    DateTime? now,
  }) => submitReport(
    CitizenReportDraft(type: CitizenReportType.safeStatus, description: note),
    reporterId: reporterId,
    now: now,
  );
}
