import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/application/hazard_query_service.dart';

final hazardNormalizerProvider = Provider<HazardNormalizer>(
  (ref) => HazardNormalizer(),
);

final hazardIngestionServiceProvider = Provider<HazardIngestionService>(
  (ref) => HazardIngestionService(
    normalizer: ref.watch(hazardNormalizerProvider),
    repository: ref.watch(localHazardZoneRepositoryProvider),
    syncQueueDao: ref.watch(syncQueueDaoProvider),
    auditLogDao: ref.watch(auditLogDaoProvider),
  ),
);

final hazardQueryServiceProvider = Provider<HazardQueryService>(
  (ref) => HazardQueryService(ref.watch(localHazardZoneRepositoryProvider)),
);
