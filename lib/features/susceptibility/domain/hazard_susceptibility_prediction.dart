/// One model's estimate of how prone a location is to a hazard occurring
/// at all — independent of whether an official has already registered a
/// [LocalHazardZone] there. Deliberately a different question from
/// [RiskEngine]'s: risk asks "given known hazards, how dangerous is this
/// habitation"; susceptibility asks "how likely is a hazard here in the
/// first place," the way GSI's own landslide susceptibility mapping does.
///
/// [featureContributions] exists so a prediction is never just a number —
/// matching every other model in this app (M07/M08/M09/M10's own "factor
/// explanation" convention), a susceptibility score should be able to say
/// *why* (e.g. `{'slope': 0.41, 'rainfall_72h': 0.33, ...}`), which also
/// happens to be the concrete answer to "what if the model is wrong" —
/// the contributing factors are inspectable, not hidden inside a model.
class HazardSusceptibilityPrediction {
  final double score;
  final String modelName;
  final String modelVersion;
  final Map<String, double> featureContributions;
  final double confidence;
  final DateTime predictedAt;

  /// A short plain-English explanation of this prediction, if one exists.
  /// Never set by a deterministic model — only an enrichment layer (e.g.
  /// a Gemini-backed decorator) populates this, and only ever as
  /// commentary on [score]/[featureContributions], never a replacement
  /// for them: the enrichment layer is not allowed to change the numbers
  /// above, only explain them. Null means no such enrichment ran.
  final String? rationale;

  const HazardSusceptibilityPrediction({
    required this.score,
    required this.modelName,
    required this.modelVersion,
    required this.featureContributions,
    required this.confidence,
    required this.predictedAt,
    this.rationale,
  });

  HazardSusceptibilityPrediction withRationale(String rationale) =>
      HazardSusceptibilityPrediction(
        score: score,
        modelName: modelName,
        modelVersion: modelVersion,
        featureContributions: featureContributions,
        confidence: confidence,
        predictedAt: predictedAt,
        rationale: rationale,
      );
}
