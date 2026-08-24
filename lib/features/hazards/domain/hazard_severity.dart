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

  /// Numeric weight used by M07's risk engine to combine severity with
  /// hazard-zone confidence into a single exposure figure. Midpoints of
  /// the normalizer's own bucket thresholds, so a zone right at a bucket
  /// boundary doesn't get an outsized intensity jump.
  double get intensity => switch (this) {
    HazardSeverity.low => 0.25,
    HazardSeverity.medium => 0.5,
    HazardSeverity.high => 0.75,
    HazardSeverity.critical => 1.0,
  };

  static HazardSeverity? fromStorageValue(String value) {
    for (final severity in HazardSeverity.values) {
      if (severity.storageValue == value) return severity;
    }
    return null;
  }
}
