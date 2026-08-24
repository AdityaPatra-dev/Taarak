import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:taarak/core/routing/road_network_provider.dart';
import 'package:taarak/core/routing/road_route.dart';
import 'package:taarak/features/routing/application/routing_service.dart';

import '../../support/sqlite3_test_setup.dart';

class _ScriptedRoadNetworkProvider implements RoadNetworkProvider {
  final Result<RoadRoute> Function() _script;
  int callCount = 0;
  _ScriptedRoadNetworkProvider(this._script);

  @override
  Future<Result<RoadRoute>> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    callCount++;
    return _script();
  }
}

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late RoutingService service;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = RoutingService(
      hazardZoneRepository: LocalHazardZoneRepository(db),
      incidentRepository: LocalIncidentRepository(db),
      routeRepository: LocalRouteRepository(db),
      habitationRepository: LocalHabitationRepository(db),
      relocationPlanRepository: LocalRelocationPlanRepository(db),
      shelterRepository: LocalShelterRepository(db),
    );
  });

  tearDown(() => db.close());

  group('planRoute', () {
    test('a planned route is cached and re-readable by the same endpoints', () async {
      const origin = LatLng(0, 0);
      const destination = LatLng(0, 1);

      final result = await service.planRoute(
        origin: origin,
        destination: destination,
        now: now,
      );
      expect(result.isSuccess, isTrue);

      final cached = await service.getCachedRoute(
        origin: origin,
        destination: destination,
      );
      expect(cached.isSuccess, isTrue);
      expect(cached.dataOrNull?.isSafe, isTrue);
    });

    test('re-planning the same endpoints increments the cached version', () async {
      const origin = LatLng(0, 0);
      const destination = LatLng(0, 1);

      await service.planRoute(origin: origin, destination: destination, now: now);
      await service.planRoute(origin: origin, destination: destination, now: now);

      final cached = await service.getCachedRoute(
        origin: origin,
        destination: destination,
      );
      expect(cached.dataOrNull?.version, 2);
    });

    test('an uncached endpoint pair has no cached route yet', () async {
      final result = await service.getCachedRoute(
        origin: const LatLng(10, 10),
        destination: const LatLng(20, 20),
      );
      expect(result.isFailure, isTrue);
    });
  });

  group('planRoute with a RoadNetworkProvider', () {
    RoutingService serviceWithProvider(RoadNetworkProvider provider) => RoutingService(
      hazardZoneRepository: LocalHazardZoneRepository(db),
      incidentRepository: LocalIncidentRepository(db),
      routeRepository: LocalRouteRepository(db),
      habitationRepository: LocalHabitationRepository(db),
      relocationPlanRepository: LocalRelocationPlanRepository(db),
      shelterRepository: LocalShelterRepository(db),
      roadNetworkProvider: provider,
    );

    test(
      'a successful road route is cached as road-snapped with the real geometry',
      () async {
        const origin = LatLng(0, 0);
        const destination = LatLng(0, 1);
        final roadPoints = [
          origin,
          const LatLng(0.02, 0.3),
          const LatLng(-0.01, 0.6),
          destination,
        ];
        final provider = _ScriptedRoadNetworkProvider(
          () => Result.success(
            RoadRoute(points: roadPoints, distanceMeters: 12000, etaSeconds: 900),
          ),
        );

        final result = await serviceWithProvider(
          provider,
        ).planRoute(origin: origin, destination: destination, now: now);

        expect(result.isSuccess, isTrue);
        expect(provider.callCount, 1);

        final cached = await (db.select(
          db.localRoutes,
        )..where((t) => t.id.equals(routeCacheKey(origin, destination)))).getSingle();
        expect(cached.isRoadSnapped, isTrue);
        expect(decodePolygonPoints(cached.polylineJson), roadPoints);
        expect(cached.etaSeconds, 900);
      },
    );

    test(
      'when the provider fails, the route falls back to the straight-line engine',
      () async {
        const origin = LatLng(0, 0);
        const destination = LatLng(0, 1);
        final provider = _ScriptedRoadNetworkProvider(
          () => const Result.failure(NetworkFailure('offline')),
        );

        final result = await serviceWithProvider(
          provider,
        ).planRoute(origin: origin, destination: destination, now: now);

        expect(result.isSuccess, isTrue);
        // The straight-line fallback for a clear path is just the two endpoints.
        expect(result.dataOrNull?.primaryRoute.points, [origin, destination]);

        final cached = await (db.select(
          db.localRoutes,
        )..where((t) => t.id.equals(routeCacheKey(origin, destination)))).getSingle();
        expect(cached.isRoadSnapped, isFalse);
      },
    );

    test(
      'an unsafe road route still surfaces the straight-line detour as an alternative',
      () async {
        const origin = LatLng(0, 0);
        const destination = LatLng(0, 1);

        // A hazard zone that the road route (but not necessarily the
        // straight line) passes directly through.
        await db
            .into(db.localHazardZones)
            .insert(
              LocalHazardZonesCompanion.insert(
                id: 'zone-1',
                hazardType: 'landslide',
                severity: 'high',
                geometryJson: encodePolygonPoints(const [
                  LatLng(0.01, 0.29),
                  LatLng(0.01, 0.31),
                  LatLng(0.03, 0.31),
                  LatLng(0.03, 0.29),
                ]),
                source: 'test',
                observedAt: now,
                updatedAt: now,
              ),
            );

        final roadPoints = [origin, const LatLng(0.02, 0.3), destination];
        final provider = _ScriptedRoadNetworkProvider(
          () => Result.success(
            RoadRoute(points: roadPoints, distanceMeters: 12000, etaSeconds: 900),
          ),
        );

        final result = await serviceWithProvider(
          provider,
        ).planRoute(origin: origin, destination: destination, now: now);

        expect(result.isSuccess, isTrue);
        final plan = result.dataOrNull!;
        expect(plan.primaryRoute.isSafe, isFalse);
        expect(plan.alternativeRoutes, isNotEmpty);
        expect(plan.alternativeRoutes.any((route) => route.isSafe), isTrue);
      },
    );

    test('a road route of fewer than two points falls back to the straight-line engine', () async {
      const origin = LatLng(0, 0);
      const destination = LatLng(0, 1);
      final provider = _ScriptedRoadNetworkProvider(
        () => Result.success(
          RoadRoute(points: [origin], distanceMeters: 0, etaSeconds: 0),
        ),
      );

      final result = await serviceWithProvider(
        provider,
      ).planRoute(origin: origin, destination: destination, now: now);

      expect(result.dataOrNull?.primaryRoute.points, [origin, destination]);
    });
  });

  group('planEvacuationRoute', () {
    setUp(() async {
      await db
          .into(db.localHabitations)
          .insert(
            LocalHabitationsCompanion.insert(
              id: 'hab-1',
              name: 'Test Habitation',
              latitude: 0,
              longitude: 0,
              population: const Value(500),
              updatedAt: now,
            ),
          );
      await db
          .into(db.localShelters)
          .insert(
            LocalSheltersCompanion.insert(
              id: 'shelter-1',
              name: 'Test Shelter',
              latitude: 0,
              longitude: 1,
              capacityTotal: const Value(600),
              updatedAt: now,
            ),
          );
      await db
          .into(db.localRelocationPlans)
          .insert(
            LocalRelocationPlansCompanion.insert(
              habitationId: 'hab-1',
              populationToRelocate: 500,
              rankedCandidatesJson:
                  '[{"shelterId":"shelter-1","shelterName":"Test Shelter"}]',
              modelVersion: '1.0.0',
              plannedAt: now,
            ),
          );
    });

    test('routes a habitation to its top relocation candidate', () async {
      final result = await service.planEvacuationRoute('hab-1', now: now);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.destination, const LatLng(0, 1));
    });

    test('fails cleanly when the habitation has no relocation plan', () async {
      final result = await service.planEvacuationRoute('no-plan', now: now);
      expect(result.isFailure, isTrue);
    });

    test('fails cleanly when the relocation plan has no candidates', () async {
      await db
          .into(db.localHabitations)
          .insert(
            LocalHabitationsCompanion.insert(
              id: 'hab-2',
              name: 'No Candidates',
              latitude: 5,
              longitude: 5,
              updatedAt: now,
            ),
          );
      await db
          .into(db.localRelocationPlans)
          .insert(
            LocalRelocationPlansCompanion.insert(
              habitationId: 'hab-2',
              populationToRelocate: 100,
              rankedCandidatesJson: '[]',
              modelVersion: '1.0.0',
              plannedAt: now,
            ),
          );

      final result = await service.planEvacuationRoute('hab-2', now: now);
      expect(result.isFailure, isTrue);
    });
  });

  group('planEvacuationRoutesForAllHabitations', () {
    test('skips habitations with zero population to relocate', () async {
      await db
          .into(db.localHabitations)
          .insert(
            LocalHabitationsCompanion.insert(
              id: 'hab-safe',
              name: 'Safe Habitation',
              latitude: 9,
              longitude: 9,
              updatedAt: now,
            ),
          );
      await db
          .into(db.localRelocationPlans)
          .insert(
            LocalRelocationPlansCompanion.insert(
              habitationId: 'hab-safe',
              populationToRelocate: 0,
              rankedCandidatesJson: '[]',
              modelVersion: '1.0.0',
              plannedAt: now,
            ),
          );

      await db
          .into(db.localHabitations)
          .insert(
            LocalHabitationsCompanion.insert(
              id: 'hab-1',
              name: 'Exposed Habitation',
              latitude: 0,
              longitude: 0,
              population: const Value(500),
              updatedAt: now,
            ),
          );
      await db
          .into(db.localShelters)
          .insert(
            LocalSheltersCompanion.insert(
              id: 'shelter-1',
              name: 'Test Shelter',
              latitude: 0,
              longitude: 1,
              capacityTotal: const Value(600),
              updatedAt: now,
            ),
          );
      await db
          .into(db.localRelocationPlans)
          .insert(
            LocalRelocationPlansCompanion.insert(
              habitationId: 'hab-1',
              populationToRelocate: 500,
              rankedCandidatesJson:
                  '[{"shelterId":"shelter-1","shelterName":"Test Shelter"}]',
              modelVersion: '1.0.0',
              plannedAt: now,
            ),
          );

      final results = await service.planEvacuationRoutesForAllHabitations(
        now: now,
      );

      expect(results, hasLength(1));
      expect(results.single.origin, const LatLng(0, 0));
    });
  });
}
