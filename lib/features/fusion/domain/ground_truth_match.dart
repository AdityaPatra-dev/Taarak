/// The engine's decision for a new report: fold it into an existing
/// incident (deduplication) or start a new one — plus the recomputed
/// source count/confidence/severity that decision implies.
class GroundTruthMatch {
  /// Null means "start a new incident"; non-null is the existing
  /// incident's id this report should be merged into.
  final String? matchedIncidentId;

  /// Distinct reporters (deduplicated by reporter id) behind this
  /// incident, including the new report — "count independent sources".
  final int independentSourceCount;

  final double confidence;

  /// The incident's severity after this report — the worse of the
  /// existing incident's severity and the new report's, so a corroborating
  /// account never quietly downgrades an already-reported severity.
  final String severity;

  const GroundTruthMatch({
    required this.matchedIncidentId,
    required this.independentSourceCount,
    required this.confidence,
    required this.severity,
  });

  bool get isNewIncident => matchedIncidentId == null;
}
