import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/features/routing/application/risk_aware_routing_engine.dart';

void main() {
  final engine = RiskAwareRoutingEngine();
  final now = DateTime.utc(2026, 1, 1);

  LocalHazardZone squareZoneAround(
    double lat,
    double lng, {
    String id = 'z1',
    double halfSize = 0.01,
  }) => LocalHazardZone(
    id: id,
    hazardType: 'landslide',
    severity: 'high',
    geometryJson: encodePolygonPoints([
      LatLng(lat - halfSize, lng - halfSize),
      LatLng(lat - halfSize, lng + halfSize),
      LatLng(lat + halfSize, lng + halfSize),
      LatLng(lat + halfSize, lng - halfSize),
    ]),
    source: 'test',
    observedAt: now,
    confidence: 1.0,
    updatedAt: now,
    version: 1,
  );

  LocalIncident blockedRoadAt(double lat, double lng, {String id = 'i1'}) =>
      LocalIncident(
        id: id,
        type: 'road_blockage',
        status: 'active',
        latitude: lat,
        longitude: lng,
        description: 'Blocked',
        severity: 'medium',
        independentSourceCount: 1,
        confidence: 0.5,
        createdAt: now,
        updatedAt: now,
        version: 1,
        isSynced: false,
      );

  test('a clear path with no hazards or blockages is used directly', () {
    final plan = engine.planRoute(
      origin: const LatLng(0, 0),
      destination: const LatLng(0, 1),
      hazardZones: const [],
      blockedRoadIncidents: const [],
      now: now,
    );

    expect(plan.primaryRoute.points, [const LatLng(0, 0), const LatLng(0, 1)]);
    expect(plan.primaryRoute.isSafe, isTrue);
    expect(plan.alternativeRoutes, isEmpty);
  });

  test('BLOCKED ROAD CHANGES THE RECOMMENDED ROUTE — the acceptance criterion', () {
    // A direct path straight through the midpoint...
    final origin = const LatLng(0, 0);
    final destination = const LatLng(0, 1);

    final withoutBlockage = engine.planRoute(
      origin: origin,
      destination: destination,
      hazardZones: const [],
      blockedRoadIncidents: const [],
      now: now,
    );
    expect(withoutBlockage.primaryRoute.points.length, 2); // straight line

    // ...now report a blockage right on that direct path.
    final blockage = blockedRoadAt(0, 0.5);
    final withBlockage = engine.planRoute(
      origin: origin,
      destination: destination,
      hazardZones: const [],
      blockedRoadIncidents: [blockage],
      now: now,
    );

    // The recommended route is no longer the straight line.
    expect(withBlockage.primaryRoute.points, isNot(withoutBlockage.primaryRoute.points));
    expect(withBlockage.primaryRoute.points.length, 3); // detoured via a waypoint
    // The original direct route is still visible as a (now-unsafe) alternative.
    expect(
      withBlockage.alternativeRoutes.any((route) => route.points.length == 2 && !route.isSafe),
      isTrue,
    );
  });

  test('a hazard zone crossing the direct path also forces a detour', () {
    final origin = const LatLng(0, 0);
    final destination = const LatLng(0, 1);
    final zone = squareZoneAround(0, 0.5);

    final plan = engine.planRoute(
      origin: origin,
      destination: destination,
      hazardZones: [zone],
      blockedRoadIncidents: const [],
      now: now,
    );

    expect(plan.primaryRoute.points.length, 3);
    expect(plan.primaryRoute.isSafe, isTrue);
  });

  test('the recommended detour is actually safe, not just different', () {
    final origin = const LatLng(0, 0);
    final destination = const LatLng(0, 1);
    final blockage = blockedRoadAt(0, 0.5);

    final plan = engine.planRoute(
      origin: origin,
      destination: destination,
      hazardZones: const [],
      blockedRoadIncidents: [blockage],
      now: now,
    );

    expect(plan.primaryRoute.isSafe, isTrue);
    expect(plan.primaryRoute.segments.every((s) => s.isSafe), isTrue);
  });

  test('segments carry human-readable reasons when unsafe', () {
    final origin = const LatLng(0, 0);
    final destination = const LatLng(0, 1);
    final blockage = blockedRoadAt(0, 0.5);

    final plan = engine.planRoute(
      origin: origin,
      destination: destination,
      hazardZones: const [],
      blockedRoadIncidents: [blockage],
      now: now,
    );

    final unsafeAlternative = plan.alternativeRoutes.firstWhere((r) => !r.isSafe);
    final unsafeSegment = unsafeAlternative.segments.firstWhere((s) => !s.isSafe);
    expect(unsafeSegment.reasons, isNotEmpty);
    expect(unsafeSegment.reasons.first, contains('blockage'));
  });

  test('distance and ETA are computed and positive for a real route', () {
    final plan = engine.planRoute(
      origin: const LatLng(12.9716, 77.5946),
      destination: const LatLng(12.98, 77.60),
      hazardZones: const [],
      blockedRoadIncidents: const [],
      now: now,
    );
    expect(plan.primaryRoute.distanceMeters, greaterThan(0));
    expect(plan.primaryRoute.etaSeconds, greaterThan(0));
  });

  test('carries the model version for traceability', () {
    final plan = engine.planRoute(
      origin: const LatLng(0, 0),
      destination: const LatLng(0, 1),
      hazardZones: const [],
      blockedRoadIncidents: const [],
      now: now,
    );
    expect(plan.modelVersion, isNotEmpty);
  });

  test('an incident far from the path does not force a detour', () {
    final origin = const LatLng(0, 0);
    final destination = const LatLng(0, 1);
    final farBlockage = blockedRoadAt(5, 5);

    final plan = engine.planRoute(
      origin: origin,
      destination: destination,
      hazardZones: const [],
      blockedRoadIncidents: [farBlockage],
      now: now,
    );

    expect(plan.primaryRoute.points.length, 2);
    expect(plan.primaryRoute.isSafe, isTrue);
  });
}
