import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

/// A System Admin's ([Permission.managePermissions]) edits to a role's
/// default permission set — the missing screen behind a permission that,
/// until now, was declared and granted but had nothing to actually manage.
/// Deliberately a *full replacement* per role rather than an additive/
/// subtractive diff: simpler to reason about, and a role with no override
/// here just falls back to [UserRoleX.permissions] unchanged, so most
/// roles never need an entry at all.
class RolePermissionOverrides {
  final Map<UserRole, Set<Permission>> overridesByRole;

  const RolePermissionOverrides({this.overridesByRole = const {}});

  static const empty = RolePermissionOverrides();

  /// What a role can actually do right now: its saved override if one
  /// exists, otherwise its hardcoded default — the single call site every
  /// permission check ([computeRedirect], the home screen's quick actions)
  /// should go through instead of [UserRoleX.permissions] directly.
  Set<Permission> effectivePermissionsFor(UserRole role) =>
      overridesByRole[role] ?? role.permissions;

  factory RolePermissionOverrides.fromFirestore(Map<String, dynamic> data) {
    final overrides = <UserRole, Set<Permission>>{};
    for (final entry in data.entries) {
      final role = UserRole.values
          .where((r) => r.name == entry.key)
          .firstOrNull;
      final permissionNames = entry.value;
      if (role == null || permissionNames is! List) continue;

      final permissions = <Permission>{
        for (final name in permissionNames)
          ...Permission.values.where((p) => p.name == name),
      };
      overrides[role] = permissions;
    }
    return RolePermissionOverrides(overridesByRole: overrides);
  }

  Map<String, dynamic> toFirestore() => {
    for (final entry in overridesByRole.entries)
      entry.key.name: [for (final p in entry.value) p.name],
  };

  /// Returns a copy with [role]'s override replaced by [permissions] —
  /// used by the edit screen so it never has to touch the raw map itself.
  RolePermissionOverrides withRole(UserRole role, Set<Permission> permissions) =>
      RolePermissionOverrides(
        overridesByRole: {...overridesByRole, role: permissions},
      );
}
