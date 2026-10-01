import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/susceptibility/domain/hazard_susceptibility_prediction.dart';

/// "How likely is a hazard here in the first place" — independent of
/// whether an official has already mapped a [LocalHazardZone] there. A
/// trained model (GSI landslide inventory + SRTM terrain, per this
/// module's original design notes) is still future work; the default
/// implementation now wired in ([DeterministicHazardSusceptibilityModel],
/// in this same directory) answers a narrower version of the same
/// question from live weather signals alone (rainfall/soil moisture via
/// [EnvironmentalDataService]) — real, but honestly limited, never dressed
/// up as more than it is. [UnavailableHazardSusceptibilityModel] stays in
/// the codebase as a fallback/test double, the same way
/// `DemoEnvironmentalDataSource` was kept after being superseded.
///
/// [habitationId]/[hazardType] were added when this stopped being a pure
/// extension point: a real prediction needs to read the cached
/// observations for *this* habitation and apply hazard-type-specific
/// thresholds, not just a bare lat/lng.
abstract class HazardSusceptibilityModel {
  /// [habitationName]/[populationExposed] are display context only —
  /// used solely by an enrichment layer (e.g. a Gemini-backed decorator)
  /// to write a readable rationale; the deterministic tier ignores them.
  Future<HazardSusceptibilityPrediction?> predict({
    required String habitationId,
    required double latitude,
    required double longitude,
    required HazardType hazardType,
    DateTime? now,
    String habitationName = '',
    int populationExposed = 0,
  });
}

/// Kept as an explicit "no answer" implementation for tests/fallback use
/// — not the default anymore (see [HazardSusceptibilityModel]'s doc
/// comment), but still the honest choice for a caller that wants no
/// prediction rather than a fabricated one. Always returns `null`.
class UnavailableHazardSusceptibilityModel implements HazardSusceptibilityModel {
  const UnavailableHazardSusceptibilityModel();

  @override
  Future<HazardSusceptibilityPrediction?> predict({
    required String habitationId,
    required double latitude,
    required double longitude,
    required HazardType hazardType,
    DateTime? now,
    String habitationName = '',
    int populationExposed = 0,
  }) async => null;
}
