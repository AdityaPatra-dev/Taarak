import 'package:taarak/core/database/app_database.dart';

/// [EnvironmentalRiskEngine.evaluate]'s output: not just a number, but
/// which observations produced it and which were excluded for being
/// stale — the "visible provenance" the acceptance criterion asks for,
/// split so a caller can show both "what influenced this" and "what's
/// available but not currently trusted".
class EnvironmentalRiskAdjustment {
  final double adjustment;
  final List<LocalEnvironmentalObservation> influencing;
  final List<LocalEnvironmentalObservation> stale;

  const EnvironmentalRiskAdjustment({
    required this.adjustment,
    required this.influencing,
    required this.stale,
  });
}
