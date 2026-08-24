import 'package:taarak/features/risk/domain/risk_class.dart';

/// M07's model version. Bump this whenever the scoring formula or weights
/// change, so a stored assessment stays attributable to the logic that
/// produced it — the "model version" the blueprint calls out explicitly.
const String riskModelVersion = '1.0.0';

/// The engine's output: not just a score, but the factors that produced
/// it — what the acceptance criterion calls a "factor explanation".
class RiskAssessmentResult {
  final String habitationId;

  /// How exposed the habitation is to current hazard zones (0.0–1.0):
  /// the strongest (severity × confidence) among zones it falls inside,
  /// or 0.0 if it's inside none.
  final double hazardExposure;

  /// The habitation's non-hazard vulnerability (0.0–1.0), from
  /// [[VulnerabilityProvider]].
  final double vulnerabilityIndex;

  final double hazardWeight;
  final double vulnerabilityWeight;

  final double riskScore;
  final RiskClass riskClass;

  /// Ids of the hazard zones that drove [hazardExposure] — empty if the
  /// habitation isn't inside any.
  final List<String> contributingHazardZoneIds;

  final String modelVersion;
  final DateTime assessedAt;

  const RiskAssessmentResult({
    required this.habitationId,
    required this.hazardExposure,
    required this.vulnerabilityIndex,
    required this.hazardWeight,
    required this.vulnerabilityWeight,
    required this.riskScore,
    required this.riskClass,
    required this.contributingHazardZoneIds,
    required this.modelVersion,
    required this.assessedAt,
  });
}
