import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/providers/core_providers.dart';

/// Map layers read straight from the M03 local cache — the same data a
/// future sync pass (M17) will keep filled from the backend. A cache read
/// failure degrades to an empty layer (logged by the repository) rather
/// than crashing the map; there's nothing more useful to show either way.
final hazardZonesProvider = FutureProvider<List<LocalHazardZone>>((ref) async {
  final result = await ref.watch(localHazardZoneRepositoryProvider).getAll();
  return result.dataOrNull ?? const [];
});

final sheltersProvider = FutureProvider<List<LocalShelter>>((ref) async {
  final result = await ref.watch(localShelterRepositoryProvider).getAll();
  return result.dataOrNull ?? const [];
});

final incidentsProvider = FutureProvider<List<LocalIncident>>((ref) async {
  final result = await ref.watch(localIncidentRepositoryProvider).getAll();
  return result.dataOrNull ?? const [];
});
