import 'package:latlong2/latlong.dart';
import 'package:taarak/features/routing/domain/route_segment_assessment.dart';

/// M11's model version — bump when the routing/detour formula changes,
/// same rationale as M07-M10's model versions.
const String routingModelVersion = '1.0.0';

/// One candidate path from origin to destination, segment-by-segment
/// assessed for hazard exposure and blockage.
class RouteCandidate {
  final List<LatLng> points;
  final List<RouteSegmentAssessment> segments;
  final double distanceMeters;
  final int etaSeconds;

  const RouteCandidate({
    required this.points,
    required this.segments,
    required this.distanceMeters,
    required this.etaSeconds,
  });

  bool get isSafe => segments.every((segment) => segment.isSafe);
}

/// The engine's output for one origin/destination pair: the recommended
/// route (safe if any candidate achieved that) plus whichever other
/// candidates were considered — the "alternatives" the acceptance
/// criterion calls out.
class RoutePlan {
  final LatLng origin;
  final LatLng destination;
  final RouteCandidate primaryRoute;
  final List<RouteCandidate> alternativeRoutes;
  final String modelVersion;
  final DateTime plannedAt;

  const RoutePlan({
    required this.origin,
    required this.destination,
    required this.primaryRoute,
    required this.alternativeRoutes,
    required this.modelVersion,
    required this.plannedAt,
  });
}
