import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/auth/data/auth_remote_data_source.dart';
import 'package:taarak/features/auth/domain/app_user.dart';
import 'package:taarak/features/auth/domain/auth_session.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

/// The real Identity backend, replacing [[DevMockAuthRemoteDataSource]]'s
/// in-memory directory and [[ApiAuthRemoteDataSource]]'s never-deployed
/// stub. Firebase Auth owns credentials; a `users/{uid}` Firestore document
/// owns everything Firebase Auth has no concept of — name and role — since
/// public self-registration only ever creates a Citizen (see [register]),
/// exactly the restriction the two data sources it replaces already
/// enforced.
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const Result.failure(
          UnauthorizedFailure('Invalid email or password'),
        );
      }
      return _sessionForExistingUser(user);
    } on FirebaseAuthException catch (error) {
      return Result.failure(_mapAuthException(error));
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return const Result.failure(UnknownFailure());

      await user.updateDisplayName(name);
      // Public self-registration is always Citizen; Field Responder,
      // Official and Admin accounts are provisioned separately (by hand, in
      // the Firestore console, until an admin UI exists), not self-declared.
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'role': UserRole.citizen.name,
      });

      final token = await user.getIdToken() ?? '';
      return Result.success(
        AuthSession(
          user: AppUser(
            id: user.uid,
            name: name,
            email: email,
            role: UserRole.citizen,
          ),
          token: token,
        ),
      );
    } on FirebaseAuthException catch (error) {
      return Result.failure(_mapAuthException(error));
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Result.success(null);
    } on FirebaseAuthException catch (error) {
      return Result.failure(_mapAuthException(error));
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  Future<Result<AuthSession>> _sessionForExistingUser(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data == null) {
        return const Result.failure(
          NotFoundFailure(
            'No profile found for this account — contact a system admin',
          ),
        );
      }
      final token = await user.getIdToken() ?? '';
      return Result.success(
        AuthSession(
          user: AppUser(
            id: user.uid,
            name: data['name'] as String? ?? user.email ?? 'Unknown',
            email: data['email'] as String? ?? user.email ?? '',
            role: UserRole.values.byName(
              data['role'] as String? ?? UserRole.citizen.name,
            ),
          ),
          token: token,
        ),
      );
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  Failure _mapAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const UnauthorizedFailure('Invalid email or password');
      case 'email-already-in-use':
        return const ValidationFailure(
          'An account with this email already exists',
        );
      case 'weak-password':
        return const ValidationFailure(
          'Password is too weak — use at least 6 characters',
        );
      case 'invalid-email':
        return const ValidationFailure('Enter a valid email');
      case 'network-request-failed':
        return const NetworkFailure();
      default:
        return UnknownFailure(error.message ?? 'Authentication failed');
    }
  }
}
