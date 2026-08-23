import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/application/hazard_query_service.dart';
import 'package:taarak/features/hazards/domain/hazard_freshness.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late HazardQueryService queryService;
  final now = DateTime.utc(2026, 1, 1, 12);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final ingestion = HazardIngestionService(
      normalizer: HazardNormalizer(),
      repository: LocalHazardZoneRepository(db),
    );
    queryService = HazardQueryService(LocalHazardZoneRepository(db));

    const points = [LatLng(1, 1), LatLng(1, 2), LatLng(2, 2)];

    await ingestion.ingest(
      id: 'fresh-landslide',
      observation: RawHazardObservation(
        hazardType: 'landslide',
        severityScore: 0.7,
        boundaryPoints: points,
        source: 's',
        observedAt: now,
      ),
      now: now,
    );
    await ingestion.ingest(
      id: 'stale-flood',
      observation: RawHazardObservation(
        hazardType: 'flood',
        severityScore: 0.5,
        boundaryPoints: points,
        source: 's',
        observedAt: now.subtract(const Duration(hours: 72)),
      ),
      now: now,
    );
  });

  tearDown(() => db.close());

  test('querying with no filters returns everything', () async {
    final result = await queryService.query(now: now);
    expect(result.dataOrNull, hasLength(2));
  });

  test('filtering by hazard type narrows the result', () async {
    final result = await queryService.query(
      hazardTypes: {HazardType.landslide},
      now: now,
    );
    expect(result.dataOrNull?.map((z) => z.id), ['fresh-landslide']);
  });

  test('filtering by minFreshness excludes stale entries', () async {
    final result = await queryService.query(
      minFreshness: HazardFreshness.fresh,
      now: now,
    );
    expect(result.dataOrNull?.map((z) => z.id), ['fresh-landslide']);
  });
}
