import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/auth/domain/auth_session.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  /// Reads a previously persisted session, if any — used on app start to
  /// decide whether the user lands on login or straight into the app.
  Future<AuthSession?> restoreSession();
}
