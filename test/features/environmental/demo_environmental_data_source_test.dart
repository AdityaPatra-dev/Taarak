import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/environmental/application/demo_environmental_data_source.dart';
import 'package:taarak/features/environmental/application/environmental_risk_engine.dart';
import 'package:taarak/features/environmental/domain/environmental_parameter.dart';

void main() {
  final source = DemoEnvironmentalDataSource();
  final now = DateTime.utc(2026, 1, 1, 12);

  test('the same location always produces the same readings (deterministic, not random)', () async {
    final first = await source.fetchReadings(latitude: 12.9716, longitude: 77.5946, now: now);
    final second = await source.fetchReadings(latitude: 12.9716, longitude: 77.5946, now: now);

    expect(first.map((r) => r.value), second.map((r) => r.value));
  });

  test('different locations produce different readings', () async {
    final here = await source.fetchReadings(latitude: 12.9716, longitude: 77.5946, now: now);
    final there = await source.fetchReadings(latitude: 28.6139, longitude: 77.2090, now: now);

    expect(
      here.map((r) => r.value).toList(),
      isNot(there.map((r) => r.value).toList()),
    );
  });

  test('every declared parameter is represented exactly once', () async {
    final readings = await source.fetchReadings(latitude: 10, longitude: 10, now: now);
    expect(readings.map((r) => r.parameter).toSet(), EnvironmentalParameter.values.toSet());
  });

  test('every reading carries a non-empty source attribution', () async {
    final readings = await source.fetchReadings(latitude: 10, longitude: 10, now: now);
    for (final reading in readings) {
      expect(reading.source, isNotEmpty);
    }
  });

  test(
    'soil moisture is deliberately stale, demonstrating the freshness gate has '
    'something real to exclude',
    () async {
      final readings = await source.fetchReadings(latitude: 10, longitude: 10, now: now);
      final soilMoisture = readings.firstWhere(
        (r) => r.parameter == EnvironmentalParameter.soilMoisture,
      );
      expect(
        now.difference(soilMoisture.observedAt),
        greaterThan(EnvironmentalRiskEngine.freshnessThreshold),
      );
    },
  );

  test('rainfall and river level readings are fresh enough to actually influence risk', () async {
    final readings = await source.fetchReadings(latitude: 10, longitude: 10, now: now);
    for (final parameter in [EnvironmentalParameter.rainfall24h, EnvironmentalParameter.riverLevel]) {
      final reading = readings.firstWhere((r) => r.parameter == parameter);
      expect(
        now.difference(reading.observedAt),
        lessThan(EnvironmentalRiskEngine.freshnessThreshold),
      );
    }
  });
}
