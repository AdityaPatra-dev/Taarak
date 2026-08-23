import 'dart:convert';

import 'package:latlong2/latlong.dart';

/// Encodes/decodes the polygon point lists stored in
/// [LocalHazardZones.geometryJson] (M03) as `[[lat, lng], [lat, lng], ...]`.
/// Kept deliberately simple — a plain point ring, not full GeoJSON — since
/// nothing downstream needs GeoJSON's extra structure yet. Shared between
/// M05 (rendering) and, later, M06's hazard engine (producing this data).
List<LatLng> decodePolygonPoints(String geometryJson) {
  final Object? decoded;
  try {
    decoded = jsonDecode(geometryJson);
  } on FormatException {
    return const [];
  }
  if (decoded is! List) return const [];
  return decoded
      .whereType<List>()
      .where((point) => point.length >= 2 && point[0] is num && point[1] is num)
      .map((point) => LatLng((point[0] as num).toDouble(), (point[1] as num).toDouble()))
      .toList();
}

String encodePolygonPoints(List<LatLng> points) =>
    jsonEncode(points.map((p) => [p.latitude, p.longitude]).toList());
