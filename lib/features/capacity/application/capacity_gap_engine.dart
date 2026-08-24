import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/hazard_exposure.dart';
import 'package:taarak/features/capacity/domain/capacity_gap_result.dart';

const _distance = Distance();

/// M09's deterministic core: "safe capacity" excludes any shelter that's
/// itself sitting inside a current hazard zone (free beds don't help if
/// the shelter would need evacuating too), and excludes shelters beyond a
/// reasonable evacuation catchment radius. Pure — given the same
/// habitation, shelters and hazard zones, always the same gap.
///
/// This is per-habitation only: it doesn't resolve contention between
/// habitations competing for the same nearby shelter. Allocating capacity
/// across multiple habitations is M10 (Relocation)'s job, not this one's.
class CapacityGapEngine {
  static const double defaultAccessibleRadiusMeters = 15000;

  CapacityGapResult assess({
    required LocalHabitation habitation,
    required int exposedPopulation,
    required List<LocalShelter> shelters,
    required List<LocalHazardZone> hazardZones,
    double accessibleRadiusMeters = defaultAccessibleRadiusMeters,
    DateTime? now,
  }) {
    final habitationPoint = LatLng(habitation.latitude, habitation.longitude);

    final contributing = <ContributingShelter>[];
    for (final shelter in shelters) {
      final shelterPoint = LatLng(shelter.latitude, shelter.longitude);

      if (isPointHazardExposed(shelterPoint, hazardZones)) continue;

      final distanceMeters = _distance.as(
        LengthUnit.Meter,
        habitationPoint,
        shelterPoint,
      );
      if (distanceMeters > accessibleRadiusMeters) continue;

      final available = shelter.capacityTotal - shelter.occupancy;
      if (available <= 0) continue;

      contributing.add(
        ContributingShelter(
          shelterId: shelter.id,
          shelterName: shelter.name,
          availableCapacity: available,
          distanceMeters: distanceMeters,
        ),
      );
    }
    contributing.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    final totalAvailable = contributing.fold<int>(
      0,
      (sum, shelter) => sum + shelter.availableCapacity,
    );

    return CapacityGapResult(
      habitationId: habitation.id,
      exposedPopulation: exposedPopulation,
      availableSafeCapacity: totalAvailable,
      capacityGap: exposedPopulation - totalAvailable,
      contributingShelters: contributing,
      accessibleRadiusMeters: accessibleRadiusMeters,
      modelVersion: capacityModelVersion,
      assessedAt: now ?? DateTime.now(),
    );
  }
}
