import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/auth/data/auth_local_data_source.dart';
import 'package:taarak/features/auth/data/auth_repository_impl.dart';
import 'package:taarak/features/auth/data/dev_mock_auth_remote_data_source.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

import '../../support/fake_secure_key_value_store.dart';

void main() {
  late AuthRepositoryImpl repository;
  late AuthLocalDataSource local;

  setUp(() {
    local = AuthLocalDataSource(FakeSecureKeyValueStore());
    repository = AuthRepositoryImpl(
      remote: DevMockAuthRemoteDataSource(),
      local: local,
    );
  });

  group('login', () {
    test('a valid demo account succeeds and persists the session', () async {
      final result = await repository.login(
        email: 'citizen@taarak.dev',
        password: 'citizen123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.user.role, UserRole.citizen);

      final restored = await local.readSession();
      expect(restored?.user.email, 'citizen@taarak.dev');
    });

    test('a wrong password fails and persists nothing', () async {
      final result = await repository.login(
        email: 'citizen@taarak.dev',
        password: 'wrong-password',
      );

      expect(result.isFailure, isTrue);
      expect(await local.readSession(), isNull);
    });
  });

  group('register', () {
    test('creates a citizen account regardless of what the caller asks for', () async {
      final result = await repository.register(
        name: 'New Citizen',
        email: 'new.citizen@example.com',
        password: 'somepassword',
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.user.role, UserRole.citizen);
    });

    test('rejects a duplicate email', () async {
      final result = await repository.register(
        name: 'Duplicate',
        email: 'citizen@taarak.dev',
        password: 'somepassword',
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('session lifecycle', () {
    test('restoreSession reflects the last login until logout', () async {
      await repository.login(
        email: 'responder@taarak.dev',
        password: 'responder123',
      );
      expect((await repository.restoreSession())?.user.role, UserRole.fieldResponder);

      await repository.logout();
      expect(await repository.restoreSession(), isNull);
    });
  });
}
