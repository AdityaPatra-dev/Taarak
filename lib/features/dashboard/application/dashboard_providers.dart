import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/alerts/application/alert_providers.dart';
import 'package:taarak/features/dashboard/application/dashboard_aggregator.dart';
import 'package:taarak/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/sync/application/sync_providers.dart';

/// The I/O half of M18: reads every already-existing module's data (no new
/// source of truth is introduced here) and hands it to the pure
/// [buildDashboardSnapshot] aggregator.
final dashboardSnapshotProvider = FutureProvider.autoDispose<DashboardSnapshot>((
  ref,
) async {
  final hazardZones = await ref.watch(hazardZonesProvider.future);
  final habitations = await ref.watch(habitationsOverviewProvider.future);
  final incidents = await ref.watch(incidentsProvider.future);
  final alertHistoryResult = await ref
      .watch(alertBroadcastServiceProvider)
      .history();
  final pendingSyncCount = await ref.watch(pendingSyncCountProvider.future);

  final usersResult = await ref.watch(localUserRepositoryProvider).getAll();
  final responderCount = (usersResult.dataOrNull ?? const [])
      .where((user) => user.role == 'fieldResponder')
      .length;

  return buildDashboardSnapshot(
    hazardZones: hazardZones,
    habitations: habitations,
    incidents: incidents,
    alerts: alertHistoryResult.dataOrNull ?? const [],
    pendingSyncCount: pendingSyncCount,
    responderCount: responderCount,
  );
});
