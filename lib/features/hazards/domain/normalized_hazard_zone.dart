import 'package:latlong2/latlong.dart';
import 'package:taarak/features/hazards/domain/hazard_freshness.dart';
import 'package:taarak/features/hazards/domain/hazard_severity.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';

/// The output of normalization: a hazard observation that's been validated,
/// bucketed into a canonical severity, and given a computed confidence.
/// Ready to persist via [[HazardIngestionService]].
class NormalizedHazardZone {
  final HazardType hazardType;
  final HazardSeverity severity;
  final HazardFreshness freshness;

  /// Combines the source's own confidence (if given) with how stale the
  /// observation is — never higher than the source claimed, and always
  /// discounted as the data ages.
  final double confidence;

  final List<LatLng> boundaryPoints;
  final String source;
  final DateTime observedAt;

  const NormalizedHazardZone({
    required this.hazardType,
    required this.severity,
    required this.freshness,
    required this.confidence,
    required this.boundaryPoints,
    required this.source,
    required this.observedAt,
  });
}
