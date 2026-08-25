/// A more honest breakdown of what "N items waiting to sync" actually
/// means than a single count can convey — Phase 3's fix for a banner that
/// used to look identical whether nothing had been attempted yet or every
/// attempt had already failed repeatedly.
class SyncQueueSummary {
  /// Never attempted yet — offline, or simply hasn't been this entry's
  /// turn. Nothing has gone wrong.
  final int pendingCount;

  /// At least one push attempt failed, but still within the retry budget
  /// — actively (if quietly) trying again.
  final int retryingCount;

  /// Exhausted its retry budget ([SyncEngine.shouldGiveUp]). Still queued
  /// (nothing is deleted), but won't be retried automatically anymore.
  final int stalledCount;

  const SyncQueueSummary({
    this.pendingCount = 0,
    this.retryingCount = 0,
    this.stalledCount = 0,
  });

  int get totalCount => pendingCount + retryingCount + stalledCount;
  bool get isEmpty => totalCount == 0;
}

/// The point of [SyncQueueSummary]: "waiting to sync" alone doesn't say
/// whether that's a routine, no-connectivity queue or something that's
/// been genuinely failing — this picks the most urgent true thing to say
/// instead of always showing the same neutral line, in priority order:
/// stalled (needs attention) > retrying (a real but ongoing problem) >
/// pending (nothing has gone wrong yet).
String syncQueueSummaryMessage(SyncQueueSummary summary) {
  if (summary.isEmpty) return 'Up to date';
  if (summary.stalledCount > 0) {
    final n = summary.stalledCount;
    return "$n item${n == 1 ? '' : 's'} couldn't be sent after repeated attempts";
  }
  if (summary.retryingCount > 0) {
    final n = summary.retryingCount;
    return '$n item${n == 1 ? '' : 's'} waiting — having trouble reaching the server';
  }
  final n = summary.pendingCount;
  return '$n item${n == 1 ? '' : 's'} queued, will send when possible';
}
