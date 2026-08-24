import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/features/alerts/application/alert_engine.dart';

void main() {
  final engine = AlertEngine();
  final now = DateTime.utc(2026, 1, 1, 12);

  final zonePolygon = encodePolygonPoints([
    const LatLng(9.99, 9.99),
    const LatLng(9.99, 10.01),
    const LatLng(10.01, 10.01),
    const LatLng(10.01, 9.99),
  ]);

  LocalAlert alertWith({
    DateTime? issuedAt,
    DateTime? validUntil,
    DateTime? cancelledAt,
    String geometryJson = '',
  }) => LocalAlert(
    id: 'alert-1',
    title: 'Landslide warning',
    message: 'Evacuate low-lying areas',
    severity: 'high',
    zoneId: 'zone-1',
    zoneLabel: 'landslide zone',
    geometryJson: geometryJson.isEmpty ? zonePolygon : geometryJson,
    issuedBy: 'official-1',
    issuedAt: issuedAt ?? now,
    validUntil: validUntil ?? now.add(const Duration(hours: 6)),
    cancelledAt: cancelledAt,
    version: 1,
  );

  group('isActive', () {
    test('an alert within its validity window is active', () {
      expect(engine.isActive(alertWith(), now.add(const Duration(hours: 1))), isTrue);
    });

    test('an alert before it was issued is not active', () {
      expect(
        engine.isActive(alertWith(issuedAt: now.add(const Duration(hours: 1))), now),
        isFalse,
      );
    });

    test('an alert past its validity window is not active', () {
      expect(
        engine.isActive(
          alertWith(validUntil: now.add(const Duration(hours: 1))),
          now.add(const Duration(hours: 2)),
        ),
        isFalse,
      );
    });

    test('a cancelled alert is never active, even within its validity window', () {
      expect(
        engine.isActive(alertWith(cancelledAt: now), now.add(const Duration(minutes: 1))),
        isFalse,
      );
    });
  });

  group('appliesToLocation', () {
    test('a point inside the zone polygon is covered', () {
      expect(engine.appliesToLocation(alertWith(), const LatLng(10, 10)), isTrue);
    });

    test('a point outside the zone polygon is not covered', () {
      expect(engine.appliesToLocation(alertWith(), const LatLng(20, 20)), isFalse);
    });
  });

  group('activeAlertsForLocation', () {
    test(
      'OFFICIAL CAN BROADCAST TO SELECTED ZONE — the acceptance criterion, from the '
      'citizen side: an alert only applies to citizens inside the zone it targeted',
      () {
        final matches = engine.activeAlertsForLocation(
          alerts: [alertWith()],
          point: const LatLng(10, 10),
          now: now.add(const Duration(hours: 1)),
        );
        expect(matches, hasLength(1));

        final noMatches = engine.activeAlertsForLocation(
          alerts: [alertWith()],
          point: const LatLng(20, 20),
          now: now.add(const Duration(hours: 1)),
        );
        expect(noMatches, isEmpty);
      },
    );

    test('an inactive alert never applies even if the point is inside its zone', () {
      final matches = engine.activeAlertsForLocation(
        alerts: [alertWith(cancelledAt: now)],
        point: const LatLng(10, 10),
        now: now.add(const Duration(hours: 1)),
      );
      expect(matches, isEmpty);
    });
  });
}
