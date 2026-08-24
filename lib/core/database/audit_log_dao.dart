import 'package:drift/drift.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/repository/result.dart';

/// Write-and-read access to the append-only audit trail. No update/delete
/// method exists here at all — that's deliberate, not an oversight: the
/// blueprint's own restriction ("No silent alteration of protected audit
/// records") is enforced by simply never exposing a way to do it.
class AuditLogDao {
  final AppDatabase _db;

  AuditLogDao(this._db);

  Future<Result<int>> record({
    required String actorId,
    required String action,
    required String objectType,
    required String objectId,
    String? oldValue,
    String? newValue,
    String? reason,
    DateTime? now,
  }) => guardCacheOperation(
    () => _db
        .into(_db.localAuditEvents)
        .insert(
          LocalAuditEventsCompanion.insert(
            actorId: actorId,
            action: action,
            objectType: objectType,
            objectId: objectId,
            oldValue: Value(oldValue),
            newValue: Value(newValue),
            reason: Value(reason),
            occurredAt: now ?? DateTime.now(),
          ),
        ),
  );

  Future<Result<List<LocalAuditEvent>>> listForObject(
    String objectType,
    String objectId,
  ) => guardCacheOperation(
    () =>
        (_db.select(_db.localAuditEvents)
              ..where(
                (t) => t.objectType.equals(objectType) & t.objectId.equals(objectId),
              )
              // `id` (auto-increment, strictly insertion-ordered) breaks
              // ties between events that share an `occurredAt` timestamp
              // — two actions in the same millisecond should still sort
              // as "most recent last written", not arbitrarily.
              ..orderBy([
                (t) => OrderingTerm.desc(t.occurredAt),
                (t) => OrderingTerm.desc(t.id),
              ]))
            .get(),
  );

  Future<Result<List<LocalAuditEvent>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localAuditEvents).get());
}
