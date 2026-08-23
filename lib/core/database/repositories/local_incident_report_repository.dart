import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalIncidentReportRepository
    implements LocalRepository<LocalIncidentReport, String> {
  final AppDatabase _db;

  LocalIncidentReportRepository(this._db);

  @override
  Future<Result<LocalIncidentReport>> getById(String id) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localIncidentReports,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (row == null) {
          throw const CacheException('Report not cached locally');
        }
        return row;
      });

  @override
  Future<Result<List<LocalIncidentReport>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localIncidentReports).get());

  @override
  Future<Result<LocalIncidentReport>> save(LocalIncidentReport item) =>
      guardCacheOperation(() async {
        await _db.into(_db.localIncidentReports).insertOnConflictUpdate(item);
        return item;
      });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(
      _db.localIncidentReports,
    )..where((t) => t.id.equals(id))).go(),
  );
}
