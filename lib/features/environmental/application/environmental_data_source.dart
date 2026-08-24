import 'package:taarak/features/environmental/domain/environmental_parameter.dart';

/// One reading as a "connected" source would hand it back — before it's
/// stamped with a fetch time and turned into a [LocalEnvironmentalObservation]
/// by [[EnvironmentalDataService]].
class RawEnvironmentalReading {
  final EnvironmentalParameter parameter;
  final double value;
  final String source;
  final DateTime observedAt;
  final double confidence;

  const RawEnvironmentalReading({
    required this.parameter,
    required this.value,
    required this.source,
    required this.observedAt,
    this.confidence = 0.7,
  });
}

/// Abstracts the external weather/satellite/environmental feed behind our
/// own interface — same reasoning as [[LocationService]]/
/// [[AdministrativeContextResolver]]: no real backend exists yet (see
/// [[AppConfig]]'s own doc comments), so this is where a genuine API
/// integration plugs in later without anything downstream changing.
abstract class EnvironmentalDataSource {
  Future<List<RawEnvironmentalReading>> fetchReadings({
    required double latitude,
    required double longitude,
    DateTime? now,
  });
}
