import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/auth/data/auth_remote_data_source.dart';
import 'package:taarak/features/auth/domain/app_user.dart';
import 'package:taarak/features/auth/domain/auth_session.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

class _DevAccount {
  final String name;
  final String email;
  final String password;
  final UserRole role;

  const _DevAccount({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}

/// In-memory demo directory used only while [AppConfig.useMockAuth] is
/// true, so the RBAC flow (blueprint section 3) is demoable before the
/// Identity backend exists. Seeds one account per role — swap this out for
/// [[ApiAuthRemoteDataSource]] once that service is reachable.
class DevMockAuthRemoteDataSource implements AuthRemoteDataSource {
  final Map<String, _DevAccount> _accounts = {
    for (final account in _seedAccounts) account.email: account,
  };

  static const _seedAccounts = [
    _DevAccount(
      name: 'Citizen Demo',
      email: 'citizen@taarak.dev',
      password: 'citizen123',
      role: UserRole.citizen,
    ),
    _DevAccount(
      name: 'Responder Demo',
      email: 'responder@taarak.dev',
      password: 'responder123',
      role: UserRole.fieldResponder,
    ),
    _DevAccount(
      name: 'Local Official Demo',
      email: 'official@taarak.dev',
      password: 'official123',
      role: UserRole.localOfficial,
    ),
    _DevAccount(
      name: 'District Command Demo',
      email: 'command@taarak.dev',
      password: 'command123',
      role: UserRole.districtCommand,
    ),
    _DevAccount(
      name: 'State Admin Demo',
      email: 'stateadmin@taarak.dev',
      password: 'stateadmin123',
      role: UserRole.stateAdmin,
    ),
    _DevAccount(
      name: 'System Admin Demo',
      email: 'sysadmin@taarak.dev',
      password: 'sysadmin123',
      role: UserRole.systemAdmin,
    ),
  ];

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    final account = _accounts[email];
    if (account == null || account.password != password) {
      return const Result.failure(
        UnauthorizedFailure('Invalid email or password'),
      );
    }
    return Result.success(_sessionFor(account));
  }

  @override
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_accounts.containsKey(email)) {
      return const Result.failure(
        ValidationFailure('An account with this email already exists'),
      );
    }
    // Public self-registration is always Citizen; official/responder/admin
    // accounts are provisioned separately, not self-declared (see
    // blueprint section 3's System Admin "Accounts" capability).
    final account = _DevAccount(
      name: name,
      email: email,
      password: password,
      role: UserRole.citizen,
    );
    _accounts[email] = account;
    return Result.success(_sessionFor(account));
  }

  AuthSession _sessionFor(_DevAccount account) => AuthSession(
    user: AppUser(
      id: account.email,
      name: account.name,
      email: account.email,
      role: account.role,
    ),
    token: 'dev-token-${account.email}',
  );
}
