import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/alerts/application/alert_providers.dart';

/// A System Admin's moderation queues — deliberately the same repositories
/// every other screen reads, so a removal here (an actual delete — see
/// [HazardIngestionService.remove]/[IncidentVerificationService.
/// removeIncident]/[AlertBroadcastService.deleteAlert]) always matches
/// exactly what's currently visible elsewhere in the app.
final moderatableHazardZonesProvider =
    FutureProvider.autoDispose<List<LocalHazardZone>>((ref) async {
      final result = await ref.watch(localHazardZoneRepositoryProvider).getAll();
      final zones = result.dataOrNull ?? const <LocalHazardZone>[];
      return zones.toList()
        ..sort((a, b) => b.observedAt.compareTo(a.observedAt));
    });

final moderatableIncidentsProvider =
    FutureProvider.autoDispose<List<LocalIncident>>((ref) async {
      final result = await ref.watch(localIncidentRepositoryProvider).getAll();
      final incidents = result.dataOrNull ?? const <LocalIncident>[];
      return incidents.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

/// Every alert, cancelled or not — a moderator deleting bad data has no
/// reason to be blocked from also purging one a Local Official already
/// cancelled, unlike every other screen that only cares about active ones.
final moderatableAlertsProvider =
    FutureProvider.autoDispose<List<LocalAlert>>((ref) async {
      final result = await ref.watch(alertBroadcastServiceProvider).history();
      return result.dataOrNull ?? const <LocalAlert>[];
    });
