import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';

/// Temporary shared landing screen. Its job right now is to prove RBAC
/// works — each role sees only the capability list the blueprint's role
/// table (section 3) grants it. Replaced by the real per-role home screens
/// (My Safety / Operations Dashboard) as those modules land.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    if (session == null) {
      // Guarded by the router redirect; nothing to render while it kicks in.
      return const SizedBox.shrink();
    }

    final user = session.user;
    final permissions = user.role.permissions.toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return Scaffold(
      appBar: AppBar(
        title: const Text('TAARAK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Welcome, ${user.name}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(user.role.label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(
            'Available to your role',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (permissions.isEmpty)
            const Text('No capabilities configured for this role yet.')
          else
            for (final permission in permissions)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(permission.label),
              ),
        ],
      ),
    );
  }
}
