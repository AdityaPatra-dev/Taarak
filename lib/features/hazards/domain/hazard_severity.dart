/// Canonical severity band. The normalizer buckets a raw 0.0–1.0 intensity
/// score into one of these — nothing downstream (storage, the M05 map
/// layer, M18's dashboard) should ever see an arbitrary free-text severity
/// string that didn't come from here.
enum HazardSeverity {
  low,
  medium,
  high,
  critical;

  String get storageValue => name;
}
