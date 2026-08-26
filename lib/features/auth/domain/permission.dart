/// Granular capabilities, derived directly from the "Main capabilities"
/// column of the blueprint's role table (section 3). Routes and UI gate on
/// these rather than on role directly, so a screen only has to declare what
/// it requires, not which roles happen to grant it.
enum Permission {
  // Citizen
  viewRiskMap,
  viewAlerts,
  submitIncidentReport,
  sendSos,
  updateSafeStatus,
  viewSheltersRoutes,

  // Field Responder
  viewAssignedIncidents,
  navigateToIncident,
  submitDamageReport,
  updateFieldStatus,
  verifyFieldObservation,

  // Local Official
  verifyReports,
  manageLocalIncidents,
  manageSheltersResources,
  sendBroadcast,

  // District/Command
  monitorZones,
  viewCapacityGaps,
  manageResources,
  manageResponders,
  manageRelocation,

  // State/Admin
  crossDistrictOversight,
  viewReports,
  managePolicyConfiguration,

  // System Admin
  manageAccounts,
  managePermissions,
  manageTechnicalConfiguration,
  reviewAudit,
  moderateContent,
}

extension PermissionLabel on Permission {
  String get label => switch (this) {
    Permission.viewRiskMap => 'View risk map',
    Permission.viewAlerts => 'View alerts',
    Permission.submitIncidentReport => 'Submit incident reports',
    Permission.sendSos => 'Send SOS / need help',
    Permission.updateSafeStatus => 'Update "I am safe" status',
    Permission.viewSheltersRoutes => 'View shelters & evacuation routes',
    Permission.viewAssignedIncidents => 'View assigned incidents',
    Permission.navigateToIncident => 'Navigate to incidents',
    Permission.submitDamageReport => 'Submit damage reports',
    Permission.updateFieldStatus => 'Update field status',
    Permission.verifyFieldObservation => 'Verify field observations',
    Permission.verifyReports => 'Verify citizen reports',
    Permission.manageLocalIncidents => 'Manage local incidents',
    Permission.manageSheltersResources => 'Manage shelters & resources',
    Permission.sendBroadcast => 'Send emergency broadcasts',
    Permission.monitorZones => 'Monitor zones',
    Permission.viewCapacityGaps => 'View capacity gaps',
    Permission.manageResources => 'Manage resources',
    Permission.manageResponders => 'Manage responders',
    Permission.manageRelocation => 'Manage relocation planning',
    Permission.crossDistrictOversight => 'Cross-district oversight',
    Permission.viewReports => 'View reports',
    Permission.managePolicyConfiguration => 'Manage policy & configuration',
    Permission.manageAccounts => 'Manage accounts',
    Permission.managePermissions => 'Manage permissions',
    Permission.manageTechnicalConfiguration => 'Manage technical configuration',
    Permission.reviewAudit => 'Review audit log',
    Permission.moderateContent => 'Remove hazard zones, incidents & alerts',
  };
}
