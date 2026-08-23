import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late HazardIngestionService service;
  final now = DateTime.utc(2026, 1, 1, 12);

  RawHazardObservation observation({
    String hazardType = 'landslide',
    double severityScore = 0.75,
    double? sourceConfidence = 0.9,
    DateTime? observedAt,
  }) => RawHazardObservation(
    hazardType: hazardType,
    severityScore: severityScore,
    boundaryPoints: const [LatLng(1, 1), LatLng(1, 2), LatLng(2, 2)],
    source: 'test-source',
    observedAt: observedAt ?? now,
    sourceConfidence: sourceConfidence,
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = HazardIngestionService(
      normalizer: HazardNormalizer(),
      repository: LocalHazardZoneRepository(db),
    );
  });

  tearDown(() => db.close());

  test('a valid observation is persisted with normalized fields', () async {
    final result = await service.ingest(
      id: 'zone-1',
      observation: observation(),
      now: now,
    );

    expect(result.isSuccess, isTrue);
    final saved = await (db.select(
      db.localHazardZones,
    )..where((t) => t.id.equals('zone-1'))).getSingle();
    expect(saved.hazardType, 'landslide');
    expect(saved.severity, 'high');
    expect(saved.version, 1);
  });

  test('an invalid observation is rejected and nothing is persisted', () async {
    final result = await service.ingest(
      id: 'zone-2',
      observation: observation(hazardType: 'earthquake'),
      now: now,
    );

    expect(result.isFailure, isTrue);
    final rows = await db.select(db.localHazardZones).get();
    expect(rows, isEmpty);
  });

  test('re-ingesting the same id increments its version', () async {
    await service.ingest(id: 'zone-3', observation: observation(), now: now);
    await service.ingest(
      id: 'zone-3',
      observation: observation(severityScore: 0.9),
      now: now.add(const Duration(hours: 1)),
    );

    final saved = await (db.select(
      db.localHazardZones,
    )..where((t) => t.id.equals('zone-3'))).getSingle();
    expect(saved.version, 2);
    expect(saved.severity, 'critical');
  });
}
