import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_relocation_plan_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/core/gis/hazard_exposure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/relocation/application/relocation_engine.dart';
import 'package:taarak/features/relocation/domain/relocation_candidate.dart';

/// Orchestrates M10: works out how many people need relocating (same
/// hazard-exposure determination M09 uses, so both agree on who's
/// currently at risk), runs [RelocationEngine], and persists the ranked
/// plan — one current plan per habitation.
class RelocationPlanningService {
  final LocalHabitationRepository _habitationRepository;
  final LocalHazardZoneRepository _hazardZoneRepository;
  final LocalShelterRepository _shelterRepository;
  final LocalRelocationPlanRepository _planRepository;
  final RelocationEngine _engine;

  RelocationPlanningService({
    required LocalHabitationRepository habitationRepository,
    required LocalHazardZoneRepository hazardZoneRepository,
    required LocalShelterRepository shelterRepository,
    required LocalRelocationPlanRepository planRepository,
    RelocationEngine? engine,
  }) : _habitationRepository = habitationRepository,
       _hazardZoneRepository = hazardZoneRepository,
       _shelterRepository = shelterRepository,
       _planRepository = planRepository,
       _engine = engine ?? RelocationEngine();

  /// [populationOverride] lets a caller plan for a hypothetical relocation
  /// need (e.g. "what if we had to move 300 people") even when the
  /// habitation isn't currently hazard-exposed; omitted, it defaults to
  /// the same exposed-population figure M09 computes.
  Future<Result<RelocationPlan>> planForHabitation(
    String habitationId, {
    int? populationOverride,
    double maxRelevantDistanceMeters =
        RelocationEngine.defaultMaxRelevantDistanceMeters,
    DateTime? now,
  }) async {
    final habitationResult = await _habitationRepository.getById(habitationId);
    if (habitationResult case Failed<LocalHabitation>(:final failure)) {
      return Result.failure(failure);
    }
    final habitation = habitationResult.dataOrNull!;

    final hazardZonesResult = await _hazardZoneRepository.getAll();
    final hazardZones = hazardZonesResult.dataOrNull ?? const [];

    final sheltersResult = await _shelterRepository.getAll();
    final shelters = sheltersResult.dataOrNull ?? const [];

    final populationToRelocate = populationOverride ??
        (isPointHazardExposed(
                  LatLng(habitation.latitude, habitation.longitude),
                  hazardZones,
                )
            ? habitation.population
            : 0);

    final plan = _engine.plan(
      habitation: habitation,
      populationToRelocate: populationToRelocate,
      shelters: shelters,
      hazardZones: hazardZones,
      maxRelevantDistanceMeters: maxRelevantDistanceMeters,
      now: now,
    );

    final existing = await _planRepository.getById(habitationId);
    final nextVersion = (existing.dataOrNull?.version ?? 0) + 1;

    final saveResult = await _planRepository.save(
      LocalRelocationPlan(
        habitationId: habitationId,
        populationToRelocate: plan.populationToRelocate,
        rankedCandidatesJson: jsonEncode([
          for (final candidate in plan.rankedCandidates)
            {
              'shelterId': candidate.shelterId,
              'shelterName': candidate.shelterName,
              'availableCapacity': candidate.availableCapacity,
              'distanceMeters': candidate.distanceMeters,
              'distanceScore': candidate.distanceScore,
              'capacityScore': candidate.capacityScore,
              'accessScore': candidate.accessScore,
              'facilitiesScore': candidate.facilitiesScore,
              'compositeScore': candidate.compositeScore,
              'reasons': candidate.reasons,
            },
        ]),
        modelVersion: plan.modelVersion,
        plannedAt: plan.plannedAt,
        version: nextVersion,
      ),
    );
    if (saveResult case Failed<LocalRelocationPlan>(:final failure)) {
      return Result.failure(failure);
    }

    return Result.success(plan);
  }

  Future<List<RelocationPlan>> planForAllHabitations({DateTime? now}) async {
    final habitationsResult = await _habitationRepository.getAll();
    final habitations = habitationsResult.dataOrNull ?? const [];

    final results = <RelocationPlan>[];
    for (final habitation in habitations) {
      final result = await planForHabitation(habitation.id, now: now);
      if (result case Success<RelocationPlan>(:final data)) {
        results.add(data);
      }
    }
    return results;
  }
}
