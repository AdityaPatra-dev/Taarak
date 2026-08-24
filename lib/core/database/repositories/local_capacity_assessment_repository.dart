import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalCapacityAssessmentRepository
    implements LocalRepository<LocalCapacityAssessment, String> {
  final AppDatabase _db;

  LocalCapacityAssessmentRepository(this._db);

  @override
  Future<Result<LocalCapacityAssessment>> getById(String habitationId) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localCapacityAssessments,
        )..where((t) => t.habitationId.equals(habitationId))).getSingleOrNull();
        if (row == null) {
          throw const CacheException(
            'No capacity assessment for this habitation yet',
          );
        }
        return row;
      });

  @override
  Future<Result<List<LocalCapacityAssessment>>> getAll() =>
      guardCacheOperation(
        () => _db.select(_db.localCapacityAssessments).get(),
      );

  @override
  Future<Result<LocalCapacityAssessment>> save(
    LocalCapacityAssessment item,
  ) => guardCacheOperation(() async {
    await _db.into(_db.localCapacityAssessments).insertOnConflictUpdate(item);
    return item;
  });

  @override
  Future<Result<void>> delete(String habitationId) => guardCacheOperation(
    () => (_db.delete(
      _db.localCapacityAssessments,
    )..where((t) => t.habitationId.equals(habitationId))).go(),
  );
}
