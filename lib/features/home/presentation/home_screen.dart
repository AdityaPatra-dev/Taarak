import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';
import 'package:taarak/features/sync/application/sync_providers.dart';
import 'package:taarak/features/sync/domain/sync_queue_summary.dart';
import 'package:taarak/shared/widgets/responsive.dart';

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
        ref.watch(syncQueueSummaryProvider).valueOrNull ??
        const SyncQueueSummary();
    final isDevMode = ref.watch(appConfigProvider).isDevMode;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasSos = user.role.can(Permission.sendSos);

    final actions = <_QuickAction>[
      if (user.role.can(Permission.submitIncidentReport))
        _QuickAction(
          icon: Icons.report_outlined,
          label: 'Report Incident',
          onTap: () => context.go('/report'),
        ),
      if (user.role.can(Permission.updateSafeStatus))
        _QuickAction(
          icon: Icons.health_and_safety_outlined,
          label: 'I Am Safe',
          onTap: () => context.go('/safe-status'),
        ),
      if (user.role.can(Permission.verifyReports))
        _QuickAction(
          icon: Icons.fact_check_outlined,
          label: 'Verify Reports',
          onTap: () => context.go('/verification'),
        ),
      if (user.role.can(Permission.manageSheltersResources))
        _QuickAction(
          icon: Icons.home_work_outlined,
          label: 'Shelters & Resources',
          onTap: () => context.go('/shelters/manage'),
        ),
      if (user.role.can(Permission.viewAlerts))
        _QuickAction(
          icon: Icons.campaign_outlined,
          label: 'Alerts',
          onTap: () => context.go('/alerts'),
        ),
      if (user.role.can(Permission.sendBroadcast))
        _QuickAction(
          icon: Icons.campaign,
          label: 'Broadcast Alert',
          onTap: () => context.go('/alerts/broadcast'),
        ),
      if (user.role.can(Permission.monitorZones))
        _QuickAction(
          icon: Icons.dashboard_outlined,
          label: 'Command Dashboard',
          onTap: () => context.go('/dashboard'),
        ),
      if (user.role.can(Permission.reviewAudit))
        _QuickAction(
          icon: Icons.history_outlined,
          label: 'Audit Log',
          onTap: () => context.go('/audit'),
        ),
      if (isDevMode && hasSos)
        _QuickAction(
          icon: Icons.sms_outlined,
          label: 'SMS Fallback',
          onTap: () => context.go('/sms-prototype'),
        ),
      if (isDevMode && hasSos)
        _QuickAction(
          icon: Icons.wifi_tethering,
          label: 'Device Relay',
          onTap: () => context.go('/device-relay'),
        ),
    ];

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
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        children: [
          ContentWidth(
            maxWidth: 860,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GreetingCard(
                  name: user.name,
                  roleLabel: user.role.label,
                  scheme: scheme,
                  textTheme: textTheme,
                ),
                if (!syncSummary.isEmpty) ...[
                  const SizedBox(height: Spacing.sm),
                  _SyncBanner(summary: syncSummary, ref: ref),
                ],
                if (hasSos) ...[
                  const SizedBox(height: Spacing.md),
                  _SosCard(onTap: () => context.go('/sos')),
                ],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: Spacing.lg),
                  Text('Quick actions', style: textTheme.titleMedium),
                  const SizedBox(height: Spacing.sm),
                  ResponsiveBuilder(
                    builder: (context, size) {
                      final columns = switch (size) {
                        ScreenSize.mobile => 2,
                        ScreenSize.tablet => 3,
                        ScreenSize.desktop => 4,
                      };
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: actions.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: Spacing.sm,
                          mainAxisSpacing: Spacing.sm,
                          childAspectRatio: 1.25,
                        ),
                        itemBuilder: (context, index) => actions[index],
                      );
                    },
                  ),
                ],
                const SizedBox(height: Spacing.lg),
                Text('Available to your role', style: textTheme.titleMedium),
                const SizedBox(height: Spacing.sm),
                if (permissions.isEmpty)
                  Text(
                    'No capabilities configured for this role yet.',
                    style: textTheme.bodyMedium,
                  )
                else
                  Wrap(
                    spacing: Spacing.xs,
                    runSpacing: Spacing.xs,
                    children: [
                      for (final permission in permissions)
                        Chip(
                          avatar: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: scheme.primary,
                          ),
                          label: Text(permission.label),
                        ),
                    ],
                  ),
                const SizedBox(height: Spacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String name;
  final String roleLabel;
  final ColorScheme scheme;
  final TextTheme textTheme;

  const _GreetingCard({
    required this.name,
    required this.roleLabel,
    required this.scheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: scheme.primary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: textTheme.titleLarge?.copyWith(color: scheme.onPrimary),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $name',
                  style: textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    roleLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SosCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SosCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: scheme.error,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.onError.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.sos, color: scheme.onError, size: 26),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency SOS',
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onError,
                      ),
                    ),
                    Text(
                      'Alert responders immediately with your location',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onError.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onError),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncBanner extends ConsumerWidget {
  final SyncQueueSummary summary;
  final WidgetRef ref;

  const _SyncBanner({required this.summary, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isStalled = summary.stalledCount > 0;
    final isRetrying = summary.retryingCount > 0;
    final background = isStalled
        ? scheme.errorContainer
        : scheme.secondaryContainer;
    final foreground = isStalled
        ? scheme.onErrorContainer
        : scheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isStalled
                ? Icons.sync_problem
                : isRetrying
                ? Icons.sync_problem_outlined
                : Icons.schedule,
            size: 18,
            color: foreground,
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              syncQueueSummaryMessage(summary),
              style: textTheme.bodySmall?.copyWith(color: foreground),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: foreground),
            onPressed: () async {
              await ref
                  .read(syncCoordinatorServiceProvider)
                  .syncPendingEntries();
              ref.invalidate(pendingSyncCountProvider);
              ref.invalidate(syncQueueSummaryProvider);
            },
            child: const Text('Sync now'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.sm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
