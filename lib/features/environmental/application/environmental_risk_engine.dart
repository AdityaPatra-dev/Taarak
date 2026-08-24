import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/environmental/domain/environmental_parameter.dart';
import 'package:taarak/features/environmental/domain/environmental_risk_adjustment.dart';

const String environmentalModelVersion = '1.0.0';

/// M24's deterministic core: whether connected-mode environmental data is
/// fresh enough to trust, and how much it should nudge a habitation's
/// risk score. No I/O — a caller supplies whatever's cached locally.
class EnvironmentalRiskEngine {
  /// A reading older than this is shown as available but excluded from
  /// scoring — the blueprint's own rule ("do not present stale
  /// environmental data as current without freshness information"),
  /// enforced here rather than left to the UI to remember.
  static const Duration freshnessThreshold = Duration(hours: 24);

  /// Caps how far environmental data alone can move a risk score — it's
  /// a contributing signal, not a substitute for M07's hazard/
  /// vulnerability assessment.
  static const double maxAdjustment = 0.15;

  EnvironmentalRiskAdjustment evaluate({
    required List<LocalEnvironmentalObservation> observations,
    required DateTime now,
  }) {
    final fresh = <LocalEnvironmentalObservation>[];
    final stale = <LocalEnvironmentalObservation>[];
    for (final observation in observations) {
      if (now.difference(observation.observedAt) > freshnessThreshold) {
        stale.add(observation);
      } else {
        fresh.add(observation);
      }
    }

    if (fresh.isEmpty) {
      return EnvironmentalRiskAdjustment(adjustment: 0, influencing: const [], stale: stale);
    }

    var weightedTotal = 0.0;
    for (final observation in fresh) {
      final parameter = EnvironmentalParameter.fromStorageValue(observation.parameter);
      if (parameter == null) continue;
      final normalized = _normalize(parameter, observation.value).clamp(0.0, 1.0);
      weightedTotal += normalized * observation.confidence.clamp(0.0, 1.0);
    }

    final adjustment = (weightedTotal / fresh.length * maxAdjustment).clamp(
      0.0,
      maxAdjustment,
    );

    return EnvironmentalRiskAdjustment(adjustment: adjustment, influencing: fresh, stale: stale);
  }

  /// Maps a raw reading to how "concerning" it is (0.0–1.0). The
  /// reference thresholds are illustrative, not meteorologically
  /// authoritative — a real deployment would source these per-region.
  double _normalize(EnvironmentalParameter parameter, double value) => switch (parameter) {
    EnvironmentalParameter.rainfall24h => (value / 200).clamp(0.0, 1.0),
    EnvironmentalParameter.riverLevel => (value / 10).clamp(0.0, 1.0),
    EnvironmentalParameter.soilMoisture => value.clamp(0.0, 1.0),
  };
}
