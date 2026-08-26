import 'package:latlong2/latlong.dart';

const Distance _distanceCalculator = Distance();

/// Approximates a circle of [radiusMeters] around [center] as a closed
/// polygon, for hazard zones drawn as "epicenter + affected radius" rather
/// than a freehand boundary — the normalizer only requires 3+ boundary
/// points, and a many-sided polygon renders indistinguishably from a true
/// circle on the map at any zoom level a citizen would actually use.
List<LatLng> circlePolygonPoints(
  LatLng center,
  double radiusMeters, {
  int segments = 24,
}) {
  return [
    for (var i = 0; i < segments; i++)
      _distanceCalculator.offset(center, radiusMeters, (360 / segments) * i),
  ];
}
