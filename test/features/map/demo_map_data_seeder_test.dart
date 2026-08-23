import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/map/application/demo_map_data_seeder.dart';
import 'package:taarak/features/map/domain/road_blockage.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late DemoMapDataSeeder seeder;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    seeder = DemoMapDataSeeder(db);
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
  });

  test('seeding twice does not duplicate data', () async {
    await seeder.seedIfEmpty();
    await seeder.seedIfEmpty();

    final hazardZones = await db.select(db.localHazardZones).get();
    expect(hazardZones.length, 2);
  });
}
