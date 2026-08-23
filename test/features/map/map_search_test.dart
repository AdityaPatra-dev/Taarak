import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/features/map/application/map_search.dart';
import 'package:latlong2/latlong.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1);

  final hazardZones = [
    LocalHazardZone(
      id: 'h1',
      hazardType: 'landslide',
      severity: 'high',
      geometryJson: encodePolygonPoints([const LatLng(1, 1), const LatLng(1, 2)]),
      source: 'test',
      observedAt: now,
      confidence: 1,
      updatedAt: now,
      version: 1,
    ),
  ];
  final shelters = [
    LocalShelter(
      id: 's1',
      name: 'Community Hall',
      latitude: 2,
      longitude: 2,
      capacityTotal: 0,
      occupancy: 0,
      facilitiesJson: '[]',
      updatedAt: now,
      version: 1,
    ),
  ];
  final incidents = [
    LocalIncident(
      id: 'i1',
      type: 'road_blockage',
      status: 'active',
      latitude: 3,
      longitude: 3,
      description: 'Road blocked by debris',
      severity: 'medium',
      createdAt: now,
      updatedAt: now,
      version: 1,
      isSynced: false,
    ),
  ];

  test('the search index includes hazard zones, shelters and incidents', () {
    final index = buildSearchIndex(
      hazardZones: hazardZones,
      shelters: shelters,
      incidents: incidents,
    );

    expect(index.map((r) => r.label), containsAll(['landslide hazard zone', 'Community Hall', 'Road blocked by debris']));
  });

  test('filtering is case-insensitive and matches on substrings', () {
    final index = buildSearchIndex(
      hazardZones: hazardZones,
      shelters: shelters,
      incidents: incidents,
    );

    expect(filterSearchIndex(index, 'community').map((r) => r.label), ['Community Hall']);
    expect(filterSearchIndex(index, 'BLOCKED').map((r) => r.label), ['Road blocked by debris']);
  });

  test('an empty query returns no results rather than everything', () {
    final index = buildSearchIndex(
      hazardZones: hazardZones,
      shelters: shelters,
      incidents: incidents,
    );

    expect(filterSearchIndex(index, ''), isEmpty);
    expect(filterSearchIndex(index, '   '), isEmpty);
  });
}
