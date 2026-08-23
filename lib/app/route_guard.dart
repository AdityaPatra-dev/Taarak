import 'package:taarak/features/auth/domain/auth_session.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

const _authRoutes = {'/login', '/register'};

/// Registered by each feature as its screens land, e.g. once M18's command
/// dashboard exists: `'/dashboard': Permission.monitorZones`. Empty for now
/// — M02 only ships the shared home screen, which every authenticated role
/// may see (it just renders a different permitted-module list per role).
const Map<String, Permission> defaultRoutePermissions = {};

/// Pure redirect decision for the app router: unauthenticated users are sent
/// to login, authenticated users are kept off the auth screens, and anyone
/// missing the permission a route requires is sent to /unauthorized.
/// Kept side-effect free (no BuildContext/GoRouterState) so it's unit
/// testable without pumping a widget tree.
String? computeRedirect({
  required AuthSession? session,
  required String location,
  Map<String, Permission> routePermissions = defaultRoutePermissions,
}) {
  if (session == null) {
    return _authRoutes.contains(location) ? null : '/login';
  }

  if (_authRoutes.contains(location)) {
    return '/';
  }

  final required = routePermissions[location];
  if (required != null && !session.user.role.can(required)) {
    return '/unauthorized';
  }

  return null;
}
