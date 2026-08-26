import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/state_admin/domain/state_report_summary.dart';

/// Pure — no I/O — same shape as [buildDashboardSnapshot]: tallies data
/// every other module already computed rather than introducing a new
/// source of truth.
StateReportSummary buildStateReportSummary({
  required List<LocalIncident> incidents,
  required List<LocalIncidentReport> reports,
  required List<LocalAlert> alerts,
  required List<LocalShelter> shelters,
  required List<LocalHazardZone> hazardZones,
  DateTime? now,
}) {
  final currentTime = now ?? DateTime.now();

  return StateReportSummary(
    totalIncidents: incidents.length,
    activeIncidents: incidents
        .where((incident) => incident.status == 'active')
        .length,
    resolvedIncidents: incidents
        .where((incident) => incident.status == 'resolved')
        .length,
    totalReports: reports.length,
    unresolvedReports: reports
        .where((report) => report.incidentId == null)
        .length,
    totalAlertsIssued: alerts.length,
    activeAlerts: alerts
        .where(
          (alert) =>
              alert.cancelledAt == null &&
              currentTime.isBefore(alert.validUntil),
        )
        .length,
    totalShelters: shelters.length,
    totalHazardZones: hazardZones.length,
  );
}
