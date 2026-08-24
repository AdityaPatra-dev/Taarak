import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/features/capacity/application/capacity_gap_engine.dart';

void main() {
  final engine = CapacityGapEngine();
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
    int capacityTotal = 100,
    int occupancy = 0,
  }) => LocalShelter(
    id: id,
    name: 'Shelter $id',
    latitude: lat,
    longitude: lng,
    capacityTotal: capacityTotal,
    occupancy: occupancy,
    facilitiesJson: '[]',
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

  test('zero exposed population means no shortfall regardless of shelters', () {
    final result = engine.assess(
      habitation: habitationAt(10, 10),
      exposedPopulation: 0,
      shelters: const [],
      hazardZones: const [],
      now: now,
    );
    expect(result.capacityGap, 0);
    expect(result.hasSufficientCapacity, isTrue);
  });

  test('a nearby safe shelter with enough room closes the gap', () {
    final result = engine.assess(
      habitation: habitationAt(10, 10),
      exposedPopulation: 500,
      shelters: [shelterAt(10.01, 10.01, capacityTotal: 600, occupancy: 0)],
      hazardZones: const [],
      now: now,
    );
    expect(result.availableSafeCapacity, 600);
    expect(result.capacityGap, -100);
    expect(result.hasSufficientCapacity, isTrue);
  });

  test('insufficient shelter capacity produces a positive gap', () {
    final result = engine.assess(
      habitation: habitationAt(10, 10),
      exposedPopulation: 500,
      shelters: [shelterAt(10.01, 10.01, capacityTotal: 200, occupancy: 0)],
      hazardZones: const [],
      now: now,
    );
    expect(result.availableSafeCapacity, 200);
    expect(result.capacityGap, 300);
    expect(result.hasSufficientCapacity, isFalse);
  });

  test('a shelter inside a hazard zone does not count as safe capacity', () {
    final hazardZone = squareZoneAround(10.01, 10.01, id: 'zone-on-shelter');
    final result = engine.assess(
      habitation: habitationAt(10, 10),
      exposedPopulation: 500,
      shelters: [shelterAt(10.01, 10.01, capacityTotal: 600, occupancy: 0)],
      hazardZones: [hazardZone],
      now: now,
    );
    expect(result.availableSafeCapacity, 0);
    expect(result.contributingShelters, isEmpty);
  });

  test('a shelter beyond the accessible radius is excluded', () {
    final result = engine.assess(
      habitation: habitationAt(0, 0),
      exposedPopulation: 500,
      shelters: [shelterAt(5, 5, capacityTotal: 600)], // ~780km away
      hazardZones: const [],
      accessibleRadiusMeters: 15000,
      now: now,
    );
    expect(result.availableSafeCapacity, 0);
  });

  test('a full shelter contributes nothing', () {
    final result = engine.assess(
      habitation: habitationAt(10, 10),
      exposedPopulation: 500,
      shelters: [shelterAt(10.01, 10.01, capacityTotal: 100, occupancy: 100)],
      hazardZones: const [],
      now: now,
    );
    expect(result.availableSafeCapacity, 0);
    expect(result.contributingShelters, isEmpty);
  });

  test('multiple shelters sum their available capacity, nearest first', () {
    final near = shelterAt(10.001, 10.001, id: 'near', capacityTotal: 100);
    final far = shelterAt(10.05, 10.05, id: 'far', capacityTotal: 200);
    final result = engine.assess(
      habitation: habitationAt(10, 10),
      exposedPopulation: 500,
      shelters: [far, near],
      hazardZones: const [],
      now: now,
    );
    expect(result.availableSafeCapacity, 300);
    expect(result.contributingShelters.first.shelterId, 'near');
  });

  test('carries the model version for traceability', () {
    final result = engine.assess(
      habitation: habitationAt(10, 10),
      exposedPopulation: 0,
      shelters: const [],
      hazardZones: const [],
      now: now,
    );
    expect(result.modelVersion, isNotEmpty);
  });
}
