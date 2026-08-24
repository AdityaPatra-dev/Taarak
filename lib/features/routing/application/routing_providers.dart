import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/core/routing/osrm_road_network_provider.dart';
import 'package:taarak/core/routing/road_network_provider.dart';
import 'package:taarak/features/routing/application/risk_aware_routing_engine.dart';
import 'package:taarak/features/routing/application/routing_service.dart';

final riskAwareRoutingEngineProvider = Provider<RiskAwareRoutingEngine>(
  (ref) => RiskAwareRoutingEngine(),
);

final roadNetworkProviderProvider = Provider<RoadNetworkProvider>(
  (ref) => OsrmRoadNetworkProvider(networkInfo: ref.watch(networkInfoProvider)),
);

final routingServiceProvider = Provider<RoutingService>(
  (ref) => RoutingService(
    hazardZoneRepository: ref.watch(localHazardZoneRepositoryProvider),
    incidentRepository: ref.watch(localIncidentRepositoryProvider),
    routeRepository: ref.watch(localRouteRepositoryProvider),
    habitationRepository: ref.watch(localHabitationRepositoryProvider),
    relocationPlanRepository: ref.watch(localRelocationPlanRepositoryProvider),
    shelterRepository: ref.watch(localShelterRepositoryProvider),
    engine: ref.watch(riskAwareRoutingEngineProvider),
    roadNetworkProvider: ref.watch(roadNetworkProviderProvider),
  ),
);
