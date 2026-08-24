import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/severity_palette.dart';
import 'package:taarak/features/alerts/application/alert_providers.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';

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
      appBar: AppBar(title: const Text('Alerts')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeAlertsForCurrentLocationProvider);
          ref.invalidate(alertHistoryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Active for your location', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            activeAlerts.when(
              data: (alerts) => alerts.isEmpty
                  ? const Text('No active alerts for your current location.')
                  : Column(
                      children: [
                        for (final alert in alerts)
                          _AlertCard(alert: alert, showAcknowledge: true),
                      ],
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text(
                "Couldn't determine your location — check location permissions.",
              ),
            ),
            const SizedBox(height: 24),
            Text('History', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (history.isEmpty)
              const Text('No alerts broadcast yet.')
            else
              for (final alert in history)
                _AlertCard(alert: alert, showAcknowledge: false),
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
    final isActive = alert.cancelledAt == null && DateTime.now().isBefore(alert.validUntil);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: severityColor(alert.severity),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(alert.title, style: Theme.of(context).textTheme.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(alert.message),
            const SizedBox(height: 4),
            Text(
              '${alert.zoneLabel} · ${isActive ? "Active" : "Not active"} · '
              'valid until ${alert.validUntil.toLocal()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (widget.showAcknowledge && isActive)
              Align(
                alignment: Alignment.centerRight,
                child: _acknowledged
                    ? const Text('Acknowledged')
                    : TextButton(
                        onPressed: _acknowledge,
                        child: const Text('Acknowledge'),
                      ),
              ),
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
