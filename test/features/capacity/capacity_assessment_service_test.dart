import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_capacity_assessment_repository.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/features/capacity/application/capacity_assessment_service.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late CapacityAssessmentService service;
  late HazardIngestionService hazardIngestionService;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    hazardIngestionService = HazardIngestionService(
      normalizer: HazardNormalizer(),
      repository: LocalHazardZoneRepository(db),
    );
    service = CapacityAssessmentService(
      habitationRepository: LocalHabitationRepository(db),
      hazardZoneRepository: LocalHazardZoneRepository(db),
      shelterRepository: LocalShelterRepository(db),
      assessmentRepository: LocalCapacityAssessmentRepository(db),
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

  test('a habitation outside any hazard zone has zero exposed population', () async {
    final result = await service.assessHabitation('hab-1', now: now);

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.exposedPopulation, 0);
    expect(result.dataOrNull?.hasSufficientCapacity, isTrue);
  });

  test('a habitation inside a hazard zone counts its full population as exposed', () async {
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

    final result = await service.assessHabitation('hab-1', now: now);

    expect(result.dataOrNull?.exposedPopulation, 500);
  });

  test('assessing an unknown habitation fails without writing anything', () async {
    final result = await service.assessHabitation('missing', now: now);

    expect(result.isFailure, isTrue);
    final rows = await db.select(db.localCapacityAssessments).get();
    expect(rows, isEmpty);
  });

  test('persists a decodable contributing-shelters breakdown', () async {
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

    await service.assessHabitation('hab-1', now: now);

    final saved = await (db.select(
      db.localCapacityAssessments,
    )..where((t) => t.habitationId.equals('hab-1'))).getSingle();
    final shelters = jsonDecode(saved.contributingSheltersJson) as List;
    expect(shelters, hasLength(1));
    expect((shelters.first as Map)['shelterId'], 'shelter-1');
    expect(saved.capacityGap, 200); // 500 exposed - 300 available
  });

  test('re-assessing increments the version', () async {
    await service.assessHabitation('hab-1', now: now);
    await service.assessHabitation('hab-1', now: now.add(const Duration(hours: 1)));

    final saved = await (db.select(
      db.localCapacityAssessments,
    )..where((t) => t.habitationId.equals('hab-1'))).getSingle();
    expect(saved.version, 2);
  });

  test('assessAllHabitations covers every cached habitation', () async {
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

    final results = await service.assessAllHabitations(now: now);

    expect(results.map((r) => r.habitationId), containsAll(['hab-1', 'hab-2']));
  });
}
