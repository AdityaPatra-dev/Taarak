import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/gis/severity_palette.dart';
import 'package:taarak/features/map/domain/road_blockage.dart';

PolygonLayer buildHazardZoneLayer(List<LocalHazardZone> hazardZones) {
  return PolygonLayer(
    polygons: [
      for (final zone in hazardZones)
        Polygon(
          points: decodePolygonPoints(zone.geometryJson),
          color: severityColor(zone.severity).withValues(alpha: 0.35),
          borderColor: severityColor(zone.severity),
          borderStrokeWidth: 2,
          label: zone.hazardType,
        ),
    ],
  );
}

MarkerLayer buildShelterLayer(List<LocalShelter> shelters) {
  return MarkerLayer(
    markers: [
      for (final shelter in shelters)
        Marker(
          point: LatLng(shelter.latitude, shelter.longitude),
          width: 36,
          height: 36,
          child: Tooltip(
            message: shelter.name,
            child: const Icon(Icons.home_filled, color: Colors.blue),
          ),
        ),
    ],
  );
}

MarkerLayer buildIncidentLayer(List<LocalIncident> incidents) {
  return MarkerLayer(
    markers: [
      for (final incident in incidents)
        Marker(
          point: LatLng(incident.latitude, incident.longitude),
          width: 36,
          height: 36,
          child: Tooltip(
            message: incident.description.isEmpty
                ? incident.type
                : incident.description,
            child: Icon(
              incident.type == roadBlockageIncidentType
                  ? Icons.block
                  : Icons.warning_amber,
              color: severityColor(incident.severity),
            ),
          ),
        ),
    ],
  );
}
