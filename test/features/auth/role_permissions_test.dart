import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

void main() {
  group('UserRole permissions (blueprint section 3)', () {
    test('every role has at least one permission', () {
      for (final role in UserRole.values) {
        expect(role.permissions, isNotEmpty, reason: 'role: $role');
      }
    });

    test('a citizen can act like a citizen and nothing else', () {
      const role = UserRole.citizen;
      expect(role.can(Permission.sendSos), isTrue);
      expect(role.can(Permission.submitIncidentReport), isTrue);
      expect(role.can(Permission.manageAccounts), isFalse);
      expect(role.can(Permission.verifyReports), isFalse);
      expect(role.can(Permission.monitorZones), isFalse);
    });

    test('a field responder cannot verify citizen reports or manage users', () {
      const role = UserRole.fieldResponder;
      expect(role.can(Permission.verifyFieldObservation), isTrue);
      expect(role.can(Permission.verifyReports), isFalse);
      expect(role.can(Permission.manageAccounts), isFalse);
    });

    test(
      'a field responder can view the risk map — navigateToIncident\'s only '
      'implementation pushes to /map to show the planned route, so without '
      'this that push bounces to /unauthorized',
      () {
        expect(UserRole.fieldResponder.can(Permission.viewRiskMap), isTrue);
      },
    );

    test('a local official can verify reports but not manage accounts', () {
      const role = UserRole.localOfficial;
      expect(role.can(Permission.verifyReports), isTrue);
      expect(role.can(Permission.sendBroadcast), isTrue);
      expect(role.can(Permission.manageAccounts), isFalse);
    });

    test('only system admin can manage accounts and permissions', () {
      for (final role in UserRole.values) {
        if (role == UserRole.systemAdmin) {
          expect(role.can(Permission.manageAccounts), isTrue);
          expect(role.can(Permission.managePermissions), isTrue);
        } else {
          expect(
            role.can(Permission.manageAccounts),
            isFalse,
            reason: 'role: $role',
          );
        }
      }
    });

    test('roles do not silently inherit capabilities from other roles', () {
      const role = UserRole.districtCommand;
      expect(role.can(Permission.manageRelocation), isTrue);
      expect(role.can(Permission.sendBroadcast), isFalse);
      expect(role.can(Permission.crossDistrictOversight), isFalse);
    });
  });
}
