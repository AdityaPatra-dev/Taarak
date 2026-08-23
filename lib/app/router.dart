import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// App-wide route table. M02 (auth/RBAC) will add a `redirect` here to send
/// unauthenticated users to login and gate routes by role; kept as a single
/// placeholder route until then.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const FoundationHomeScreen(),
      ),
    ],
  );
});

/// Temporary landing screen proving the app shell boots end to end.
/// Replaced by the real role-based home screens as their modules land.
class FoundationHomeScreen extends StatelessWidget {
  const FoundationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TAARAK')),
      body: const Center(
        child: Text('Foundation ready — role-based screens land in M02+'),
      ),
    );
  }
}
