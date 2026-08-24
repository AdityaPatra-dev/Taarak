import 'dart:math';

import 'package:taarak/features/environmental/application/environmental_data_source.dart';
import 'package:taarak/features/environmental/domain/environmental_parameter.dart';

/// Stands in for a real weather/satellite/river-gauge API, which this
/// project doesn't have (see [[AppConfig]]'s own honest stance on the
/// missing backend). Deterministic — the same location always produces
/// the same readings — rather than random, matching every other engine
/// in this app's insistence on reproducibility. Soil moisture is
/// deliberately given an old `observedAt` (satellites revisit an area on
/// a multi-day cycle in reality) so [[EnvironmentalRiskEngine]]'s
/// freshness gate has something real to demonstrate rather than always
/// seeing all-fresh data.
class DemoEnvironmentalDataSource implements EnvironmentalDataSource {
  @override
  Future<List<RawEnvironmentalReading>> fetchReadings({
    required double latitude,
    required double longitude,
    DateTime? now,
  }) async {
    final occurredAt = now ?? DateTime.now();
    final seed = ((latitude * 1000).round() * 31 + (longitude * 1000).round()).abs();
    final random = Random(seed);

    return [
      RawEnvironmentalReading(
        parameter: EnvironmentalParameter.rainfall24h,
        value: (random.nextDouble() * 180).roundToDouble(),
        source: 'IMD (demo feed)',
        observedAt: occurredAt.subtract(const Duration(hours: 1)),
        confidence: 0.85,
      ),
      RawEnvironmentalReading(
        parameter: EnvironmentalParameter.riverLevel,
        value: (2 + random.nextDouble() * 9),
        source: 'CWC River Gauge (demo feed)',
        observedAt: occurredAt.subtract(const Duration(minutes: 30)),
        confidence: 0.8,
      ),
      RawEnvironmentalReading(
        parameter: EnvironmentalParameter.soilMoisture,
        value: random.nextDouble(),
        source: 'Bhuvan Satellite (demo feed)',
        observedAt: occurredAt.subtract(const Duration(days: 3)),
        confidence: 0.6,
      ),
    ];
  }
}
