import 'package:taarak/core/repository/result.dart';

/// Contract for on-device storage of entity [T] keyed by [ID].
///
/// Implemented per-entity once M03 (local database) lands. Kept separate
/// from [[RemoteRepository]] because offline mode must keep working with
/// only this half available.
abstract class LocalRepository<T, ID> {
  Future<Result<T>> getById(ID id);

  Future<Result<List<T>>> getAll();

  Future<Result<T>> save(T item);

  Future<Result<void>> delete(ID id);
}
