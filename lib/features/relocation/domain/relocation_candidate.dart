/// M10's model version — bump when the ranking formula or weights change,
/// same rationale as M07/M08/M09's model versions.
const String relocationModelVersion = '1.0.0';

/// One safe zone (shelter) ranked as a relocation destination for a
/// habitation, with the per-factor scores and plain-language reasons that
/// justify its rank — the "ranked candidates with reasons" acceptance
/// criterion.
class RelocationCandidate {
  final String shelterId;
  final String shelterName;
  final int availableCapacity;
  final double distanceMeters;

  final double distanceScore;
  final double capacityScore;
  final double accessScore;
  final double facilitiesScore;

  /// Weighted combination of the four factor scores above — higher is a
  /// better candidate.
  final double compositeScore;

  final List<String> reasons;

  const RelocationCandidate({
    required this.shelterId,
    required this.shelterName,
    required this.availableCapacity,
    required this.distanceMeters,
    required this.distanceScore,
    required this.capacityScore,
    required this.accessScore,
    required this.facilitiesScore,
    required this.compositeScore,
    required this.reasons,
  });
}

/// A habitation's ranked relocation candidates, best first. Zones that
/// fail the hard gates (hazard-exposed, or no capacity left) never appear
/// here at all rather than being ranked last — an unsafe or full shelter
/// isn't a "worse candidate", it isn't a candidate.
class RelocationPlan {
  final String habitationId;
  final int populationToRelocate;
  final List<RelocationCandidate> rankedCandidates;
  final String modelVersion;
  final DateTime plannedAt;

  const RelocationPlan({
    required this.habitationId,
    required this.populationToRelocate,
    required this.rankedCandidates,
    required this.modelVersion,
    required this.plannedAt,
  });
}
