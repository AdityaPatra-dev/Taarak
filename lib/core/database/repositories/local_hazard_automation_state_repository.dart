import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalHazardAutomationStateRepository
    implements LocalRepository<LocalHazardAutomationState, String> {
  final AppDatabase _db;

  LocalHazardAutomationStateRepository(this._db);

  @override
  Future<Result<LocalHazardAutomationState>> getById(String id) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localHazardAutomationStates,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (row == null) {
          throw const CacheException('Hazard automation state not cached locally');
        }
        return row;
      });

  @override
  Future<Result<List<LocalHazardAutomationState>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localHazardAutomationStates).get());

  @override
  Future<Result<LocalHazardAutomationState>> save(LocalHazardAutomationState item) =>
      guardCacheOperation(() async {
        await _db.into(_db.localHazardAutomationStates).insertOnConflictUpdate(item);
        return item;
      });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(
      _db.localHazardAutomationStates,
    )..where((t) => t.id.equals(id))).go(),
  );
}
