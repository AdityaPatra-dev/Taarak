import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/verification/application/verification_providers.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';

/// Official Verification (M13): unlinked citizen reports (M12) waiting to
/// be acknowledged into a tracked incident, and tracked incidents an
/// official can move through the rest of the lifecycle. There's no
/// dedicated screen named for this in the blueprint's own screen list
/// (section 4) — this is the natural home for the workflow M13's
/// acceptance criterion describes.
class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingReports = ref.watch(pendingReportsProvider).valueOrNull ?? const [];
    final incidents = ref.watch(incidentsProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Official Verification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pending reports', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (pendingReports.isEmpty)
            const Text('No unlinked reports waiting for review.')
          else
            for (final report in pendingReports)
              Card(
                child: ListTile(
                  title: Text(
                    report.description.isEmpty ? report.reportType : report.description,
                  ),
                  subtitle: Text(
                    '${report.reportType} · severity ${report.severity}\n'
                    '${report.latitude.toStringAsFixed(4)}, ${report.longitude.toStringAsFixed(4)}',
                  ),
                  isThreeLine: true,
                  trailing: FilledButton(
                    onPressed: () => _acknowledge(context, ref, report.id),
                    child: const Text('Acknowledge'),
                  ),
                ),
              ),
          const SizedBox(height: 24),
          Text('Tracked incidents', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (incidents.isEmpty)
            const Text('No incidents tracked yet.')
          else
            for (final incident in incidents)
              _IncidentCard(incident: incident),
        ],
      ),
    );
  }

  Future<void> _acknowledge(BuildContext context, WidgetRef ref, String reportId) async {
    final officialId = ref.read(currentUserProvider)?.id;
    if (officialId == null) return;

    final result = await ref
        .read(incidentVerificationServiceProvider)
        .acknowledgeReport(reportId: reportId, officialId: officialId);

    ref.invalidate(pendingReportsProvider);
    ref.invalidate(incidentsProvider);

    if (!context.mounted) return;
    result.when(
      success: (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report acknowledged')),
      ),
      failure: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }
}

class _IncidentCard extends ConsumerWidget {
  final LocalIncident incident;

  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        IncidentVerificationStatus.fromStorageValue(incident.status) ??
        IncidentVerificationStatus.reported;
    final nextOptions = allowedIncidentStatusTransitions[status] ?? const {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${incident.type} — ${status.label}', style: Theme.of(context).textTheme.titleSmall),
            if (incident.description.isNotEmpty) Text(incident.description),
            if (incident.independentSourceCount > 1)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Confirmed by ${incident.independentSourceCount} independent sources '
                  '(${(incident.confidence * 100).round()}% confidence)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final next in nextOptions)
                  OutlinedButton(
                    onPressed: () => _showTransitionDialog(context, ref, next),
                    child: Text(next.label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTransitionDialog(
    BuildContext context,
    WidgetRef ref,
    IncidentVerificationStatus to,
  ) async {
    final reasonController = TextEditingController();
    final evidenceController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Move to "${to.label}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
            TextField(
              controller: evidenceController,
              decoration: const InputDecoration(labelText: 'Evidence (optional)'),
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
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final officialId = ref.read(currentUserProvider)?.id;
    if (officialId == null) return;

    final result = await ref
        .read(incidentVerificationServiceProvider)
        .transitionIncident(
          incidentId: incident.id,
          to: to,
          officialId: officialId,
          reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
          evidence: evidenceController.text.trim().isEmpty ? null : evidenceController.text.trim(),
        );

    ref.invalidate(incidentsProvider);

    if (!context.mounted) return;
    result.when(
      success: (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incident moved to "${to.label}"')),
      ),
      failure: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }
}
