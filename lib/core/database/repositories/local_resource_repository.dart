import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalResourceRepository
    implements LocalRepository<LocalResource, String> {
  final AppDatabase _db;

  LocalResourceRepository(this._db);

  @override
  Future<Result<LocalResource>> getById(String id) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localResources,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (row == null) {
          throw const CacheException('Resource not cached locally');
        }
        return row;
      });

  @override
  Future<Result<List<LocalResource>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localResources).get());

  @override
  Future<Result<LocalResource>> save(LocalResource item) =>
      guardCacheOperation(() async {
        await _db.into(_db.localResources).insertOnConflictUpdate(item);
        return item;
      });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(_db.localResources)..where((t) => t.id.equals(id))).go(),
  );
}
