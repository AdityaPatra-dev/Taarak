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

    test('the real M12 routes admit citizens', () {
      final session = _sessionFor(UserRole.citizen);
      expect(computeRedirect(session: session, location: '/report'), isNull);
      expect(computeRedirect(session: session, location: '/sos'), isNull);
      expect(computeRedirect(session: session, location: '/safe-status'), isNull);
    });

    test('the real M12 routes turn away a role without those permissions', () {
      final session = _sessionFor(UserRole.systemAdmin);
      expect(computeRedirect(session: session, location: '/report'), '/unauthorized');
      expect(computeRedirect(session: session, location: '/sos'), '/unauthorized');
      expect(
        computeRedirect(session: session, location: '/safe-status'),
        '/unauthorized',
      );
    });

    test('the real /verification route (M13) admits a local official', () {
      final session = _sessionFor(UserRole.localOfficial);
      expect(computeRedirect(session: session, location: '/verification'), isNull);
    });

    test('the real /verification route (M13) turns away a citizen', () {
      final session = _sessionFor(UserRole.citizen);
      expect(
        computeRedirect(session: session, location: '/verification'),
        '/unauthorized',
      );
    });
  });
}
