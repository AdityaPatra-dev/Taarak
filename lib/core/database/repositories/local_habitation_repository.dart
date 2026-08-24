import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalHabitationRepository
    implements LocalRepository<LocalHabitation, String> {
  final AppDatabase _db;

  LocalHabitationRepository(this._db);

  @override
  Future<Result<LocalHabitation>> getById(String id) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localHabitations,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (row == null) {
          throw const CacheException('Habitation not cached locally');
        }
        return row;
      });

  @override
  Future<Result<List<LocalHabitation>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localHabitations).get());

  @override
  Future<Result<LocalHabitation>> save(LocalHabitation item) =>
      guardCacheOperation(() async {
        await _db.into(_db.localHabitations).insertOnConflictUpdate(item);
        return item;
      });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(
      _db.localHabitations,
    )..where((t) => t.id.equals(id))).go(),
  );
}
