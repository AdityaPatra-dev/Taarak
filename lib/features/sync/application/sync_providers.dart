import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/admin/application/admin_providers.dart';
import 'package:taarak/features/admin/domain/technical_config.dart';
import 'package:taarak/features/alerts/application/alert_providers.dart';
import 'package:taarak/features/audit/application/audit_providers.dart';
import 'package:taarak/features/dashboard/application/dashboard_providers.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/sync/application/firestore_sync_transport.dart';
import 'package:taarak/features/sync/application/sync_coordinator_service.dart';
import 'package:taarak/features/sync/application/sync_engine.dart';
import 'package:taarak/features/sync/application/sync_transport.dart';
import 'package:taarak/features/sync/domain/sync_queue_summary.dart';
import 'package:taarak/features/verification/application/verification_providers.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) => SyncEngine());

final syncTransportProvider = Provider<SyncTransport>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useFirebaseAuth) {
    return FirestoreSyncTransport();
  }
  return ApiSyncTransport(ref.watch(apiClientProvider));
});

final syncCoordinatorServiceProvider = Provider<SyncCoordinatorService>(
  (ref) => SyncCoordinatorService(
    syncQueueDao: ref.watch(syncQueueDaoProvider),
    networkInfo: ref.watch(networkInfoProvider),
    transport: ref.watch(syncTransportProvider),
    engine: ref.watch(syncEngineProvider),
    incidentReportRepository: ref.watch(localIncidentReportRepositoryProvider),
    incidentRepository: ref.watch(localIncidentRepositoryProvider),
    hazardZoneRepository: ref.watch(localHazardZoneRepositoryProvider),
    shelterRepository: ref.watch(localShelterRepositoryProvider),
    alertRepository: ref.watch(localAlertRepositoryProvider),
    damageReportRepository: ref.watch(localDamageReportRepositoryProvider),
    resourceRepository: ref.watch(localResourceRepositoryProvider),
    habitationRepository: ref.watch(localHabitationRepositoryProvider),
  ),
);

final pendingSyncCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final result = await ref.watch(syncQueueDaoProvider).listSyncable();
  return result.dataOrNull?.length ?? 0;
});

/// The honest breakdown behind [pendingSyncCountProvider]'s single number
/// — see [SyncQueueSummary] for why a flat count alone can't distinguish
/// "not attempted yet" from "has been failing repeatedly".
final syncQueueSummaryProvider = FutureProvider.autoDispose<SyncQueueSummary>((
  ref,
) async {
  final result = await ref.watch(syncQueueDaoProvider).listSyncable();
  final entries = result.dataOrNull ?? const [];
  return ref.watch(syncEngineProvider).summarize(entries);
});

/// Watched once from the app root ([TaarakApp]) so it lives for the whole
/// app session: fires [SyncCoordinatorService.syncPendingEntries] on every
/// offline→online transition — the acceptance criterion's "after
/// reconnection" half — without any screen needing to know sync exists.
final syncOnReconnectTriggerProvider = Provider.autoDispose<void>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  var wasConnected = true;

  final subscription = networkInfo.onConnectivityChanged.listen((isConnected) {
    if (isConnected && !wasConnected) {
      _syncAndRefresh(ref);
    }
    wasConnected = isConnected;
  });

  ref.onDispose(subscription.cancel);
});

/// Watched once from the app root alongside [syncOnReconnectTriggerProvider]
/// — before this, only the Risk Map screen ever pulled fresh data on its
/// own, so a shelter or hazard zone another device just created stayed
/// invisible on every other screen (Dashboard, Alerts, Verification,
/// Shelters, Audit Log) until someone thought to tap "Sync now" first.
/// Polling centrally here means every screen that already `ref.watch`es
/// its data provider benefits automatically, with no per-screen wiring.
final syncPollingTriggerProvider = Provider.autoDispose<void>((ref) {
  // Watching the admin-configurable interval here (rather than reading it
  // once) means an admin's change on Manage Technical Configuration
  // rebuilds this provider — cancelling and recreating the timer with the
  // new interval — for every running session, not just after a restart.
  final intervalSeconds =
      ref.watch(technicalConfigProvider).valueOrNull?.syncIntervalSeconds ??
      TechnicalConfig.defaults.syncIntervalSeconds;

  // Timer.periodic's first tick only fires after the interval elapses —
  // sync once immediately too, so app launch doesn't wait for the first
  // pull (matching how fast the old per-screen pull used to be).
  _syncAndRefresh(ref);
  final timer = Timer.periodic(
    Duration(seconds: intervalSeconds),
    (_) => _syncAndRefresh(ref),
  );
  ref.onDispose(timer.cancel);
});

Future<void> _syncAndRefresh(Ref ref) async {
  try {
    await ref.read(syncCoordinatorServiceProvider).syncPendingEntries();
  } catch (_) {
    // Best-effort background refresh — a transient failure (network
    // blip, backend not reachable yet) shouldn't surface anywhere; the
    // next periodic tick or reconnect event just tries again.
    return;
  }
  ref.invalidate(hazardZonesProvider);
  ref.invalidate(sheltersProvider);
  ref.invalidate(incidentsProvider);
  ref.invalidate(habitationsOverviewProvider);
  ref.invalidate(routesProvider);
  ref.invalidate(alertHistoryProvider);
  ref.invalidate(activeAlertsForCurrentLocationProvider);
  ref.invalidate(pendingReportsProvider);
  ref.invalidate(auditEventsProvider);
  ref.invalidate(dashboardSnapshotProvider);
}
