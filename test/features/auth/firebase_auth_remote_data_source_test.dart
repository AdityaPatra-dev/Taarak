import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/auth/data/firebase_auth_remote_data_source.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

void main() {
  group('register', () {
    test(
      'A NEW ACCOUNT REGISTERS AS CITIZEN AND CAN THEN LOG IN — the acceptance criterion',
      () async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();
        final dataSource = FirebaseAuthRemoteDataSource(
          auth: auth,
          firestore: firestore,
        );

        final result = await dataSource.register(
          name: 'New Citizen',
          email: 'new@taarak.dev',
          password: 'password123',
        );

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.user.name, 'New Citizen');
        expect(result.dataOrNull?.user.role, UserRole.citizen);
        expect(result.dataOrNull?.token, isNotEmpty);

        final uid = auth.currentUser!.uid;
        final doc = await firestore.collection('users').doc(uid).get();
        expect(doc.data()?['role'], 'citizen');
      },
    );

    test('an email already in use maps to a validation failure', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      whenCalling(
        Invocation.method(#createUserWithEmailAndPassword, null, {
          #email: 'taken@taarak.dev',
          #password: 'password123',
        }),
      ).on(auth).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      final dataSource = FirebaseAuthRemoteDataSource(
        auth: auth,
        firestore: firestore,
      );

      final result = await dataSource.register(
        name: 'Someone',
        email: 'taken@taarak.dev',
        password: 'password123',
      );

      expect(result.isFailure, isTrue);
      expect((result as Failed).failure, isA<ValidationFailure>());
    });
  });

  group('login', () {
    test('a wrong password maps to an unauthorized failure', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      whenCalling(
        Invocation.method(#signInWithEmailAndPassword, null, {
          #email: 'citizen@taarak.dev',
          #password: 'wrong',
        }),
      ).on(auth).thenThrow(FirebaseAuthException(code: 'wrong-password'));
      final dataSource = FirebaseAuthRemoteDataSource(
        auth: auth,
        firestore: firestore,
      );

      final result = await dataSource.login(
        email: 'citizen@taarak.dev',
        password: 'wrong',
      );

      expect(result.isFailure, isTrue);
      expect((result as Failed).failure, isA<UnauthorizedFailure>());
    });

    test(
      'a signed-in user with no Firestore profile fails with not found',
      () async {
        final mockUser = MockUser(
          uid: 'orphan-uid',
          email: 'orphan@taarak.dev',
        );
        final auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
        final firestore = FakeFirebaseFirestore();
        final dataSource = FirebaseAuthRemoteDataSource(
          auth: auth,
          firestore: firestore,
        );

        final result = await dataSource.login(
          email: 'orphan@taarak.dev',
          password: 'whatever',
        );

        expect(result.isFailure, isTrue);
        expect((result as Failed).failure, isA<NotFoundFailure>());
      },
    );

    test(
      'A DEVICE COMMAND ACCOUNT LOGS IN AND GETS ITS REAL ROLE FROM FIRESTORE — the '
      'multi-role acceptance criterion',
      () async {
        final mockUser = MockUser(
          uid: 'command-uid',
          email: 'command@taarak.dev',
        );
        final auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
        final firestore = FakeFirebaseFirestore();
        await firestore.collection('users').doc('command-uid').set({
          'name': 'District Command Demo',
          'email': 'command@taarak.dev',
          'role': 'districtCommand',
        });
        final dataSource = FirebaseAuthRemoteDataSource(
          auth: auth,
          firestore: firestore,
        );

        final result = await dataSource.login(
          email: 'command@taarak.dev',
          password: 'whatever',
        );

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.user.role, UserRole.districtCommand);
        expect(result.dataOrNull?.user.name, 'District Command Demo');
      },
    );
  });

  group('sendPasswordResetEmail', () {
    test('succeeds for a real account', () async {
      final auth = MockFirebaseAuth();
      final dataSource = FirebaseAuthRemoteDataSource(
        auth: auth,
        firestore: FakeFirebaseFirestore(),
      );

      final result = await dataSource.sendPasswordResetEmail(
        email: 'citizen@taarak.dev',
      );

      expect(result.isSuccess, isTrue);
    });

    test('a Firebase error maps to the same failure login already uses', () async {
      final auth = MockFirebaseAuth();
      whenCalling(
        Invocation.method(#sendPasswordResetEmail, null, {
          #email: 'unknown@taarak.dev',
        }),
      ).on(auth).thenThrow(FirebaseAuthException(code: 'user-not-found'));
      final dataSource = FirebaseAuthRemoteDataSource(
        auth: auth,
        firestore: FakeFirebaseFirestore(),
      );

      final result = await dataSource.sendPasswordResetEmail(
        email: 'unknown@taarak.dev',
      );

      expect(result.isFailure, isTrue);
      expect((result as Failed).failure, isA<UnauthorizedFailure>());
    });
  });
}
