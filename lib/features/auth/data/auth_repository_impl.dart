import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/auth/data/auth_local_data_source.dart';
import 'package:taarak/features/auth/data/auth_remote_data_source.dart';
import 'package:taarak/features/auth/data/auth_repository.dart';
import 'package:taarak/features/auth/domain/auth_session.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    final result = await _remote.login(email: email, password: password);
    if (result case Success<AuthSession>(:final data)) {
      await _local.saveSession(data);
    }
    return result;
  }

  @override
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _remote.register(
      name: name,
      email: email,
      password: password,
    );
    if (result case Success<AuthSession>(:final data)) {
      await _local.saveSession(data);
    }
    return result;
  }

  @override
  Future<void> logout() => _local.clearSession();

  @override
  Future<AuthSession?> restoreSession() => _local.readSession();
}
