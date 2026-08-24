import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/hazards/application/hazard_providers.dart';
import 'package:taarak/features/map/domain/habitation_overview.dart';

/// Map layers read straight from the M03 local cache — the same data a
/// future sync pass (M17) will keep filled from the backend. A cache read
/// failure degrades to an empty layer (logged by the repository) rather
/// than crashing the map; there's nothing more useful to show either way.
final hazardZonesProvider = FutureProvider<List<LocalHazardZone>>((ref) async {
  final result = await ref.watch(hazardQueryServiceProvider).query();
  return result.dataOrNull ?? const [];
});

final sheltersProvider = FutureProvider<List<LocalShelter>>((ref) async {
  final result = await ref.watch(localShelterRepositoryProvider).getAll();
  return result.dataOrNull ?? const [];
});

final incidentsProvider = FutureProvider<List<LocalIncident>>((ref) async {
  final result = await ref.watch(localIncidentRepositoryProvider).getAll();
  return result.dataOrNull ?? const [];
});

final routesProvider = FutureProvider<List<LocalRoute>>((ref) async {
  final result = await ref.watch(localRouteRepositoryProvider).getAll();
  return result.dataOrNull ?? const [];
});

/// Habitations paired with their latest M07 risk and M09 capacity
/// assessments, if any have been run yet — a habitation with no
/// assessment renders unscored rather than being hidden.
final habitationsOverviewProvider = FutureProvider<List<HabitationOverview>>((
  ref,
) async {
  final habitationsResult = await ref
      .watch(localHabitationRepositoryProvider)
      .getAll();
  final habitations = habitationsResult.dataOrNull ?? const [];

  final riskAssessmentsResult = await ref
      .watch(localRiskAssessmentRepositoryProvider)
      .getAll();
  final riskAssessmentsByHabitationId = {
    for (final assessment in riskAssessmentsResult.dataOrNull ?? const [])
      assessment.habitationId: assessment,
  };

  final capacityAssessmentsResult = await ref
      .watch(localCapacityAssessmentRepositoryProvider)
      .getAll();
  final capacityAssessmentsByHabitationId = {
    for (final assessment in capacityAssessmentsResult.dataOrNull ?? const [])
      assessment.habitationId: assessment,
  };

  final relocationPlansResult = await ref
      .watch(localRelocationPlanRepositoryProvider)
      .getAll();
  final relocationPlansByHabitationId = {
    for (final plan in relocationPlansResult.dataOrNull ?? const [])
      plan.habitationId: plan,
  };

  return [
    for (final habitation in habitations)
      HabitationOverview(
        habitation: habitation,
        riskAssessment: riskAssessmentsByHabitationId[habitation.id],
        capacityAssessment: capacityAssessmentsByHabitationId[habitation.id],
        relocationPlan: relocationPlansByHabitationId[habitation.id],
      ),
  ];
});
