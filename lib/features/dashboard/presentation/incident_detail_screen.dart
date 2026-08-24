import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/gis/severity_palette.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/verification/application/verification_providers.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Detail')),
      body: incidentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load this incident: $error')),
        data: (incident) {
          if (incident == null) {
            return const Center(child: Text('Incident not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: 12, color: severityColor(incident.severity)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      incident.type,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Status: ${incident.status} · Severity: ${incident.severity}'),
              const SizedBox(height: 8),
              if (incident.description.isNotEmpty) Text(incident.description),
              const SizedBox(height: 8),
              Text(
                'Location: ${incident.latitude.toStringAsFixed(4)}, '
                '${incident.longitude.toStringAsFixed(4)}',
              ),
              const SizedBox(height: 8),
              if (incident.independentSourceCount > 1)
                Text(
                  'Confirmed by ${incident.independentSourceCount} independent sources '
                  '(${(incident.confidence * 100).round()}% confidence)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 24),
              Text('Audit trail', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              auditTrailAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text('Could not load the audit trail: $error'),
                data: (trail) => trail.isEmpty
                    ? const Text('No audit entries yet.')
                    : Column(
                        children: [
                          for (final event in trail)
                            Card(
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
          );
        },
      ),
    );
  }
}

final _incidentProvider = FutureProvider.autoDispose.family((ref, String id) async {
  final result = await ref.watch(localIncidentRepositoryProvider).getById(id);
  return result.dataOrNull;
});

final _auditTrailProvider = FutureProvider.autoDispose.family((ref, String id) async {
  final result = await ref.watch(incidentVerificationServiceProvider).auditTrailFor(id);
  return result.dataOrNull ?? const [];
});
