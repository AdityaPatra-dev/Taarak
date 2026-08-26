import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/alerts/application/alert_providers.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/state_admin/application/state_report_aggregator.dart';
import 'package:taarak/features/state_admin/data/app_policy_data_source.dart';
import 'package:taarak/features/state_admin/domain/app_policy.dart';
import 'package:taarak/features/state_admin/domain/state_report_summary.dart';

final appPolicyDataSourceProvider = Provider<AppPolicyDataSource>(
  (ref) => AppPolicyDataSource(),
);

final appPolicyProvider = FutureProvider.autoDispose<AppPolicy>((ref) async {
  final result = await ref.watch(appPolicyDataSourceProvider).read();
  return result.dataOrNull ?? AppPolicy.defaults;
});

final stateReportSummaryProvider =
    FutureProvider.autoDispose<StateReportSummary>((ref) async {
      final incidents = await ref.watch(incidentsProvider.future);
      final reportsResult = await ref
          .watch(localIncidentReportRepositoryProvider)
          .getAll();
      final alerts = await ref.watch(alertHistoryProvider.future);
      final shelters = await ref.watch(sheltersProvider.future);
      final hazardZones = await ref.watch(hazardZonesProvider.future);

      return buildStateReportSummary(
        incidents: incidents,
        reports: reportsResult.dataOrNull ?? const [],
        alerts: alerts,
        shelters: shelters,
        hazardZones: hazardZones,
      );
    });
