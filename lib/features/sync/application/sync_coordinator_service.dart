import 'dart:convert';

import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_incident_report_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/sync/application/sync_engine.dart';
import 'package:taarak/features/sync/application/sync_transport.dart';
import 'package:taarak/features/sync/domain/remote_sync_record.dart';
import 'package:taarak/features/sync/domain/sync_conflict_resolution.dart';
import 'package:taarak/features/sync/domain/sync_push_outcome.dart';
import 'package:taarak/features/sync/domain/sync_run_summary.dart';

const _incidentReportsTable = 'local_incident_reports';

/// Orchestrates M17: drains the M03 sync outbox — every offline-created
/// citizen action, regardless of which feature enqueued it — through
/// [SyncEngine]'s dedup/priority/backoff/conflict rules and a
/// [SyncTransport]. The acceptance criterion is this class's whole job:
/// offline data must synchronize safely once connectivity is back, "safely"
/// meaning no duplicate pushes, no silent data loss on conflict, and no
/// hammering a backend that just rejected a request.
class SyncCoordinatorService {
  final SyncQueueDao _syncQueueDao;
  final NetworkInfo _networkInfo;
  final SyncTransport _transport;
  final SyncEngine _engine;
  final LocalIncidentReportRepository? _incidentReportRepository;

  SyncCoordinatorService({
    required SyncQueueDao syncQueueDao,
    required NetworkInfo networkInfo,
    required SyncTransport transport,
    SyncEngine? engine,
    LocalIncidentReportRepository? incidentReportRepository,
  }) : _syncQueueDao = syncQueueDao,
       _networkInfo = networkInfo,
       _transport = transport,
       _engine = engine ?? SyncEngine(),
       _incidentReportRepository = incidentReportRepository;

  Future<SyncRunSummary> syncPendingEntries({DateTime? now}) async {
    if (!await _networkInfo.isConnected) {
      return const SyncRunSummary(skippedOffline: true);
    }

    final occurredAt = now ?? DateTime.now();

    final pendingResult = await _syncQueueDao.listSyncable();
    final pending = pendingResult.dataOrNull ?? const [];
    if (pending.isEmpty) {
      // Nothing of ours to push, but an official/command device that
      // never creates its own citizen reports should still pull in
      // whatever other devices have pushed — an empty outbox isn't a
      // reason to skip that half of sync.
      final pulled = await _pullIncidentReports();
      return SyncRunSummary(pulledCount: pulled);
    }

    final deduped = _engine.dedupe(pending);
    for (final stale in deduped.superseded) {
      await _syncQueueDao.markSynced(stale.id);
    }

    final ordered = _engine.prioritize(deduped.toPush);

    var synced = 0;
    var conflicts = 0;
    var failed = 0;
    var abandoned = 0;

    for (final entry in ordered) {
      if (_engine.shouldGiveUp(entry)) {
        abandoned++;
        continue;
      }
      if (!_engine.isReadyToRetry(entry, occurredAt)) {
        continue;
      }

      final pushResult = await _transport.push(entry);
      switch (pushResult) {
        case Success<SyncPushOutcome>(:final data):
          if (data.status == SyncPushStatus.accepted) {
            await _syncQueueDao.markSynced(entry.id);
            synced++;
          } else {
            conflicts++;
            final resolution = _engine.resolveConflict(
              localVersion: _engine.localVersionOf(entry),
              serverVersion:
                  data.serverVersion ?? _engine.localVersionOf(entry),
            );
            if (resolution == SyncConflictResolution.serverWins) {
              // The server already has an equal-or-newer version — this
              // push is redundant, not an error, so it's done, not failed.
              await _syncQueueDao.markSynced(entry.id);
            } else {
              await _syncQueueDao.markFailed(entry.id, now: occurredAt);
            }
          }
        case Failed<SyncPushOutcome>():
          failed++;
          await _syncQueueDao.markFailed(entry.id, now: occurredAt);
      }
    }

    final pulled = await _pullIncidentReports();

    return SyncRunSummary(
      syncedCount: synced,
      conflictCount: conflicts,
      failedCount: failed,
      abandonedCount: abandoned,
      pulledCount: pulled,
    );
  }

  /// The other half of "sync": brings in incident reports other devices
  /// have pushed, so a citizen's report is actually visible to an
  /// official on a second device, not just accepted into a backend no one
  /// ever reads from. Only applied when [_incidentReportRepository] was
  /// wired in — tests that only care about the push path can omit it and
  /// this is a no-op.
  Future<int> _pullIncidentReports() async {
    final repository = _incidentReportRepository;
    if (repository == null) return 0;

    final pullResult = await _transport.pullAll(_incidentReportsTable);
    final remoteRecords = pullResult.dataOrNull ?? const <RemoteSyncRecord>[];

    var applied = 0;
    for (final record in remoteRecords) {
      final localResult = await repository.getById(record.entityId);
      final local = localResult.dataOrNull;
      if (local != null && local.version >= record.version) continue;

      final report = _reportFromPayload(record);
      if (report == null) continue;

      await repository.save(report);
      applied++;
    }
    return applied;
  }

  LocalIncidentReport? _reportFromPayload(RemoteSyncRecord record) {
    try {
      final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
      return LocalIncidentReport(
        id: record.entityId,
        incidentId: null,
        reporterId: payload['reporterId'] as String?,
        latitude: (payload['latitude'] as num).toDouble(),
        longitude: (payload['longitude'] as num).toDouble(),
        reportType: payload['reportType'] as String,
        description: payload['description'] as String? ?? '',
        severity: payload['severity'] as String? ?? 'unknown',
        affectedPeopleCount: (payload['affectedPeopleCount'] as num?)?.toInt(),
        // A remote report's photo, if any, lives on the device that took
        // it — there's no media upload/download path in this backend
        // stub, so pulling a path that only resolves on another device
        // would be a broken reference here, not a real attachment.
        mediaPath: null,
        createdAt: DateTime.parse(payload['createdAt'] as String),
        updatedAt: DateTime.now(),
        version: record.version,
        isSynced: true,
      );
    } catch (_) {
      return null;
    }
  }
}
