import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/sync/application/firestore_sync_transport.dart';
import 'package:taarak/features/sync/application/sync_coordinator_service.dart';
import 'package:taarak/features/sync/application/sync_engine.dart';
import 'package:taarak/features/sync/application/sync_transport.dart';
import 'package:taarak/features/sync/domain/sync_queue_summary.dart';

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
      ref.read(syncCoordinatorServiceProvider).syncPendingEntries();
    }
    wasConnected = isConnected;
  });

  ref.onDispose(subscription.cancel);
});
