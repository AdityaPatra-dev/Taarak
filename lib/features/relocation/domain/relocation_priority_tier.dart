/// The time-horizon action bucket a habitation's [RelocationPriorityResult]
/// falls into — distinct from [RiskClass]: risk alone says "how dangerous
/// is this place," priority says "how soon do we need to act, given
/// danger, capacity, and how hard it'd actually be to move these people."
/// A critical-risk habitation next to an under-full shelter can rank
/// [immediate]; the same risk with no reachable capacity anywhere still
/// ranks [immediate] but for a different, visible reason (see
/// [RelocationPriorityResult.reasoning]).
enum RelocationPriorityTier {
  immediate,
  shortTerm,
  mediumTerm,
  monitor;

  String get label => switch (this) {
    RelocationPriorityTier.immediate => 'Immediate',
    RelocationPriorityTier.shortTerm => 'Short-term',
    RelocationPriorityTier.mediumTerm => 'Medium-term',
    RelocationPriorityTier.monitor => 'Monitor',
  };

  String get recommendedAction => switch (this) {
    RelocationPriorityTier.immediate =>
      'Begin relocation planning now — coordinate with District/Command.',
    RelocationPriorityTier.shortTerm =>
      'Plan relocation within the current season; confirm shelter capacity.',
    RelocationPriorityTier.mediumTerm =>
      'Schedule a capacity/vulnerability review; no immediate action required.',
    RelocationPriorityTier.monitor =>
      'No action required — continue routine monitoring.',
  };
}

RelocationPriorityTier classifyPriorityScore(double score) {
  if (score >= 0.75) return RelocationPriorityTier.immediate;
  if (score >= 0.55) return RelocationPriorityTier.shortTerm;
  if (score >= 0.35) return RelocationPriorityTier.mediumTerm;
  return RelocationPriorityTier.monitor;
}
