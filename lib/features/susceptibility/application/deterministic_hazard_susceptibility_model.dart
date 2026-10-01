import 'package:taarak/features/environmental/application/environmental_data_service.dart';
import 'package:taarak/features/environmental/application/environmental_risk_engine.dart';
import 'package:taarak/features/environmental/domain/environmental_parameter.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/susceptibility/application/hazard_susceptibility_model.dart';
import 'package:taarak/features/susceptibility/domain/hazard_susceptibility_prediction.dart';

const String deterministicSusceptibilityModelVersion = '1.0.0';

/// The default [HazardSusceptibilityModel]: pure threshold logic over
/// whatever [EnvironmentalDataService] already has cached for this
/// habitation (rainfall24h/soilMoisture, via Open-Meteo) — no training,
/// no fabricated confidence, an honest `null` when there's nothing fresh
/// enough to trust. This is the tier [AutoHazardScanService] uses to
/// decide whether to create/keep/delete an automatic hazard zone; a
/// [[GeminiHazardSusceptibilityDecorator]] may wrap this to add a
/// rationale string, but never touches the numbers this class computes.
///
/// Reuses [EnvironmentalRiskEngine.freshnessThreshold] rather than
/// defining its own — "don't trust a reading older than 24h" is the same
/// rule in both places, not a coincidence.
class DeterministicHazardSusceptibilityModel implements HazardSusceptibilityModel {
  final EnvironmentalDataService _environmentalDataService;

  DeterministicHazardSusceptibilityModel({
    required EnvironmentalDataService environmentalDataService,
  }) : _environmentalDataService = environmentalDataService;

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
    final occurredAt = now ?? DateTime.now();
    final observations = await _environmentalDataService.observationsFor(habitationId);

    double? rainfall24h;
    double? rainfallConfidence;
    double? soilMoisture;
    double? soilMoistureConfidence;

    for (final observation in observations) {
      if (occurredAt.difference(observation.observedAt) >
          EnvironmentalRiskEngine.freshnessThreshold) {
        continue; // stale — excluded, same rule as the risk-adjustment engine
      }
      switch (EnvironmentalParameter.fromStorageValue(observation.parameter)) {
        case EnvironmentalParameter.rainfall24h:
          rainfall24h = observation.value;
          rainfallConfidence = observation.confidence;
        case EnvironmentalParameter.soilMoisture:
          soilMoisture = observation.value;
          soilMoistureConfidence = observation.confidence;
        case EnvironmentalParameter.riverLevel:
        case null:
          break; // no river-gauge signal exists via Open-Meteo; unrecognized ignored
      }
    }

    if (rainfall24h == null && soilMoisture == null) return null;

    final rainfallConcern = rainfall24h == null
        ? null
        : (rainfall24h / (hazardType == HazardType.flood ? 150 : 100)).clamp(0.0, 1.0);
    final soilConcern = soilMoisture?.clamp(0.0, 1.0);

    final double score;
    final featureContributions = <String, double>{};
    if (rainfallConcern != null) featureContributions['rainfall24h'] = rainfallConcern;
    if (soilConcern != null) featureContributions['soilMoisture'] = soilConcern;

    switch (hazardType) {
      case HazardType.landslide:
        // Saturation-led: soil moisture carries the most weight, rainfall
        // is the trigger on top of it.
        score = switch ((soilConcern, rainfallConcern)) {
          (final s?, final r?) => (0.6 * s + 0.4 * r).clamp(0.0, 1.0),
          (final s?, null) => s,
          (null, final r?) => r,
          (null, null) => 0.0,
        };
      case HazardType.flood:
        // No river-gauge signal exists (Open-Meteo's honest gap), so
        // rainfall volume dominates.
        score = switch ((rainfallConcern, soilConcern)) {
          (final r?, final s?) => (0.8 * r + 0.2 * s).clamp(0.0, 1.0),
          (final r?, null) => r,
          (null, final s?) => s,
          (null, null) => 0.0,
        };
    }

    final confidences = [
      if (rainfall24h != null) rainfallConfidence ?? 0.5,
      if (soilMoisture != null) soilMoistureConfidence ?? 0.5,
    ];
    var confidence = confidences.reduce((a, b) => a + b) / confidences.length;
    if (confidences.length == 1) confidence *= 0.7; // only one of two signals present

    return HazardSusceptibilityPrediction(
      score: score,
      modelName: 'deterministic-rainfall-soil-threshold',
      modelVersion: deterministicSusceptibilityModelVersion,
      featureContributions: featureContributions,
      confidence: confidence.clamp(0.0, 1.0),
      predictedAt: occurredAt,
    );
  }
}
