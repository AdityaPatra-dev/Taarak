import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/gis/severity_palette.dart';
import 'package:taarak/features/map/domain/habitation_overview.dart';
import 'package:taarak/features/map/domain/road_blockage.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';
import 'package:taarak/features/risk/presentation/risk_class_color.dart';

gmaps.LatLng _toG(double lat, double lng) => gmaps.LatLng(lat, lng);

/// Google Maps markers only tint a standard pin by hue (0–360), not an
/// arbitrary [Color] — the closest a marker glyph can get to this app's
/// severity/status palette without shipping custom bitmap icons.
double _markerHue(Color color) => HSVColor.fromColor(color).hue;

Set<gmaps.Polygon> buildHazardZoneLayer(List<LocalHazardZone> hazardZones) {
  return {
    for (final zone in hazardZones)
      gmaps.Polygon(
        polygonId: gmaps.PolygonId('hazard-${zone.id}'),
        points: [
          for (final point in decodePolygonPoints(zone.geometryJson))
            _toG(point.latitude, point.longitude),
        ],
        fillColor: severityColor(zone.severity).withValues(alpha: 0.35),
        strokeColor: severityColor(zone.severity),
        strokeWidth: 2,
      ),
  };
}

/// M15 made visible: a citizen deciding where to go should see whether a
/// shelter still has room, not just that it exists.
String _shelterTooltip(LocalShelter shelter) {
  final available = shelter.capacityTotal - shelter.occupancy;
  if (shelter.capacityTotal <= 0) return shelter.name;
  return '${shelter.occupancy}/${shelter.capacityTotal} occupied '
      '(${available > 0 ? '$available available' : 'full'})';
}

/// [onTap], when given, turns each marker into "get directions here" —
/// used by the citizen Risk Map to trigger M11 routing without a separate
/// shelter-picker screen.
Set<gmaps.Marker> buildShelterLayer(
  List<LocalShelter> shelters, {
  void Function(LocalShelter shelter)? onTap,
}) {
  return {
    for (final shelter in shelters)
      gmaps.Marker(
        markerId: gmaps.MarkerId('shelter-${shelter.id}'),
        position: _toG(shelter.latitude, shelter.longitude),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          shelter.capacityTotal > 0 && shelter.occupancy >= shelter.capacityTotal
              ? gmaps.BitmapDescriptor.hueAzure
              : gmaps.BitmapDescriptor.hueBlue,
        ),
        infoWindow: gmaps.InfoWindow(
          title: shelter.name,
          snippet: onTap == null
              ? _shelterTooltip(shelter)
              : '${_shelterTooltip(shelter)} · Tap for directions',
        ),
        onTap: onTap == null ? null : () => onTap(shelter),
      ),
  };
}

/// M07's risk assessment made visible: each habitation renders in its risk
/// class color, with the tooltip spelling out the factor breakdown the
/// engine produced (hazard exposure, vulnerability, weights) plus M09's
/// capacity gap — not just the score.
Set<gmaps.Marker> buildHabitationLayer(List<HabitationOverview> habitations) {
  return {
    for (final item in habitations)
      gmaps.Marker(
        markerId: gmaps.MarkerId('habitation-${item.habitation.id}'),
        position: _toG(item.habitation.latitude, item.habitation.longitude),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          item.riskAssessment == null
              ? gmaps.BitmapDescriptor.hueViolet
              : _markerHue(
                  riskClassColor(RiskClass.values.byName(item.riskAssessment!.riskClass)),
                ),
        ),
        infoWindow: gmaps.InfoWindow(
          title: item.habitation.name,
          snippet: _habitationTooltip(item),
        ),
      ),
  };
}

String _habitationTooltip(HabitationOverview item) {
  final risk = item.riskAssessment;
  final capacity = item.capacityAssessment;

  final buffer = StringBuffer();

  if (risk == null) {
    buffer.write('Not yet assessed');
  } else {
    buffer.write(
      '${riskClassLabel(RiskClass.values.byName(risk.riskClass))} '
      '(score ${risk.riskScore.toStringAsFixed(2)}) — '
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
        ' · +${risk.environmentalAdjustment.toStringAsFixed(2)} from environmental data ($sources)',
      );
    }
  }

  if (capacity != null && capacity.exposedPopulation > 0) {
    buffer.write(
      capacity.hasSufficientCapacity
          ? ' · Capacity sufficient (${capacity.availableSafeCapacity} available for ${capacity.exposedPopulation})'
          : ' · Capacity gap: short by ${capacity.capacityGap} '
                '(${capacity.availableSafeCapacity} available for ${capacity.exposedPopulation})',
    );
  }

  final relocation = item.relocationPlan;
  if (relocation != null && relocation.populationToRelocate > 0) {
    final candidates = jsonDecode(relocation.rankedCandidatesJson) as List;
    if (candidates.isNotEmpty) {
      final top = candidates.first as Map<String, dynamic>;
      final distanceKm = ((top['distanceMeters'] as num) / 1000).toStringAsFixed(1);
      buffer.write(' · Best relocation: ${top['shelterName']} ($distanceKm km)');
    } else {
      buffer.write(' · No safe relocation candidate found nearby');
    }
  }

  return buffer.toString();
}

/// M11's recommended routes, each colored green when every segment cleared
/// the hazard/blockage checks and orange when it's a detour (or the best
/// still-imperfect option) around a blocked/hazard-exposed direct path.
/// Solid means the geometry came from a real road-network provider; dashed
/// means it's the offline/no-provider straight-line estimate — a route is
/// never shown in a way that could be mistaken for the other kind.
Set<gmaps.Polyline> buildRouteLayer(List<LocalRoute> routes) {
  return {
    for (final route in routes)
      gmaps.Polyline(
        polylineId: gmaps.PolylineId('route-${route.id}'),
        points: [
          for (final point in decodePolygonPoints(route.polylineJson))
            _toG(point.latitude, point.longitude),
        ],
        width: 4,
        color: route.isSafe ? Colors.green.shade700 : Colors.orange.shade900,
        patterns: route.isRoadSnapped
            ? const []
            : [gmaps.PatternItem.dash(20), gmaps.PatternItem.gap(12)],
      ),
  };
}

/// M14 made visible: once a second independent source corroborates an
/// incident, the tooltip says so — a citizen shouldn't have to guess
/// whether a marker represents one report or several agreeing accounts.
String _incidentTooltip(LocalIncident incident) {
  final label = incident.description.isEmpty ? incident.type : incident.description;
  if (incident.independentSourceCount <= 1) return label;
  return '$label · Confirmed by ${incident.independentSourceCount} independent sources '
      '(${(incident.confidence * 100).round()}% confidence)';
}

Set<gmaps.Marker> buildIncidentLayer(List<LocalIncident> incidents) {
  return {
    for (final incident in incidents)
      gmaps.Marker(
        markerId: gmaps.MarkerId('incident-${incident.id}'),
        position: _toG(incident.latitude, incident.longitude),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          _markerHue(severityColor(incident.severity)),
        ),
        infoWindow: gmaps.InfoWindow(
          title: incident.type == roadBlockageIncidentType
              ? 'Blocked road'
              : 'Incident',
          snippet: _incidentTooltip(incident),
        ),
      ),
  };
}
