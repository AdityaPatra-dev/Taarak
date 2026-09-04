import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/config/gemini_config.dart';
import 'package:taarak/features/admin/application/admin_providers.dart';
import 'package:taarak/features/environmental/application/environmental_providers.dart';
import 'package:taarak/features/susceptibility/application/deterministic_hazard_susceptibility_model.dart';
import 'package:taarak/features/susceptibility/application/gemini_hazard_client.dart';
import 'package:taarak/features/susceptibility/application/gemini_hazard_susceptibility_decorator.dart';
import 'package:taarak/features/susceptibility/application/hazard_susceptibility_model.dart';

final geminiHazardClientProvider = Provider<GeminiHazardClient>(
  (ref) => GeminiHazardClient(),
);

/// The deterministic weather-threshold model is always the base — real,
/// but honestly limited to what live rainfall/soil-moisture data can
/// say. When a Gemini key is compiled in, it's wrapped by a decorator
/// that only ever adds a rationale string to predictions the
/// deterministic tier already flagged; it can't change a score or
/// invent a zone on its own, and every caller that watches this
/// provider gets the swap automatically the moment a key becomes
/// available (or [TechnicalConfig.geminiEnabled] is flipped).
final hazardSusceptibilityModelProvider = Provider<HazardSusceptibilityModel>((ref) {
  final deterministic = DeterministicHazardSusceptibilityModel(
    environmentalDataService: ref.watch(environmentalDataServiceProvider),
  );
  if (!GeminiConfig.isConfigured) return deterministic;

  return GeminiHazardSusceptibilityDecorator(
    inner: deterministic,
    client: ref.watch(geminiHazardClientProvider),
    isEnabled: () =>
        ref.read(technicalConfigProvider).valueOrNull?.geminiEnabled ?? false,
  );
});
