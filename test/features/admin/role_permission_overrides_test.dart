import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/admin/domain/role_permission_overrides.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

void main() {
  group('RolePermissionOverrides', () {
    test('a role with no override falls back to its default permissions', () {
      const overrides = RolePermissionOverrides.empty;

      expect(
        overrides.effectivePermissionsFor(UserRole.citizen),
        UserRole.citizen.permissions,
      );
    });

    test('withRole replaces only the targeted role, leaving others default', () {
      final overrides = const RolePermissionOverrides().withRole(
        UserRole.citizen,
        {Permission.viewRiskMap},
      );

      expect(
        overrides.effectivePermissionsFor(UserRole.citizen),
        {Permission.viewRiskMap},
      );
      expect(
        overrides.effectivePermissionsFor(UserRole.fieldResponder),
        UserRole.fieldResponder.permissions,
      );
    });

    test('an empty set is a valid override — revokes every permission', () {
      final overrides = const RolePermissionOverrides().withRole(
        UserRole.citizen,
        {},
      );

      expect(overrides.effectivePermissionsFor(UserRole.citizen), isEmpty);
    });

    test('round-trips through Firestore encoding', () {
      final overrides = const RolePermissionOverrides().withRole(
        UserRole.districtCommand,
        {Permission.monitorZones, Permission.manageResources},
      );

      final decoded = RolePermissionOverrides.fromFirestore(
        overrides.toFirestore(),
      );

      expect(
        decoded.effectivePermissionsFor(UserRole.districtCommand),
        {Permission.monitorZones, Permission.manageResources},
      );
    });

    test('unknown role/permission names in stored data are ignored, not fatal', () {
      final decoded = RolePermissionOverrides.fromFirestore({
        'notARealRole': ['viewRiskMap'],
        'citizen': ['viewRiskMap', 'notARealPermission'],
      });

      expect(
        decoded.effectivePermissionsFor(UserRole.citizen),
        {Permission.viewRiskMap},
      );
    });
  });
}
