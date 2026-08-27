import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/features/susceptibility/application/hazard_susceptibility_model.dart';

/// Swap this for a real implementation once a model is actually trained
/// (see [HazardSusceptibilityModel]'s doc comment) — every caller that
/// watches this provider picks the change up automatically.
final hazardSusceptibilityModelProvider = Provider<HazardSusceptibilityModel>(
  (ref) => const UnavailableHazardSusceptibilityModel(),
);
