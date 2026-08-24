import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/fusion/domain/ground_truth_match.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';

const _distance = Distance();

/// M14's deterministic core: does a new report describe something already
/// tracked, or something new. Two reports are considered the same
/// real-world event when they're the same type, within
/// [clusterRadiusMeters] of each other, and within [clusterTimeWindow] —
/// matching "cluster nearby/time-similar reports" from the spec. Rejected
/// and resolved incidents are never candidates: a closed incident isn't
/// still absorbing new reports.
class GroundTruthFusionEngine {
  static const double clusterRadiusMeters = 500;
  static const Duration clusterTimeWindow = Duration(hours: 6);

  GroundTruthMatch evaluate({
    required LocalIncidentReport newReport,
    required List<LocalIncident> existingIncidents,
    required Map<String, List<LocalIncidentReport>> reportsByIncidentId,
  }) {
    final reportPoint = LatLng(newReport.latitude, newReport.longitude);

    LocalIncident? closestMatch;
    double closestDistance = double.infinity;

    for (final incident in existingIncidents) {
      if (incident.type != newReport.reportType) continue;

      final status = IncidentVerificationStatus.fromStorageValue(incident.status);
      if (status == IncidentVerificationStatus.rejected ||
          status == IncidentVerificationStatus.resolved) {
        continue;
      }

      final timeDelta = newReport.createdAt.difference(incident.createdAt).abs();
      if (timeDelta > clusterTimeWindow) continue;

      final distanceMeters = _distance.as(
        LengthUnit.Meter,
        reportPoint,
        LatLng(incident.latitude, incident.longitude),
      );
      if (distanceMeters > clusterRadiusMeters) continue;

      if (distanceMeters < closestDistance) {
        closestDistance = distanceMeters;
        closestMatch = incident;
      }
    }

    if (closestMatch == null) {
      return GroundTruthMatch(
        matchedIncidentId: null,
        independentSourceCount: 1,
        confidence: _confidenceFor(1),
        severity: newReport.severity,
      );
    }

    final existingReporterIds = (reportsByIncidentId[closestMatch.id] ?? const [])
        .map((report) => report.reporterId)
        .whereType<String>()
        .toSet();
    if (newReport.reporterId != null) {
      existingReporterIds.add(newReport.reporterId!);
    }
    // A report from an anonymous (null-reporterId) source still counts as
    // at least one source even though it can't be deduplicated by id.
    final sourceCount = existingReporterIds.isEmpty ? 1 : existingReporterIds.length;

    return GroundTruthMatch(
      matchedIncidentId: closestMatch.id,
      independentSourceCount: sourceCount,
      confidence: _confidenceFor(sourceCount),
      severity: _worseSeverity(closestMatch.severity, newReport.severity),
    );
  }

  /// 1 source stays at the same neutral baseline M06 uses for
  /// unconfigured confidence; each additional independent source raises
  /// it, capped short of certainty since these are still unverified
  /// citizen accounts.
  double _confidenceFor(int sourceCount) =>
      (0.5 + 0.1 * (sourceCount - 1)).clamp(0.0, 0.95);

  static const _severityRank = {
    'critical': 4,
    'high': 3,
    'medium': 2,
    'low': 1,
  };

  String _worseSeverity(String a, String b) {
    final rankA = _severityRank[a] ?? 0;
    final rankB = _severityRank[b] ?? 0;
    return rankB > rankA ? b : a;
  }
}
