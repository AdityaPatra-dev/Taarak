import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/features/map/domain/map_search_result.dart';

/// Local, offline search over whatever's currently loaded on the map —
/// there's no geocoding service wired in (that would need its own API
/// key/account, which nothing here has been given), so this searches
/// feature names/descriptions rather than arbitrary place names.
List<MapSearchResult> buildSearchIndex({
  required List<LocalHazardZone> hazardZones,
  required List<LocalShelter> shelters,
  required List<LocalIncident> incidents,
}) {
  return [
    for (final zone in hazardZones)
      if (decodePolygonPoints(zone.geometryJson).isNotEmpty)
        MapSearchResult(
          label: '${zone.hazardType} hazard zone',
          point: decodePolygonPoints(zone.geometryJson).first,
        ),
    for (final shelter in shelters)
      MapSearchResult(
        label: shelter.name,
        point: LatLng(shelter.latitude, shelter.longitude),
      ),
    for (final incident in incidents)
      MapSearchResult(
        label: incident.description.isEmpty
            ? incident.type
            : incident.description,
        point: LatLng(incident.latitude, incident.longitude),
      ),
  ];
}

List<MapSearchResult> filterSearchIndex(
  List<MapSearchResult> index,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return const [];
  return index
      .where((result) => result.label.toLowerCase().contains(normalized))
      .toList();
}
