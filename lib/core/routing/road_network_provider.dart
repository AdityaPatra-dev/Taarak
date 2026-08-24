import 'package:latlong2/latlong.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/core/routing/road_route.dart';

/// Abstracts fetching real, road-following route geometry behind our own
/// interface — same reasoning as [[LocationService]]/[[NetworkInfo]]/
/// [[EnvironmentalDataSource]]: the routing provider is swappable, and
/// [[RiskAwareRoutingEngine]]'s hazard/blockage logic never needs to know
/// which one produced the points it's assessing. When no real route can
/// be obtained (offline, provider unreachable), [RoutingService] falls
/// back to the engine's own straight-line/detour geometry — this is never
/// the only way a route gets planned.
abstract class RoadNetworkProvider {
  Future<Result<RoadRoute>> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  });
}
