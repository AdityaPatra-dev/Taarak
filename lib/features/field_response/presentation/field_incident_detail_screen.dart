import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/field_response/application/field_response_providers.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/profile/application/location_status_controller.dart';
import 'package:taarak/features/routing/application/routing_providers.dart';
import 'package:taarak/features/routing/domain/route_candidate.dart';
import 'package:taarak/features/verification/application/verification_providers.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/severity_chip.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// A Field Responder's working view of one assigned incident: navigate to
/// it ([Permission.navigateToIncident]), move it through the verification
/// lifecycle on-site ([Permission.verifyFieldObservation],
/// [Permission.updateFieldStatus] — both are just
/// [IncidentVerificationService.transitionIncident] calls, since M13's
/// existing acknowledged→verified→active→resolved lifecycle already
/// models exactly what a responder does in the field), and submit a
/// damage report ([Permission.submitDamageReport]).
class FieldIncidentDetailScreen extends ConsumerStatefulWidget {
  final String incidentId;

  const FieldIncidentDetailScreen({super.key, required this.incidentId});

  @override
  ConsumerState<FieldIncidentDetailScreen> createState() =>
      _FieldIncidentDetailScreenState();
}

class _FieldIncidentDetailScreenState
    extends ConsumerState<FieldIncidentDetailScreen> {
  bool _isBusy = false;
  final _damageDescriptionController = TextEditingController();
  String _damageSeverity = 'medium';

  @override
  void dispose() {
    _damageDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incidentsAsync = ref.watch(incidentsProvider);
    final damageReportsAsync = ref.watch(
      damageReportsForIncidentProvider(widget.incidentId),
    );

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Assigned Incident'),
      body: incidentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Unable to load incident')),
        data: (incidents) {
          final incident = incidents
              .where((incident) => incident.id == widget.incidentId)
              .firstOrNull;
          if (incident == null) {
            return const Center(child: Text('Incident not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              ContentWidth(
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        SeverityChip(severity: incident.severity),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Status: ${incident.status}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Spacing.md),
                    FilledButton.icon(
                      onPressed: _isBusy ? null : () => _navigate(incident),
                      icon: const Icon(Icons.directions_outlined),
                      label: const Text('Navigate to incident'),
                    ),
                    const SizedBox(height: Spacing.sm),
                    _StatusActionButton(
                      incident: incident,
                      isBusy: _isBusy,
                      onTransition: _transition,
                    ),
                    const SizedBox(height: Spacing.lg),
                    const SectionHeader(
                      title: 'Submit damage report',
                      icon: Icons.assignment_outlined,
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _damageDescriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'What did you find on-site?',
                              ),
                            ),
                            const SizedBox(height: Spacing.sm),
                            Wrap(
                              spacing: Spacing.sm,
                              children: [
                                for (final severity in [
                                  'low',
                                  'medium',
                                  'high',
                                  'critical',
                                ])
                                  ChoiceChip(
                                    label: Text(severity),
                                    selected: _damageSeverity == severity,
                                    onSelected: (_) => setState(
                                      () => _damageSeverity = severity,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: Spacing.md),
                            FilledButton.icon(
                              onPressed: _isBusy
                                  ? null
                                  : () => _submitDamageReport(incident),
                              icon: const Icon(Icons.send_outlined),
                              label: const Text('Submit report'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    const SectionHeader(
                      title: 'Reports submitted so far',
                      icon: Icons.history,
                    ),
                    damageReportsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const Text('Unable to load reports'),
                      data: (reports) => reports.isEmpty
                          ? const Text('No damage reports submitted yet.')
                          : Column(
                              children: [
                                for (final report in reports)
                                  Card(
                                    margin: const EdgeInsets.only(
                                      bottom: Spacing.sm,
                                    ),
                                    child: ListTile(
                                      title: Text(report.description),
                                      trailing: SeverityChip(
                                        severity: report.severity,
                                      ),
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

  Future<void> _navigate(LocalIncident incident) async {
    final messenger = ScaffoldMessenger.of(context);
    final userPoint = ref.read(locationStatusProvider).valueOrNull?.geoTag;
    if (userPoint == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Your location isn\'t available yet.')),
      );
      return;
    }

    setState(() => _isBusy = true);
    final result = await ref
        .read(routingServiceProvider)
        .planRoute(
          origin: LatLng(userPoint.fix.latitude, userPoint.fix.longitude),
          destination: LatLng(incident.latitude, incident.longitude),
        );
    if (!mounted) return;
    setState(() => _isBusy = false);

    switch (result) {
      case Success<RoutePlan>():
        ref.invalidate(routesProvider);
        if (mounted) context.push('/map');
      case Failed<RoutePlan>(:final failure):
        messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  Future<void> _transition(IncidentVerificationStatus to) async {
    final responderId = ref.read(currentUserProvider)?.id;
    if (responderId == null) return;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isBusy = true);
    final result = await ref
        .read(incidentVerificationServiceProvider)
        .transitionIncident(
          incidentId: widget.incidentId,
          to: to,
          officialId: responderId,
        );
    if (!mounted) return;
    setState(() => _isBusy = false);
    ref.invalidate(incidentsProvider);
    ref.invalidate(assignedIncidentsProvider);

    result.when(
      success: (_) => messenger.showSnackBar(
        SnackBar(content: Text('Marked as ${to.label}')),
      ),
      failure: (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _submitDamageReport(LocalIncident incident) async {
    final responderId = ref.read(currentUserProvider)?.id;
    if (responderId == null) return;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isBusy = true);
    final result = await ref
        .read(damageReportServiceProvider)
        .submit(
          incidentId: incident.id,
          responderId: responderId,
          description: _damageDescriptionController.text.trim(),
          severity: _damageSeverity,
        );
    if (!mounted) return;
    setState(() => _isBusy = false);
    ref.invalidate(damageReportsForIncidentProvider(widget.incidentId));

    result.when(
      success: (_) {
        _damageDescriptionController.clear();
        messenger.showSnackBar(
          const SnackBar(content: Text('Damage report submitted')),
        );
      },
      failure: (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}

class _StatusActionButton extends StatelessWidget {
  final LocalIncident incident;
  final bool isBusy;
  final void Function(IncidentVerificationStatus to) onTransition;

  const _StatusActionButton({
    required this.incident,
    required this.isBusy,
    required this.onTransition,
  });

  @override
  Widget build(BuildContext context) {
    final current = IncidentVerificationStatus.fromStorageValue(
      incident.status,
    );
    final (label, icon, next) = switch (current) {
      IncidentVerificationStatus.acknowledged => (
        'Confirm on-site (verify)',
        Icons.fact_check_outlined,
        IncidentVerificationStatus.verified,
      ),
      IncidentVerificationStatus.verified => (
        'Mark active',
        Icons.play_circle_outline,
        IncidentVerificationStatus.active,
      ),
      IncidentVerificationStatus.active => (
        'Mark resolved',
        Icons.check_circle_outline,
        IncidentVerificationStatus.resolved,
      ),
      _ => (null, null, null),
    };

    if (label == null || next == null) return const SizedBox.shrink();

    return OutlinedButton.icon(
      onPressed: isBusy ? null : () => onTransition(next),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
