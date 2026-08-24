import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_relocation_plan_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';
import 'package:taarak/features/relocation/application/relocation_planning_service.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late RelocationPlanningService service;
  late HazardIngestionService hazardIngestionService;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    hazardIngestionService = HazardIngestionService(
      normalizer: HazardNormalizer(),
      repository: LocalHazardZoneRepository(db),
    );
    service = RelocationPlanningService(
      habitationRepository: LocalHabitationRepository(db),
      hazardZoneRepository: LocalHazardZoneRepository(db),
      shelterRepository: LocalShelterRepository(db),
      planRepository: LocalRelocationPlanRepository(db),
    );

    await db
        .into(db.localHabitations)
        .insert(
          LocalHabitationsCompanion.insert(
            id: 'hab-1',
            name: 'Test Habitation',
            latitude: 10,
            longitude: 10,
            population: const Value(500),
            updatedAt: now,
          ),
        );
  });

  tearDown(() => db.close());

  test('a non-exposed habitation defaults to zero population to relocate', () async {
    final result = await service.planForHabitation('hab-1', now: now);
    expect(result.dataOrNull?.populationToRelocate, 0);
  });

  test('an exposed habitation plans for its full population', () async {
    await hazardIngestionService.ingest(
      id: 'zone-1',
      observation: RawHazardObservation(
        hazardType: 'landslide',
        severityScore: 0.8,
        boundaryPoints: const [
          LatLng(9.99, 9.99),
          LatLng(9.99, 10.01),
          LatLng(10.01, 10.01),
          LatLng(10.01, 9.99),
        ],
        source: 'test',
        observedAt: now,
      ),
      now: now,
    );

    final result = await service.planForHabitation('hab-1', now: now);
    expect(result.dataOrNull?.populationToRelocate, 500);
  });

  test('a population override plans for a hypothetical scenario', () async {
    final result = await service.planForHabitation(
      'hab-1',
      populationOverride: 200,
      now: now,
    );
    expect(result.dataOrNull?.populationToRelocate, 200);
  });

  test('persists a decodable ranked-candidates breakdown', () async {
    await db
        .into(db.localShelters)
        .insert(
          LocalSheltersCompanion.insert(
            id: 'shelter-1',
            name: 'Nearby Shelter',
            latitude: 10.02,
            longitude: 10.02,
            capacityTotal: const Value(300),
            updatedAt: now,
          ),
        );

    await service.planForHabitation('hab-1', populationOverride: 200, now: now);

    final saved = await (db.select(
      db.localRelocationPlans,
    )..where((t) => t.habitationId.equals('hab-1'))).getSingle();
    final candidates = jsonDecode(saved.rankedCandidatesJson) as List;
    expect(candidates, hasLength(1));
    expect((candidates.first as Map)['shelterId'], 'shelter-1');
  });

  test('planning for an unknown habitation fails without writing anything', () async {
    final result = await service.planForHabitation('missing', now: now);

    expect(result.isFailure, isTrue);
    final rows = await db.select(db.localRelocationPlans).get();
    expect(rows, isEmpty);
  });

  test('re-planning increments the version', () async {
    await service.planForHabitation('hab-1', now: now);
    await service.planForHabitation('hab-1', now: now.add(const Duration(hours: 1)));

    final saved = await (db.select(
      db.localRelocationPlans,
    )..where((t) => t.habitationId.equals('hab-1'))).getSingle();
    expect(saved.version, 2);
  });

  test('planForAllHabitations covers every cached habitation', () async {
    await db
        .into(db.localHabitations)
        .insert(
          LocalHabitationsCompanion.insert(
            id: 'hab-2',
            name: 'Second Habitation',
            latitude: 20,
            longitude: 20,
            updatedAt: now,
          ),
        );

    final results = await service.planForAllHabitations(now: now);

    expect(results.map((r) => r.habitationId), containsAll(['hab-1', 'hab-2']));
  });
}
