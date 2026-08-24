import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/environmental/application/environmental_data_service.dart';
import 'package:taarak/features/environmental/application/environmental_data_source.dart';
import 'package:taarak/features/environmental/application/environmental_risk_engine.dart';
import 'package:taarak/features/environmental/application/open_meteo_data_source.dart';

/// M24 originally shipped with [[DemoEnvironmentalDataSource]] as the
/// default (a deterministic stand-in, since no real backend existed at
/// the time). It now defaults to the real Open-Meteo feed; the demo
/// source stays in the codebase for tests and as a fallback reference,
/// not deleted.
final environmentalDataSourceProvider = Provider<EnvironmentalDataSource>(
  (ref) => OpenMeteoDataSource(networkInfo: ref.watch(networkInfoProvider)),
);

final environmentalRiskEngineProvider = Provider<EnvironmentalRiskEngine>(
  (ref) => EnvironmentalRiskEngine(),
);

final environmentalDataServiceProvider = Provider<EnvironmentalDataService>(
  (ref) => EnvironmentalDataService(
    dataSource: ref.watch(environmentalDataSourceProvider),
    repository: ref.watch(localEnvironmentalObservationRepositoryProvider),
    engine: ref.watch(environmentalRiskEngineProvider),
  ),
);
