/// M09's model version — bump when the gap formula or accessible-radius
/// default changes, same rationale as M07/M08's model versions.
const String capacityModelVersion = '1.0.0';

/// One shelter that counted toward a habitation's available safe capacity:
/// not hazard-exposed itself, within the accessible radius, and with room
/// left.
class ContributingShelter {
  final String shelterId;
  final String shelterName;
  final int availableCapacity;
  final double distanceMeters;

  const ContributingShelter({
    required this.shelterId,
    required this.shelterName,
    required this.availableCapacity,
    required this.distanceMeters,
  });
}

class CapacityGapResult {
  final String habitationId;

  /// The habitation's population, counted only if it's currently inside a
  /// hazard zone — this is exposure, not vulnerability (M08) or risk
  /// (M07); a habitation can be vulnerable without being exposed right now.
  final int exposedPopulation;

  /// Sum of [contributingShelters]' available capacity.
  final int availableSafeCapacity;

  /// exposedPopulation - availableSafeCapacity. Positive means a shortfall.
  final int capacityGap;

  bool get hasSufficientCapacity => capacityGap <= 0;

  final List<ContributingShelter> contributingShelters;
  final double accessibleRadiusMeters;
  final String modelVersion;
  final DateTime assessedAt;

  const CapacityGapResult({
    required this.habitationId,
    required this.exposedPopulation,
    required this.availableSafeCapacity,
    required this.capacityGap,
    required this.contributingShelters,
    required this.accessibleRadiusMeters,
    required this.modelVersion,
    required this.assessedAt,
  });
}
