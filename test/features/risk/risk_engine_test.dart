import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/features/risk/application/risk_engine.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';

void main() {
  final engine = RiskEngine();
  final now = DateTime.utc(2026, 1, 1);

  LocalHabitation habitationAt(double lat, double lng, {String id = 'h1'}) =>
      LocalHabitation(
        id: id,
        name: 'Test Habitation',
        latitude: lat,
        longitude: lng,
        population: 100,
        updatedAt: now,
        version: 1,
      );

  LocalHazardZone squareZoneAround(
    double lat,
    double lng, {
    String id = 'z1',
    String severity = 'high',
    double confidence = 1.0,
  }) => LocalHazardZone(
    id: id,
    hazardType: 'landslide',
    severity: severity,
    geometryJson: encodePolygonPoints([
      LatLng(lat - 0.01, lng - 0.01),
      LatLng(lat - 0.01, lng + 0.01),
      LatLng(lat + 0.01, lng + 0.01),
      LatLng(lat + 0.01, lng - 0.01),
    ]),
    source: 'test',
    observedAt: now,
    confidence: confidence,
    updatedAt: now,
    version: 1,
  );

  test('a habitation with no overlapping hazard zones scores from vulnerability alone', () {
    final habitation = habitationAt(10, 10);
    final result = engine.assess(
      habitation: habitation,
      hazardZones: const [],
      vulnerabilityIndex: 0.5,
      now: now,
    );

    expect(result.hazardExposure, 0.0);
    expect(result.contributingHazardZoneIds, isEmpty);
    expect(result.riskScore, closeTo(RiskEngine.vulnerabilityWeight * 0.5, 0.001));
  });

  test('a habitation inside a hazard zone gets a nonzero hazard exposure', () {
    final habitation = habitationAt(10, 10);
    final zone = squareZoneAround(10, 10, severity: 'high', confidence: 0.8);

    final result = engine.assess(
      habitation: habitation,
      hazardZones: [zone],
      vulnerabilityIndex: 0.0,
      now: now,
    );

    // high intensity (0.75) * confidence (0.8) = 0.6
    expect(result.hazardExposure, closeTo(0.6, 0.001));
    expect(result.contributingHazardZoneIds, ['z1']);
    expect(
      result.riskScore,
      closeTo(RiskEngine.hazardWeight * 0.6, 0.001),
    );
  });

  test('overlapping zones use the worst hazard, not the sum', () {
    final habitation = habitationAt(10, 10);
    final lowZone = squareZoneAround(10, 10, id: 'low', severity: 'low', confidence: 1.0);
    final criticalZone = squareZoneAround(
      10,
      10,
      id: 'critical',
      severity: 'critical',
      confidence: 1.0,
    );

    final result = engine.assess(
      habitation: habitation,
      hazardZones: [lowZone, criticalZone],
      vulnerabilityIndex: 0.0,
      now: now,
    );

    expect(result.hazardExposure, closeTo(1.0, 0.001)); // critical wins
    expect(result.contributingHazardZoneIds, containsAll(['low', 'critical']));
  });

  test('a habitation outside a hazard zone is not exposed to it', () {
    final habitation = habitationAt(50, 50);
    final zone = squareZoneAround(10, 10);

    final result = engine.assess(
      habitation: habitation,
      hazardZones: [zone],
      vulnerabilityIndex: 0.0,
      now: now,
    );

    expect(result.hazardExposure, 0.0);
    expect(result.contributingHazardZoneIds, isEmpty);
  });

  test('the same inputs always produce the same score (reproducible)', () {
    final habitation = habitationAt(10, 10);
    final zone = squareZoneAround(10, 10);

    final first = engine.assess(
      habitation: habitation,
      hazardZones: [zone],
      vulnerabilityIndex: 0.4,
      now: now,
    );
    final second = engine.assess(
      habitation: habitation,
      hazardZones: [zone],
      vulnerabilityIndex: 0.4,
      now: now,
    );

    expect(first.riskScore, second.riskScore);
    expect(first.riskClass, second.riskClass);
  });

  test('a high combined score classifies as a red zone', () {
    final habitation = habitationAt(10, 10);
    final zone = squareZoneAround(10, 10, severity: 'critical', confidence: 1.0);

    final result = engine.assess(
      habitation: habitation,
      hazardZones: [zone],
      vulnerabilityIndex: 1.0,
      now: now,
    );

    expect(result.riskScore, closeTo(1.0, 0.001));
    expect(result.riskClass, RiskClass.red);
    expect(result.riskClass.isRedZone, isTrue);
  });

  test('vulnerability index is clamped into 0.0-1.0', () {
    final habitation = habitationAt(10, 10);
    final result = engine.assess(
      habitation: habitation,
      hazardZones: const [],
      vulnerabilityIndex: 5.0,
      now: now,
    );
    expect(result.vulnerabilityIndex, 1.0);
  });

  test('the result carries the model version for traceability', () {
    final habitation = habitationAt(10, 10);
    final result = engine.assess(
      habitation: habitation,
      hazardZones: const [],
      vulnerabilityIndex: 0.0,
      now: now,
    );
    expect(result.modelVersion, isNotEmpty);
  });
}
