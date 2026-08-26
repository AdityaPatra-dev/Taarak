import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/app/route_guard.dart';
import 'package:taarak/features/alerts/presentation/alerts_screen.dart';
import 'package:taarak/features/alerts/presentation/broadcast_alert_screen.dart';
import 'package:taarak/features/audit/presentation/audit_log_screen.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/dashboard/presentation/command_dashboard_screen.dart';
import 'package:taarak/features/dashboard/presentation/incident_detail_screen.dart';
import 'package:taarak/features/device_relay/presentation/device_relay_screen.dart';
import 'package:taarak/features/auth/presentation/login_screen.dart';
import 'package:taarak/features/auth/presentation/register_screen.dart';
import 'package:taarak/features/home/presentation/home_screen.dart';
import 'package:taarak/features/admin/presentation/content_moderation_screen.dart';
import 'package:taarak/features/admin/presentation/user_admin_screen.dart';
import 'package:taarak/features/command/presentation/manage_relocation_screen.dart';
import 'package:taarak/features/command/presentation/manage_resources_screen.dart';
import 'package:taarak/features/command/presentation/manage_responders_screen.dart';
import 'package:taarak/features/field_response/presentation/assigned_incidents_screen.dart';
import 'package:taarak/features/field_response/presentation/field_incident_detail_screen.dart';
import 'package:taarak/features/hazards/presentation/report_hazard_zone_screen.dart';
import 'package:taarak/features/home/presentation/unauthorized_screen.dart';
import 'package:taarak/features/map/presentation/risk_map_screen.dart';
import 'package:taarak/features/state_admin/presentation/policy_configuration_screen.dart';
import 'package:taarak/features/state_admin/presentation/state_reports_screen.dart';
import 'package:taarak/features/profile/presentation/profile_screen.dart';
import 'package:taarak/features/reporting/presentation/i_am_safe_screen.dart';
import 'package:taarak/features/reporting/presentation/report_incident_screen.dart';
import 'package:taarak/features/reporting/presentation/sos_screen.dart';
import 'package:taarak/features/shelters/presentation/shelter_management_screen.dart';
import 'package:taarak/features/sms_prototype/presentation/sms_prototype_screen.dart';
import 'package:taarak/features/verification/presentation/verification_screen.dart';

/// Bridges Riverpod's `authControllerProvider` changes into GoRouter's
/// `refreshListenable`, so a login/logout re-evaluates the redirect without
/// the app having to rebuild the whole router each time.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final _routerRefreshProvider = Provider.autoDispose<_RouterRefreshNotifier>((
  ref,
) {
  final notifier = _RouterRefreshNotifier();
  ref.listen(authControllerProvider, (_, _) => notifier.notify());
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Only mounted once the initial session restore (see [AuthController])
/// has resolved — see app/app.dart — so redirect logic here never has to
/// handle an in-flight `AsyncLoading` state.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);

  return GoRouter(
    // No initialLocation override — go_router's own default reads the
    // real browser URL on web (Uri.base), so a refresh or a direct link
    // to e.g. /command/responders lands there instead of always bouncing
    // to home. computeRedirect below still gates it exactly the same way
    // regardless of how the location was reached.
    refreshListenable: refreshNotifier,
    redirect: (context, state) => computeRedirect(
      session: ref.read(authControllerProvider).valueOrNull,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const RiskMapScreen(),
      ),
      GoRoute(
        path: '/hazards/report',
        builder: (context, state) => const ReportHazardZoneScreen(),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => const ReportIncidentScreen(),
      ),
      GoRoute(path: '/sos', builder: (context, state) => const SosScreen()),
      GoRoute(
        path: '/safe-status',
        builder: (context, state) => const IAmSafeScreen(),
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: '/shelters/manage',
        builder: (context, state) => const ShelterManagementScreen(),
      ),
      GoRoute(path: '/alerts', builder: (context, state) => const AlertsScreen()),
      GoRoute(
        path: '/alerts/broadcast',
        builder: (context, state) => const BroadcastAlertScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const CommandDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/incidents/:incidentId',
        builder: (context, state) => IncidentDetailScreen(
          incidentId: state.pathParameters['incidentId']!,
        ),
      ),
      GoRoute(path: '/audit', builder: (context, state) => const AuditLogScreen()),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserAdminScreen(),
      ),
      GoRoute(
        path: '/admin/moderation',
        builder: (context, state) => const ContentModerationScreen(),
      ),
      GoRoute(
        path: '/field/incidents',
        builder: (context, state) => const AssignedIncidentsScreen(),
      ),
      GoRoute(
        path: '/field/incidents/:incidentId',
        builder: (context, state) => FieldIncidentDetailScreen(
          incidentId: state.pathParameters['incidentId']!,
        ),
      ),
      GoRoute(
        path: '/command/responders',
        builder: (context, state) => const ManageRespondersScreen(),
      ),
      GoRoute(
        path: '/command/resources',
        builder: (context, state) => const ManageResourcesScreen(),
      ),
      GoRoute(
        path: '/command/relocation',
        builder: (context, state) => const ManageRelocationScreen(),
      ),
      GoRoute(
        path: '/state/oversight',
        builder: (context, state) =>
            const CommandDashboardScreen(title: 'Cross-District Oversight'),
      ),
      GoRoute(
        path: '/state/reports',
        builder: (context, state) => const StateReportsScreen(),
      ),
      GoRoute(
        path: '/state/policy',
        builder: (context, state) => const PolicyConfigurationScreen(),
      ),
      GoRoute(
        path: '/sms-prototype',
        builder: (context, state) => const SmsPrototypeScreen(),
      ),
      GoRoute(
        path: '/device-relay',
        builder: (context, state) => const DeviceRelayScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
    ],
  );
});
