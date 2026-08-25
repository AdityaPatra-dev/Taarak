import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/alerts/application/alert_providers.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/severity_chip.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// M16, citizen-facing ([Permission.viewAlerts]): active alerts for the
/// citizen's current location up top, full broadcast history below —
/// mirroring the official-side [BroadcastAlertScreen] so both roles see
/// the same underlying alert records from their own vantage point.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAlerts = ref.watch(activeAlertsForCurrentLocationProvider);
    final history = ref.watch(alertHistoryProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Alerts'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeAlertsForCurrentLocationProvider);
          ref.invalidate(alertHistoryProvider);
        },
        child: ListView(
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Active for your location',
                    icon: Icons.notifications_active_outlined,
                  ),
                  activeAlerts.when(
                    data: (alerts) => alerts.isEmpty
                        ? const EmptyView(
                            icon: Icons.campaign_outlined,
                            title: 'No active alerts',
                            message:
                                'Nothing has been broadcast to your current location.',
                          )
                        : Column(
                            children: [
                              for (final alert in alerts)
                                _AlertCard(alert: alert, showAcknowledge: true),
                            ],
                          ),
                    loading: () => const LoadingView(),
                    error: (_, _) => const ErrorView(
                      message:
                          "Couldn't determine your location — check location permissions.",
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  const SectionHeader(title: 'History', icon: Icons.history),
                  if (history.isEmpty)
                    const EmptyView(
                      icon: Icons.history,
                      title: 'No alerts broadcast yet',
                    )
                  else
                    for (final alert in history)
                      _AlertCard(alert: alert, showAcknowledge: false),
                  const SizedBox(height: Spacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends ConsumerStatefulWidget {
  final LocalAlert alert;
  final bool showAcknowledge;

  const _AlertCard({required this.alert, required this.showAcknowledge});

  @override
  ConsumerState<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends ConsumerState<_AlertCard> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final isActive =
        alert.cancelledAt == null && DateTime.now().isBefore(alert.validUntil);

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                SeverityChip(severity: alert.severity),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(alert.message),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle_outline : Icons.circle_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${alert.zoneLabel} · ${isActive ? "Active" : "Not active"} · '
                    'valid until ${alert.validUntil.toLocal()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (widget.showAcknowledge && isActive) ...[
              const SizedBox(height: Spacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: _acknowledged
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          const Text('Acknowledged'),
                        ],
                      )
                    : FilledButton.tonal(
                        onPressed: _acknowledge,
                        child: const Text('Acknowledge'),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _acknowledge() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final result = await ref
        .read(alertBroadcastServiceProvider)
        .acknowledge(alertId: widget.alert.id, userId: userId);

    if (!mounted) return;
    if (result.isSuccess) {
      setState(() => _acknowledged = true);
    }
  }
}
