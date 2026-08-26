import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/features/map/presentation/widgets/caching_tile_provider.dart';

/// The shared base map every map screen builds on (this citizen Risk Map
/// today; the official Incident Map / Risk & Red-Zone Map and M18's
/// command dashboard map later). Owns only the base tile layer and offline
/// caching — hazard/shelter/incident overlays are supplied by the caller
/// via [overlayLayers] so this widget stays reusable across those screens.
class TaarakMapView extends StatelessWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final List<Widget> overlayLayers;
  final MapController? mapController;
  final void Function(LatLng point)? onTap;

  const TaarakMapView({
    super.key,
    required this.initialCenter,
    this.initialZoom = 13,
    this.overlayLayers = const [],
    this.mapController,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        onTap: onTap == null ? null : (_, point) => onTap!(point),
      ),
      children: [
        TileLayer(
          // OpenStreetMap's shared tile server — fine for development and
          // this scale of demo. A production deployment should switch to a
          // dedicated provider (self-hosted or e.g. MapTiler/Stadia Maps)
          // per OSM's tile usage policy.
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.taarak.app',
          tileProvider: CachingTileProvider(),
        ),
        ...overlayLayers,
      ],
    );
  }
}
