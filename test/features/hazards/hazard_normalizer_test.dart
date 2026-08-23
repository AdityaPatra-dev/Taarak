import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/domain/hazard_freshness.dart';
import 'package:taarak/features/hazards/domain/hazard_severity.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/hazards/domain/normalized_hazard_zone.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';

void main() {
  final normalizer = HazardNormalizer();
  final now = DateTime.utc(2026, 1, 1, 12);

  RawHazardObservation observation({
    String hazardType = 'landslide',
    double severityScore = 0.5,
    List<LatLng>? boundaryPoints,
    DateTime? observedAt,
    double? sourceConfidence,
  }) => RawHazardObservation(
    hazardType: hazardType,
    severityScore: severityScore,
    boundaryPoints:
        boundaryPoints ?? const [LatLng(1, 1), LatLng(1, 2), LatLng(2, 2)],
    source: 'test-source',
    observedAt: observedAt ?? now,
    sourceConfidence: sourceConfidence,
  );

  group('type validation', () {
    test('accepts landslide and flood', () {
      expect(
        normalizer.normalize(observation(hazardType: 'landslide'), now: now).isSuccess,
        isTrue,
      );
      expect(
        normalizer.normalize(observation(hazardType: 'flood'), now: now).isSuccess,
        isTrue,
      );
    });

    test('is case-insensitive', () {
      expect(
        normalizer.normalize(observation(hazardType: 'LANDSLIDE'), now: now).isSuccess,
        isTrue,
      );
    });

    test('rejects an unsupported hazard type', () {
      final result = normalizer.normalize(observation(hazardType: 'earthquake'), now: now);
      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('expected failure'),
        failure: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });
  });

  group('geometry validation', () {
    test('rejects fewer than 3 boundary points', () {
      final result = normalizer.normalize(
        observation(boundaryPoints: const [LatLng(1, 1), LatLng(1, 2)]),
        now: now,
      );
      expect(result.isFailure, isTrue);
    });
  });

  group('severity score validation', () {
    test('rejects a score outside 0.0-1.0', () {
      expect(normalizer.normalize(observation(severityScore: 1.5), now: now).isFailure, isTrue);
      expect(normalizer.normalize(observation(severityScore: -0.1), now: now).isFailure, isTrue);
    });
  });

  group('observedAt validation', () {
    test('rejects a timestamp in the future', () {
      final result = normalizer.normalize(
        observation(observedAt: now.add(const Duration(hours: 1))),
        now: now,
      );
      expect(result.isFailure, isTrue);
    });
  });

  group('severity bucketing', () {
    final cases = {
      0.0: HazardSeverity.low,
      0.34: HazardSeverity.low,
      0.35: HazardSeverity.medium,
      0.64: HazardSeverity.medium,
      0.65: HazardSeverity.high,
      0.84: HazardSeverity.high,
      0.85: HazardSeverity.critical,
      1.0: HazardSeverity.critical,
    };

    cases.forEach((score, expected) {
      test('score $score buckets to ${expected.name}', () {
        final result = normalizer.normalize(observation(severityScore: score), now: now);
        expect(
          result.dataOrNull?.severity,
          expected,
        );
      });
    });
  });

  group('confidence computation', () {
    test('a fresh observation keeps the source confidence as-is', () {
      final result = normalizer.normalize(
        observation(observedAt: now, sourceConfidence: 0.8),
        now: now,
      );
      expect(result.dataOrNull?.confidence, closeTo(0.8, 0.001));
      expect(result.dataOrNull?.freshness, HazardFreshness.fresh);
    });

    test('a stale observation discounts confidence', () {
      final result = normalizer.normalize(
        observation(
          observedAt: now.subtract(const Duration(hours: 72)),
          sourceConfidence: 0.8,
        ),
        now: now,
      );
      expect(result.dataOrNull?.freshness, HazardFreshness.stale);
      expect(result.dataOrNull?.confidence, lessThan(0.8));
    });

    test('missing source confidence defaults to a neutral 0.5', () {
      final result = normalizer.normalize(observation(observedAt: now), now: now);
      expect(result.dataOrNull?.confidence, closeTo(0.5, 0.001));
    });
  });

  test('a valid observation carries its hazard type and geometry through', () {
    final points = const [LatLng(10, 20), LatLng(10, 21), LatLng(11, 20.5)];
    final result = normalizer.normalize(
      observation(hazardType: 'flood', boundaryPoints: points),
      now: now,
    );

    final zone = result.dataOrNull;
    expect(zone, isA<NormalizedHazardZone>());
    expect(zone!.hazardType, HazardType.flood);
    expect(zone.boundaryPoints, points);
    expect(zone.source, 'test-source');
  });
}
