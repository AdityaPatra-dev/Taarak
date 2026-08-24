/// The lifecycle a report/incident moves through under official review:
/// "New→acknowledged→verified/rejected→active→resolved" (blueprint M13),
/// transcribed exactly except the first state, which is named [reported]
/// here since `new` is a reserved word in Dart — its storage value is
/// still the literal string `'new'`.
enum IncidentVerificationStatus {
  reported,
  acknowledged,
  verified,
  rejected,
  active,
  resolved;

  String get storageValue => switch (this) {
    IncidentVerificationStatus.reported => 'new',
    IncidentVerificationStatus.acknowledged => 'acknowledged',
    IncidentVerificationStatus.verified => 'verified',
    IncidentVerificationStatus.rejected => 'rejected',
    IncidentVerificationStatus.active => 'active',
    IncidentVerificationStatus.resolved => 'resolved',
  };

  String get label => switch (this) {
    IncidentVerificationStatus.reported => 'New',
    IncidentVerificationStatus.acknowledged => 'Acknowledged',
    IncidentVerificationStatus.verified => 'Verified',
    IncidentVerificationStatus.rejected => 'Rejected',
    IncidentVerificationStatus.active => 'Active',
    IncidentVerificationStatus.resolved => 'Resolved',
  };

  static IncidentVerificationStatus? fromStorageValue(String value) {
    for (final status in IncidentVerificationStatus.values) {
      if (status.storageValue == value) return status;
    }
    return null;
  }
}

/// Rejected and resolved are terminal — matching the spec's linear
/// "verified/rejected→active→resolved" wording, there's no path back out
/// of either. Reopening a wrongly-rejected report is a manual
/// re-acknowledgement (a fresh entry into the lifecycle), not a
/// transition this map allows.
const Map<IncidentVerificationStatus, Set<IncidentVerificationStatus>>
allowedIncidentStatusTransitions = {
  IncidentVerificationStatus.reported: {IncidentVerificationStatus.acknowledged},
  IncidentVerificationStatus.acknowledged: {
    IncidentVerificationStatus.verified,
    IncidentVerificationStatus.rejected,
  },
  IncidentVerificationStatus.verified: {IncidentVerificationStatus.active},
  IncidentVerificationStatus.rejected: {},
  IncidentVerificationStatus.active: {IncidentVerificationStatus.resolved},
  IncidentVerificationStatus.resolved: {},
};
