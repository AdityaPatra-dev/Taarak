/// What a citizen submission is about. The four hazard/issue values plus
/// two special-case citizen actions the blueprint calls out by name
/// ("SOS and I Am Safe") — all share the same underlying storage
/// ([LocalIncidentReports]) since they're all GPS+time-stamped ground
/// observations from a citizen, just with very different UI friction.
enum CitizenReportType {
  landslide,
  flood,
  roadBlockage,
  other,
  sos,
  safeStatus;

  String get storageValue => switch (this) {
    CitizenReportType.landslide => 'landslide',
    CitizenReportType.flood => 'flood',
    CitizenReportType.roadBlockage => 'road_blockage',
    CitizenReportType.other => 'other',
    CitizenReportType.sos => 'sos',
    CitizenReportType.safeStatus => 'safe_status',
  };

  String get label => switch (this) {
    CitizenReportType.landslide => 'Landslide',
    CitizenReportType.flood => 'Flood',
    CitizenReportType.roadBlockage => 'Blocked road',
    CitizenReportType.other => 'Other hazard/issue',
    CitizenReportType.sos => 'SOS / Need help',
    CitizenReportType.safeStatus => 'I am safe',
  };

  /// The four types a citizen picks from in the full "Report Incident"
  /// form — sos/safeStatus have their own dedicated, lower-friction flows.
  bool get isHazardIssue => switch (this) {
    CitizenReportType.landslide ||
    CitizenReportType.flood ||
    CitizenReportType.roadBlockage ||
    CitizenReportType.other => true,
    CitizenReportType.sos || CitizenReportType.safeStatus => false,
  };

  static CitizenReportType? fromStorageValue(String value) {
    for (final type in CitizenReportType.values) {
      if (type.storageValue == value) return type;
    }
    return null;
  }
}
