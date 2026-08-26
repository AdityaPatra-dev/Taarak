import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/field_response/application/damage_report_service.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';

final damageReportServiceProvider = Provider<DamageReportService>(
  (ref) => DamageReportService(
    repository: ref.watch(localDamageReportRepositoryProvider),
    syncQueueDao: ref.watch(syncQueueDaoProvider),
  ),
);

/// The Field Responder's own worklist — every incident assigned to the
/// current account, sourced from the same [incidentsProvider] read
/// everyone else's screens already use, just filtered client-side.
final assignedIncidentsProvider = FutureProvider.autoDispose<
  List<LocalIncident>
>((ref) async {
  final currentUserId = ref.watch(currentUserProvider)?.id;
  if (currentUserId == null) return const [];
  final incidents = await ref.watch(incidentsProvider.future);
  return incidents
      .where((incident) => incident.assignedResponderId == currentUserId)
      .toList();
});

final damageReportsForIncidentProvider = FutureProvider.autoDispose
    .family<List<LocalDamageReport>, String>((ref, incidentId) async {
      final result = await ref
          .watch(damageReportServiceProvider)
          .forIncident(incidentId);
      return result.dataOrNull ?? const [];
    });
