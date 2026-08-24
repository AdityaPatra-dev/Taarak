import 'package:drift/drift.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/repository/result.dart';

/// Outbox access for the future sync engine (M17). Doesn't implement
/// [LocalRepository] — enqueue/list-pending/mark-synced is a different
/// shape than plain entity CRUD, since a queue entry's lifecycle (attempt
/// counting, status transitions) is the whole point of the table.
class SyncQueueDao {
  final AppDatabase _db;

  SyncQueueDao(this._db);

  Future<Result<int>> enqueue({
    required String entityTable,
    required String entityId,
    required String operation,
    required String payloadJson,
  }) => guardCacheOperation(
    () => _db
        .into(_db.syncQueueEntries)
        .insert(
          SyncQueueEntriesCompanion.insert(
            entityTable: entityTable,
            entityId: entityId,
            operation: operation,
            payloadJson: payloadJson,
            createdAt: DateTime.now(),
          ),
        ),
  );

  Future<Result<List<SyncQueueEntry>>> listPending() => guardCacheOperation(
    () => (_db.select(
      _db.syncQueueEntries,
    )..where((t) => t.status.equals('pending'))).get(),
  );

  /// M17's input queue: everything not yet synced, including entries a
  /// previous run marked 'failed' — those are still retry candidates
  /// (subject to [SyncEngine.isReadyToRetry]/[SyncEngine.shouldGiveUp]),
  /// not abandoned just because one attempt didn't land.
  Future<Result<List<SyncQueueEntry>>> listSyncable() => guardCacheOperation(
    () => (_db.select(_db.syncQueueEntries)
          ..where((t) => t.status.isIn(['pending', 'failed']))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get(),
  );

  Future<Result<void>> markSynced(int id) => guardCacheOperation(
    () => (_db.update(
      _db.syncQueueEntries,
    )..where((t) => t.id.equals(id))).write(
      const SyncQueueEntriesCompanion(status: Value('synced')),
    ),
  );

  Future<Result<void>> markFailed(int id, {DateTime? now}) =>
      guardCacheOperation(() async {
        final entry = await (_db.select(
          _db.syncQueueEntries,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        final attempts = (entry?.attemptCount ?? 0) + 1;
        await (_db.update(_db.syncQueueEntries)..where((t) => t.id.equals(id)))
            .write(
              SyncQueueEntriesCompanion(
                status: const Value('failed'),
                attemptCount: Value(attempts),
                lastAttemptAt: Value(now ?? DateTime.now()),
              ),
            );
      });

  Future<Result<void>> delete(int id) => guardCacheOperation(
    () => (_db.delete(
      _db.syncQueueEntries,
    )..where((t) => t.id.equals(id))).go(),
  );
}
