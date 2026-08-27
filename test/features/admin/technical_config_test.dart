import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/admin/domain/technical_config.dart';

void main() {
  group('TechnicalConfig', () {
    test('decodes a valid stored interval', () {
      final config = TechnicalConfig.fromFirestore({
        'syncIntervalSeconds': 90,
      });

      expect(config.syncIntervalSeconds, 90);
    });

    test('falls back to defaults when the value is missing', () {
      final config = TechnicalConfig.fromFirestore({});

      expect(config.syncIntervalSeconds, TechnicalConfig.defaults.syncIntervalSeconds);
    });

    test('falls back to defaults when the stored value is out of bounds', () {
      final tooLow = TechnicalConfig.fromFirestore({'syncIntervalSeconds': 1});
      final tooHigh = TechnicalConfig.fromFirestore({
        'syncIntervalSeconds': 10000,
      });

      expect(tooLow.syncIntervalSeconds, TechnicalConfig.defaults.syncIntervalSeconds);
      expect(tooHigh.syncIntervalSeconds, TechnicalConfig.defaults.syncIntervalSeconds);
    });

    test('round-trips through Firestore encoding', () {
      const config = TechnicalConfig(syncIntervalSeconds: 30);

      final decoded = TechnicalConfig.fromFirestore(config.toFirestore());

      expect(decoded.syncIntervalSeconds, 30);
    });
  });
}
