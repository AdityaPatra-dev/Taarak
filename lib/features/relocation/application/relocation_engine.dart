import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/hazard_exposure.dart';
import 'package:taarak/features/relocation/domain/relocation_candidate.dart';

const _distance = Distance();

/// M10's deterministic core: ranks shelters as relocation destinations for
/// one habitation. Two hard gates come first — hazard exclusion and
/// capacity — matching the spec's own ordering ("hazard exclusion,
/// capacity, distance, access and facilities"); a shelter that's itself
/// hazard-exposed or already full is never a candidate at all, no matter
/// how good its other factors are. The remaining candidates are then
/// scored on distance, capacity headroom, access and facilities.
///
/// Unlike M09's capacity gap, distance here is scored, not a hard cutoff —
/// a relocation plan should still surface the best available option even
/// if it's far, rather than reporting no candidates at all.
class RelocationEngine {
  static const double distanceWeight = 0.3;
  static const double capacityWeight = 0.3;
  static const double accessWeight = 0.2;
  static const double facilitiesWeight = 0.2;

  static const double defaultMaxRelevantDistanceMeters = 15000;
  static const int facilitiesReferenceCount = 3;

  RelocationPlan plan({
    required LocalHabitation habitation,
    required int populationToRelocate,
    required List<LocalShelter> shelters,
    required List<LocalHazardZone> hazardZones,
    double maxRelevantDistanceMeters = defaultMaxRelevantDistanceMeters,
    DateTime? now,
  }) {
    final habitationPoint = LatLng(habitation.latitude, habitation.longitude);

    final candidates = <RelocationCandidate>[];
    for (final shelter in shelters) {
      final shelterPoint = LatLng(shelter.latitude, shelter.longitude);

      if (isPointHazardExposed(shelterPoint, hazardZones)) continue;

      final availableCapacity = shelter.capacityTotal - shelter.occupancy;
      if (availableCapacity <= 0) continue;

      final distanceMeters = _distance.as(
        LengthUnit.Meter,
        habitationPoint,
        shelterPoint,
      );
      final distanceScore = (1 - distanceMeters / maxRelevantDistanceMeters)
          .clamp(0.0, 1.0);

      final capacityScore = populationToRelocate <= 0
          ? 1.0
          : (availableCapacity / populationToRelocate).clamp(0.0, 1.0);

      final accessScore = (1 - (shelter.accessQuality ?? 0.5)).clamp(0.0, 1.0);

      final facilities = _decodeFacilities(shelter.facilitiesJson);
      final facilitiesScore = (facilities.length / facilitiesReferenceCount)
          .clamp(0.0, 1.0);

      final compositeScore = distanceWeight * distanceScore +
          capacityWeight * capacityScore +
          accessWeight * accessScore +
          facilitiesWeight * facilitiesScore;

      candidates.add(
        RelocationCandidate(
          shelterId: shelter.id,
          shelterName: shelter.name,
          availableCapacity: availableCapacity,
          distanceMeters: distanceMeters,
          distanceScore: distanceScore,
          capacityScore: capacityScore,
          accessScore: accessScore,
          facilitiesScore: facilitiesScore,
          compositeScore: compositeScore,
          reasons: _buildReasons(
            distanceMeters: distanceMeters,
            availableCapacity: availableCapacity,
            populationToRelocate: populationToRelocate,
            accessQuality: shelter.accessQuality,
            accessScore: accessScore,
            facilities: facilities,
          ),
        ),
      );
    }

    candidates.sort((a, b) => b.compositeScore.compareTo(a.compositeScore));

    return RelocationPlan(
      habitationId: habitation.id,
      populationToRelocate: populationToRelocate,
      rankedCandidates: candidates,
      modelVersion: relocationModelVersion,
      plannedAt: now ?? DateTime.now(),
    );
  }

  List<String> _decodeFacilities(String facilitiesJson) {
    try {
      final decoded = jsonDecode(facilitiesJson);
      return decoded is List ? decoded.map((f) => f.toString()).toList() : const [];
    } on FormatException {
      return const [];
    }
  }

  List<String> _buildReasons({
    required double distanceMeters,
    required int availableCapacity,
    required int populationToRelocate,
    required double? accessQuality,
    required double accessScore,
    required List<String> facilities,
  }) {
    return [
      '${(distanceMeters / 1000).toStringAsFixed(1)} km away',
      availableCapacity >= populationToRelocate
          ? '$availableCapacity spaces available (covers all $populationToRelocate people)'
          : '$availableCapacity spaces available (short of the $populationToRelocate people needing shelter)',
      accessQuality == null
          ? 'Access not yet surveyed'
          : (accessScore >= 0.5 ? 'Good road access' : 'Difficult road access'),
      facilities.isEmpty
          ? 'No special facilities recorded'
          : 'Facilities: ${facilities.join(', ')}',
    ];
  }
}
