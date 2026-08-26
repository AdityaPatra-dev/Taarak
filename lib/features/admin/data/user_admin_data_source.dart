import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/admin/domain/admin_user_summary.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

/// System Admin's ([Permission.manageAccounts]) account management: reads
/// every user profile and reassigns roles directly in Firestore's `users`
/// collection. Deliberately talks to Firestore directly rather than going
/// through M17's offline sync pipeline — account/role data is inherently
/// "always online, source of truth" data (security rules already reject a
/// user from writing anyone else's role), not offline-cacheable entity
/// data like incidents or shelters.
class UserAdminDataSource {
  final FirebaseFirestore _firestore;

  UserAdminDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Result<List<AdminUserSummary>>> listUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = [
        for (final doc in snapshot.docs)
          AdminUserSummary.fromFirestore(doc.id, doc.data()),
      ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return Result.success(users);
    } catch (_) {
      return const Result.failure(NetworkFailure('Unable to load accounts'));
    }
  }

  Future<Result<void>> updateRole({
    required String uid,
    required UserRole role,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role.name,
      });
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(NetworkFailure('Unable to update role'));
    }
  }
}
