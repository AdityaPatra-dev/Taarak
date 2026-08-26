import 'package:taarak/features/auth/domain/user_role.dart';

/// A row in the System Admin's account list — just enough to identify the
/// account and change its role, not the full [AppUser] shape auth uses.
class AdminUserSummary {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  const AdminUserSummary({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AdminUserSummary.fromFirestore(
    String uid,
    Map<String, dynamic> data,
  ) {
    final roleName = data['role'] as String?;
    return AdminUserSummary(
      uid: uid,
      name: data['name'] as String? ?? '(no name)',
      email: data['email'] as String? ?? '(no email)',
      // A role string that doesn't match any known UserRole (shouldn't
      // happen via the app's own write paths, but this reads whatever is
      // actually in Firestore) falls back to citizen rather than crashing
      // the whole admin list over one bad row.
      role: UserRole.values.firstWhere(
        (role) => role.name == roleName,
        orElse: () => UserRole.citizen,
      ),
    );
  }
}
