import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';

/// Thin wrapper around [gmaps.GoogleMapController] matching the shape
/// callers already used with flutter_map's synchronous `MapController` —
/// Google Maps only hands back its controller asynchronously (via
/// `onMapCreated`), so calls made before the map finishes initializing
/// queue on [_ready] instead of callers needing to know/handle that.
class TaarakMapController {
  final Completer<gmaps.GoogleMapController> _ready = Completer();

  void attach(gmaps.GoogleMapController controller) {
    if (!_ready.isCompleted) _ready.complete(controller);
  }

  Future<void> move(LatLng point, double zoom) async {
    final controller = await _ready.future;
    await controller.animateCamera(
      gmaps.CameraUpdate.newLatLngZoom(
        gmaps.LatLng(point.latitude, point.longitude),
        zoom,
      ),
    );
  }

  Future<void> fitBounds(
    List<LatLng> points, {
    double paddingPixels = 48,
  }) async {
    if (points.isEmpty) return;
    if (points.length == 1) {
      await move(points.first, 15);
      return;
    }

    final controller = await _ready.future;
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final point in points.skip(1)) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    await controller.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(
        gmaps.LatLngBounds(
          southwest: gmaps.LatLng(minLat, minLng),
          northeast: gmaps.LatLng(maxLat, maxLng),
        ),
        paddingPixels,
      ),
    );
  }
}
