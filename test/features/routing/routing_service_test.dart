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
import 'package:taarak/features/routing/application/routing_service.dart';

import '../../support/sqlite3_test_setup.dart';

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
