import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/features/disaster_events/application/disaster_event_processor.dart';
import 'package:taarak/features/disaster_events/application/government_alert_parser.dart';
import 'package:taarak/features/hazards/application/hazard_providers.dart';

final governmentAlertParserProvider = Provider<GovernmentAlertParser>(
  (ref) => GovernmentAlertParser(),
);

final disasterEventProcessorProvider = Provider<DisasterEventProcessor>(
  (ref) => DisasterEventProcessor(
    hazardIngestionService: ref.watch(hazardIngestionServiceProvider),
  ),
);
