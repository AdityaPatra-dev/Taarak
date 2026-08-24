import 'package:latlong2/latlong.dart';

/// A real, road-following path between two points, as returned by a
/// [RoadNetworkProvider] — distinct from the app's own straight-line
/// fallback geometry.
class RoadRoute {
  final List<LatLng> points;
  final double distanceMeters;
  final int etaSeconds;

  const RoadRoute({
    required this.points,
    required this.distanceMeters,
    required this.etaSeconds,
  });
}
