import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalRelocationPlanRepository
    implements LocalRepository<LocalRelocationPlan, String> {
  final AppDatabase _db;

  LocalRelocationPlanRepository(this._db);

  @override
  Future<Result<LocalRelocationPlan>> getById(String habitationId) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localRelocationPlans,
        )..where((t) => t.habitationId.equals(habitationId))).getSingleOrNull();
        if (row == null) {
          throw const CacheException('No relocation plan for this habitation yet');
        }
        return row;
      });

  @override
  Future<Result<List<LocalRelocationPlan>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localRelocationPlans).get());

  @override
  Future<Result<LocalRelocationPlan>> save(LocalRelocationPlan item) =>
      guardCacheOperation(() async {
        await _db.into(_db.localRelocationPlans).insertOnConflictUpdate(item);
        return item;
      });

  @override
  Future<Result<void>> delete(String habitationId) => guardCacheOperation(
    () => (_db.delete(
      _db.localRelocationPlans,
    )..where((t) => t.habitationId.equals(habitationId))).go(),
  );
}
