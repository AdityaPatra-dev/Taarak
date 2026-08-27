import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/disaster_events/application/government_alert_parser.dart';
import 'package:taarak/features/disaster_events/domain/disaster_event.dart';

void main() {
  final parser = GovernmentAlertParser();

  test('extracts rainfall, river and road mentions from a bulletin', () {
    final result = parser.parse(
      'Heavy rainfall warning: 180mm expected in the next 24 hours. '
      'Teesta river rising rapidly. NH-10 is vulnerable to blockage.',
    );

    expect(result.rainfall24hMm, 180);
    expect(result.riverMentions, contains('Teesta'));
    expect(result.roadMentions, contains('NH10'));
    // A river actually rising is classified ahead of generic rainfall —
    // it's the more specific, more actionable signal.
    expect(result.hazardType, DisasterEventType.riverRise);
    expect(result.hasAnyStructuredData, isTrue);
  });

  test('classifies a landslide bulletin', () {
    final result = parser.parse('Landslide reported near the district road.');

    expect(result.hazardType, DisasterEventType.landslide);
  });

  test('classifies plain rainfall without a river mention as heavyRainfall', () {
    final result = parser.parse('Heavy rainfall of 90mm recorded overnight.');

    expect(result.hazardType, DisasterEventType.heavyRainfall);
    expect(result.rainfall24hMm, 90);
  });

  test('classifies a river-rise bulletin distinctly from generic rainfall', () {
    final result = parser.parse('Ganga river is rising above danger mark.');

    expect(result.hazardType, DisasterEventType.riverRise);
  });

  test('returns no structured data for unrelated text', () {
    final result = parser.parse('Office will remain closed tomorrow.');

    expect(result.hasAnyStructuredData, isFalse);
    expect(result.hazardType, isNull);
    expect(result.rainfall24hMm, isNull);
  });

  test('does not invent a river or road mention that is not present', () {
    final result = parser.parse('Heavy rain expected this evening.');

    expect(result.riverMentions, isEmpty);
    expect(result.roadMentions, isEmpty);
  });
}
