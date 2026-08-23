import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/hazards/domain/hazard_freshness.dart';
import 'package:taarak/features/hazards/domain/hazard_severity.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/hazards/domain/normalized_hazard_zone.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';

/// The deterministic core of M06: turns a [RawHazardObservation] into a
/// [NormalizedHazardZone], or rejects it. Pure — no I/O, no clock reads
/// unless a caller wants "now" to be something other than [DateTime.now],
/// which is why [now] is a parameter rather than read internally.
class HazardNormalizer {
  Result<NormalizedHazardZone> normalize(
    RawHazardObservation observation, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    final hazardType = HazardType.fromStorageValue(
      observation.hazardType.toLowerCase(),
    );
    if (hazardType == null) {
      return Result.failure(
        ValidationFailure(
          'Unsupported hazard type "${observation.hazardType}" — only '
          'landslide and flood are normalized today.',
        ),
      );
    }

    if (observation.boundaryPoints.length < 3) {
      return const Result.failure(
        ValidationFailure('A hazard zone needs at least 3 boundary points'),
      );
    }

    if (observation.severityScore.isNaN ||
        observation.severityScore < 0 ||
        observation.severityScore > 1) {
      return const Result.failure(
        ValidationFailure('severityScore must be between 0.0 and 1.0'),
      );
    }

    final age = currentTime.difference(observation.observedAt);
    if (age.isNegative) {
      return const Result.failure(
        ValidationFailure('observedAt cannot be in the future'),
      );
    }

    final severity = _bucketSeverity(observation.severityScore);
    final freshness = classifyFreshness(age);
    final baseConfidence = (observation.sourceConfidence ?? 0.5).clamp(0.0, 1.0);
    final confidence = baseConfidence * freshnessConfidenceFactor(age);

    return Result.success(
      NormalizedHazardZone(
        hazardType: hazardType,
        severity: severity,
        freshness: freshness,
        confidence: confidence,
        boundaryPoints: observation.boundaryPoints,
        source: observation.source,
        observedAt: observation.observedAt,
      ),
    );
  }

  HazardSeverity _bucketSeverity(double score) {
    if (score >= 0.85) return HazardSeverity.critical;
    if (score >= 0.65) return HazardSeverity.high;
    if (score >= 0.35) return HazardSeverity.medium;
    return HazardSeverity.low;
  }
}
