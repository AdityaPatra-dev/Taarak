import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalRouteRepository implements LocalRepository<LocalRoute, String> {
  final AppDatabase _db;

  LocalRouteRepository(this._db);

  @override
  Future<Result<LocalRoute>> getById(String id) => guardCacheOperation(() async {
    final row = await (_db.select(
      _db.localRoutes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw const CacheException('Route not cached locally');
    return row;
  });

  @override
  Future<Result<List<LocalRoute>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localRoutes).get());

  @override
  Future<Result<LocalRoute>> save(LocalRoute item) => guardCacheOperation(() async {
    await _db.into(_db.localRoutes).insertOnConflictUpdate(item);
    return item;
  });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(_db.localRoutes)..where((t) => t.id.equals(id))).go(),
  );
}
