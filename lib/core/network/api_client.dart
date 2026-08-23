import 'package:dio/dio.dart';
import 'package:taarak/core/config/app_config.dart';
import 'package:taarak/core/error/app_exception.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/logging/app_logger.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/repository/result.dart';

/// Thin wrapper around [Dio] that centralizes base config, connectivity
/// checks, logging and error-to-[Failure] mapping, so per-entity remote
/// repositories only deal in [Result].
class ApiClient {
  final Dio dio;
  final NetworkInfo networkInfo;
  Future<String?> Function()? _tokenProvider;

  ApiClient({required AppConfig config, required this.networkInfo})
    : dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: config.apiTimeout,
          receiveTimeout: config.apiTimeout,
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenProvider?.call();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (message) => AppLogger.debug(message.toString()),
      ),
    );
  }

  /// Lets the auth feature supply the current session token without core/
  /// depending on features/auth. Wired once during provider setup.
  void attachTokenProvider(Future<String?> Function() provider) {
    _tokenProvider = provider;
  }

  Future<Result<T>> get<T>(
    String path, {
    required T Function(dynamic json) parser,
    Map<String, dynamic>? queryParameters,
  }) => _request(() async {
    final response = await dio.get(path, queryParameters: queryParameters);
    return parser(response.data);
  });

  Future<Result<T>> post<T>(
    String path, {
    required T Function(dynamic json) parser,
    Object? data,
  }) => _request(() async {
    final response = await dio.post(path, data: data);
    return parser(response.data);
  });

  Future<Result<T>> _request<T>(Future<T> Function() action) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      return Result.success(await action());
    } on DioException catch (error, stackTrace) {
      final exception = _mapDioException(error);
      AppLogger.error(exception.message, exception, stackTrace);
      return Result.failure(_mapExceptionToFailure(exception));
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected API error', error, stackTrace);
      return const Result.failure(UnknownFailure());
    }
  }

  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return const UnauthorizedException();
        }
        if (statusCode == 404) {
          return const NotFoundException();
        }
        return ServerException(statusCode: statusCode);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkException();
    }
  }

  Failure _mapExceptionToFailure(AppException exception) {
    return switch (exception) {
      NetworkException() => NetworkFailure(exception.message),
      ServerException(:final statusCode) => ServerFailure(
        statusCode: statusCode,
        message: exception.message,
      ),
      NotFoundException() => NotFoundFailure(exception.message),
      UnauthorizedException() => UnauthorizedFailure(exception.message),
      CacheException() => CacheFailure(exception.message),
      _ => UnknownFailure(exception.message),
    };
  }
}
