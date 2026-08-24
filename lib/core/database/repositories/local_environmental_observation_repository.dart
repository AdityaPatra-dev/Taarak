import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/database_result_guard.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

class LocalEnvironmentalObservationRepository
    implements LocalRepository<LocalEnvironmentalObservation, String> {
  final AppDatabase _db;

  LocalEnvironmentalObservationRepository(this._db);

  @override
  Future<Result<LocalEnvironmentalObservation>> getById(String id) =>
      guardCacheOperation(() async {
        final row = await (_db.select(
          _db.localEnvironmentalObservations,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (row == null) {
          throw const CacheException('Environmental observation not cached locally');
        }
        return row;
      });

  @override
  Future<Result<List<LocalEnvironmentalObservation>>> getAll() =>
      guardCacheOperation(() => _db.select(_db.localEnvironmentalObservations).get());

  @override
  Future<Result<LocalEnvironmentalObservation>> save(
    LocalEnvironmentalObservation item,
  ) => guardCacheOperation(() async {
    await _db.into(_db.localEnvironmentalObservations).insertOnConflictUpdate(item);
    return item;
  });

  @override
  Future<Result<void>> delete(String id) => guardCacheOperation(
    () => (_db.delete(
      _db.localEnvironmentalObservations,
    )..where((t) => t.id.equals(id))).go(),
  );
}
