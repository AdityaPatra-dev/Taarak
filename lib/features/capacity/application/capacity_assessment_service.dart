import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_capacity_assessment_repository.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/gis/point_in_polygon.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/capacity/application/capacity_gap_engine.dart';
import 'package:taarak/features/capacity/domain/capacity_gap_result.dart';

/// Orchestrates M09: determines whether a habitation is currently
/// hazard-exposed (independently of M07 — this doesn't require a risk
/// assessment to have run first), runs [CapacityGapEngine], and persists
/// the result — one current assessment per habitation.
class CapacityAssessmentService {
  final LocalHabitationRepository _habitationRepository;
  final LocalHazardZoneRepository _hazardZoneRepository;
  final LocalShelterRepository _shelterRepository;
  final LocalCapacityAssessmentRepository _assessmentRepository;
  final CapacityGapEngine _engine;

  CapacityAssessmentService({
    required LocalHabitationRepository habitationRepository,
    required LocalHazardZoneRepository hazardZoneRepository,
    required LocalShelterRepository shelterRepository,
    required LocalCapacityAssessmentRepository assessmentRepository,
    CapacityGapEngine? engine,
  }) : _habitationRepository = habitationRepository,
       _hazardZoneRepository = hazardZoneRepository,
       _shelterRepository = shelterRepository,
       _assessmentRepository = assessmentRepository,
       _engine = engine ?? CapacityGapEngine();

  Future<Result<CapacityGapResult>> assessHabitation(
    String habitationId, {
    double accessibleRadiusMeters = CapacityGapEngine.defaultAccessibleRadiusMeters,
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

    final habitationPoint = LatLng(habitation.latitude, habitation.longitude);
    final isExposed = hazardZones.any(
      (zone) => isPointInPolygon(habitationPoint, decodePolygonPoints(zone.geometryJson)),
    );
    final exposedPopulation = isExposed ? habitation.population : 0;

    final assessment = _engine.assess(
      habitation: habitation,
      exposedPopulation: exposedPopulation,
      shelters: shelters,
      hazardZones: hazardZones,
      accessibleRadiusMeters: accessibleRadiusMeters,
      now: now,
    );

    final existing = await _assessmentRepository.getById(habitationId);
    final nextVersion = (existing.dataOrNull?.version ?? 0) + 1;

    final saveResult = await _assessmentRepository.save(
      LocalCapacityAssessment(
        habitationId: habitationId,
        exposedPopulation: assessment.exposedPopulation,
        availableSafeCapacity: assessment.availableSafeCapacity,
        capacityGap: assessment.capacityGap,
        hasSufficientCapacity: assessment.hasSufficientCapacity,
        contributingSheltersJson: jsonEncode([
          for (final shelter in assessment.contributingShelters)
            {
              'shelterId': shelter.shelterId,
              'shelterName': shelter.shelterName,
              'availableCapacity': shelter.availableCapacity,
              'distanceMeters': shelter.distanceMeters,
            },
        ]),
        accessibleRadiusMeters: assessment.accessibleRadiusMeters,
        modelVersion: assessment.modelVersion,
        assessedAt: assessment.assessedAt,
        version: nextVersion,
      ),
    );
    if (saveResult case Failed<LocalCapacityAssessment>(:final failure)) {
      return Result.failure(failure);
    }

    return Result.success(assessment);
  }

  Future<List<CapacityGapResult>> assessAllHabitations({DateTime? now}) async {
    final habitationsResult = await _habitationRepository.getAll();
    final habitations = habitationsResult.dataOrNull ?? const [];

    final results = <CapacityGapResult>[];
    for (final habitation in habitations) {
      final result = await assessHabitation(habitation.id, now: now);
      if (result case Success<CapacityGapResult>(:final data)) {
        results.add(data);
      }
    }
    return results;
  }
}
