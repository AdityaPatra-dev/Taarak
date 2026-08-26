import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_controller.dart';

/// The shared base map every map screen builds on (the citizen Risk Map,
/// the official dashboard's situation map, and both officials' tap-to-place
/// forms for hazards/shelters) — owns only the Google Maps view itself,
/// with overlays supplied by the caller so this stays reusable across those
/// screens.
class TaarakMapView extends StatelessWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final Set<gmaps.Marker> markers;
  final Set<gmaps.Polygon> polygons;
  final Set<gmaps.Polyline> polylines;
  final TaarakMapController? mapController;
  final void Function(LatLng point)? onTap;

  const TaarakMapView({
    super.key,
    required this.initialCenter,
    this.initialZoom = 13,
    this.markers = const {},
    this.polygons = const {},
    this.polylines = const {},
    this.mapController,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(initialCenter.latitude, initialCenter.longitude),
        zoom: initialZoom,
      ),
      onMapCreated: (controller) => mapController?.attach(controller),
      onTap: onTap == null
          ? null
          : (point) => onTap!(LatLng(point.latitude, point.longitude)),
      markers: markers,
      polygons: polygons,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
