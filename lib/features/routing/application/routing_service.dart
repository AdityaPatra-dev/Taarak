import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_incident_repository.dart';
import 'package:taarak/core/database/repositories/local_relocation_plan_repository.dart';
import 'package:taarak/core/database/repositories/local_route_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/map/domain/road_blockage.dart';
import 'package:taarak/features/routing/application/risk_aware_routing_engine.dart';
import 'package:taarak/features/routing/domain/route_candidate.dart';

/// A route's cache key is derived from its endpoints (rounded to ~1m) so
/// repeated queries for the same origin/destination hit the same
/// [LocalRoutes] row instead of the caller having to invent an id.
String routeCacheKey(LatLng origin, LatLng destination) =>
    '${origin.latitude.toStringAsFixed(5)},${origin.longitude.toStringAsFixed(5)}'
    '->${destination.latitude.toStringAsFixed(5)},${destination.longitude.toStringAsFixed(5)}';

/// Orchestrates M11: runs [RiskAwareRoutingEngine] against the current
/// hazard zones and blocked-road incidents, and caches the recommended
/// route — the "cached last-known routes" the acceptance criterion calls
/// out, read straight from [LocalRouteRepository] when a fresh plan isn't
/// needed.
class RoutingService {
  final LocalHazardZoneRepository _hazardZoneRepository;
  final LocalIncidentRepository _incidentRepository;
  final LocalRouteRepository _routeRepository;
  final LocalHabitationRepository _habitationRepository;
  final LocalRelocationPlanRepository _relocationPlanRepository;
  final LocalShelterRepository _shelterRepository;
  final RiskAwareRoutingEngine _engine;

  RoutingService({
    required LocalHazardZoneRepository hazardZoneRepository,
    required LocalIncidentRepository incidentRepository,
    required LocalRouteRepository routeRepository,
    required LocalHabitationRepository habitationRepository,
    required LocalRelocationPlanRepository relocationPlanRepository,
    required LocalShelterRepository shelterRepository,
    RiskAwareRoutingEngine? engine,
  }) : _hazardZoneRepository = hazardZoneRepository,
       _incidentRepository = incidentRepository,
       _routeRepository = routeRepository,
       _habitationRepository = habitationRepository,
       _relocationPlanRepository = relocationPlanRepository,
       _shelterRepository = shelterRepository,
       _engine = engine ?? RiskAwareRoutingEngine();

  Future<Result<RoutePlan>> planRoute({
    required LatLng origin,
    required LatLng destination,
    DateTime? now,
  }) async {
    final hazardZonesResult = await _hazardZoneRepository.getAll();
    final hazardZones = hazardZonesResult.dataOrNull ?? const [];

    final incidentsResult = await _incidentRepository.getAll();
    final blockedRoadIncidents = (incidentsResult.dataOrNull ?? const [])
        .where((incident) => incident.type == roadBlockageIncidentType)
        .toList();

    final plan = _engine.planRoute(
      origin: origin,
      destination: destination,
      hazardZones: hazardZones,
      blockedRoadIncidents: blockedRoadIncidents,
      now: now,
    );

    final cacheKey = routeCacheKey(origin, destination);
    final existing = await _routeRepository.getById(cacheKey);
    final nextVersion = (existing.dataOrNull?.version ?? 0) + 1;

    await _routeRepository.save(
      LocalRoute(
        id: cacheKey,
        originLat: origin.latitude,
        originLng: origin.longitude,
        destLat: destination.latitude,
        destLng: destination.longitude,
        polylineJson: encodePolygonPoints(plan.primaryRoute.points),
        distanceMeters: plan.primaryRoute.distanceMeters,
        etaSeconds: plan.primaryRoute.etaSeconds,
        isSafe: plan.primaryRoute.isSafe,
        cachedAt: plan.plannedAt,
        version: nextVersion,
      ),
    );

    return Result.success(plan);
  }

  /// The last route cached for this origin/destination pair, without
  /// recomputing — for offline display or when a fresh plan isn't needed.
  Future<Result<LocalRoute>> getCachedRoute({
    required LatLng origin,
    required LatLng destination,
  }) => _routeRepository.getById(routeCacheKey(origin, destination));

  /// Routes a habitation to the top candidate from its current M10
  /// relocation plan. Fails with a [ValidationFailure] if no relocation
  /// plan (or no viable candidate) exists yet — run M10 first.
  Future<Result<RoutePlan>> planEvacuationRoute(
    String habitationId, {
    DateTime? now,
  }) async {
    final habitationResult = await _habitationRepository.getById(habitationId);
    if (habitationResult case Failed<LocalHabitation>(:final failure)) {
      return Result.failure(failure);
    }
    final habitation = habitationResult.dataOrNull!;

    final relocationPlanResult = await _relocationPlanRepository.getById(
      habitationId,
    );
    if (relocationPlanResult case Failed<LocalRelocationPlan>(:final failure)) {
      return Result.failure(failure);
    }
    final relocationPlan = relocationPlanResult.dataOrNull!;

    final candidates = jsonDecode(relocationPlan.rankedCandidatesJson) as List;
    if (candidates.isEmpty) {
      return const Result.failure(
        ValidationFailure('No relocation candidate available to route to'),
      );
    }
    final topShelterId = (candidates.first as Map)['shelterId'] as String;

    final shelterResult = await _shelterRepository.getById(topShelterId);
    if (shelterResult case Failed<LocalShelter>(:final failure)) {
      return Result.failure(failure);
    }
    final shelter = shelterResult.dataOrNull!;

    return planRoute(
      origin: LatLng(habitation.latitude, habitation.longitude),
      destination: LatLng(shelter.latitude, shelter.longitude),
      now: now,
    );
  }

  /// Plans an evacuation route for every habitation whose current M10 plan
  /// says people actually need relocating — skips habitations with a
  /// relocation plan but zero population to relocate (nothing to route).
  Future<List<RoutePlan>> planEvacuationRoutesForAllHabitations({
    DateTime? now,
  }) async {
    final relocationPlansResult = await _relocationPlanRepository.getAll();
    final habitationIdsNeedingRoute = (relocationPlansResult.dataOrNull ?? const [])
        .where((plan) => plan.populationToRelocate > 0)
        .map((plan) => plan.habitationId);

    final results = <RoutePlan>[];
    for (final habitationId in habitationIdsNeedingRoute) {
      final result = await planEvacuationRoute(habitationId, now: now);
      if (result case Success<RoutePlan>(:final data)) {
        results.add(data);
      }
    }
    return results;
  }
}
