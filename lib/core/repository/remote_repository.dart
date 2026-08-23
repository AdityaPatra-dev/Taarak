import 'package:taarak/core/repository/result.dart';

/// Contract for server-backed access to entity [T] keyed by [ID].
///
/// Implemented per-entity on top of [[ApiClient]] as each backend module
/// (Identity, Hazard, Incident, ...) comes online. Feature repositories
/// combine this with [[LocalRepository]] to implement offline-first reads
/// and a sync queue (M17).
abstract class RemoteRepository<T, ID> {
  Future<Result<T>> fetchById(ID id);

  Future<Result<List<T>>> fetchAll();

  Future<Result<T>> create(T item);

  Future<Result<T>> update(ID id, T item);

  Future<Result<void>> delete(ID id);
}
