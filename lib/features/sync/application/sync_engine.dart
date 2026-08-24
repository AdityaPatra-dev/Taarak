import 'dart:convert';

import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/sync/domain/dedupe_result.dart';
import 'package:taarak/features/sync/domain/sync_conflict_resolution.dart';
import 'package:taarak/features/sync/domain/sync_queue_summary.dart';

const String syncModelVersion = '1.0.0';

/// M17's deterministic core: which queued entries actually need pushing,
/// in what order, whether an entry is ready to retry yet, and who wins a
/// version conflict. No I/O — [SyncCoordinatorService] is what actually
/// talks to the queue and the transport.
class SyncEngine {
  static const int defaultMaxAttempts = 5;
  static const Duration baseBackoff = Duration(seconds: 2);
  static const Duration maxBackoff = Duration(minutes: 5);

  /// Collapses multiple queued entries for the same entity down to the
  /// most recent one (highest id, since [SyncQueueEntries.id] is
  /// insertion-ordered) — an earlier queued change for an entity that's
  /// since been superseded by a later one is redundant to push at all.
  DedupeResult dedupe(List<SyncQueueEntry> entries) {
    final latestByEntity = <String, SyncQueueEntry>{};
    for (final entry in entries) {
      final key = '${entry.entityTable}:${entry.entityId}';
      final current = latestByEntity[key];
      if (current == null || entry.id > current.id) {
        latestByEntity[key] = entry;
      }
    }

    final toPush = latestByEntity.values.toList();
    final keptIds = toPush.map((e) => e.id).toSet();
    final superseded = entries.where((e) => !keptIds.contains(e.id)).toList();

    return DedupeResult(toPush: toPush, superseded: superseded);
  }

  /// Highest priority first — an SOS or critical-severity report jumps
  /// the queue ahead of routine reports, and every report (M21's "critical
  /// text/GPS") is pushed before any media attachment regardless of how
  /// long the media has been queued — then oldest-first within the same
  /// priority, so the queue is still a FIFO except for those two rules.
  List<SyncQueueEntry> prioritize(List<SyncQueueEntry> entries) {
    final sorted = [...entries];
    sorted.sort((a, b) {
      final priorityCompare = _priorityOf(a).compareTo(_priorityOf(b));
      if (priorityCompare != 0) return priorityCompare;
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }

  static const String mediaAttachmentsTable = 'media_attachments';

  int _priorityOf(SyncQueueEntry entry) {
    if (entry.entityTable == mediaAttachmentsTable) return 3;
    final payload = _decodePayload(entry);
    if (payload['reportType'] == 'sos') return 0;
    if (payload['severity'] == 'critical') return 1;
    return 2;
  }

  Map<String, dynamic> _decodePayload(SyncQueueEntry entry) {
    try {
      final decoded = jsonDecode(entry.payloadJson);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }

  /// A 'pending' entry (never attempted) is always ready. A 'failed' one
  /// waits out an exponential backoff from its last attempt first, so a
  /// reconnect doesn't immediately hammer a backend that just rejected it.
  bool isReadyToRetry(SyncQueueEntry entry, DateTime now) {
    if (entry.status != 'failed') return true;
    final lastAttempt = entry.lastAttemptAt;
    if (lastAttempt == null) return true;
    return !now.isBefore(lastAttempt.add(backoffDelay(entry.attemptCount)));
  }

  Duration backoffDelay(int attemptCount) {
    final exponent = attemptCount.clamp(0, 8);
    final scaled = baseBackoff * (1 << exponent);
    return scaled > maxBackoff ? maxBackoff : scaled;
  }

  bool shouldGiveUp(SyncQueueEntry entry, {int maxAttempts = defaultMaxAttempts}) =>
      entry.attemptCount >= maxAttempts;

  /// Version-based conflict resolution: whichever side actually has newer
  /// data wins, rather than always preferring the client or the server.
  SyncConflictResolution resolveConflict({
    required int localVersion,
    required int serverVersion,
  }) => localVersion > serverVersion
      ? SyncConflictResolution.localWins
      : SyncConflictResolution.serverWins;

  int localVersionOf(SyncQueueEntry entry) {
    final version = _decodePayload(entry)['version'];
    return version is int ? version : 1;
  }

  /// The honest breakdown behind a UI's "N items waiting to sync" — see
  /// [SyncQueueSummary] for why a flat count alone can't distinguish
  /// "not attempted yet" from "has been failing repeatedly".
  SyncQueueSummary summarize(List<SyncQueueEntry> entries) {
    var pending = 0;
    var retrying = 0;
    var stalled = 0;
    for (final entry in entries) {
      if (entry.status == 'pending') {
        pending++;
      } else if (shouldGiveUp(entry)) {
        stalled++;
      } else {
        retrying++;
      }
    }
    return SyncQueueSummary(pendingCount: pending, retryingCount: retrying, stalledCount: stalled);
  }
}
