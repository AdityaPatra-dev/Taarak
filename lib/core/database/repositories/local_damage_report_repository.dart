import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalDamageReportRepository
    implements LocalRepository<LocalDamageReport, String> {
  final AppDatabase _db;

  LocalDamageReportRepository(this._db);

  @override
  Future<Result<LocalDamageReport>> getById(String id) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localDamageReports,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (row == null) {
          throw const CacheException('Damage report not cached locally');
        }
        return row;
      });

  @override
  Future<Result<List<LocalDamageReport>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localDamageReports).get());

  Future<Result<List<LocalDamageReport>>> getForIncident(
    String incidentId,
  ) => guardCacheOperation(
    () => (_db.select(
      _db.localDamageReports,
    )..where((t) => t.incidentId.equals(incidentId))).get(),
  );

  @override
  Future<Result<LocalDamageReport>> save(LocalDamageReport item) =>
      guardCacheOperation(() async {
        await _db.into(_db.localDamageReports).insertOnConflictUpdate(item);
        return item;
      });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(
      _db.localDamageReports,
    )..where((t) => t.id.equals(id))).go(),
  );
}
