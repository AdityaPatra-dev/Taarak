import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/environmental/application/environmental_risk_engine.dart';
import 'package:taarak/features/environmental/domain/environmental_parameter.dart';

void main() {
  final engine = EnvironmentalRiskEngine();
  final now = DateTime.utc(2026, 1, 1, 12);

  LocalEnvironmentalObservation observation({
    String id = 'hab-1-rainfall_24h',
    EnvironmentalParameter parameter = EnvironmentalParameter.rainfall24h,
    double value = 100,
    DateTime? observedAt,
    double confidence = 0.8,
  }) => LocalEnvironmentalObservation(
    id: id,
    habitationId: 'hab-1',
    parameter: parameter.storageValue,
    value: value,
    source: 'test source',
    observedAt: observedAt ?? now,
    fetchedAt: now,
    confidence: confidence,
    version: 1,
  );

  test('no observations at all means no adjustment', () {
    final result = engine.evaluate(observations: const [], now: now);
    expect(result.adjustment, 0);
    expect(result.influencing, isEmpty);
    expect(result.stale, isEmpty);
  });

  group('freshness', () {
    test('a reading exactly at the threshold is still fresh', () {
      final result = engine.evaluate(
        observations: [
          observation(observedAt: now.subtract(EnvironmentalRiskEngine.freshnessThreshold)),
        ],
        now: now,
      );
      expect(result.influencing, hasLength(1));
      expect(result.stale, isEmpty);
    });

    test(
      'EXTERNAL DATA CAN INFLUENCE RISK WITH VISIBLE PROVENANCE — the acceptance '
      'criterion: a reading past the threshold is excluded as stale, not silently trusted',
      () {
        final result = engine.evaluate(
          observations: [
            observation(
              observedAt: now.subtract(
                EnvironmentalRiskEngine.freshnessThreshold + const Duration(minutes: 1),
              ),
            ),
          ],
          now: now,
        );

        expect(result.influencing, isEmpty);
        expect(result.stale, hasLength(1));
        expect(result.adjustment, 0);
      },
    );

    test('a mix of fresh and stale readings only lets the fresh ones influence the score', () {
      final fresh = observation(id: 'fresh', observedAt: now);
      final stale = observation(
        id: 'stale',
        observedAt: now.subtract(const Duration(days: 3)),
      );

      final result = engine.evaluate(observations: [fresh, stale], now: now);

      expect(result.influencing.map((o) => o.id), ['fresh']);
      expect(result.stale.map((o) => o.id), ['stale']);
      expect(result.adjustment, greaterThan(0));
    });
  });

  group('adjustment magnitude', () {
    test('adjustment never exceeds maxAdjustment even for an extreme reading', () {
      final result = engine.evaluate(
        observations: [
          observation(parameter: EnvironmentalParameter.rainfall24h, value: 10000, confidence: 1),
        ],
        now: now,
      );
      expect(result.adjustment, lessThanOrEqualTo(EnvironmentalRiskEngine.maxAdjustment));
    });

    test('a negligible reading contributes close to zero', () {
      final result = engine.evaluate(
        observations: [
          observation(parameter: EnvironmentalParameter.rainfall24h, value: 0, confidence: 1),
        ],
        now: now,
      );
      expect(result.adjustment, closeTo(0, 0.001));
    });

    test('a lower-confidence source contributes less than an identical high-confidence one', () {
      final lowConfidence = engine.evaluate(
        observations: [
          observation(id: 'a', parameter: EnvironmentalParameter.rainfall24h, value: 150, confidence: 0.3),
        ],
        now: now,
      );
      final highConfidence = engine.evaluate(
        observations: [
          observation(id: 'a', parameter: EnvironmentalParameter.rainfall24h, value: 150, confidence: 1.0),
        ],
        now: now,
      );

      expect(lowConfidence.adjustment, lessThan(highConfidence.adjustment));
    });

    test('an unrecognized parameter storage value is safely ignored', () {
      final unknown = LocalEnvironmentalObservation(
        id: 'x',
        habitationId: 'hab-1',
        parameter: 'wind_speed', // not a known EnvironmentalParameter
        value: 999,
        source: 'test',
        observedAt: now,
        fetchedAt: now,
        confidence: 1,
        version: 1,
      );

      final result = engine.evaluate(observations: [unknown], now: now);
      expect(result.adjustment, 0);
    });
  });
}
