import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/capacity/application/capacity_assessment_service.dart';
import 'package:taarak/features/capacity/application/capacity_gap_engine.dart';

final capacityGapEngineProvider = Provider<CapacityGapEngine>(
  (ref) => CapacityGapEngine(),
);

final capacityAssessmentServiceProvider = Provider<CapacityAssessmentService>(
  (ref) => CapacityAssessmentService(
    habitationRepository: ref.watch(localHabitationRepositoryProvider),
    hazardZoneRepository: ref.watch(localHazardZoneRepositoryProvider),
    shelterRepository: ref.watch(localShelterRepositoryProvider),
    assessmentRepository: ref.watch(localCapacityAssessmentRepositoryProvider),
    engine: ref.watch(capacityGapEngineProvider),
  ),
);
