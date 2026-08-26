import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/field_response/application/field_response_providers.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/severity_chip.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// A Field Responder's ([Permission.viewAssignedIncidents]) worklist —
/// the front door for the whole role, since every other Field Responder
/// action (navigate, submit damage report, update status, verify) starts
/// from a specific assigned incident.
class AssignedIncidentsScreen extends ConsumerWidget {
  const AssignedIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(assignedIncidentsProvider);

    return Scaffold(
      appBar: const TaarakAppBar(title: 'My Assigned Incidents'),
      body: incidentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: 'Unable to load assigned incidents',
          onRetry: () => ref.invalidate(assignedIncidentsProvider),
        ),
        data: (incidents) {
          if (incidents.isEmpty) {
            return const EmptyView(
              icon: Icons.assignment_turned_in_outlined,
              title: 'No incidents assigned to you',
              message:
                  'District/Command assigns incidents from Manage Responders.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(assignedIncidentsProvider),
            child: ListView(
              padding: const EdgeInsets.all(Spacing.md),
              children: [
                ContentWidth(
                  child: Column(
                    children: [
                      for (final incident in incidents)
                        _IncidentCard(incident: incident),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final LocalIncident incident;

  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: ListTile(
        onTap: () => context.push('/field/incidents/${incident.id}'),
        leading: const Icon(Icons.warning_amber_outlined),
        title: Text(
          incident.description.isEmpty ? incident.type : incident.description,
        ),
        subtitle: Text(incident.status),
        trailing: SeverityChip(severity: incident.severity),
      ),
    );
  }
}
