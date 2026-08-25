import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/fusion/application/fusion_providers.dart';
import 'package:taarak/features/verification/application/incident_verification_engine.dart';
import 'package:taarak/features/verification/application/incident_verification_service.dart';

final incidentVerificationEngineProvider = Provider<IncidentVerificationEngine>(
  (ref) => IncidentVerificationEngine(),
);

final incidentVerificationServiceProvider = Provider<IncidentVerificationService>(
  (ref) => IncidentVerificationService(
    reportRepository: ref.watch(localIncidentReportRepositoryProvider),
    incidentRepository: ref.watch(localIncidentRepositoryProvider),
    auditLogDao: ref.watch(auditLogDaoProvider),
    engine: ref.watch(incidentVerificationEngineProvider),
    fusionEngine: ref.watch(groundTruthFusionEngineProvider),
    syncQueueDao: ref.watch(syncQueueDaoProvider),
  ),
);

final pendingReportsProvider = FutureProvider.autoDispose((ref) async {
  final result = await ref
      .watch(incidentVerificationServiceProvider)
      .pendingReports();
  return result.dataOrNull ?? const [];
});
