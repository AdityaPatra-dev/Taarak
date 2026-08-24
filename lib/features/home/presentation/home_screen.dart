import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';
import 'package:taarak/features/sync/application/sync_providers.dart';

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
    final pendingSyncCount = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TAARAK'),
        actions: [
          if (user.role.can(Permission.viewRiskMap))
            IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: 'Risk Map',
              onPressed: () => context.go('/map'),
            ),
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
          if (pendingSyncCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.sync, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$pendingSyncCount item${pendingSyncCount == 1 ? '' : 's'} waiting to sync',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    await ref.read(syncCoordinatorServiceProvider).syncPendingEntries();
                    ref.invalidate(pendingSyncCountProvider);
                  },
                  child: const Text('Sync now'),
                ),
              ],
            ),
          ],
          if (user.role.can(Permission.submitIncidentReport) ||
              user.role.can(Permission.sendSos) ||
              user.role.can(Permission.updateSafeStatus) ||
              user.role.can(Permission.verifyReports) ||
              user.role.can(Permission.manageSheltersResources) ||
              user.role.can(Permission.viewAlerts) ||
              user.role.can(Permission.sendBroadcast)) ...[
            const SizedBox(height: 24),
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (user.role.can(Permission.submitIncidentReport))
                  OutlinedButton.icon(
                    onPressed: () => context.go('/report'),
                    icon: const Icon(Icons.report_outlined),
                    label: const Text('Report Incident'),
                  ),
                if (user.role.can(Permission.sendSos))
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => context.go('/sos'),
                    icon: const Icon(Icons.sos),
                    label: const Text('SOS'),
                  ),
                if (user.role.can(Permission.updateSafeStatus))
                  OutlinedButton.icon(
                    onPressed: () => context.go('/safe-status'),
                    icon: const Icon(Icons.health_and_safety_outlined),
                    label: const Text('I Am Safe'),
                  ),
                if (user.role.can(Permission.verifyReports))
                  OutlinedButton.icon(
                    onPressed: () => context.go('/verification'),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Verify Reports'),
                  ),
                if (user.role.can(Permission.manageSheltersResources))
                  OutlinedButton.icon(
                    onPressed: () => context.go('/shelters/manage'),
                    icon: const Icon(Icons.home_work_outlined),
                    label: const Text('Shelters & Resources'),
                  ),
                if (user.role.can(Permission.viewAlerts))
                  OutlinedButton.icon(
                    onPressed: () => context.go('/alerts'),
                    icon: const Icon(Icons.campaign_outlined),
                    label: const Text('Alerts'),
                  ),
                if (user.role.can(Permission.sendBroadcast))
                  OutlinedButton.icon(
                    onPressed: () => context.go('/alerts/broadcast'),
                    icon: const Icon(Icons.campaign),
                    label: const Text('Broadcast Alert'),
                  ),
              ],
            ),
          ],
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
