import 'package:drift/drift.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/features/map/domain/road_blockage.dart';

/// Dev-only convenience: before M06 (hazard engine) and M12 (citizen
/// reporting) exist to populate the local cache for real, this seeds a
/// handful of sample hazard zones, shelters and incidents so the map
/// screen has something to render. Gated behind [AppConfig.isDevMode] at
/// the call site — never runs in a real build.
class DemoMapDataSeeder {
  static const LatLng demoCenter = LatLng(12.9716, 77.5946);

  final AppDatabase _db;

  DemoMapDataSeeder(this._db);

  Future<void> seedIfEmpty() async {
    final existing = await (_db.select(
      _db.localHazardZones,
    )..limit(1)).get();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    const c = demoCenter;

    await _db.batch((batch) {
      batch.insertAll(_db.localHazardZones, [
        LocalHazardZonesCompanion.insert(
          id: 'demo-hazard-landslide',
          hazardType: 'landslide',
          severity: 'high',
          geometryJson: encodePolygonPoints([
            LatLng(c.latitude + 0.010, c.longitude - 0.010),
            LatLng(c.latitude + 0.016, c.longitude + 0.004),
            LatLng(c.latitude + 0.004, c.longitude + 0.014),
            LatLng(c.latitude - 0.002, c.longitude + 0.002),
          ]),
          source: 'demo-seed',
          observedAt: now,
          updatedAt: now,
        ),
        LocalHazardZonesCompanion.insert(
          id: 'demo-hazard-flood',
          hazardType: 'flood',
          severity: 'medium',
          geometryJson: encodePolygonPoints([
            LatLng(c.latitude - 0.008, c.longitude - 0.018),
            LatLng(c.latitude - 0.002, c.longitude - 0.010),
            LatLng(c.latitude - 0.010, c.longitude - 0.004),
            LatLng(c.latitude - 0.016, c.longitude - 0.014),
          ]),
          source: 'demo-seed',
          observedAt: now,
          updatedAt: now,
        ),
      ]);

      batch.insertAll(_db.localShelters, [
        LocalSheltersCompanion.insert(
          id: 'demo-shelter-1',
          name: 'Community Hall',
          latitude: c.latitude - 0.006,
          longitude: c.longitude + 0.006,
          updatedAt: now,
        ),
        LocalSheltersCompanion.insert(
          id: 'demo-shelter-2',
          name: 'Government School',
          latitude: c.latitude + 0.012,
          longitude: c.longitude - 0.016,
          updatedAt: now,
        ),
      ]);

      batch.insertAll(_db.localIncidents, [
        LocalIncidentsCompanion.insert(
          id: 'demo-incident-landslide',
          type: 'landslide',
          status: 'active',
          latitude: c.latitude + 0.009,
          longitude: c.longitude - 0.002,
          description: const Value('Debris flow reported near the ridge'),
          severity: const Value('high'),
          createdAt: now,
          updatedAt: now,
        ),
        LocalIncidentsCompanion.insert(
          id: 'demo-incident-road-blockage',
          type: roadBlockageIncidentType,
          status: 'active',
          latitude: c.latitude - 0.004,
          longitude: c.longitude + 0.009,
          description: const Value('Road blocked by fallen debris'),
          severity: const Value('medium'),
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    });
  }
}
