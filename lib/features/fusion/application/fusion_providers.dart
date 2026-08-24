import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/features/fusion/application/ground_truth_fusion_engine.dart';

final groundTruthFusionEngineProvider = Provider<GroundTruthFusionEngine>(
  (ref) => GroundTruthFusionEngine(),
);
