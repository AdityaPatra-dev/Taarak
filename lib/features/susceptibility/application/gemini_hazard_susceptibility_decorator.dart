import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/susceptibility/application/gemini_hazard_client.dart';
import 'package:taarak/features/susceptibility/application/hazard_susceptibility_model.dart';
import 'package:taarak/features/susceptibility/domain/hazard_susceptibility_prediction.dart';

/// Wraps a [HazardSusceptibilityModel] to attach a Gemini-written
/// rationale to predictions that already crossed [enrichmentThreshold] —
/// it never runs for a prediction the inner model didn't already flag as
/// worth investigating, which both bounds API cost and keeps Gemini out
/// of the create/delete decision itself (that's [inner]'s score alone).
///
/// [inner]'s `score`/`confidence`/`featureContributions` are always
/// returned byte-identical; the only thing this class can add is
/// [HazardSusceptibilityPrediction.rationale]. A malformed, missing, or
/// slow Gemini response degrades to [inner]'s own prediction, unchanged
/// — the same "never throws to the caller" contract as
/// [GeminiHazardClient] and [OpenMeteoDataSource] before it.
class GeminiHazardSusceptibilityDecorator implements HazardSusceptibilityModel {
  final HazardSusceptibilityModel _inner;
  final GeminiHazardClient _client;
  final bool Function() _isEnabled;
  final double _enrichmentThreshold;

  GeminiHazardSusceptibilityDecorator({
    required HazardSusceptibilityModel inner,
    required GeminiHazardClient client,
    required bool Function() isEnabled,
    double enrichmentThreshold = 0.6,
  }) : _inner = inner,
       _client = client,
       _isEnabled = isEnabled,
       _enrichmentThreshold = enrichmentThreshold;

  @override
  Future<HazardSusceptibilityPrediction?> predict({
    required String habitationId,
    required double latitude,
    required double longitude,
    required HazardType hazardType,
    DateTime? now,
    String habitationName = '',
    int populationExposed = 0,
  }) async {
    final base = await _inner.predict(
      habitationId: habitationId,
      latitude: latitude,
      longitude: longitude,
      hazardType: hazardType,
      now: now,
      habitationName: habitationName,
      populationExposed: populationExposed,
    );
    if (base == null) return null; // nothing to enrich, ever
    if (!_isEnabled() || base.score < _enrichmentThreshold) return base;

    try {
      final result = await _client
          .classify(
            prediction: base,
            hazardType: hazardType,
            habitationName: habitationName.isEmpty ? 'this location' : habitationName,
            populationExposed: populationExposed,
          )
          .timeout(const Duration(seconds: 6));
      return result == null ? base : base.withRationale(result.rationale);
    } catch (_) {
      return base; // never throws — a missing rationale is fine, a crash isn't
    }
  }
}
