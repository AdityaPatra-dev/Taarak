import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/fusion/application/ground_truth_fusion_engine.dart';

void main() {
  final engine = GroundTruthFusionEngine();
  final now = DateTime.utc(2026, 1, 1, 12);

  LocalIncidentReport reportAt({
    double lat = 10,
    double lng = 10,
    String type = 'landslide',
    String severity = 'medium',
    String? reporterId = 'reporter-1',
    DateTime? createdAt,
    String id = 'report-x',
  }) => LocalIncidentReport(
    id: id,
    reporterId: reporterId,
    latitude: lat,
    longitude: lng,
    reportType: type,
    description: '',
    severity: severity,
    createdAt: createdAt ?? now,
    updatedAt: createdAt ?? now,
    version: 1,
    isSynced: false,
  );

  LocalIncident incidentAt({
    double lat = 10,
    double lng = 10,
    String type = 'landslide',
    String severity = 'medium',
    String status = 'acknowledged',
    DateTime? createdAt,
    String id = 'incident-x',
  }) => LocalIncident(
    id: id,
    type: type,
    status: status,
    latitude: lat,
    longitude: lng,
    description: '',
    severity: severity,
    independentSourceCount: 1,
    confidence: 0.5,
    createdAt: createdAt ?? now,
    updatedAt: createdAt ?? now,
    version: 1,
    isSynced: false,
  );

  test('a report with no nearby incidents starts a new, single-source match', () {
    final match = engine.evaluate(
      newReport: reportAt(),
      existingIncidents: const [],
      reportsByIncidentId: const {},
    );

    expect(match.isNewIncident, isTrue);
    expect(match.independentSourceCount, 1);
    expect(match.confidence, 0.5);
  });

  test(
    'REPEATED REPORTS BECOME ONE INCIDENT WITH MULTIPLE SOURCES — the acceptance criterion',
    () {
      final existing = incidentAt(id: 'incident-1');
      final secondReport = reportAt(
        id: 'report-2',
        reporterId: 'reporter-2',
        lat: 10.001,
        lng: 10.001,
      );

      final match = engine.evaluate(
        newReport: secondReport,
        existingIncidents: [existing],
        reportsByIncidentId: {
          'incident-1': [reportAt(id: 'report-1', reporterId: 'reporter-1')],
        },
      );

      expect(match.isNewIncident, isFalse);
      expect(match.matchedIncidentId, 'incident-1');
      expect(match.independentSourceCount, 2);
    },
  );

  test('a different incident type at the same place does not merge', () {
    final existing = incidentAt(id: 'incident-1', type: 'flood');

    final match = engine.evaluate(
      newReport: reportAt(type: 'landslide'),
      existingIncidents: [existing],
      reportsByIncidentId: const {},
    );

    expect(match.isNewIncident, isTrue);
  });

  test('a report far outside the cluster radius does not merge', () {
    final existing = incidentAt(id: 'incident-1', lat: 10, lng: 10);

    final match = engine.evaluate(
      newReport: reportAt(lat: 20, lng: 20),
      existingIncidents: [existing],
      reportsByIncidentId: const {},
    );

    expect(match.isNewIncident, isTrue);
  });

  test('a report outside the cluster time window does not merge', () {
    final existing = incidentAt(id: 'incident-1', createdAt: now);

    final match = engine.evaluate(
      newReport: reportAt(createdAt: now.add(const Duration(hours: 7))),
      existingIncidents: [existing],
      reportsByIncidentId: const {},
    );

    expect(match.isNewIncident, isTrue);
  });

  test('a rejected incident is never a merge candidate', () {
    final existing = incidentAt(id: 'incident-1', status: 'rejected');

    final match = engine.evaluate(
      newReport: reportAt(),
      existingIncidents: [existing],
      reportsByIncidentId: const {},
    );

    expect(match.isNewIncident, isTrue);
  });

  test('a resolved incident is never a merge candidate', () {
    final existing = incidentAt(id: 'incident-1', status: 'resolved');

    final match = engine.evaluate(
      newReport: reportAt(),
      existingIncidents: [existing],
      reportsByIncidentId: const {},
    );

    expect(match.isNewIncident, isTrue);
  });

  test('the closest of two candidate incidents is chosen, not the first', () {
    final near = incidentAt(id: 'near', lat: 10.0005, lng: 10.0005);
    final far = incidentAt(id: 'far', lat: 10.003, lng: 10.003);

    final match = engine.evaluate(
      newReport: reportAt(lat: 10, lng: 10),
      existingIncidents: [far, near],
      reportsByIncidentId: const {},
    );

    expect(match.matchedIncidentId, 'near');
  });

  test('repeated reports from the same reporter do not inflate the source count', () {
    final existing = incidentAt(id: 'incident-1');

    final match = engine.evaluate(
      newReport: reportAt(reporterId: 'reporter-1'),
      existingIncidents: [existing],
      reportsByIncidentId: {
        'incident-1': [reportAt(id: 'report-1', reporterId: 'reporter-1')],
      },
    );

    expect(match.independentSourceCount, 1);
  });

  test('an anonymous new report still counts as a source without deduplication', () {
    final existing = incidentAt(id: 'incident-1');

    final match = engine.evaluate(
      newReport: reportAt(reporterId: null),
      existingIncidents: [existing],
      reportsByIncidentId: {
        'incident-1': [reportAt(id: 'report-1', reporterId: 'reporter-1')],
      },
    );

    expect(match.independentSourceCount, 1);
  });

  test('merging escalates severity to the worse of the two', () {
    final existing = incidentAt(id: 'incident-1', severity: 'medium');

    final match = engine.evaluate(
      newReport: reportAt(severity: 'critical'),
      existingIncidents: [existing],
      reportsByIncidentId: const {},
    );

    expect(match.severity, 'critical');
  });

  test('merging never downgrades severity', () {
    final existing = incidentAt(id: 'incident-1', severity: 'high');

    final match = engine.evaluate(
      newReport: reportAt(severity: 'low'),
      existingIncidents: [existing],
      reportsByIncidentId: const {},
    );

    expect(match.severity, 'high');
  });

  test('confidence rises with each additional independent source, capped below certainty', () {
    expect(engine.evaluate(
      newReport: reportAt(reporterId: 'r3'),
      existingIncidents: [incidentAt(id: 'i1')],
      reportsByIncidentId: {
        'i1': [
          reportAt(id: 'r1', reporterId: 'r1'),
          reportAt(id: 'r2', reporterId: 'r2'),
        ],
      },
    ).confidence, closeTo(0.7, 0.0001));

    final manySources = engine.evaluate(
      newReport: reportAt(reporterId: 'r10'),
      existingIncidents: [incidentAt(id: 'i1')],
      reportsByIncidentId: {
        'i1': [
          for (var i = 0; i < 8; i++) reportAt(id: 'r$i', reporterId: 'reporter-$i'),
        ],
      },
    );
    expect(manySources.confidence, lessThanOrEqualTo(0.95));
  });
}
