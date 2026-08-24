import 'package:taarak/features/environmental/domain/environmental_risk_adjustment.dart';
import 'package:taarak/features/risk/domain/risk_assessment_result.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';

/// Combines M07's base assessment with M24's environmental adjustment
/// into one result: `hazardExposure`/`vulnerabilityIndex` are left
/// exactly as [[RiskEngine]] computed them (M24 is additive, not a
/// replacement for the hazard/vulnerability model), `riskScore` is
/// nudged and `riskClass` re-derived from the adjusted score.
RiskAssessmentResult mergeEnvironmentalAdjustment(
  RiskAssessmentResult base,
  EnvironmentalRiskAdjustment environmental,
) {
  final adjustedScore = (base.riskScore + environmental.adjustment).clamp(0.0, 1.0);

  return RiskAssessmentResult(
    habitationId: base.habitationId,
    hazardExposure: base.hazardExposure,
    vulnerabilityIndex: base.vulnerabilityIndex,
    hazardWeight: base.hazardWeight,
    vulnerabilityWeight: base.vulnerabilityWeight,
    riskScore: adjustedScore,
    riskClass: classifyRiskScore(adjustedScore),
    contributingHazardZoneIds: base.contributingHazardZoneIds,
    modelVersion: base.modelVersion,
    assessedAt: base.assessedAt,
    environmentalAdjustment: environmental.adjustment,
    environmentalProvenance: environmental.influencing,
  );
}
