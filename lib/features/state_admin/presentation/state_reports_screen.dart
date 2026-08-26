import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/features/state_admin/application/state_admin_providers.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// State/Admin's ([Permission.viewReports]) statewide statistics —
/// counts/trends over incidents, reports, and alerts.
class StateReportsScreen extends ConsumerWidget {
  const StateReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(stateReportSummaryProvider);

    return Scaffold(
      appBar: TaarakAppBar(
        title: 'State Reports',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(stateReportSummaryProvider),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorView(
          message: 'Unable to load statistics',
          onRetry: () => ref.invalidate(stateReportSummaryProvider),
        ),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            ContentWidth(
              child: Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  _StatCard(
                    label: 'Total incidents',
                    value: summary.totalIncidents,
                  ),
                  _StatCard(
                    label: 'Active incidents',
                    value: summary.activeIncidents,
                  ),
                  _StatCard(
                    label: 'Resolved incidents',
                    value: summary.resolvedIncidents,
                  ),
                  _StatCard(
                    label: 'Citizen reports',
                    value: summary.totalReports,
                  ),
                  _StatCard(
                    label: 'Unresolved reports',
                    value: summary.unresolvedReports,
                  ),
                  _StatCard(
                    label: 'Alerts issued',
                    value: summary.totalAlertsIssued,
                  ),
                  _StatCard(
                    label: 'Active alerts',
                    value: summary.activeAlerts,
                  ),
                  _StatCard(
                    label: 'Shelters tracked',
                    value: summary.totalShelters,
                  ),
                  _StatCard(
                    label: 'Hazard zones',
                    value: summary.totalHazardZones,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: Spacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
