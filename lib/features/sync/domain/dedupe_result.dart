import 'package:taarak/core/database/app_database.dart';

/// Output of [SyncEngine.dedupe]: which queued entries are still worth
/// pushing, and which are stale duplicates of a later entry for the same
/// entity that can be marked synced immediately without a network call.
class DedupeResult {
  final List<SyncQueueEntry> toPush;
  final List<SyncQueueEntry> superseded;

  const DedupeResult({required this.toPush, required this.superseded});
}
