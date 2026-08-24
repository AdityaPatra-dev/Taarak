import 'package:taarak/features/auth/domain/auth_session.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

const _authRoutes = {'/login', '/register'};

/// Registered by each feature as its screens land. `/map` is the citizen
/// Risk Map (blueprint section 4); the official Incident Map / Risk &
/// Red-Zone Map variants will get their own gated routes reusing the same
/// map engine once those modules land.
const Map<String, Permission> defaultRoutePermissions = {
  '/map': Permission.viewRiskMap,
  '/report': Permission.submitIncidentReport,
  '/sos': Permission.sendSos,
  '/safe-status': Permission.updateSafeStatus,
  '/verification': Permission.verifyReports,
  '/shelters/manage': Permission.manageSheltersResources,
  '/alerts': Permission.viewAlerts,
  '/alerts/broadcast': Permission.sendBroadcast,
  '/dashboard': Permission.monitorZones,
};

/// [defaultRoutePermissions] only matches exact locations; a route with a
/// path parameter (like the incident detail drill-down) needs its own
/// prefix check since its concrete path varies per incident.
const dashboardIncidentDetailPrefix = '/dashboard/incidents/';

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

  final required = location.startsWith(dashboardIncidentDetailPrefix)
      ? Permission.monitorZones
      : routePermissions[location];
  if (required != null && !session.user.role.can(required)) {
    return '/unauthorized';
  }

  return null;
}
