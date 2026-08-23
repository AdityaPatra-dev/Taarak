/// User-facing error types produced at repository/API boundaries.
///
/// Deterministic code (risk scoring, permissions, etc.) always deals in
/// [Failure], never raw exceptions — see [[AppException]] for the internal
/// counterpart that gets caught and mapped into one of these.
sealed class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No network connection']);
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({this.statusCode, String message = 'Server error'})
    : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data unavailable']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Not authorized']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error']);
}
