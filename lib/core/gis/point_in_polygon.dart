import 'package:latlong2/latlong.dart';

/// Standard ray-casting point-in-polygon test. Used by M07's risk engine
/// to check whether a habitation falls inside a hazard zone, and available
/// for any later module that needs the same containment check (e.g. M11
/// routing against a blocked area).
bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
  if (polygon.length < 3) return false;

  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final vi = polygon[i];
    final vj = polygon[j];

    final intersects = ((vi.latitude > point.latitude) != (vj.latitude > point.latitude)) &&
        (point.longitude <
            (vj.longitude - vi.longitude) *
                    (point.latitude - vi.latitude) /
                    (vj.latitude - vi.latitude) +
                vi.longitude);

    if (intersects) inside = !inside;
  }
  return inside;
}
