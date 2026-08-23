/// Internal exceptions thrown by data sources (API client, local database).
///
/// Repositories catch these and translate them into a [[Failure]] before
/// returning a [[Result]] to callers — UI and domain code never see these
/// exception types directly.
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No network connection']);
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({this.statusCode, String message = 'Server error'})
    : super(message);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Local data unavailable']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Not authorized']);
}
