import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/location/gps_fix.dart';

void main() {
  group('GpsFix freshness', () {
    test('a fix captured moments ago is fresh', () {
      final now = DateTime.utc(2026, 1, 1, 12, 0);
      final fix = GpsFix(
        latitude: 1,
        longitude: 1,
        accuracyMeters: 5,
        capturedAt: now.subtract(const Duration(seconds: 30)),
      );

      expect(fix.isFreshAsOf(now), isTrue);
      expect(fix.ageAsOf(now), const Duration(seconds: 30));
    });

    test('a fix older than the max age is stale', () {
      final now = DateTime.utc(2026, 1, 1, 12, 0);
      final fix = GpsFix(
        latitude: 1,
        longitude: 1,
        accuracyMeters: 5,
        capturedAt: now.subtract(const Duration(minutes: 10)),
      );

      expect(
        fix.isFreshAsOf(now, maxAge: const Duration(minutes: 5)),
        isFalse,
      );
    });
  });
}
