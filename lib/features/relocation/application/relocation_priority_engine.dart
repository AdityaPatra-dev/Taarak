import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/capacity/domain/capacity_gap_result.dart';
import 'package:taarak/features/relocation/domain/relocation_candidate.dart';
import 'package:taarak/features/relocation/domain/relocation_priority_result.dart';
import 'package:taarak/features/relocation/domain/relocation_priority_tier.dart';
import 'package:taarak/features/risk/domain/risk_assessment_result.dart';

/// Answers the PS's own question directly: "which habitations should be
/// prioritized for relocation?" — a deterministic combination of three
/// assessments that already exist (M07 risk, M09 capacity, M10 relocation
/// candidates), not a new source of truth. Pure — no I/O — so the same
/// three inputs always produce the same result, matching every other
/// engine in this app.
///
/// Weights, and why: risk (0.4) is the foundational "is this place
/// dangerous" signal M07 already computes from hazard + vulnerability.
/// Capacity shortfall (0.3) is weighted almost as heavily because a
/// habitation can be moderately at-risk but urgent anyway if nowhere
/// nearby can actually take the population — this is the PS's own
/// "carrying capacity" criterion, not an afterthought. Evacuation
/// distance (0.2) and site accessibility (0.1) modulate urgency by how
/// hard the move itself would be — real, but secondary to whether the
/// place is dangerous and whether anywhere safe exists to go.
class RelocationPriorityEngine {
  static const double riskWeight = 0.4;
  static const double capacityWeight = 0.3;
  static const double distanceWeight = 0.2;
  static const double accessibilityWeight = 0.1;

  /// Matches [RelocationEngine.defaultMaxRelevantDistanceMeters] so a
  /// "far" shelter is scored the same way here as it is when ranking
  /// destination candidates for one habitation.
  static const double defaultMaxRelevantDistanceMeters = 15000;

  RelocationPriorityResult assess({
    required LocalHabitation habitation,
    required RiskAssessmentResult risk,
    required CapacityGapResult capacity,
    required RelocationPlan relocationPlan,
    double maxRelevantDistanceMeters = defaultMaxRelevantDistanceMeters,
    DateTime? now,
  }) {
    final bestCandidate = relocationPlan.rankedCandidates.isEmpty
        ? null
        : relocationPlan.rankedCandidates.first;

    // No reachable safe capacity at all is the worst possible outcome for
    // this factor — scored as maximally difficult rather than left
    // undefined, so a habitation with nowhere to go doesn't silently rank
    // *lower* than one with merely a distant option.
    final distanceDifficulty = bestCandidate == null
        ? 1.0
        : (bestCandidate.distanceMeters / maxRelevantDistanceMeters).clamp(
            0.0,
            1.0,
          );

    final capacityGapRatio = capacity.exposedPopulation <= 0
        ? 0.0
        : (capacity.capacityGap / capacity.exposedPopulation).clamp(0.0, 1.0);

    final accessibilityDifficulty = (habitation.accessQuality ?? 0.5).clamp(
      0.0,
      1.0,
    );

    final priorityScore =
        (riskWeight * risk.riskScore +
                capacityWeight * capacityGapRatio +
                distanceWeight * distanceDifficulty +
                accessibilityWeight * accessibilityDifficulty)
            .clamp(0.0, 1.0);

    final priorityTier = classifyPriorityScore(priorityScore);

    return RelocationPriorityResult(
      habitationId: habitation.id,
      habitationName: habitation.name,
      priorityScore: priorityScore,
      priorityTier: priorityTier,
      riskScore: risk.riskScore,
      riskClass: risk.riskClass,
      populationExposed: capacity.exposedPopulation,
      shelterCapacity: capacity.availableSafeCapacity,
      capacityGap: capacity.capacityGap,
      nearestSafeShelterId: bestCandidate?.shelterId,
      nearestSafeShelterName: bestCandidate?.shelterName,
      distanceToShelterMeters: bestCandidate?.distanceMeters,
      accessibilityDifficulty: accessibilityDifficulty,
      recommendedAction: priorityTier.recommendedAction,
      reasoning: _buildReasoning(
        risk: risk,
        capacity: capacity,
        bestCandidate: bestCandidate,
        accessibilityDifficulty: accessibilityDifficulty,
        priorityTier: priorityTier,
      ),
      modelVersion: relocationPriorityModelVersion,
      assessedAt: now ?? DateTime.now(),
    );
  }

  List<String> _buildReasoning({
    required RiskAssessmentResult risk,
    required CapacityGapResult capacity,
    required RelocationCandidate? bestCandidate,
    required double accessibilityDifficulty,
    required RelocationPriorityTier priorityTier,
  }) {
    final reasons = <String>[
      '${risk.riskClass.name[0].toUpperCase()}${risk.riskClass.name.substring(1)} '
          'risk (score ${(risk.riskScore * 100).round()}/100) from '
          '${(risk.hazardExposure * 100).round()}% hazard exposure and '
          '${(risk.vulnerabilityIndex * 100).round()}% vulnerability.',
    ];

    if (capacity.exposedPopulation > 0) {
      reasons.add(
        capacity.hasSufficientCapacity
            ? '${capacity.exposedPopulation} people exposed; nearby shelters '
                  'can currently absorb them.'
            : '${capacity.exposedPopulation} people exposed against only '
                  '${capacity.availableSafeCapacity} available safe capacity '
                  '— a shortfall of ${capacity.capacityGap}.',
      );
    } else {
      reasons.add('Not currently inside a mapped hazard zone.');
    }

    if (bestCandidate == null) {
      reasons.add(
        'No hazard-free shelter with available capacity was found within '
        'range — the most severe finding this assessment can report.',
      );
    } else {
      reasons.add(
        'Nearest viable shelter: ${bestCandidate.shelterName} '
        '(${(bestCandidate.distanceMeters / 1000).toStringAsFixed(1)} km).',
      );
    }

    if (accessibilityDifficulty >= 0.7) {
      reasons.add('Site access is rated difficult, complicating evacuation.');
    }

    reasons.add('Recommended: ${priorityTier.recommendedAction}');
    return reasons;
  }
}
