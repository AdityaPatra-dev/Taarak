import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/sync/application/sync_engine.dart';
import 'package:taarak/features/sync/application/sync_transport.dart';
import 'package:taarak/features/sync/domain/sync_conflict_resolution.dart';
import 'package:taarak/features/sync/domain/sync_push_outcome.dart';
import 'package:taarak/features/sync/domain/sync_run_summary.dart';

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

  SyncCoordinatorService({
    required SyncQueueDao syncQueueDao,
    required NetworkInfo networkInfo,
    required SyncTransport transport,
    SyncEngine? engine,
  }) : _syncQueueDao = syncQueueDao,
       _networkInfo = networkInfo,
       _transport = transport,
       _engine = engine ?? SyncEngine();

  Future<SyncRunSummary> syncPendingEntries({DateTime? now}) async {
    if (!await _networkInfo.isConnected) {
      return const SyncRunSummary(skippedOffline: true);
    }

    final occurredAt = now ?? DateTime.now();

    final pendingResult = await _syncQueueDao.listSyncable();
    final pending = pendingResult.dataOrNull ?? const [];
    if (pending.isEmpty) return const SyncRunSummary();

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
              serverVersion: data.serverVersion ?? _engine.localVersionOf(entry),
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

    return SyncRunSummary(
      syncedCount: synced,
      conflictCount: conflicts,
      failedCount: failed,
      abandonedCount: abandoned,
    );
  }
}
