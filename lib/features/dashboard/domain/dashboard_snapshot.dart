import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/map/domain/habitation_overview.dart';

/// M18's single pane: everything a Command user needs to understand the
/// current situation at a glance, aggregated from every module that
/// already tracks a piece of it (M06 hazards, M07 risk, M09 capacity, M13
/// incidents, M16 alerts, M17 sync) rather than introducing a new source
/// of truth for any of it.
class DashboardSnapshot {
  final List<LocalHazardZone> redZones;
  final List<HabitationOverview> vulnerableHabitations;
  final int totalCapacityGap;
  final List<LocalIncident> activeIncidents;
  final List<LocalAlert> activeAlerts;
  final int pendingSyncCount;
  final int responderCount;

  const DashboardSnapshot({
    required this.redZones,
    required this.vulnerableHabitations,
    required this.totalCapacityGap,
    required this.activeIncidents,
    required this.activeAlerts,
    required this.pendingSyncCount,
    required this.responderCount,
  });

  int get redZoneCount => redZones.length;
  int get vulnerableHabitationCount => vulnerableHabitations.length;
  int get activeIncidentCount => activeIncidents.length;
  int get activeAlertCount => activeAlerts.length;
}
