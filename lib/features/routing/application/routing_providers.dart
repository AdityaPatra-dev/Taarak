import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/routing/application/risk_aware_routing_engine.dart';
import 'package:taarak/features/routing/application/routing_service.dart';

final riskAwareRoutingEngineProvider = Provider<RiskAwareRoutingEngine>(
  (ref) => RiskAwareRoutingEngine(),
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
  ),
);
