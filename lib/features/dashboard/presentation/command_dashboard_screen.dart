import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/severity_palette.dart';
import 'package:taarak/features/dashboard/application/dashboard_providers.dart';
import 'package:taarak/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:taarak/features/map/application/demo_map_data_seeder.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/map/domain/habitation_overview.dart';
import 'package:taarak/features/map/presentation/widgets/map_overlay_layers.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_view.dart';
import 'package:taarak/features/risk/presentation/risk_class_color.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';

/// M18: the single pane a Command user reads the current situation from —
/// KPIs, a read-only situational map, and the red zones/vulnerable
/// habitations/capacity gaps/incidents/alerts/responders panels the spec
/// calls out, each already built by an earlier module and just surfaced
/// here together. Tapping an incident is the "drills into incidents" half
/// of the acceptance criterion.
///
/// On a wide viewport this is the app's flagship responsive layout — a
/// two-column situation room instead of a phone-width column stretched
/// across a desktop window, per the UI audit's specific call-out that
/// this screen in particular should take advantage of larger displays.
class CommandDashboardScreen extends ConsumerWidget {
  const CommandDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(dashboardSnapshotProvider);
    final hazardZones = ref.watch(hazardZonesProvider).valueOrNull ?? const [];
    final shelters = ref.watch(sheltersProvider).valueOrNull ?? const [];
    final incidents = ref.watch(incidentsProvider).valueOrNull ?? const [];
    final habitations =
        ref.watch(habitationsOverviewProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Command Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dashboardSnapshotProvider),
          ),
        ],
      ),
      body: snapshotAsync.when(
        loading: () =>
            const LoadingView(message: 'Loading the current situation…'),
        error: (error, _) => ErrorView(
          message: 'Could not load the dashboard: $error',
          onRetry: () => ref.invalidate(dashboardSnapshotProvider),
        ),
        data: (snapshot) => ResponsiveBuilder(
          builder: (context, size) {
            final map = _SituationMap(
              hazardZones: hazardZones,
              shelters: shelters,
              incidents: incidents,
              habitations: habitations,
              height: size == ScreenSize.mobile ? 240 : 360,
            );
            final leftSections = _leftSections(snapshot);
            final rightSections = _rightSections(context, snapshot);

            if (size == ScreenSize.mobile) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _KpiRow(snapshot: snapshot),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'Situation map',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: Spacing.sm),
                    map,
                    const SizedBox(height: Spacing.lg),
                    ...leftSections,
                    ...rightSections,
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KpiRow(snapshot: snapshot),
                  const SizedBox(height: Spacing.lg),
                  Text(
                    'Situation map',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.sm),
                  map,
                  const SizedBox(height: Spacing.lg),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: leftSections,
                          ),
                        ),
                        const SizedBox(width: Spacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: rightSections,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _leftSections(DashboardSnapshot snapshot) => [
    _SectionCard(
      title: 'Red zones',
      count: snapshot.redZoneCount,
      emptyText: 'No high/critical hazard zones currently tracked.',
      children: [
        for (final zone in snapshot.redZones)
          ListTile(
            dense: true,
            leading: Icon(Icons.warning, color: severityColor(zone.severity)),
            title: Text('${zone.hazardType} (${zone.severity})'),
            subtitle: Text('source: ${zone.source}'),
          ),
      ],
    ),
    _SectionCard(
      title: 'Vulnerable habitations',
      count: snapshot.vulnerableHabitationCount,
      emptyText: 'No habitations currently classified high-risk.',
      children: [
        for (final overview in snapshot.vulnerableHabitations)
          ListTile(
            dense: true,
            leading: Icon(
              Icons.location_city,
              color: riskClassColor(
                RiskClass.values.byName(overview.riskAssessment!.riskClass),
              ),
            ),
            title: Text(overview.habitation.name),
            subtitle: Text(
              'risk score ${overview.riskAssessment!.riskScore.toStringAsFixed(2)}',
            ),
          ),
      ],
    ),
    _SectionCard(
      title: 'Capacity gap',
      count: snapshot.totalCapacityGap,
      emptyText: 'No capacity shortfall across assessed habitations.',
      children: snapshot.totalCapacityGap > 0
          ? [
              ListTile(
                dense: true,
                leading: const Icon(Icons.groups),
                title: Text(
                  '${snapshot.totalCapacityGap} people short of safe shelter capacity',
                ),
              ),
            ]
          : const [],
    ),
  ];

  List<Widget> _rightSections(
    BuildContext context,
    DashboardSnapshot snapshot,
  ) => [
    _SectionCard(
      title: 'Incidents',
      count: snapshot.activeIncidentCount,
      emptyText: 'No active incidents.',
      children: [
        for (final incident in snapshot.activeIncidents)
          ListTile(
            dense: true,
            leading: Icon(
              Icons.report,
              color: severityColor(incident.severity),
            ),
            title: Text('${incident.type} — ${incident.status}'),
            subtitle: incident.independentSourceCount > 1
                ? Text('${incident.independentSourceCount} independent sources')
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/dashboard/incidents/${incident.id}'),
          ),
      ],
    ),
    _SectionCard(
      title: 'Alerts',
      count: snapshot.activeAlertCount,
      emptyText: 'No active alerts.',
      children: [
        for (final alert in snapshot.activeAlerts)
          ListTile(
            dense: true,
            leading: Icon(Icons.campaign, color: severityColor(alert.severity)),
            title: Text(alert.title),
            subtitle: Text(alert.zoneLabel),
          ),
      ],
    ),
    _SectionCard(
      title: 'Responders',
      count: snapshot.responderCount,
      emptyText: 'No field responders cached on this device yet.',
      children: const [],
    ),
  ];
}

class _SituationMap extends StatelessWidget {
  final List<LocalHazardZone> hazardZones;
  final List<LocalShelter> shelters;
  final List<LocalIncident> incidents;
  final List<HabitationOverview> habitations;
  final double height;

  const _SituationMap({
    required this.hazardZones,
    required this.shelters,
    required this.incidents,
    required this.habitations,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: TaarakMapView(
          initialCenter: DemoMapDataSeeder.demoCenter,
          overlayLayers: [
            buildHazardZoneLayer(hazardZones),
            buildShelterLayer(shelters),
            buildIncidentLayer(incidents),
            buildHabitationLayer(habitations),
          ],
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final DashboardSnapshot snapshot;

  const _KpiRow({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        _KpiCard(
          label: 'Red zones',
          value: snapshot.redZoneCount,
          color: scheme.error,
        ),
        _KpiCard(
          label: 'Vulnerable habitations',
          value: snapshot.vulnerableHabitationCount,
          color: Colors.orange.shade800,
        ),
        _KpiCard(
          label: 'Capacity gap',
          value: snapshot.totalCapacityGap,
          color: Colors.deepPurple,
        ),
        _KpiCard(
          label: 'Active incidents',
          value: snapshot.activeIncidentCount,
          color: Colors.red.shade700,
        ),
        _KpiCard(
          label: 'Active alerts',
          value: snapshot.activeAlertCount,
          color: Colors.amber.shade800,
        ),
        _KpiCard(
          label: 'Pending sync',
          value: snapshot.pendingSyncCount,
          color: Colors.blueGrey,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final int count;
  final String emptyText;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.count,
    required this.emptyText,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title ($count)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (children.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  emptyText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}
