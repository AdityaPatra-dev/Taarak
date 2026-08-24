import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/app/route_guard.dart';
import 'package:taarak/features/alerts/presentation/alerts_screen.dart';
import 'package:taarak/features/alerts/presentation/broadcast_alert_screen.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/auth/presentation/login_screen.dart';
import 'package:taarak/features/auth/presentation/register_screen.dart';
import 'package:taarak/features/home/presentation/home_screen.dart';
import 'package:taarak/features/home/presentation/unauthorized_screen.dart';
import 'package:taarak/features/map/presentation/risk_map_screen.dart';
import 'package:taarak/features/profile/presentation/profile_screen.dart';
import 'package:taarak/features/reporting/presentation/i_am_safe_screen.dart';
import 'package:taarak/features/reporting/presentation/report_incident_screen.dart';
import 'package:taarak/features/reporting/presentation/sos_screen.dart';
import 'package:taarak/features/shelters/presentation/shelter_management_screen.dart';
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
    initialLocation: '/',
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
