import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/command/application/command_providers.dart';
import 'package:taarak/features/field_response/application/field_response_providers.dart';
import 'package:taarak/features/verification/application/verification_providers.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/severity_chip.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// The "drills into incidents" half of M18's acceptance criterion: a
/// read-oriented detail view for a Command user — full record plus the
/// M13 audit trail — distinct from Verification's action-oriented cards,
/// which exist to let an official change the incident's state rather than
/// just understand it.
class IncidentDetailScreen extends ConsumerWidget {
  final String incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentAsync = ref.watch(_incidentProvider(incidentId));
    final auditTrailAsync = ref.watch(_auditTrailProvider(incidentId));
    final respondersAsync = ref.watch(fieldRespondersProvider);
    final damageReportsAsync = ref.watch(
      damageReportsForIncidentProvider(incidentId),
    );

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Incident Detail'),
      body: incidentAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: 'Could not load this incident: $error',
          onRetry: () => ref.invalidate(_incidentProvider(incidentId)),
        ),
        data: (incident) {
          if (incident == null) {
            return const EmptyView(
              icon: Icons.search_off,
              title: 'Incident not found',
            );
          }
          return ListView(
            children: [
              ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                ),
                                const SizedBox(width: Spacing.sm),
                                SeverityChip(severity: incident.severity),
                              ],
                            ),
                            const SizedBox(height: Spacing.xs),
                            StatusPill(
                              label: incident.status,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            if (incident.description.isNotEmpty) ...[
                              const SizedBox(height: Spacing.sm),
                              Text(incident.description),
                            ],
                            const SizedBox(height: Spacing.sm),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${incident.latitude.toStringAsFixed(4)}, '
                                  '${incident.longitude.toStringAsFixed(4)}',
                                ),
                              ],
                            ),
                            if (incident.independentSourceCount > 1) ...[
                              const SizedBox(height: Spacing.sm),
                              Text(
                                'Confirmed by ${incident.independentSourceCount} independent sources '
                                '(${(incident.confidence * 100).round()}% confidence)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            const SizedBox(height: Spacing.sm),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_pin_circle_outlined,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  incident.assignedResponderId == null
                                      ? 'No responder assigned yet'
                                      : 'Assigned to: ${respondersAsync.valueOrNull?.where((r) => r.uid == incident.assignedResponderId).firstOrNull?.name ?? incident.assignedResponderId}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    const SectionHeader(
                      title: 'Damage reports',
                      icon: Icons.assignment_outlined,
                    ),
                    damageReportsAsync.when(
                      loading: () => const LoadingView(),
                      error: (error, _) => ErrorView(
                        message: 'Could not load damage reports: $error',
                      ),
                      data: (reports) => reports.isEmpty
                          ? const EmptyView(
                              icon: Icons.assignment_outlined,
                              title: 'No damage reports submitted yet',
                            )
                          : Column(
                              children: [
                                for (final report in reports)
                                  Card(
                                    margin: const EdgeInsets.only(
                                      bottom: Spacing.xs,
                                    ),
                                    child: ListTile(
                                      title: Text(report.description),
                                      subtitle: Text(
                                        'By ${report.responderId} · '
                                        '${report.submittedAt.toLocal()}',
                                      ),
                                      trailing: SeverityChip(
                                        severity: report.severity,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    const SectionHeader(
                      title: 'Audit trail',
                      icon: Icons.history,
                    ),
                    auditTrailAsync.when(
                      loading: () => const LoadingView(),
                      error: (error, _) => ErrorView(
                        message: 'Could not load the audit trail: $error',
                      ),
                      data: (trail) => trail.isEmpty
                          ? const EmptyView(
                              icon: Icons.history,
                              title: 'No audit entries yet',
                            )
                          : Column(
                              children: [
                                for (final event in trail)
                                  Card(
                                    margin: const EdgeInsets.only(
                                      bottom: Spacing.xs,
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      title: Text(event.action),
                                      subtitle: Text(
                                        '${event.actorId} · ${event.occurredAt.toLocal()}'
                                        '${event.reason == null ? '' : '\n${event.reason}'}',
                                      ),
                                      isThreeLine: event.reason != null,
                                    ),
                                  ),
                              ],
                            ),
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

final _incidentProvider = FutureProvider.autoDispose.family((
  ref,
  String id,
) async {
  final result = await ref.watch(localIncidentRepositoryProvider).getById(id);
  return result.dataOrNull;
});

final _auditTrailProvider = FutureProvider.autoDispose.family((
  ref,
  String id,
) async {
  final result = await ref
      .watch(incidentVerificationServiceProvider)
      .auditTrailFor(id);
  return result.dataOrNull ?? const [];
});
