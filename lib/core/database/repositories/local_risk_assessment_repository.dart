import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

/// Keyed by habitationId rather than a separate id — see the table's doc
/// comment: one current assessment per habitation, not a history table.
class LocalRiskAssessmentRepository
    implements LocalRepository<LocalRiskAssessment, String> {
  final AppDatabase _db;

  LocalRiskAssessmentRepository(this._db);

  @override
  Future<Result<LocalRiskAssessment>> getById(String habitationId) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localRiskAssessments,
        )..where((t) => t.habitationId.equals(habitationId))).getSingleOrNull();
        if (row == null) {
          throw const CacheException('No risk assessment for this habitation yet');
        }
        return row;
      });

  @override
  Future<Result<List<LocalRiskAssessment>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localRiskAssessments).get());

  @override
  Future<Result<LocalRiskAssessment>> save(LocalRiskAssessment item) =>
      guardCacheOperation(() async {
        await _db.into(_db.localRiskAssessments).insertOnConflictUpdate(item);
        return item;
      });

  @override
  Future<Result<void>> delete(String habitationId) => guardCacheOperation(
    () => (_db.delete(
      _db.localRiskAssessments,
    )..where((t) => t.habitationId.equals(habitationId))).go(),
  );
}
