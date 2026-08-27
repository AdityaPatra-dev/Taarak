import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/capacity/application/capacity_providers.dart';
import 'package:taarak/features/relocation/application/relocation_priority_engine.dart';
import 'package:taarak/features/relocation/application/relocation_providers.dart';
import 'package:taarak/features/relocation/application/relocation_priority_service.dart';
import 'package:taarak/features/relocation/domain/relocation_priority_result.dart';
import 'package:taarak/features/risk/application/risk_providers.dart';

final relocationPriorityEngineProvider = Provider<RelocationPriorityEngine>(
  (ref) => RelocationPriorityEngine(),
);

final relocationPriorityServiceProvider = Provider<RelocationPriorityService>(
  (ref) => RelocationPriorityService(
    habitationRepository: ref.watch(localHabitationRepositoryProvider),
    riskAssessmentService: ref.watch(riskAssessmentServiceProvider),
    capacityAssessmentService: ref.watch(capacityAssessmentServiceProvider),
    relocationPlanningService: ref.watch(relocationPlanningServiceProvider),
    engine: ref.watch(relocationPriorityEngineProvider),
  ),
);

/// The priority queue itself — a [FutureProvider] rather than a stream
/// since it's a deliberate recompute-on-open action (re-running M07/M09/
/// M10 for every habitation isn't free), matching how the rest of this
/// app treats assessment refreshes as explicit, not continuous.
final relocationPriorityQueueProvider =
    FutureProvider.autoDispose<List<RelocationPriorityResult>>((ref) async {
      return ref.watch(relocationPriorityServiceProvider).buildQueue();
    });
