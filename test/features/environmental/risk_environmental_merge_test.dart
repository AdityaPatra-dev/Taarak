import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/environmental/application/risk_environmental_merge.dart';
import 'package:taarak/features/environmental/domain/environmental_risk_adjustment.dart';
import 'package:taarak/features/risk/domain/risk_assessment_result.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1);

  RiskAssessmentResult baseResult({double riskScore = 0.5}) => RiskAssessmentResult(
    habitationId: 'hab-1',
    hazardExposure: 0.6,
    vulnerabilityIndex: 0.4,
    hazardWeight: 0.6,
    vulnerabilityWeight: 0.4,
    riskScore: riskScore,
    riskClass: classifyRiskScore(riskScore),
    contributingHazardZoneIds: const ['zone-1'],
    modelVersion: '1.0.0',
    assessedAt: now,
  );

  LocalEnvironmentalObservation observation() => LocalEnvironmentalObservation(
    id: 'hab-1-rainfall_24h',
    habitationId: 'hab-1',
    parameter: 'rainfall_24h',
    value: 100,
    source: 'IMD',
    observedAt: now,
    fetchedAt: now,
    confidence: 0.8,
    version: 1,
  );

  test('a zero adjustment leaves the base result identical', () {
    final base = baseResult();
    const adjustment = EnvironmentalRiskAdjustment(adjustment: 0, influencing: [], stale: []);

    final merged = mergeEnvironmentalAdjustment(base, adjustment);

    expect(merged.riskScore, base.riskScore);
    expect(merged.riskClass, base.riskClass);
    expect(merged.hazardExposure, base.hazardExposure);
    expect(merged.vulnerabilityIndex, base.vulnerabilityIndex);
    expect(merged.environmentalAdjustment, 0);
    expect(merged.environmentalProvenance, isEmpty);
  });

  test(
    'EXTERNAL DATA CAN INFLUENCE RISK WITH VISIBLE PROVENANCE — the acceptance '
    'criterion: a positive adjustment raises the score and carries provenance',
    () {
      final base = baseResult(riskScore: 0.5);
      final adjustment = EnvironmentalRiskAdjustment(
        adjustment: 0.1,
        influencing: [observation()],
        stale: const [],
      );

      final merged = mergeEnvironmentalAdjustment(base, adjustment);

      expect(merged.riskScore, closeTo(0.6, 0.001));
      expect(merged.environmentalAdjustment, 0.1);
      expect(merged.environmentalProvenance, hasLength(1));
      expect(merged.environmentalProvenance.single.source, 'IMD');
    },
  );

  test('the merged score never exceeds 1.0 even with a near-maximal base and adjustment', () {
    final base = baseResult(riskScore: 0.95);
    const adjustment = EnvironmentalRiskAdjustment(adjustment: 0.15, influencing: [], stale: []);

    final merged = mergeEnvironmentalAdjustment(base, adjustment);

    expect(merged.riskScore, lessThanOrEqualTo(1.0));
  });

  test('riskClass is re-derived from the adjusted score, not left stale', () {
    // A score just below the 'red' threshold, nudged over it.
    final base = baseResult(riskScore: 0.7);
    expect(base.riskClass, isNot(RiskClass.red));

    const adjustment = EnvironmentalRiskAdjustment(adjustment: 0.1, influencing: [], stale: []);
    final merged = mergeEnvironmentalAdjustment(base, adjustment);

    expect(merged.riskClass, RiskClass.red);
  });

  test('contributingHazardZoneIds and modelVersion/assessedAt pass through unchanged', () {
    final base = baseResult();
    const adjustment = EnvironmentalRiskAdjustment(adjustment: 0.05, influencing: [], stale: []);

    final merged = mergeEnvironmentalAdjustment(base, adjustment);

    expect(merged.contributingHazardZoneIds, base.contributingHazardZoneIds);
    expect(merged.modelVersion, base.modelVersion);
    expect(merged.assessedAt, base.assessedAt);
  });
}
