import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalUserRepository implements LocalRepository<LocalUser, String> {
  final AppDatabase _db;

  LocalUserRepository(this._db);

  @override
  Future<Result<LocalUser>> getById(String id) => guardCacheOperation(() async {
    final row = await (_db.select(
      _db.localUsers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw const CacheException('User not cached locally');
    return row;
  });

  @override
  Future<Result<List<LocalUser>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localUsers).get());

  @override
  Future<Result<LocalUser>> save(LocalUser item) => guardCacheOperation(() async {
    await _db.into(_db.localUsers).insertOnConflictUpdate(item);
    return item;
  });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(_db.localUsers)..where((t) => t.id.equals(id))).go(),
  );
}
