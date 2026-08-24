import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';
import 'package:taarak/features/sync/application/sync_providers.dart';
import 'package:taarak/features/sync/domain/sync_queue_summary.dart';

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
    final syncSummary =
        ref.watch(syncQueueSummaryProvider).valueOrNull ?? const SyncQueueSummary();
    final isDevMode = ref.watch(appConfigProvider).isDevMode;

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
          if (!syncSummary.isEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  syncSummary.stalledCount > 0
                      ? Icons.sync_problem
                      : syncSummary.retryingCount > 0
                      ? Icons.sync_problem_outlined
                      : Icons.schedule,
                  size: 16,
                  color: syncSummary.stalledCount > 0
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    syncQueueSummaryMessage(syncSummary),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    await ref.read(syncCoordinatorServiceProvider).syncPendingEntries();
                    ref.invalidate(pendingSyncCountProvider);
                    ref.invalidate(syncQueueSummaryProvider);
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
              user.role.can(Permission.sendBroadcast) ||
              user.role.can(Permission.monitorZones) ||
              user.role.can(Permission.reviewAudit)) ...[
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
                if (user.role.can(Permission.monitorZones))
                  OutlinedButton.icon(
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(Icons.dashboard_outlined),
                    label: const Text('Command Dashboard'),
                  ),
                if (user.role.can(Permission.reviewAudit))
                  OutlinedButton.icon(
                    onPressed: () => context.go('/audit'),
                    icon: const Icon(Icons.history_outlined),
                    label: const Text('Audit Log'),
                  ),
                if (isDevMode && user.role.can(Permission.sendSos))
                  OutlinedButton.icon(
                    onPressed: () => context.go('/sms-prototype'),
                    icon: const Icon(Icons.sms_outlined),
                    label: const Text('SMS Fallback (Prototype)'),
                  ),
                if (isDevMode && user.role.can(Permission.sendSos))
                  OutlinedButton.icon(
                    onPressed: () => context.go('/device-relay'),
                    icon: const Icon(Icons.wifi_tethering),
                    label: const Text('Device Relay (Prototype)'),
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
