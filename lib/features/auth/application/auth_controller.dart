import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/auth/application/auth_providers.dart';
import 'package:taarak/features/auth/domain/app_user.dart';
import 'package:taarak/features/auth/domain/auth_session.dart';

/// Holds the current session: null once restored means signed out, an
/// [AuthSession] means signed in. The router (see app/route_guard.dart)
/// watches this to decide what's reachable.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authControllerProvider).valueOrNull?.user,
);

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() {
    return ref.watch(authRepositoryProvider).restoreSession();
  }

  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    result.when(
      success: (session) => state = AsyncData(session),
      failure: (_) {},
    );
    return result;
  }

  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .register(name: name, email: email, password: password);
    result.when(
      success: (session) => state = AsyncData(session),
      failure: (_) {},
    );
    return result;
  }

  Future<Result<void>> sendPasswordResetEmail({required String email}) {
    return ref
        .read(authRepositoryProvider)
        .sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
