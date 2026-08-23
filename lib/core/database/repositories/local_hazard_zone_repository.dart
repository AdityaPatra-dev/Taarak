import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalHazardZoneRepository
    implements LocalRepository<LocalHazardZone, String> {
  final AppDatabase _db;

  LocalHazardZoneRepository(this._db);

  @override
  Future<Result<LocalHazardZone>> getById(String id) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localHazardZones,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (row == null) {
          throw const CacheException('Hazard zone not cached locally');
        }
        return row;
      });

  @override
  Future<Result<List<LocalHazardZone>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localHazardZones).get());

  @override
  Future<Result<LocalHazardZone>> save(LocalHazardZone item) =>
      guardCacheOperation(() async {
        await _db.into(_db.localHazardZones).insertOnConflictUpdate(item);
        return item;
      });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(
      _db.localHazardZones,
    )..where((t) => t.id.equals(id))).go(),
  );
}
