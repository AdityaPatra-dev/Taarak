import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/repository/result.dart';

/// M16's acknowledgement tracking. Deliberately not a [LocalRepository]
/// implementation — like [AuditLogDao], acknowledgements are
/// insert-then-query only, keyed by a composite id rather than a
/// caller-supplied one.
class AlertAcknowledgementDao {
  final AppDatabase _db;

  AlertAcknowledgementDao(this._db);

  static String compositeId(String alertId, String userId) => '$alertId:$userId';

  /// Idempotent — acknowledging the same alert twice from the same user
  /// just updates the timestamp on the existing row rather than erroring
  /// or duplicating.
  Future<Result<void>> acknowledge({
    required String alertId,
    required String userId,
    DateTime? now,
  }) => guardCacheOperation(
    () => _db
        .into(_db.localAlertAcknowledgements)
        .insertOnConflictUpdate(
          LocalAlertAcknowledgementsCompanion.insert(
            id: compositeId(alertId, userId),
            alertId: alertId,
            userId: userId,
            acknowledgedAt: now ?? DateTime.now(),
          ),
        ),
  );

  Future<Result<List<LocalAlertAcknowledgement>>> listForAlert(String alertId) =>
      guardCacheOperation(
        () => (_db.select(
          _db.localAlertAcknowledgements,
        )..where((t) => t.alertId.equals(alertId))).get(),
      );

  Future<Result<bool>> hasAcknowledged({
    required String alertId,
    required String userId,
  }) => guardCacheOperation(() async {
    final row = await (_db.select(_db.localAlertAcknowledgements)..where(
      (t) => t.id.equals(compositeId(alertId, userId)),
    )).getSingleOrNull();
    return row != null;
  });
}
