import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/alerts/application/alert_engine.dart';
import 'package:taarak/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:taarak/features/map/domain/habitation_overview.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';

const _severityRank = {'critical': 4, 'high': 3, 'medium': 2, 'low': 1};

/// M18's deterministic core: turns already-fetched data from every other
/// module into the counts/lists the dashboard renders. No I/O — callers
/// (a Riverpod provider in production, a plain list in tests) supply the
/// raw data; this just filters, sums and sorts it the same way every time.
DashboardSnapshot buildDashboardSnapshot({
  required List<LocalHazardZone> hazardZones,
  required List<HabitationOverview> habitations,
  required List<LocalIncident> incidents,
  required List<LocalAlert> alerts,
  required int pendingSyncCount,
  required int responderCount,
  DateTime? now,
  AlertEngine? alertEngine,
}) {
  final occurredAt = now ?? DateTime.now();
  final engine = alertEngine ?? AlertEngine();

  final redZones = hazardZones
      .where((zone) => zone.severity == 'high' || zone.severity == 'critical')
      .toList();

  final vulnerableHabitations = habitations.where((overview) {
    final riskClass = overview.riskAssessment?.riskClass;
    if (riskClass == null) return false;
    final parsed = RiskClass.values.byName(riskClass);
    return parsed == RiskClass.high || parsed == RiskClass.red;
  }).toList();

  final totalCapacityGap = habitations
      .where((overview) => overview.capacityAssessment?.hasSufficientCapacity == false)
      .fold<int>(0, (sum, overview) => sum + overview.capacityAssessment!.capacityGap);

  final activeIncidents =
      incidents.where((incident) {
          final status = IncidentVerificationStatus.fromStorageValue(incident.status);
          return status != IncidentVerificationStatus.rejected &&
              status != IncidentVerificationStatus.resolved;
        }).toList()
        ..sort((a, b) {
          final rankCompare = (_severityRank[b.severity] ?? 0).compareTo(
            _severityRank[a.severity] ?? 0,
          );
          if (rankCompare != 0) return rankCompare;
          return b.createdAt.compareTo(a.createdAt);
        });

  final activeAlerts = alerts
      .where((alert) => engine.isActive(alert, occurredAt))
      .toList();

  return DashboardSnapshot(
    redZones: redZones,
    vulnerableHabitations: vulnerableHabitations,
    totalCapacityGap: totalCapacityGap,
    activeIncidents: activeIncidents,
    activeAlerts: activeAlerts,
    pendingSyncCount: pendingSyncCount,
    responderCount: responderCount,
  );
}
