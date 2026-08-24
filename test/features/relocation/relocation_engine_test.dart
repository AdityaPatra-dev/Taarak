import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/features/relocation/application/relocation_engine.dart';

void main() {
  final engine = RelocationEngine();
  final now = DateTime.utc(2026, 1, 1);

  LocalHabitation habitationAt(double lat, double lng) => LocalHabitation(
    id: 'h1',
    name: 'Test Habitation',
    latitude: lat,
    longitude: lng,
    population: 500,
    updatedAt: now,
    version: 1,
  );

  LocalShelter shelterAt(
    double lat,
    double lng, {
    String id = 's1',
    String name = 'Shelter',
    int capacityTotal = 100,
    int occupancy = 0,
    String facilitiesJson = '[]',
    double? accessQuality,
  }) => LocalShelter(
    id: id,
    name: name,
    latitude: lat,
    longitude: lng,
    capacityTotal: capacityTotal,
    occupancy: occupancy,
    facilitiesJson: facilitiesJson,
    accessQuality: accessQuality,
    updatedAt: now,
    version: 1,
  );

  LocalHazardZone squareZoneAround(double lat, double lng, {String id = 'z1'}) =>
      LocalHazardZone(
        id: id,
        hazardType: 'landslide',
        severity: 'high',
        geometryJson: encodePolygonPoints([
          LatLng(lat - 0.001, lng - 0.001),
          LatLng(lat - 0.001, lng + 0.001),
          LatLng(lat + 0.001, lng + 0.001),
          LatLng(lat + 0.001, lng - 0.001),
        ]),
        source: 'test',
        observedAt: now,
        confidence: 1.0,
        updatedAt: now,
        version: 1,
      );

  test('a hazard-exposed shelter is never a candidate', () {
    final plan = engine.plan(
      habitation: habitationAt(10, 10),
      populationToRelocate: 500,
      shelters: [shelterAt(10.01, 10.01, capacityTotal: 600)],
      hazardZones: [squareZoneAround(10.01, 10.01)],
      now: now,
    );
    expect(plan.rankedCandidates, isEmpty);
  });

  test('a full shelter is never a candidate', () {
    final plan = engine.plan(
      habitation: habitationAt(10, 10),
      populationToRelocate: 500,
      shelters: [shelterAt(10.01, 10.01, capacityTotal: 100, occupancy: 100)],
      hazardZones: const [],
      now: now,
    );
    expect(plan.rankedCandidates, isEmpty);
  });

  test('a distant but safe shelter still appears, unlike M09', () {
    final plan = engine.plan(
      habitation: habitationAt(0, 0),
      populationToRelocate: 500,
      shelters: [shelterAt(5, 5, capacityTotal: 600)], // far beyond 15km
      hazardZones: const [],
      now: now,
    );
    expect(plan.rankedCandidates, hasLength(1));
    expect(plan.rankedCandidates.single.distanceScore, 0.0);
  });

  test('candidates are ranked best-first by composite score', () {
    final near = shelterAt(
      10.001,
      10.001,
      id: 'near',
      capacityTotal: 600,
      facilitiesJson: '["medical","food","transport"]',
      accessQuality: 0.0,
    );
    final far = shelterAt(10.1, 10.1, id: 'far', capacityTotal: 600);

    final plan = engine.plan(
      habitation: habitationAt(10, 10),
      populationToRelocate: 500,
      shelters: [far, near],
      hazardZones: const [],
      now: now,
    );

    expect(plan.rankedCandidates.first.shelterId, 'near');
    expect(
      plan.rankedCandidates.first.compositeScore,
      greaterThan(plan.rankedCandidates.last.compositeScore),
    );
  });

  test('every candidate carries reasons explaining its rank', () {
    final plan = engine.plan(
      habitation: habitationAt(10, 10),
      populationToRelocate: 500,
      shelters: [shelterAt(10.01, 10.01, capacityTotal: 600)],
      hazardZones: const [],
      now: now,
    );
    expect(plan.rankedCandidates.single.reasons, isNotEmpty);
    expect(plan.rankedCandidates.single.reasons, hasLength(4));
  });

  test('an unconfigured access quality is called out in the reasons', () {
    final plan = engine.plan(
      habitation: habitationAt(10, 10),
      populationToRelocate: 500,
      shelters: [shelterAt(10.01, 10.01, capacityTotal: 600, accessQuality: null)],
      hazardZones: const [],
      now: now,
    );
    expect(
      plan.rankedCandidates.single.reasons,
      contains('Access not yet surveyed'),
    );
  });

  test('zero population to relocate still produces a full-confidence capacity score', () {
    final plan = engine.plan(
      habitation: habitationAt(10, 10),
      populationToRelocate: 0,
      shelters: [shelterAt(10.01, 10.01, capacityTotal: 600)],
      hazardZones: const [],
      now: now,
    );
    expect(plan.rankedCandidates.single.capacityScore, 1.0);
  });

  test('carries the model version and habitation id through', () {
    final plan = engine.plan(
      habitation: habitationAt(10, 10),
      populationToRelocate: 0,
      shelters: const [],
      hazardZones: const [],
      now: now,
    );
    expect(plan.habitationId, 'h1');
    expect(plan.modelVersion, isNotEmpty);
  });
}
