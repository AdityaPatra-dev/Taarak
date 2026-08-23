import 'package:taarak/core/error/failure.dart';

/// Outcome of any repository/API-client operation: either the data, or a
/// [Failure] explaining why not. Every [[LocalRepository]] and
/// [[RemoteRepository]] method returns this instead of throwing, so callers
/// (features, later the risk/relocation engines) always handle both paths.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;

  const factory Result.failure(Failure failure) = Failed<T>;

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is Failed<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    return switch (self) {
      Success<T>() => success(self.data),
      Failed<T>() => failure(self.failure),
    };
  }

  /// Returns the success value, or null if this is a failure.
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Failed<T>() => null,
  };
}

final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

final class Failed<T> extends Result<T> {
  final Failure failure;

  const Failed(this.failure);
}
