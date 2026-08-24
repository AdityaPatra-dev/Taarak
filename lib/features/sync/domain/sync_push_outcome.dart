enum SyncPushStatus { accepted, conflict }

/// What the backend said about one pushed [SyncQueueEntry]. `serverVersion`
/// is only meaningful when [status] is [SyncPushStatus.conflict] — it's
/// what [SyncEngine.resolveConflict] compares against the entry's own
/// version to decide which side wins.
class SyncPushOutcome {
  final SyncPushStatus status;
  final int? serverVersion;

  const SyncPushOutcome.accepted() : status = SyncPushStatus.accepted, serverVersion = null;

  const SyncPushOutcome.conflict(this.serverVersion) : status = SyncPushStatus.conflict;
}
