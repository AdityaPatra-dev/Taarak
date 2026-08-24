import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/capacity/application/capacity_providers.dart';
import 'package:taarak/features/environmental/application/environmental_providers.dart';
import 'package:taarak/features/hazards/application/hazard_providers.dart';
import 'package:taarak/features/map/application/demo_map_data_seeder.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/map/application/map_search.dart';
import 'package:taarak/features/map/presentation/widgets/map_legend.dart';
import 'package:taarak/features/map/presentation/widgets/map_overlay_layers.dart';
import 'package:taarak/features/map/presentation/widgets/map_search_bar.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_view.dart';
import 'package:taarak/features/relocation/application/relocation_providers.dart';
import 'package:taarak/features/risk/application/risk_providers.dart';
import 'package:taarak/features/routing/application/routing_providers.dart';

/// Citizen "Risk Map" screen (blueprint section 4). Also the reference
/// composition of [TaarakMapView] + overlay layers that the official
/// Incident Map / Risk & Red-Zone Map screens will follow once those
/// modules land — same base map, different layer selection.
class RiskMapScreen extends ConsumerStatefulWidget {
  const RiskMapScreen({super.key});

  @override
  ConsumerState<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends ConsumerState<RiskMapScreen> {
  final _mapController = MapController();
  bool _isSeeding = false;

  Future<void> _seedDemoData() async {
    setState(() => _isSeeding = true);
    await DemoMapDataSeeder(
      ref.read(appDatabaseProvider),
      ref.read(hazardIngestionServiceProvider),
    ).seedIfEmpty();

    // M24: refresh environmental readings before M07 assesses risk, so
    // the assessment below has fresh data available to be influenced by.
    final environmentalDataService = ref.read(environmentalDataServiceProvider);
    final habitationsResult = await ref.read(localHabitationRepositoryProvider).getAll();
    for (final habitation in habitationsResult.dataOrNull ?? const []) {
      await environmentalDataService.refreshForHabitation(
        habitationId: habitation.id,
        latitude: habitation.latitude,
        longitude: habitation.longitude,
      );
    }

    await ref.read(riskAssessmentServiceProvider).assessAllHabitations();
    await ref.read(capacityAssessmentServiceProvider).assessAllHabitations();
    await ref.read(relocationPlanningServiceProvider).planForAllHabitations();
    await ref
        .read(routingServiceProvider)
        .planEvacuationRoutesForAllHabitations();
    ref.invalidate(hazardZonesProvider);
    ref.invalidate(sheltersProvider);
    ref.invalidate(incidentsProvider);
    ref.invalidate(habitationsOverviewProvider);
    ref.invalidate(routesProvider);
    if (mounted) setState(() => _isSeeding = false);
  }

  @override
  Widget build(BuildContext context) {
    final hazardZones = ref.watch(hazardZonesProvider).valueOrNull ?? const [];
    final shelters = ref.watch(sheltersProvider).valueOrNull ?? const [];
    final incidents = ref.watch(incidentsProvider).valueOrNull ?? const [];
    final habitations =
        ref.watch(habitationsOverviewProvider).valueOrNull ?? const [];
    final routes = ref.watch(routesProvider).valueOrNull ?? const [];
    final isDevMode = ref.watch(appConfigProvider).isDevMode;

    final searchIndex = buildSearchIndex(
      hazardZones: hazardZones,
      shelters: shelters,
      incidents: incidents,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Risk Map')),
      body: Stack(
        children: [
          TaarakMapView(
            initialCenter: DemoMapDataSeeder.demoCenter,
            mapController: _mapController,
            overlayLayers: [
              buildHazardZoneLayer(hazardZones),
              buildShelterLayer(shelters),
              buildIncidentLayer(incidents),
              buildHabitationLayer(habitations),
              buildRouteLayer(routes),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: MapSearchBar(
              index: searchIndex,
              onSelect: (result) => _mapController.move(result.point, 15),
            ),
          ),
          const Positioned(bottom: 12, right: 12, child: MapLegend()),
          if (isDevMode)
            Positioned(
              bottom: 12,
              left: 12,
              child: FloatingActionButton.extended(
                onPressed: _isSeeding ? null : _seedDemoData,
                icon: _isSeeding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.data_object),
                label: const Text('Load demo data'),
              ),
            ),
        ],
      ),
    );
  }
}
