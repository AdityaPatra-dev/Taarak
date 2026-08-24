import 'package:drift/drift.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';
import 'package:taarak/features/map/domain/road_blockage.dart';

/// Dev-only convenience: before M12 (citizen reporting) exists to populate
/// the local cache for real, this seeds a handful of sample shelters,
/// incidents and habitations, and pushes a couple of sample hazard
/// observations through M06's real ingestion pipeline, so the map screen
/// has something to render. Gated behind [AppConfig.isDevMode] at the
/// call site — never runs in a real build. Doesn't run M07's risk engine
/// itself — that's a separate call once habitations exist (see
/// RiskAssessmentService.assessAllHabitations).
class DemoMapDataSeeder {
  static const LatLng demoCenter = LatLng(12.9716, 77.5946);

  final AppDatabase _db;
  final HazardIngestionService _hazardIngestionService;

  DemoMapDataSeeder(this._db, this._hazardIngestionService);

  Future<void> seedIfEmpty() async {
    final existing = await (_db.select(
      _db.localHazardZones,
    )..limit(1)).get();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    const c = demoCenter;

    await _hazardIngestionService.ingest(
      id: 'demo-hazard-landslide',
      observation: RawHazardObservation(
        hazardType: 'landslide',
        severityScore: 0.75, // buckets to "high"
        boundaryPoints: [
          LatLng(c.latitude + 0.010, c.longitude - 0.010),
          LatLng(c.latitude + 0.016, c.longitude + 0.004),
          LatLng(c.latitude + 0.004, c.longitude + 0.014),
          LatLng(c.latitude - 0.002, c.longitude + 0.002),
        ],
        source: 'demo-seed',
        observedAt: now,
        sourceConfidence: 0.9,
      ),
      now: now,
    );
    await _hazardIngestionService.ingest(
      id: 'demo-hazard-flood',
      observation: RawHazardObservation(
        hazardType: 'flood',
        severityScore: 0.5, // buckets to "medium"
        boundaryPoints: [
          LatLng(c.latitude - 0.008, c.longitude - 0.018),
          LatLng(c.latitude - 0.002, c.longitude - 0.010),
          LatLng(c.latitude - 0.010, c.longitude - 0.004),
          LatLng(c.latitude - 0.016, c.longitude - 0.014),
        ],
        source: 'demo-seed',
        observedAt: now,
        sourceConfidence: 0.8,
      ),
      now: now,
    );

    await _db.batch((batch) {
      batch.insertAll(_db.localShelters, [
        // Both sit outside the seeded hazard zones, so M09 counts them as
        // safe capacity for Ridge Colony's 850 people — 630 available
        // between them, a deliberate shortfall to demonstrate the gap.
        LocalSheltersCompanion.insert(
          id: 'demo-shelter-1',
          name: 'Community Hall',
          latitude: c.latitude - 0.006,
          longitude: c.longitude + 0.006,
          capacityTotal: const Value(400),
          occupancy: const Value(50),
          updatedAt: now,
        ),
        LocalSheltersCompanion.insert(
          id: 'demo-shelter-2',
          name: 'Government School',
          latitude: c.latitude + 0.012,
          longitude: c.longitude - 0.016,
          capacityTotal: const Value(300),
          occupancy: const Value(20),
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

      batch.insertAll(_db.localHabitations, [
        // Sits inside the landslide hazard zone above — M07 should score
        // this one high/red once assessed.
        LocalHabitationsCompanion.insert(
          id: 'demo-habitation-ridge-colony',
          name: 'Ridge Colony',
          latitude: c.latitude + 0.007,
          longitude: c.longitude + 0.0025,
          population: const Value(850),
          updatedAt: now,
        ),
        // Outside every seeded hazard zone — should score low.
        LocalHabitationsCompanion.insert(
          id: 'demo-habitation-valley-town',
          name: 'Valley Town',
          latitude: c.latitude + 0.03,
          longitude: c.longitude - 0.03,
          population: const Value(1200),
          updatedAt: now,
        ),
      ]);
    });
  }
}
