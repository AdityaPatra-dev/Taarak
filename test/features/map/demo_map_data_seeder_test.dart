import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/gis/point_in_polygon.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/map/application/demo_map_data_seeder.dart';
import 'package:taarak/features/map/domain/road_blockage.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late DemoMapDataSeeder seeder;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final hazardIngestionService = HazardIngestionService(
      normalizer: HazardNormalizer(),
      repository: LocalHazardZoneRepository(db),
    );
    seeder = DemoMapDataSeeder(db, hazardIngestionService);
  });

  tearDown(() => db.close());

  test('seeds hazard zones, shelters and one road-blockage incident', () async {
    await seeder.seedIfEmpty();

    final hazardZones = await db.select(db.localHazardZones).get();
    final shelters = await db.select(db.localShelters).get();
    final incidents = await db.select(db.localIncidents).get();

    expect(hazardZones, isNotEmpty);
    expect(shelters, isNotEmpty);
    expect(incidents, isNotEmpty);
    expect(
      incidents.where((i) => i.type == roadBlockageIncidentType),
      isNotEmpty,
    );

    // Confirms hazard zones actually went through normalization, not a
    // direct insert: bucketed severity and a computed (not raw) confidence.
    final landslideZone = hazardZones.firstWhere(
      (z) => z.id == 'demo-hazard-landslide',
    );
    expect(landslideZone.severity, 'high');
    expect(landslideZone.confidence, closeTo(0.9, 0.001));
  });

  test('seeds habitations, one of them inside the landslide zone', () async {
    await seeder.seedIfEmpty();

    final habitations = await db.select(db.localHabitations).get();
    expect(habitations, hasLength(2));

    final landslideZone = await (db.select(
      db.localHazardZones,
    )..where((t) => t.id.equals('demo-hazard-landslide'))).getSingle();
    final zonePoints = decodePolygonPoints(landslideZone.geometryJson);

    final ridgeColony = habitations.firstWhere(
      (h) => h.id == 'demo-habitation-ridge-colony',
    );
    expect(
      isPointInPolygon(
        LatLng(ridgeColony.latitude, ridgeColony.longitude),
        zonePoints,
      ),
      isTrue,
    );

    final valleyTown = habitations.firstWhere(
      (h) => h.id == 'demo-habitation-valley-town',
    );
    expect(
      isPointInPolygon(
        LatLng(valleyTown.latitude, valleyTown.longitude),
        zonePoints,
      ),
      isFalse,
    );
  });

  test('seeding twice does not duplicate data', () async {
    await seeder.seedIfEmpty();
    await seeder.seedIfEmpty();

    final hazardZones = await db.select(db.localHazardZones).get();
    expect(hazardZones.length, 2);
  });
}
