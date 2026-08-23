import 'package:latlong2/latlong.dart';

/// An unnormalized hazard signal from whatever produced it — an official's
/// manual entry, an external feed, a sensor. Nothing about its shape is
/// trusted yet; [[HazardNormalizer]] is what turns it into something the
/// rest of the app can rely on.
class RawHazardObservation {
  /// Free-form; must match a [[HazardType]]'s storage value once
  /// lowercased, or normalization rejects it.
  final String hazardType;

  /// Raw intensity from the source, 0.0 (negligible) to 1.0 (extreme).
  final double severityScore;

  /// Polygon boundary of the affected area.
  final List<LatLng> boundaryPoints;

  final String source;
  final DateTime observedAt;

  /// The source's own confidence in this observation, 0.0–1.0, if it
  /// provides one. Defaults to a neutral 0.5 when omitted.
  final double? sourceConfidence;

  const RawHazardObservation({
    required this.hazardType,
    required this.severityScore,
    required this.boundaryPoints,
    required this.source,
    required this.observedAt,
    this.sourceConfidence,
  });
}
