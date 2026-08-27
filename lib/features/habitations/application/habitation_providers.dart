import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/habitations/application/habitation_registration_service.dart';

final habitationRegistrationServiceProvider =
    Provider<HabitationRegistrationService>(
      (ref) => HabitationRegistrationService(
        repository: ref.watch(localHabitationRepositoryProvider),
        syncQueueDao: ref.watch(syncQueueDaoProvider),
        auditLogDao: ref.watch(auditLogDaoProvider),
      ),
    );

final habitationsProvider = FutureProvider.autoDispose<List<LocalHabitation>>((
  ref,
) async {
  final result = await ref
      .watch(habitationRegistrationServiceProvider)
      .listAll();
  return result.dataOrNull ?? const [];
});
