/// Outcome of one [SyncCoordinatorService.syncPendingEntries] call — what
/// actually happened to the queue, not just "it ran".
class SyncRunSummary {
  final int syncedCount;
  final int conflictCount;
  final int failedCount;

  /// Entries that hit [SyncEngine.shouldGiveUp] this run — still queued
  /// (nothing is silently deleted) but no longer retried automatically.
  final int abandonedCount;

  final bool skippedOffline;

  /// Records pulled in from other devices this run — the count that
  /// answers "did I just get anything new from someone else".
  final int pulledCount;

  const SyncRunSummary({
    this.syncedCount = 0,
    this.conflictCount = 0,
    this.failedCount = 0,
    this.abandonedCount = 0,
    this.skippedOffline = false,
    this.pulledCount = 0,
  });
}
