import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalIncidentRepository
    implements LocalRepository<LocalIncident, String> {
  final AppDatabase _db;

  LocalIncidentRepository(this._db);

  @override
  Future<Result<LocalIncident>> getById(String id) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localIncidents,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (row == null) throw const CacheException('Incident not cached locally');
        return row;
      });

  @override
  Future<Result<List<LocalIncident>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localIncidents).get());

  @override
  Future<Result<LocalIncident>> save(LocalIncident item) =>
      guardCacheOperation(() async {
        await _db.into(_db.localIncidents).insertOnConflictUpdate(item);
        return item;
      });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(_db.localIncidents)..where((t) => t.id.equals(id))).go(),
  );
}
