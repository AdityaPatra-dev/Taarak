import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/capacity/domain/capacity_gap_result.dart';
import 'package:taarak/features/relocation/application/relocation_priority_engine.dart';
import 'package:taarak/features/relocation/domain/relocation_candidate.dart';
import 'package:taarak/features/relocation/domain/relocation_priority_tier.dart';
import 'package:taarak/features/risk/domain/risk_assessment_result.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';

void main() {
  final engine = RelocationPriorityEngine();
  final now = DateTime.utc(2026, 1, 1);

  LocalHabitation habitation({double? accessQuality}) => LocalHabitation(
    id: 'h1',
    name: 'Test Habitation',
    latitude: 10,
    longitude: 10,
    population: 500,
    accessQuality: accessQuality,
    updatedAt: now,
    version: 1,
  );

  RiskAssessmentResult riskOf(double score) => RiskAssessmentResult(
    habitationId: 'h1',
    hazardExposure: score,
    vulnerabilityIndex: score,
    hazardWeight: 0.6,
    vulnerabilityWeight: 0.4,
    riskScore: score,
    riskClass: classifyRiskScore(score),
    contributingHazardZoneIds: const [],
    modelVersion: riskModelVersion,
    assessedAt: now,
  );

  CapacityGapResult capacityOf({
    required int exposedPopulation,
    required int availableSafeCapacity,
  }) => CapacityGapResult(
    habitationId: 'h1',
    exposedPopulation: exposedPopulation,
    availableSafeCapacity: availableSafeCapacity,
    capacityGap: exposedPopulation - availableSafeCapacity,
    contributingShelters: const [],
    accessibleRadiusMeters: 5000,
    modelVersion: capacityModelVersion,
    assessedAt: now,
  );

  RelocationPlan planWith(List<RelocationCandidate> candidates) =>
      RelocationPlan(
        habitationId: 'h1',
        populationToRelocate: 500,
        rankedCandidates: candidates,
        modelVersion: relocationModelVersion,
        plannedAt: now,
      );

  RelocationCandidate candidateAt(double distanceMeters) => RelocationCandidate(
    shelterId: 's1',
    shelterName: 'Shelter One',
    availableCapacity: 200,
    distanceMeters: distanceMeters,
    distanceScore: 0.5,
    capacityScore: 0.5,
    accessScore: 0.5,
    facilitiesScore: 0.5,
    compositeScore: 0.5,
    reasons: const ['test'],
  );

  test('high risk, large shortfall, no reachable shelter ranks immediate', () {
    final result = engine.assess(
      habitation: habitation(),
      risk: riskOf(0.9),
      capacity: capacityOf(exposedPopulation: 500, availableSafeCapacity: 0),
      relocationPlan: planWith(const []),
      now: now,
    );

    expect(result.priorityTier, RelocationPriorityTier.immediate);
    expect(result.priorityScore, greaterThan(0.75));
    expect(result.nearestSafeShelterId, isNull);
    expect(
      result.reasoning.any((r) => r.contains('No hazard-free shelter')),
      isTrue,
    );
  });

  test('low risk with full capacity and a nearby shelter ranks monitor', () {
    final result = engine.assess(
      habitation: habitation(),
      risk: riskOf(0.05),
      capacity: capacityOf(exposedPopulation: 0, availableSafeCapacity: 500),
      relocationPlan: planWith([candidateAt(500)]),
      now: now,
    );

    expect(result.priorityTier, RelocationPriorityTier.monitor);
    expect(result.capacityGap, lessThanOrEqualTo(0));
  });

  test('a capacity shortfall raises the score even at moderate risk', () {
    final withGap = engine.assess(
      habitation: habitation(),
      risk: riskOf(0.4),
      capacity: capacityOf(exposedPopulation: 400, availableSafeCapacity: 50),
      relocationPlan: planWith([candidateAt(2000)]),
      now: now,
    );
    final withoutGap = engine.assess(
      habitation: habitation(),
      risk: riskOf(0.4),
      capacity: capacityOf(exposedPopulation: 400, availableSafeCapacity: 400),
      relocationPlan: planWith([candidateAt(2000)]),
      now: now,
    );

    expect(withGap.priorityScore, greaterThan(withoutGap.priorityScore));
  });

  test('difficult site access raises the score', () {
    final easy = engine.assess(
      habitation: habitation(accessQuality: 0.1),
      risk: riskOf(0.4),
      capacity: capacityOf(exposedPopulation: 100, availableSafeCapacity: 100),
      relocationPlan: planWith([candidateAt(1000)]),
      now: now,
    );
    final hard = engine.assess(
      habitation: habitation(accessQuality: 0.9),
      risk: riskOf(0.4),
      capacity: capacityOf(exposedPopulation: 100, availableSafeCapacity: 100),
      relocationPlan: planWith([candidateAt(1000)]),
      now: now,
    );

    expect(hard.priorityScore, greaterThan(easy.priorityScore));
  });

  test('hazard zone sources are surfaced in reasoning when provided', () {
    final withSources = engine.assess(
      habitation: habitation(),
      risk: riskOf(0.5),
      capacity: capacityOf(exposedPopulation: 200, availableSafeCapacity: 100),
      relocationPlan: planWith([candidateAt(1000)]),
      hazardZoneSources: const ['official:local-1', 'Geological Survey of India'],
      now: now,
    );
    final withoutSources = engine.assess(
      habitation: habitation(),
      risk: riskOf(0.5),
      capacity: capacityOf(exposedPopulation: 200, availableSafeCapacity: 100),
      relocationPlan: planWith([candidateAt(1000)]),
      now: now,
    );

    expect(
      withSources.reasoning.any(
        (r) => r.contains('official:local-1') && r.contains('Geological Survey of India'),
      ),
      isTrue,
    );
    expect(
      withoutSources.reasoning.any((r) => r.contains('Hazard data source')),
      isFalse,
    );
  });

  test('reasoning is never empty and carries the model version', () {
    final result = engine.assess(
      habitation: habitation(),
      risk: riskOf(0.5),
      capacity: capacityOf(exposedPopulation: 200, availableSafeCapacity: 100),
      relocationPlan: planWith([candidateAt(1000)]),
      now: now,
    );

    expect(result.reasoning, isNotEmpty);
    expect(result.modelVersion, isNotEmpty);
    expect(result.habitationId, 'h1');
    expect(result.habitationName, 'Test Habitation');
  });
}
