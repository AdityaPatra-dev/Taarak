import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/alerts/application/alert_broadcast_service.dart';
import 'package:taarak/features/alerts/application/alert_engine.dart';

final alertEngineProvider = Provider<AlertEngine>((ref) => AlertEngine());

final alertBroadcastServiceProvider = Provider<AlertBroadcastService>(
  (ref) => AlertBroadcastService(
    alertRepository: ref.watch(localAlertRepositoryProvider),
    hazardZoneRepository: ref.watch(localHazardZoneRepositoryProvider),
    acknowledgementDao: ref.watch(alertAcknowledgementDaoProvider),
    auditLogDao: ref.watch(auditLogDaoProvider),
    geoTagService: ref.watch(geoTagServiceProvider),
    engine: ref.watch(alertEngineProvider),
    syncQueueDao: ref.watch(syncQueueDaoProvider),
  ),
);

final alertHistoryProvider = FutureProvider.autoDispose<List<LocalAlert>>((
  ref,
) async {
  final result = await ref.watch(alertBroadcastServiceProvider).history();
  return result.dataOrNull ?? const [];
});

/// Active alerts affecting the citizen's current location, re-fetched via
/// `ref.invalidate` (e.g. after a location-permission prompt is resolved).
final activeAlertsForCurrentLocationProvider =
    FutureProvider.autoDispose<List<LocalAlert>>((ref) async {
      final result = await ref
          .watch(alertBroadcastServiceProvider)
          .activeAlertsForCurrentLocation();
      return result.dataOrNull ?? const [];
    });
