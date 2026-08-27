import 'package:taarak/features/relocation/domain/relocation_priority_tier.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';

const String relocationPriorityModelVersion = '1.0.0';

/// M10's answer to the PS's own question — not "how risky is this place"
/// but "which habitations should be prioritized for relocation, and why."
/// Every field a caller (a District/Command or State/Admin screen) would
/// need to both display a ranked list and let an official interrogate a
/// single entry, matching M07/M09/M10's existing "factors, not just a
/// number" convention.
class RelocationPriorityResult {
  final String habitationId;
  final String habitationName;

  final double priorityScore;
  final RelocationPriorityTier priorityTier;

  final double riskScore;
  final RiskClass riskClass;

  final int populationExposed;
  final int shelterCapacity;
  final int capacityGap;

  final String? nearestSafeShelterId;
  final String? nearestSafeShelterName;
  final double? distanceToShelterMeters;

  /// 0.0 (easy to reach/evacuate) – 1.0 (fragile/remote) — the same scale
  /// [LocalHabitations.accessQuality] already uses.
  final double accessibilityDifficulty;

  final String recommendedAction;

  /// Plain-language contributors, in the same spirit as
  /// [RelocationCandidate.reasons] — this is the "why is this habitation
  /// prioritized" an official can inspect.
  final List<String> reasoning;

  final String modelVersion;
  final DateTime assessedAt;

  const RelocationPriorityResult({
    required this.habitationId,
    required this.habitationName,
    required this.priorityScore,
    required this.priorityTier,
    required this.riskScore,
    required this.riskClass,
    required this.populationExposed,
    required this.shelterCapacity,
    required this.capacityGap,
    required this.nearestSafeShelterId,
    required this.nearestSafeShelterName,
    required this.distanceToShelterMeters,
    required this.accessibilityDifficulty,
    required this.recommendedAction,
    required this.reasoning,
    required this.modelVersion,
    required this.assessedAt,
  });
}
