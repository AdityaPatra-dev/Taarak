/// How stale a hazard observation is, relative to when it was recorded.
/// Ordered fresh < aging < stale so callers can compare with `.index`.
enum HazardFreshness { fresh, aging, stale }

HazardFreshness classifyFreshness(Duration age) {
  if (age <= const Duration(hours: 6)) return HazardFreshness.fresh;
  if (age <= const Duration(hours: 48)) return HazardFreshness.aging;
  return HazardFreshness.stale;
}

/// How much a freshness band should discount an otherwise-trusted source's
/// confidence. Stale data is never presented as certain, even from a
/// normally reliable source.
double freshnessConfidenceFactor(Duration age) => switch (classifyFreshness(age)) {
  HazardFreshness.fresh => 1.0,
  HazardFreshness.aging => 0.7,
  HazardFreshness.stale => 0.4,
};
