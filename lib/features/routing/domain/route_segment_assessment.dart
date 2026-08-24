import 'package:latlong2/latlong.dart';

/// One leg of a candidate route, checked against current hazard zones and
/// blocked-road incidents — the "blocked/unsafe segments" the acceptance
/// criterion calls out by name.
class RouteSegmentAssessment {
  final LatLng start;
  final LatLng end;
  final bool isHazardExposed;
  final bool isBlocked;
  final List<String> reasons;

  const RouteSegmentAssessment({
    required this.start,
    required this.end,
    required this.isHazardExposed,
    required this.isBlocked,
    required this.reasons,
  });

  bool get isSafe => !isHazardExposed && !isBlocked;
}
