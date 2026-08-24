import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalAlertRepository implements LocalRepository<LocalAlert, String> {
  final AppDatabase _db;

  LocalAlertRepository(this._db);

  @override
  Future<Result<LocalAlert>> getById(String id) => guardCacheOperation(() async {
    final row = await (_db.select(
      _db.localAlerts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw const CacheException('Alert not cached locally');
    return row;
  });

  @override
  Future<Result<List<LocalAlert>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localAlerts).get());

  @override
  Future<Result<LocalAlert>> save(LocalAlert item) => guardCacheOperation(() async {
    await _db.into(_db.localAlerts).insertOnConflictUpdate(item);
    return item;
  });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(_db.localAlerts)..where((t) => t.id.equals(id))).go(),
  );
}
