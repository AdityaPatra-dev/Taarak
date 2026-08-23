import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalShelterRepository implements LocalRepository<LocalShelter, String> {
  final AppDatabase _db;

  LocalShelterRepository(this._db);

  @override
  Future<Result<LocalShelter>> getById(String id) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localShelters,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (row == null) throw const CacheException('Shelter not cached locally');
        return row;
      });

  @override
  Future<Result<List<LocalShelter>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localShelters).get());

  @override
  Future<Result<LocalShelter>> save(LocalShelter item) =>
      guardCacheOperation(() async {
        await _db.into(_db.localShelters).insertOnConflictUpdate(item);
        return item;
      });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(_db.localShelters)..where((t) => t.id.equals(id))).go(),
  );
}
