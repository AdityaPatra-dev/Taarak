import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/environmental/application/demo_environmental_data_source.dart';
import 'package:taarak/features/environmental/application/environmental_data_service.dart';
import 'package:taarak/features/environmental/application/environmental_data_source.dart';
import 'package:taarak/features/environmental/application/environmental_risk_engine.dart';

final environmentalDataSourceProvider = Provider<EnvironmentalDataSource>(
  (ref) => DemoEnvironmentalDataSource(),
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
