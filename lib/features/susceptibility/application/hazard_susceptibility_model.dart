import 'package:taarak/features/susceptibility/domain/hazard_susceptibility_prediction.dart';

/// The extension point this app doesn't use yet, on purpose — see
/// [UnavailableHazardSusceptibilityModel]. A real implementation is meant
/// to be a **trained** model (logistic regression or a shallow gradient-
/// boosted tree, per the project's own architecture notes — not a deep
/// net, since a linear model's feature weights are directly presentable:
/// "slope contributed 40% to this prediction"), trained offline against
/// GSI's public landslide inventory plus terrain (SRTM slope/elevation)
/// and rainfall (already available via [EnvironmentalDataSource])
/// features, then ported into pure Dart the same way a hand-written
/// engine is — no on-device model runtime, no new dependency, fully
/// offline-capable like everything else in this app.
///
/// Until that training happens, [predict] returning `null` is not a
/// placeholder bug — it's the honest answer: no trained model exists yet,
/// and nothing in this app should imply otherwise (see
/// [UnavailableHazardSusceptibilityModel]'s own doc comment).
abstract class HazardSusceptibilityModel {
  Future<HazardSusceptibilityPrediction?> predict({
    required double latitude,
    required double longitude,
    DateTime? now,
  });
}

/// The only implementation currently wired into this app. Always returns
/// `null` — deliberately, not as an oversight. A model that fabricated a
/// number here (even a "reasonable-looking" deterministic one) would be
/// exactly the kind of fake AI claim this project's own engineering rules
/// rule out: nothing has been trained on real hazard data yet, so nothing
/// should present as if it had been. Swap this provider for a real
/// implementation only once one actually exists.
class UnavailableHazardSusceptibilityModel implements HazardSusceptibilityModel {
  const UnavailableHazardSusceptibilityModel();

  @override
  Future<HazardSusceptibilityPrediction?> predict({
    required double latitude,
    required double longitude,
    DateTime? now,
  }) async => null;
}
