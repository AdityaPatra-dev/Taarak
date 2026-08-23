import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/app/route_guard.dart';
import 'package:taarak/features/auth/domain/app_user.dart';
import 'package:taarak/features/auth/domain/auth_session.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

AuthSession _sessionFor(UserRole role) => AuthSession(
  user: AppUser(id: '1', name: 'Test', email: 't@t.dev', role: role),
  token: 'token',
);

void main() {
  group('computeRedirect', () {
    test('sends an unauthenticated visitor to /login', () {
      expect(
        computeRedirect(session: null, location: '/'),
        '/login',
      );
    });

    test('lets an unauthenticated visitor reach /login and /register', () {
      expect(computeRedirect(session: null, location: '/login'), isNull);
      expect(computeRedirect(session: null, location: '/register'), isNull);
    });

    test('sends an authenticated user away from the auth screens', () {
      final session = _sessionFor(UserRole.citizen);
      expect(computeRedirect(session: session, location: '/login'), '/');
      expect(computeRedirect(session: session, location: '/register'), '/');
    });

    test('lets an authenticated user reach an ungated route', () {
      final session = _sessionFor(UserRole.citizen);
      expect(computeRedirect(session: session, location: '/'), isNull);
    });

    test('lets a role through a route it has permission for', () {
      final session = _sessionFor(UserRole.districtCommand);
      final result = computeRedirect(
        session: session,
        location: '/dashboard',
        routePermissions: {'/dashboard': Permission.monitorZones},
      );
      expect(result, isNull);
    });

    test('sends a role without the required permission to /unauthorized', () {
      final session = _sessionFor(UserRole.citizen);
      final result = computeRedirect(
        session: session,
        location: '/dashboard',
        routePermissions: {'/dashboard': Permission.monitorZones},
      );
      expect(result, '/unauthorized');
    });

    test('the real /map route (M05) admits citizens', () {
      final session = _sessionFor(UserRole.citizen);
      expect(computeRedirect(session: session, location: '/map'), isNull);
    });

    test('the real /map route (M05) turns away a role without viewRiskMap', () {
      final session = _sessionFor(UserRole.systemAdmin);
      expect(computeRedirect(session: session, location: '/map'), '/unauthorized');
    });
  });
}
