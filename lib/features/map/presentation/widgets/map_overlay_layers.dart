import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/gis/severity_palette.dart';
import 'package:taarak/features/map/domain/habitation_with_risk.dart';
import 'package:taarak/features/map/domain/road_blockage.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';
import 'package:taarak/features/risk/presentation/risk_class_color.dart';

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

/// M07's risk assessment made visible: each habitation renders in its risk
/// class color, with the tooltip spelling out the factor breakdown the
/// engine produced (hazard exposure, vulnerability, weights) — not just
/// the score.
MarkerLayer buildHabitationLayer(List<HabitationWithRisk> habitations) {
  return MarkerLayer(
    markers: [
      for (final item in habitations)
        Marker(
          point: LatLng(item.habitation.latitude, item.habitation.longitude),
          width: 36,
          height: 36,
          child: Tooltip(
            message: _habitationTooltip(item),
            child: Icon(
              Icons.location_city,
              color: item.assessment == null
                  ? Colors.grey
                  : riskClassColor(
                      RiskClass.values.byName(item.assessment!.riskClass),
                    ),
            ),
          ),
        ),
    ],
  );
}

String _habitationTooltip(HabitationWithRisk item) {
  final assessment = item.assessment;
  if (assessment == null) {
    return '${item.habitation.name} — not yet assessed';
  }
  return '${item.habitation.name} — ${riskClassLabel(RiskClass.values.byName(assessment.riskClass))} '
      '(score ${assessment.riskScore.toStringAsFixed(2)})\n'
      'hazard ${assessment.hazardExposure.toStringAsFixed(2)}, '
      'vulnerability ${assessment.vulnerabilityIndex.toStringAsFixed(2)}';
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
