/// The risk band a score falls into. `red` is the blueprint's "red zone"
/// (section 15's demo script: "Display hazard layer and red/high-risk
/// zone").
enum RiskClass {
  low,
  moderate,
  high,
  red;

  bool get isRedZone => this == RiskClass.red;
}

RiskClass classifyRiskScore(double score) {
  if (score >= 0.75) return RiskClass.red;
  if (score >= 0.5) return RiskClass.high;
  if (score >= 0.25) return RiskClass.moderate;
  return RiskClass.low;
}
