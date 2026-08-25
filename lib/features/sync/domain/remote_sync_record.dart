/// One entity as the backend has it — the pull-side counterpart to
/// [SyncQueueEntry]'s push side. `payloadJson` has the same shape a push
/// for this table would have sent, so the two sides can share a decoder.
class RemoteSyncRecord {
  final String entityId;
  final String payloadJson;
  final int version;

  const RemoteSyncRecord({
    required this.entityId,
    required this.payloadJson,
    required this.version,
  });
}
