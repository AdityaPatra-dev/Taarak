/// State/Admin's ([Permission.viewReports]) aggregate counts — trends
/// over incidents, reports, and alerts, without needing a new backend:
/// every number here already exists in an already-synced local table,
/// this just tallies them.
class StateReportSummary {
  final int totalIncidents;
  final int activeIncidents;
  final int resolvedIncidents;
  final int totalReports;
  final int unresolvedReports;
  final int totalAlertsIssued;
  final int activeAlerts;
  final int totalShelters;
  final int totalHazardZones;

  const StateReportSummary({
    required this.totalIncidents,
    required this.activeIncidents,
    required this.resolvedIncidents,
    required this.totalReports,
    required this.unresolvedReports,
    required this.totalAlertsIssued,
    required this.activeAlerts,
    required this.totalShelters,
    required this.totalHazardZones,
  });
}
