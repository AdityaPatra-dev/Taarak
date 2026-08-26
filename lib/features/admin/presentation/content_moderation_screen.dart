import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/admin/application/content_moderation_providers.dart';
import 'package:taarak/features/alerts/application/alert_providers.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/hazards/application/hazard_providers.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/verification/application/verification_providers.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/severity_chip.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// A System Admin's content-moderation console — the ability to pull a bad
/// hazard zone, incident (SOS or otherwise), or alert off the map and
/// dashboards without touching Firestore by hand, which was previously the
/// only way to do it. Every removal is soft (see [LocalHazardZones.
/// removedAt]/[LocalIncidents.removedAt]/[LocalAlerts.cancelledAt]) and
/// audited, never a hard delete.
class ContentModerationScreen extends ConsumerWidget {
  const ContentModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const TaarakAppBar(title: 'Content Moderation'),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _HazardZonesSection(),
                SizedBox(height: Spacing.lg),
                _IncidentsSection(),
                SizedBox(height: Spacing.lg),
                _AlertsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HazardZonesSection extends ConsumerWidget {
  const _HazardZonesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(moderatableHazardZonesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Hazard zones',
          icon: Icons.warning_amber_outlined,
        ),
        zonesAsync.when(
          loading: () => const LoadingView(),
          error: (error, _) =>
              ErrorView(message: 'Could not load hazard zones: $error'),
          data: (zones) => zones.isEmpty
              ? const EmptyView(
                  icon: Icons.warning_amber_outlined,
                  title: 'No active hazard zones',
                )
              : Column(
                  children: [
                    for (final zone in zones)
                      _ModerationCard(
                        title: zone.hazardType,
                        subtitle:
                            'Source: ${zone.source} · Observed ${zone.observedAt.toLocal()}',
                        severity: zone.severity,
                        onRemove: (reason) => _removeZone(ref, zone, reason),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<String?> _removeZone(
    WidgetRef ref,
    LocalHazardZone zone,
    String? reason,
  ) async {
    final adminId = ref.read(currentUserProvider)?.id;
    if (adminId == null) return 'Not signed in';
    final result = await ref
        .read(hazardIngestionServiceProvider)
        .remove(id: zone.id, adminId: adminId, reason: reason);
    ref.invalidate(moderatableHazardZonesProvider);
    ref.invalidate(hazardZonesProvider);
    return result.when(success: (_) => null, failure: (f) => f.message);
  }
}

class _IncidentsSection extends ConsumerWidget {
  const _IncidentsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(moderatableIncidentsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Incidents & SOS reports',
          icon: Icons.report_gmailerrorred_outlined,
        ),
        incidentsAsync.when(
          loading: () => const LoadingView(),
          error: (error, _) =>
              ErrorView(message: 'Could not load incidents: $error'),
          data: (incidents) => incidents.isEmpty
              ? const EmptyView(
                  icon: Icons.report_gmailerrorred_outlined,
                  title: 'No active incidents',
                )
              : Column(
                  children: [
                    for (final incident in incidents)
                      _ModerationCard(
                        title: incident.type,
                        subtitle:
                            '${incident.status} · ${incident.latitude.toStringAsFixed(4)}, '
                            '${incident.longitude.toStringAsFixed(4)}',
                        severity: incident.severity,
                        onRemove: (reason) =>
                            _removeIncident(ref, incident, reason),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<String?> _removeIncident(
    WidgetRef ref,
    LocalIncident incident,
    String? reason,
  ) async {
    final adminId = ref.read(currentUserProvider)?.id;
    if (adminId == null) return 'Not signed in';
    final result = await ref
        .read(incidentVerificationServiceProvider)
        .removeIncident(incidentId: incident.id, adminId: adminId, reason: reason);
    ref.invalidate(moderatableIncidentsProvider);
    ref.invalidate(incidentsProvider);
    return result.when(success: (_) => null, failure: (f) => f.message);
  }
}

class _AlertsSection extends ConsumerWidget {
  const _AlertsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(moderatableAlertsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Alerts', icon: Icons.campaign_outlined),
        alertsAsync.when(
          loading: () => const LoadingView(),
          error: (error, _) =>
              ErrorView(message: 'Could not load alerts: $error'),
          data: (alerts) => alerts.isEmpty
              ? const EmptyView(
                  icon: Icons.campaign_outlined,
                  title: 'No active alerts',
                )
              : Column(
                  children: [
                    for (final alert in alerts)
                      _ModerationCard(
                        title: alert.title,
                        subtitle: alert.message,
                        severity: alert.severity,
                        onRemove: (reason) => _removeAlert(ref, alert, reason),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<String?> _removeAlert(
    WidgetRef ref,
    LocalAlert alert,
    String? reason,
  ) async {
    final adminId = ref.read(currentUserProvider)?.id;
    if (adminId == null) return 'Not signed in';
    final result = await ref
        .read(alertBroadcastServiceProvider)
        .deleteAlert(alertId: alert.id, adminId: adminId, reason: reason);
    ref.invalidate(moderatableAlertsProvider);
    ref.invalidate(alertHistoryProvider);
    return result.when(success: (_) => null, failure: (f) => f.message);
  }
}

/// Shared card + confirmation-dialog flow for all three sections. `onRemove`
/// returns an error message on failure, or null on success, so this widget
/// stays agnostic to which of the three services actually handled it.
class _ModerationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String severity;
  final Future<String?> Function(String? reason) onRemove;

  const _ModerationCard({
    required this.title,
    required this.subtitle,
    required this.severity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.xs),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SeverityChip(severity: severity),
            const SizedBox(width: Spacing.xs),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove',
              onPressed: () => _confirmAndRemove(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndRemove(BuildContext context) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove "$title"?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes it for everyone — it will not '
              'reappear on any device. The action itself (who, when, why) '
              'stays in the audit log.',
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final reason = reasonController.text.trim();
    final error = await onRemove(reason.isEmpty ? null : reason);
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Removed')),
    );
  }
}
