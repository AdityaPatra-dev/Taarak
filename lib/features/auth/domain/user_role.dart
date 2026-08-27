import 'package:taarak/features/auth/domain/permission.dart';

/// The six roles from blueprint section 3.
enum UserRole {
  citizen,
  fieldResponder,
  localOfficial,
  districtCommand,
  stateAdmin,
  systemAdmin,
}

/// Role → permission mapping, transcribed 1:1 from the "Main capabilities"
/// column of blueprint section 3. No inherited/hierarchical access is
/// assumed — a District/Command account does not implicitly get Local
/// Official capabilities, since the blueprint's restrictions column scopes
/// each role independently.
const Map<UserRole, Set<Permission>> rolePermissions = {
  UserRole.citizen: {
    Permission.viewRiskMap,
    Permission.viewAlerts,
    Permission.submitIncidentReport,
    Permission.sendSos,
    Permission.updateSafeStatus,
    Permission.viewSheltersRoutes,
  },
  UserRole.fieldResponder: {
    Permission.viewAssignedIncidents,
    Permission.navigateToIncident,
    Permission.submitDamageReport,
    Permission.updateFieldStatus,
    Permission.verifyFieldObservation,
    // navigateToIncident's only implementation is planning a route and
    // pushing to /map to show it — without this, that push itself got
    // bounced to /unauthorized. Same fix, same reason, as localOfficial
    // below.
    Permission.viewRiskMap,
  },
  UserRole.localOfficial: {
    Permission.verifyReports,
    Permission.manageLocalIncidents,
    Permission.manageSheltersResources,
    Permission.sendBroadcast,
    Permission.manageHabitations,
    // Without this, an official reporting hazard zones/broadcasting to
    // them, verifying reports, or managing shelters had no way to see the
    // very map those actions place things on.
    Permission.viewRiskMap,
  },
  UserRole.districtCommand: {
    Permission.monitorZones,
    Permission.viewCapacityGaps,
    Permission.manageResources,
    Permission.manageResponders,
    Permission.manageRelocation,
    Permission.manageHabitations,
  },
  UserRole.stateAdmin: {
    Permission.crossDistrictOversight,
    Permission.viewReports,
    Permission.managePolicyConfiguration,
    Permission.manageHabitations,
    // A state authority needs the same relocation-priority view a
    // district does, scoped wider — the PS's own named audience
    // ("provides actionable insights to State Disaster Management
    // Authorities") is exactly this permission's reason to exist.
    Permission.manageRelocation,
  },
  UserRole.systemAdmin: {
    Permission.manageAccounts,
    Permission.managePermissions,
    Permission.manageTechnicalConfiguration,
    Permission.reviewAudit,
    Permission.moderateContent,
  },
};

extension UserRoleX on UserRole {
  String get label => switch (this) {
    UserRole.citizen => 'Citizen',
    UserRole.fieldResponder => 'Field Responder',
    UserRole.localOfficial => 'Local Official',
    UserRole.districtCommand => 'District/Command',
    UserRole.stateAdmin => 'State/Admin',
    UserRole.systemAdmin => 'System Admin',
  };

  Set<Permission> get permissions => rolePermissions[this] ?? const {};

  bool can(Permission permission) => permissions.contains(permission);
}
