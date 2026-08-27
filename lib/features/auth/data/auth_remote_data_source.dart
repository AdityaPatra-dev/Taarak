import 'package:taarak/core/network/api_client.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/auth/domain/auth_session.dart';

abstract class AuthRemoteDataSource {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<void>> sendPasswordResetEmail({required String email});
}

/// Talks to the Identity backend module (blueprint section 7). Not usable
/// until that service exists — see [[DevMockAuthRemoteDataSource]] for the
/// stand-in used while [AppConfig.useMockAuth] is true.
class ApiAuthRemoteDataSource implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  ApiAuthRemoteDataSource(this._apiClient);

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) {
    return _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      parser: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _apiClient.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
      parser: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) {
    return _apiClient.post<void>(
      '/auth/forgot-password',
      data: {'email': email},
      parser: (_) {},
    );
  }
}
