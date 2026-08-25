import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/verification/application/verification_providers.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/severity_chip.dart';

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
    final pendingReports =
        ref.watch(pendingReportsProvider).valueOrNull ?? const [];
    final incidents = ref.watch(incidentsProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Official Verification')),
      body: ListView(
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Pending reports',
                  icon: Icons.fact_check_outlined,
                  trailing: pendingReports.isEmpty
                      ? null
                      : Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text('${pendingReports.length}'),
                        ),
                ),
                if (pendingReports.isEmpty)
                  const EmptyView(
                    icon: Icons.fact_check_outlined,
                    title: 'No unlinked reports',
                    message: 'Nothing is waiting for review right now.',
                  )
                else
                  for (final report in pendingReports)
                    Card(
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
                                    report.description.isEmpty
                                        ? report.reportType
                                        : report.description,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ),
                                const SizedBox(width: Spacing.sm),
                                SeverityChip(severity: report.severity),
                              ],
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              '${report.reportType} · '
                              '${report.latitude.toStringAsFixed(4)}, '
                              '${report.longitude.toStringAsFixed(4)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: Spacing.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton(
                                onPressed: () =>
                                    _acknowledge(context, ref, report.id),
                                child: const Text('Acknowledge'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: Spacing.lg),
                const SectionHeader(
                  title: 'Tracked incidents',
                  icon: Icons.report_outlined,
                ),
                if (incidents.isEmpty)
                  const EmptyView(
                    icon: Icons.report_outlined,
                    title: 'No incidents tracked yet',
                  )
                else
                  for (final incident in incidents)
                    _IncidentCard(incident: incident),
                const SizedBox(height: Spacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acknowledge(
    BuildContext context,
    WidgetRef ref,
    String reportId,
  ) async {
    final officialId = ref.read(currentUserProvider)?.id;
    if (officialId == null) return;

    final result = await ref
        .read(incidentVerificationServiceProvider)
        .acknowledgeReport(reportId: reportId, officialId: officialId);

    ref.invalidate(pendingReportsProvider);
    ref.invalidate(incidentsProvider);

    if (!context.mounted) return;
    result.when(
      success: (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report acknowledged'))),
      failure: (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
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
                    incident.type,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                StatusPill(
                  label: status.label,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            if (incident.description.isNotEmpty) ...[
              const SizedBox(height: Spacing.xs),
              Text(incident.description),
            ],
            if (incident.independentSourceCount > 1)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  'Confirmed by ${incident.independentSourceCount} independent sources '
                  '(${(incident.confidence * 100).round()}% confidence)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            if (nextOptions.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.sm,
                children: [
                  for (final next in nextOptions)
                    OutlinedButton(
                      onPressed: () =>
                          _showTransitionDialog(context, ref, next),
                      child: Text(next.label),
                    ),
                ],
              ),
            ],
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
              decoration: const InputDecoration(
                labelText: 'Evidence (optional)',
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
          reason: reasonController.text.trim().isEmpty
              ? null
              : reasonController.text.trim(),
          evidence: evidenceController.text.trim().isEmpty
              ? null
              : evidenceController.text.trim(),
        );

    ref.invalidate(incidentsProvider);

    if (!context.mounted) return;
    result.when(
      success: (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incident moved to "${to.label}"')),
      ),
      failure: (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}
