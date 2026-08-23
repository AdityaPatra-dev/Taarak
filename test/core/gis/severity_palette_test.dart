import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/gis/severity_palette.dart';

void main() {
  test('known severities map to distinct colors', () {
    final colors = {
      severityColor('critical'),
      severityColor('high'),
      severityColor('medium'),
      severityColor('low'),
    };
    expect(colors, hasLength(4));
  });

  test('severity matching is case-insensitive', () {
    expect(severityColor('HIGH'), severityColor('high'));
  });

  test('an unknown severity falls back to a neutral color', () {
    expect(severityColor('unknown'), severityColor('anything-else'));
  });
}
