import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/gis/point_in_polygon.dart';
import 'package:taarak/features/hazards/domain/hazard_severity.dart';
import 'package:taarak/features/risk/domain/risk_assessment_result.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';

/// M07's deterministic core: combines hazard exposure and vulnerability
/// into a single risk score. Pure — no I/O, no clock reads unless a
/// caller supplies [now] — so the same inputs always produce the same
/// [RiskAssessmentResult], which is the module's whole acceptance bar.
class RiskEngine {
  /// Risk = hazardWeight × hazardExposure + vulnerabilityWeight ×
  /// vulnerabilityIndex. Weighted toward hazard because a hazard event is
  /// what actually triggers a disaster; vulnerability modulates how bad
  /// its consequences are, which M09's carrying-capacity math addresses
  /// more directly than a risk score can.
  static const double hazardWeight = 0.6;
  static const double vulnerabilityWeight = 0.4;

  RiskAssessmentResult assess({
    required LocalHabitation habitation,
    required List<LocalHazardZone> hazardZones,
    required double vulnerabilityIndex,
    DateTime? now,
  }) {
    final habitationPoint = LatLng(habitation.latitude, habitation.longitude);
    final clampedVulnerability = vulnerabilityIndex.clamp(0.0, 1.0);

    var hazardExposure = 0.0;
    final contributingZoneIds = <String>[];

    for (final zone in hazardZones) {
      if (!isPointInPolygon(habitationPoint, decodePolygonPoints(zone.geometryJson))) {
        continue;
      }
      final severity = HazardSeverity.fromStorageValue(zone.severity);
      if (severity == null) continue;

      final zoneIntensity = severity.intensity * zone.confidence.clamp(0.0, 1.0);
      contributingZoneIds.add(zone.id);
      // Worst-hazard-wins across overlapping zones, rather than summing —
      // avoids inflating risk purely because multiple hazard types
      // happen to coincide on the same habitation.
      if (zoneIntensity > hazardExposure) hazardExposure = zoneIntensity;
    }

    final riskScore = (hazardWeight * hazardExposure + vulnerabilityWeight * clampedVulnerability)
        .clamp(0.0, 1.0);

    return RiskAssessmentResult(
      habitationId: habitation.id,
      hazardExposure: hazardExposure,
      vulnerabilityIndex: clampedVulnerability,
      hazardWeight: hazardWeight,
      vulnerabilityWeight: vulnerabilityWeight,
      riskScore: riskScore,
      riskClass: classifyRiskScore(riskScore),
      contributingHazardZoneIds: contributingZoneIds,
      modelVersion: riskModelVersion,
      assessedAt: now ?? DateTime.now(),
    );
  }
}
