import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/gis/point_in_polygon.dart';

/// Whether a point currently falls inside any of the given hazard zones.
/// Shared by M09 (a shelter/habitation's exposure for the capacity gap)
/// and M10 (excluding hazard-exposed shelters from relocation candidates)
/// so both use the same exposure determination rather than each
/// reimplementing the containment loop.
bool isPointHazardExposed(LatLng point, List<LocalHazardZone> hazardZones) {
  for (final zone in hazardZones) {
    if (isPointInPolygon(point, decodePolygonPoints(zone.geometryJson))) {
      return true;
    }
  }
  return false;
}
