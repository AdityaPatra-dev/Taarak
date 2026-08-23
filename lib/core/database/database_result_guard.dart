import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/logging/app_logger.dart';
import 'package:taarak/core/repository/result.dart';

/// Shared try/catch → [Result] mapping for every local-database repository,
/// so each one only writes the query itself, not its own error handling.
Future<Result<T>> guardCacheOperation<T>(Future<T> Function() action) async {
  try {
    return Result.success(await action());
  } on CacheException catch (error, stackTrace) {
    AppLogger.error(error.message, error, stackTrace);
    return Result.failure(CacheFailure(error.message));
  } catch (error, stackTrace) {
    AppLogger.error('Local database operation failed', error, stackTrace);
    return const Result.failure(CacheFailure());
  }
}
