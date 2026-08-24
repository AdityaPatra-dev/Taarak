import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/relocation/application/relocation_engine.dart';
import 'package:taarak/features/relocation/application/relocation_planning_service.dart';

final relocationEngineProvider = Provider<RelocationEngine>(
  (ref) => RelocationEngine(),
);

final relocationPlanningServiceProvider = Provider<RelocationPlanningService>(
  (ref) => RelocationPlanningService(
    habitationRepository: ref.watch(localHabitationRepositoryProvider),
    hazardZoneRepository: ref.watch(localHazardZoneRepositoryProvider),
    shelterRepository: ref.watch(localShelterRepositoryProvider),
    planRepository: ref.watch(localRelocationPlanRepositoryProvider),
    engine: ref.watch(relocationEngineProvider),
  ),
);
