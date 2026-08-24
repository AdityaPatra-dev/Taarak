import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/gis/point_in_polygon.dart';
import 'package:taarak/features/routing/domain/route_candidate.dart';
import 'package:taarak/features/routing/domain/route_segment_assessment.dart';

const _distance = Distance();

/// M11's deterministic core. There's no real road-network graph available
/// (that would mean an external routing service/API key, which nothing
/// here has been given, and which cuts against the offline-first goal) —
/// so a "route" here is a straight-line path through a small number of
/// waypoints, exactly as the blueprint's own demo script frames this
/// scenario ("Simulate citizen report of a blocked road... Recalculate
/// route around blockage"). A real turn-by-turn road router is a
/// reasonable future replacement for this engine's internals; the
/// service/persistence layers around it wouldn't need to change.
///
/// Strategy: try the direct origin→destination line first. If any segment
/// is hazard-exposed or blocked, try a detour waypoint offset
/// perpendicular to the direct line, on each side, and recommend whichever
/// candidate is safe (preferring the shorter one if both are, or if
/// neither manages to fully clear the obstruction).
class RiskAwareRoutingEngine {
  static const double defaultSpeedMetersPerSecond = 8.33; // ~30 km/h
  static const double blockedRoadProximityMeters = 300;
  static const double detourOffsetFraction = 0.35;
  static const int segmentSampleCount = 20;

  /// Consecutive points on a real road route (from a
  /// [RoadNetworkProvider]) are already close together — unlike the
  /// straight-line/detour case, where a single segment can span
  /// kilometers — so far fewer interpolated samples are needed per
  /// segment to catch a hazard/blockage crossing.
  static const int roadRouteSamplesPerSegment = 2;

  RoutePlan planRoute({
    required LatLng origin,
    required LatLng destination,
    required List<LocalHazardZone> hazardZones,
    required List<LocalIncident> blockedRoadIncidents,
    DateTime? now,
  }) {
    final plannedAt = now ?? DateTime.now();
    final direct = _buildCandidate([origin, destination], hazardZones, blockedRoadIncidents);

    if (direct.isSafe) {
      return RoutePlan(
        origin: origin,
        destination: destination,
        primaryRoute: direct,
        alternativeRoutes: const [],
        modelVersion: routingModelVersion,
        plannedAt: plannedAt,
      );
    }

    final detourA = _buildCandidate(
      _detourWaypoints(origin, destination, side: 1),
      hazardZones,
      blockedRoadIncidents,
    );
    final detourB = _buildCandidate(
      _detourWaypoints(origin, destination, side: -1),
      hazardZones,
      blockedRoadIncidents,
    );

    final detours = [detourA, detourB]
      ..sort((a, b) {
        if (a.isSafe != b.isSafe) return a.isSafe ? -1 : 1;
        return a.distanceMeters.compareTo(b.distanceMeters);
      });

    return RoutePlan(
      origin: origin,
      destination: destination,
      primaryRoute: detours.first,
      alternativeRoutes: [direct, detours.last],
      modelVersion: routingModelVersion,
      plannedAt: plannedAt,
    );
  }

  /// Assesses a real, road-following polyline (typically from
  /// [RoadNetworkProvider]) against the same hazard/blockage rules the
  /// straight-line/detour path above already uses — same engine, a
  /// different geometry source. [etaSecondsOverride] lets the caller pass
  /// a routing provider's own (road-speed-aware) ETA instead of this
  /// engine's flat-speed estimate, since a real road route's distance
  /// already reflects actual travel distance, not a straight line.
  RouteCandidate assessRoadRoute({
    required List<LatLng> roadPoints,
    required List<LocalHazardZone> hazardZones,
    required List<LocalIncident> blockedRoadIncidents,
    int? etaSecondsOverride,
  }) {
    if (roadPoints.length < 2) {
      throw ArgumentError.value(roadPoints, 'roadPoints', 'must contain at least two points');
    }
    return _buildCandidate(
      roadPoints,
      hazardZones,
      blockedRoadIncidents,
      samplesPerSegment: roadRouteSamplesPerSegment,
      etaSecondsOverride: etaSecondsOverride,
    );
  }

  List<LatLng> _detourWaypoints(LatLng origin, LatLng destination, {required int side}) {
    final midLat = (origin.latitude + destination.latitude) / 2;
    final midLng = (origin.longitude + destination.longitude) / 2;
    final dLat = destination.latitude - origin.latitude;
    final dLng = destination.longitude - origin.longitude;
    // Perpendicular to (dLat, dLng) is (-dLng, dLat); scale by a fraction
    // of the origin-destination vector so the detour scales with how far
    // apart the two points are.
    final detourPoint = LatLng(
      midLat + (-dLng) * detourOffsetFraction * side,
      midLng + dLat * detourOffsetFraction * side,
    );
    return [origin, detourPoint, destination];
  }

  RouteCandidate _buildCandidate(
    List<LatLng> points,
    List<LocalHazardZone> hazardZones,
    List<LocalIncident> blockedRoadIncidents, {
    int samplesPerSegment = segmentSampleCount,
    int? etaSecondsOverride,
  }) {
    final segments = <RouteSegmentAssessment>[];
    var totalDistanceMeters = 0.0;

    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      totalDistanceMeters += _distance.as(LengthUnit.Meter, start, end);
      segments.add(
        _assessSegment(start, end, hazardZones, blockedRoadIncidents, samplesPerSegment),
      );
    }

    return RouteCandidate(
      points: points,
      segments: segments,
      distanceMeters: totalDistanceMeters,
      etaSeconds:
          etaSecondsOverride ?? (totalDistanceMeters / defaultSpeedMetersPerSecond).round(),
    );
  }

  RouteSegmentAssessment _assessSegment(
    LatLng start,
    LatLng end,
    List<LocalHazardZone> hazardZones,
    List<LocalIncident> blockedRoadIncidents,
    int samplesPerSegment,
  ) {
    final samplePoints = _samplePoints(start, end, samplesPerSegment);
    final reasons = <String>[];

    var isHazardExposed = false;
    for (final zone in hazardZones) {
      final polygon = decodePolygonPoints(zone.geometryJson);
      if (samplePoints.any((point) => isPointInPolygon(point, polygon))) {
        isHazardExposed = true;
        reasons.add('Crosses a ${zone.hazardType} hazard zone');
      }
    }

    var isBlocked = false;
    for (final incident in blockedRoadIncidents) {
      final incidentPoint = LatLng(incident.latitude, incident.longitude);
      final nearestMeters = samplePoints
          .map((point) => _distance.as(LengthUnit.Meter, point, incidentPoint))
          .reduce(min);
      if (nearestMeters <= blockedRoadProximityMeters) {
        isBlocked = true;
        reasons.add(
          'Passes within ${nearestMeters.round()}m of a reported road blockage',
        );
      }
    }

    return RouteSegmentAssessment(
      start: start,
      end: end,
      isHazardExposed: isHazardExposed,
      isBlocked: isBlocked,
      reasons: reasons,
    );
  }

  List<LatLng> _samplePoints(LatLng start, LatLng end, int count) {
    return [
      for (var i = 0; i <= count; i++)
        LatLng(
          start.latitude + (end.latitude - start.latitude) * i / count,
          start.longitude + (end.longitude - start.longitude) * i / count,
        ),
    ];
  }
}
