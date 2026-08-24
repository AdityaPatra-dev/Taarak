import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/hazards/application/hazard_providers.dart';
import 'package:taarak/features/map/domain/habitation_with_risk.dart';

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

/// Habitations paired with their latest M07 risk assessment, if any has
/// been run yet — a habitation with no assessment renders unscored rather
/// than being hidden.
final habitationsWithRiskProvider = FutureProvider<List<HabitationWithRisk>>((
  ref,
) async {
  final habitationsResult = await ref
      .watch(localHabitationRepositoryProvider)
      .getAll();
  final habitations = habitationsResult.dataOrNull ?? const [];

  final assessmentsResult = await ref
      .watch(localRiskAssessmentRepositoryProvider)
      .getAll();
  final assessmentsByHabitationId = {
    for (final assessment in assessmentsResult.dataOrNull ?? const [])
      assessment.habitationId: assessment,
  };

  return [
    for (final habitation in habitations)
      HabitationWithRisk(
        habitation: habitation,
        assessment: assessmentsByHabitationId[habitation.id],
      ),
  ];
});
