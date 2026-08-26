import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/admin/domain/admin_user_summary.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/command/application/command_providers.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/verification/application/verification_providers.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/severity_chip.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// District/Command's ([Permission.manageResponders]) assignment screen —
/// every tracked incident, with a Field Responder picker per row. The
/// counterpart to a Field Responder's "My Assigned Incidents" list: this
/// is where an assignment actually gets created.
class ManageRespondersScreen extends ConsumerWidget {
  const ManageRespondersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(incidentsProvider);
    final respondersAsync = ref.watch(fieldRespondersProvider);

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Manage Responders'),
      body: incidentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const ErrorView(message: 'Unable to load incidents'),
        data: (incidents) {
          if (incidents.isEmpty) {
            return const EmptyView(
              icon: Icons.groups_outlined,
              title: 'No incidents to assign yet',
            );
          }
          final responders = respondersAsync.valueOrNull ?? const [];
          return ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              ContentWidth(
                child: Column(
                  children: [
                    if (responders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: Spacing.md),
                        child: Text(
                          'No Field Responder accounts exist yet — promote '
                          'one from Manage Accounts first.',
                        ),
                      ),
                    for (final incident in incidents)
                      _IncidentAssignmentRow(
                        incident: incident,
                        responders: responders,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IncidentAssignmentRow extends ConsumerWidget {
  final LocalIncident incident;
  final List<AdminUserSummary> responders;

  const _IncidentAssignmentRow({
    required this.incident,
    required this.responders,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedId = incident.assignedResponderId;
    final assignedExists = responders.any((r) => r.uid == assignedId);

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          incident.description.isEmpty
                              ? incident.type
                              : incident.description,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      SeverityChip(severity: incident.severity),
                    ],
                  ),
                  Text(
                    'Status: ${incident.status}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            DropdownButton<String?>(
              value: assignedExists ? assignedId : null,
              hint: const Text('Unassigned'),
              onChanged: (responderId) =>
                  _assign(context, ref, responderId),
              items: [
                const DropdownMenuItem(value: null, child: Text('Unassigned')),
                for (final responder in responders)
                  DropdownMenuItem(
                    value: responder.uid,
                    child: Text(responder.name),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assign(
    BuildContext context,
    WidgetRef ref,
    String? responderId,
  ) async {
    final officialId = ref.read(currentUserProvider)?.id;
    if (officialId == null) return;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(incidentVerificationServiceProvider)
        .assignResponder(
          incidentId: incident.id,
          responderId: responderId,
          officialId: officialId,
        );
    ref.invalidate(incidentsProvider);

    result.when(
      success: (_) => messenger.showSnackBar(
        SnackBar(
          content: Text(
            responderId == null ? 'Unassigned' : 'Incident assigned',
          ),
        ),
      ),
      failure: (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}
