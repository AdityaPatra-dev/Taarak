import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/shelters/application/shelter_management_service.dart';

final shelterManagementServiceProvider = Provider<ShelterManagementService>(
  (ref) => ShelterManagementService(
    shelterRepository: ref.watch(localShelterRepositoryProvider),
    auditLogDao: ref.watch(auditLogDaoProvider),
    syncQueueDao: ref.watch(syncQueueDaoProvider),
  ),
);
