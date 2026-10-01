import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/admin/application/admin_providers.dart';
import 'package:taarak/features/admin/domain/technical_config.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';
import 'package:taarak/features/dashboard/application/dashboard_providers.dart';
import 'package:taarak/features/environmental/application/environmental_providers.dart';
import 'package:taarak/features/hazard_automation/application/auto_hazard_scan_service.dart';
import 'package:taarak/features/hazards/application/hazard_providers.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/state_admin/application/state_admin_providers.dart';
import 'package:taarak/features/state_admin/domain/app_policy.dart';
import 'package:taarak/features/susceptibility/application/susceptibility_providers.dart';

final autoHazardScanServiceProvider = Provider<AutoHazardScanService>(
  (ref) => AutoHazardScanService(
    habitationRepository: ref.watch(localHabitationRepositoryProvider),
    environmentalDataService: ref.watch(environmentalDataServiceProvider),
    susceptibilityModel: ref.watch(hazardSusceptibilityModelProvider),
    hazardIngestionService: ref.watch(hazardIngestionServiceProvider),
    automationStateRepository: ref.watch(localHazardAutomationStateRepositoryProvider),
    auditLogDao: ref.watch(auditLogDaoProvider),
  ),
);

/// Watched once from [TaarakApp], alongside [syncPollingTriggerProvider] —
/// same "app-lifetime `Timer.periodic`" shape, same best-effort
/// try/catch-and-continue on failure. Gated on
/// [Permission.manageLocalIncidents] (the same permission that already
/// guards manual hazard reporting) so a citizen's device never starts
/// this timer: no wasted Open-Meteo/Gemini traffic, and no risk of a
/// citizen session racing a Local Official's over the same auto-created
/// zone.
final hazardAutomationTriggerProvider = Provider.autoDispose<void>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final effectivePermissions =
      ref.watch(rolePermissionOverridesProvider).valueOrNull?.effectivePermissionsFor(user.role) ??
      user.role.permissions;
  if (!effectivePermissions.contains(Permission.manageLocalIncidents)) return;

  final intervalSeconds =
      ref.watch(technicalConfigProvider).valueOrNull?.hazardAutomationPollIntervalSeconds ??
      TechnicalConfig.defaults.hazardAutomationPollIntervalSeconds;

  _scanAndRefresh(ref);
  final timer = Timer.periodic(
    Duration(seconds: intervalSeconds),
    (_) => _scanAndRefresh(ref),
  );
  ref.onDispose(timer.cancel);
});

Future<void> _scanAndRefresh(Ref ref) async {
  try {
    final policy = ref.read(appPolicyProvider).valueOrNull ?? AppPolicy.defaults;
    await ref.read(autoHazardScanServiceProvider).scanAll(policy: policy);
  } catch (_) {
    // Best-effort background scan — a transient failure (Open-Meteo
    // unreachable, Gemini timeout, offline) shouldn't surface anywhere;
    // the next periodic tick just tries again.
    return;
  }
  ref.invalidate(hazardZonesProvider);
  ref.invalidate(dashboardSnapshotProvider);
}
