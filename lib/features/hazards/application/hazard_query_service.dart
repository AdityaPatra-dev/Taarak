import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/hazards/domain/hazard_freshness.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';

/// The read side of M06: "Hazard layer is queryable" — narrows the full
/// cached set by type and/or freshness. Filters in memory since the local
/// hazard set is small; a DB-level query isn't needed at this scale.
class HazardQueryService {
  final LocalHazardZoneRepository _repository;

  HazardQueryService(this._repository);

  Future<Result<List<LocalHazardZone>>> query({
    Set<HazardType>? hazardTypes,
    HazardFreshness? minFreshness,
    DateTime? now,
  }) async {
    final result = await _repository.getAll();
    return result.when(
      success: (zones) {
        final currentTime = now ?? DateTime.now();
        var filtered = zones;

        if (hazardTypes != null) {
          final storageValues = hazardTypes.map((t) => t.storageValue).toSet();
          filtered = filtered
              .where((zone) => storageValues.contains(zone.hazardType))
              .toList();
        }

        if (minFreshness != null) {
          filtered = filtered.where((zone) {
            final age = currentTime.difference(zone.observedAt);
            return classifyFreshness(age).index <= minFreshness.index;
          }).toList();
        }

        return Result.success(filtered);
      },
      failure: (failure) => Result.failure(failure),
    );
  }
}
