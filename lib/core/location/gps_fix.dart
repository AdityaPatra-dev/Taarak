/// A single GPS reading. `accuracyMeters` and `capturedAt` are what let a
/// consumer judge freshness/reliability instead of blindly trusting the
/// coordinates — the blueprint calls this out explicitly for the hazard
/// engine's data ("source, timestamp, freshness and confidence") and the
/// same discipline applies here.
class GpsFix {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;

  const GpsFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  Duration ageAsOf(DateTime now) => now.difference(capturedAt);

  bool isFreshAsOf(DateTime now, {Duration maxAge = const Duration(minutes: 5)}) =>
      ageAsOf(now) <= maxAge;
}
