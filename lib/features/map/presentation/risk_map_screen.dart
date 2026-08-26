import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/default_map_center.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/map/application/map_search.dart';
import 'package:taarak/features/map/presentation/widgets/map_legend.dart';
import 'package:taarak/features/map/presentation/widgets/map_overlay_layers.dart';
import 'package:taarak/features/map/presentation/widgets/map_search_bar.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_controller.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_view.dart';
import 'package:taarak/features/profile/application/location_status_controller.dart';
import 'package:taarak/features/routing/application/routing_providers.dart';
import 'package:taarak/features/routing/domain/route_candidate.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

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
  final _mapController = TaarakMapController();
  bool _hasCenteredOnUser = false;
  bool _hasFitToData = false;
  bool _isRouting = false;

  @override
  void initState() {
    super.initState();
    // If a location isn't already cached (e.g. nobody has visited Profile
    // yet this session), ask for one now — a map screen centering on a
    // fixed point instead of the user is exactly the bug this fixes.
    final cached = ref.read(locationStatusProvider).valueOrNull?.geoTag;
    if (cached == null) {
      ref.read(locationStatusProvider.notifier).refresh();
    }
  }

  Future<void> _routeToShelter(LocalShelter shelter, LatLng? userPoint) async {
    final messenger = ScaffoldMessenger.of(context);
    if (userPoint == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Your location isn\'t available yet — try again in a moment.'),
        ),
      );
      return;
    }

    setState(() => _isRouting = true);
    final result = await ref
        .read(routingServiceProvider)
        .planRoute(origin: userPoint, destination: LatLng(shelter.latitude, shelter.longitude));
    if (!mounted) return;
    setState(() => _isRouting = false);

    switch (result) {
      case Success<RoutePlan>(:final data):
        ref.invalidate(routesProvider);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              data.primaryRoute.isSafe
                  ? 'Route to ${shelter.name} ready — clear of known hazards.'
                  : 'Route to ${shelter.name} ready — passes near a hazard zone, proceed with caution.',
            ),
          ),
        );
      case Failed<RoutePlan>(:final failure):
        messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hazardZones = ref.watch(hazardZonesProvider).valueOrNull ?? const [];
    final shelters = ref.watch(sheltersProvider).valueOrNull ?? const [];
    final incidents = ref.watch(incidentsProvider).valueOrNull ?? const [];
    final habitations =
        ref.watch(habitationsOverviewProvider).valueOrNull ?? const [];
    final routes = ref.watch(routesProvider).valueOrNull ?? const [];

    ref.listen(locationStatusProvider, (previous, next) {
      final fix = next.valueOrNull?.geoTag?.fix;
      if (fix == null || _hasCenteredOnUser) return;
      _hasCenteredOnUser = true;
      _mapController.move(LatLng(fix.latitude, fix.longitude), 15);
    });
    final geoTag = ref.watch(locationStatusProvider).valueOrNull?.geoTag;
    final userPoint = geoTag == null
        ? null
        : LatLng(geoTag.fix.latitude, geoTag.fix.longitude);
    if (userPoint != null) _hasCenteredOnUser = true;

    // Without a GPS fix, the map opens on the whole-country default view —
    // fine as a fallback, but a hazard zone's few-hundred-meter radius is
    // literally invisible at that zoom. Once real data exists, frame it
    // instead of leaving an official staring at an empty subcontinent.
    if (!_hasCenteredOnUser && !_hasFitToData) {
      final dataPoints = <LatLng>[
        for (final shelter in shelters) LatLng(shelter.latitude, shelter.longitude),
        for (final incident in incidents) LatLng(incident.latitude, incident.longitude),
        for (final zone in hazardZones) ...decodePolygonPoints(zone.geometryJson),
      ];
      if (dataPoints.isNotEmpty) {
        _hasFitToData = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mapController.fitBounds(dataPoints);
        });
      }
    }

    final searchIndex = buildSearchIndex(
      hazardZones: hazardZones,
      shelters: shelters,
      incidents: incidents,
    );

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Risk Map'),
      body: Stack(
        children: [
          TaarakMapView(
            initialCenter: userPoint ?? defaultMapCenter,
            initialZoom: userPoint != null ? 15 : defaultMapZoom,
            mapController: _mapController,
            polygons: buildHazardZoneLayer(hazardZones),
            markers: {
              ...buildShelterLayer(
                shelters,
                onTap: (shelter) => _routeToShelter(shelter, userPoint),
              ),
              ...buildIncidentLayer(incidents),
              ...buildHabitationLayer(habitations),
            },
            polylines: buildRouteLayer(routes),
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
          if (_isRouting)
            const Positioned(
              top: 70,
              left: 12,
              right: 12,
              child: LinearProgressIndicator(),
            ),
          const Positioned(bottom: 12, right: 12, child: MapLegend()),
          Positioned(
            bottom: 12,
            left: 12,
            child: FloatingActionButton(
              heroTag: 'risk-map-recenter',
              tooltip: 'Center on my location',
              onPressed: () async {
                final result = await ref
                    .read(locationStatusProvider.notifier)
                    .refresh();
                final fix = result.dataOrNull?.fix;
                if (fix != null) {
                  _mapController.move(LatLng(fix.latitude, fix.longitude), 15);
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
