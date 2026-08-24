import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/gis/severity_palette.dart';
import 'package:taarak/features/map/domain/habitation_overview.dart';
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

/// M15 made visible: a citizen deciding where to go should see whether a
/// shelter still has room, not just that it exists.
String _shelterTooltip(LocalShelter shelter) {
  final available = shelter.capacityTotal - shelter.occupancy;
  if (shelter.capacityTotal <= 0) return shelter.name;
  return '${shelter.name}\n${shelter.occupancy}/${shelter.capacityTotal} occupied '
      '(${available > 0 ? '$available available' : 'full'})';
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
            message: _shelterTooltip(shelter),
            child: Icon(
              Icons.home_filled,
              color: shelter.capacityTotal > 0 &&
                      shelter.occupancy >= shelter.capacityTotal
                  ? Colors.grey
                  : Colors.blue,
            ),
          ),
        ),
    ],
  );
}

/// M07's risk assessment made visible: each habitation renders in its risk
/// class color, with the tooltip spelling out the factor breakdown the
/// engine produced (hazard exposure, vulnerability, weights) plus M09's
/// capacity gap — not just the score.
MarkerLayer buildHabitationLayer(List<HabitationOverview> habitations) {
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
              color: item.riskAssessment == null
                  ? Colors.grey
                  : riskClassColor(
                      RiskClass.values.byName(item.riskAssessment!.riskClass),
                    ),
            ),
          ),
        ),
    ],
  );
}

String _habitationTooltip(HabitationOverview item) {
  final risk = item.riskAssessment;
  final capacity = item.capacityAssessment;

  final buffer = StringBuffer(item.habitation.name);

  if (risk == null) {
    buffer.write(' — not yet assessed');
  } else {
    buffer.write(
      ' — ${riskClassLabel(RiskClass.values.byName(risk.riskClass))} '
      '(score ${risk.riskScore.toStringAsFixed(2)})\n'
      'hazard ${risk.hazardExposure.toStringAsFixed(2)}, '
      'vulnerability ${risk.vulnerabilityIndex.toStringAsFixed(2)}',
    );
    // M24: only shown when environmental data actually moved the score —
    // "visible provenance", not a silent adjustment.
    if (risk.environmentalAdjustment > 0) {
      final provenance = jsonDecode(risk.environmentalProvenanceJson) as List;
      final sources = provenance
          .map((entry) => (entry as Map<String, dynamic>)['source'])
          .toSet()
          .join(', ');
      buffer.write(
        '\n+${risk.environmentalAdjustment.toStringAsFixed(2)} from environmental data '
        '($sources)',
      );
    }
  }

  if (capacity != null && capacity.exposedPopulation > 0) {
    buffer.write(
      capacity.hasSufficientCapacity
          ? '\nCapacity: sufficient (${capacity.availableSafeCapacity} available for ${capacity.exposedPopulation})'
          : '\nCapacity gap: short by ${capacity.capacityGap} '
                '(${capacity.availableSafeCapacity} available for ${capacity.exposedPopulation})',
    );
  }

  final relocation = item.relocationPlan;
  if (relocation != null && relocation.populationToRelocate > 0) {
    final candidates = jsonDecode(relocation.rankedCandidatesJson) as List;
    if (candidates.isNotEmpty) {
      final top = candidates.first as Map<String, dynamic>;
      final distanceKm = ((top['distanceMeters'] as num) / 1000).toStringAsFixed(1);
      buffer.write('\nBest relocation option: ${top['shelterName']} ($distanceKm km)');
    } else {
      buffer.write('\nNo safe relocation candidate found nearby');
    }
  }

  return buffer.toString();
}

/// M11's recommended routes, each colored green when every segment cleared
/// the hazard/blockage checks and orange when it's a detour (or the best
/// still-imperfect option) around a blocked/hazard-exposed direct path.
PolylineLayer buildRouteLayer(List<LocalRoute> routes) {
  return PolylineLayer(
    polylines: [
      for (final route in routes)
        Polyline(
          points: decodePolygonPoints(route.polylineJson),
          strokeWidth: 4,
          color: route.isSafe ? Colors.green.shade700 : Colors.orange.shade900,
        ),
    ],
  );
}

/// M14 made visible: once a second independent source corroborates an
/// incident, the tooltip says so — a citizen shouldn't have to guess
/// whether a marker represents one report or several agreeing accounts.
String _incidentTooltip(LocalIncident incident) {
  final label = incident.description.isEmpty ? incident.type : incident.description;
  if (incident.independentSourceCount <= 1) return label;
  return '$label\nConfirmed by ${incident.independentSourceCount} independent sources '
      '(${(incident.confidence * 100).round()}% confidence)';
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
            message: _incidentTooltip(incident),
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
