import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/dashboard/application/dashboard_aggregator.dart';
import 'package:taarak/features/map/domain/habitation_overview.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);

  LocalHazardZone zone({
    required String id,
    required String severity,
  }) => LocalHazardZone(
    id: id,
    hazardType: 'landslide',
    severity: severity,
    geometryJson: '[]',
    source: 'test',
    observedAt: now,
    confidence: 1,
    updatedAt: now,
    version: 1,
  );

  LocalHabitation habitation(String id) => LocalHabitation(
    id: id,
    name: 'Habitation $id',
    latitude: 0,
    longitude: 0,
    population: 100,
    administrativeRegionName: null,
    infrastructureQuality: null,
    accessQuality: null,
    updatedAt: now,
    version: 1,
  );

  LocalRiskAssessment riskAssessment({
    required String habitationId,
    required String riskClass,
  }) => LocalRiskAssessment(
    habitationId: habitationId,
    hazardExposure: 0.5,
    vulnerabilityIndex: 0.5,
    riskScore: 0.5,
    riskClass: riskClass,
    modelVersion: '1.0.0',
    contributingHazardZoneIdsJson: '[]',
    environmentalAdjustment: 0,
    environmentalProvenanceJson: '[]',
    assessedAt: now,
    version: 1,
  );

  LocalCapacityAssessment capacityAssessment({
    required String habitationId,
    required int gap,
  }) => LocalCapacityAssessment(
    habitationId: habitationId,
    exposedPopulation: 100,
    availableSafeCapacity: 100 - gap,
    capacityGap: gap,
    hasSufficientCapacity: gap <= 0,
    contributingSheltersJson: '[]',
    accessibleRadiusMeters: 5000,
    modelVersion: '1.0.0',
    assessedAt: now,
    version: 1,
  );

  LocalIncident incident({
    required String id,
    String status = 'acknowledged',
    String severity = 'medium',
    DateTime? createdAt,
  }) => LocalIncident(
    id: id,
    type: 'landslide',
    status: status,
    latitude: 0,
    longitude: 0,
    description: '',
    severity: severity,
    independentSourceCount: 1,
    confidence: 0.5,
    createdAt: createdAt ?? now,
    updatedAt: createdAt ?? now,
    version: 1,
    isSynced: false,
  );

  LocalAlert alert({
    required String id,
    DateTime? issuedAt,
    DateTime? validUntil,
    DateTime? cancelledAt,
  }) => LocalAlert(
    id: id,
    title: 'Alert $id',
    message: 'Message',
    severity: 'high',
    zoneId: 'zone-1',
    zoneLabel: 'landslide zone',
    geometryJson: '[]',
    issuedBy: 'official-1',
    issuedAt: issuedAt ?? now,
    validUntil: validUntil ?? now.add(const Duration(hours: 6)),
    cancelledAt: cancelledAt,
    version: 1,
  );

  test('red zones are hazard zones with high or critical severity only', () {
    final snapshot = buildDashboardSnapshot(
      hazardZones: [
        zone(id: 'z1', severity: 'low'),
        zone(id: 'z2', severity: 'medium'),
        zone(id: 'z3', severity: 'high'),
        zone(id: 'z4', severity: 'critical'),
      ],
      habitations: const [],
      incidents: const [],
      alerts: const [],
      pendingSyncCount: 0,
      responderCount: 0,
      now: now,
    );

    expect(snapshot.redZoneCount, 2);
    expect(snapshot.redZones.map((z) => z.id), containsAll(['z3', 'z4']));
  });

  test('vulnerable habitations are those risk-classified high or red', () {
    final habitations = [
      HabitationOverview(
        habitation: habitation('h1'),
        riskAssessment: riskAssessment(habitationId: 'h1', riskClass: 'low'),
      ),
      HabitationOverview(
        habitation: habitation('h2'),
        riskAssessment: riskAssessment(habitationId: 'h2', riskClass: 'high'),
      ),
      HabitationOverview(
        habitation: habitation('h3'),
        riskAssessment: riskAssessment(habitationId: 'h3', riskClass: 'red'),
      ),
      HabitationOverview(habitation: habitation('h4')), // not yet assessed
    ];

    final snapshot = buildDashboardSnapshot(
      hazardZones: const [],
      habitations: habitations,
      incidents: const [],
      alerts: const [],
      pendingSyncCount: 0,
      responderCount: 0,
      now: now,
    );

    expect(snapshot.vulnerableHabitationCount, 2);
    expect(
      snapshot.vulnerableHabitations.map((h) => h.habitation.id),
      containsAll(['h2', 'h3']),
    );
  });

  test('total capacity gap sums only habitations with an actual shortfall', () {
    final habitations = [
      HabitationOverview(
        habitation: habitation('h1'),
        capacityAssessment: capacityAssessment(habitationId: 'h1', gap: 30),
      ),
      HabitationOverview(
        habitation: habitation('h2'),
        capacityAssessment: capacityAssessment(habitationId: 'h2', gap: 20),
      ),
      HabitationOverview(
        habitation: habitation('h3'),
        capacityAssessment: capacityAssessment(habitationId: 'h3', gap: -50), // surplus
      ),
    ];

    final snapshot = buildDashboardSnapshot(
      hazardZones: const [],
      habitations: habitations,
      incidents: const [],
      alerts: const [],
      pendingSyncCount: 0,
      responderCount: 0,
      now: now,
    );

    expect(snapshot.totalCapacityGap, 50);
  });

  test('active incidents exclude rejected/resolved, sorted by severity then recency', () {
    final incidents = [
      incident(id: 'low', severity: 'low', createdAt: now),
      incident(
        id: 'critical-old',
        severity: 'critical',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      incident(id: 'critical-new', severity: 'critical', createdAt: now),
      incident(id: 'rejected', status: 'rejected'),
      incident(id: 'resolved', status: 'resolved'),
    ];

    final snapshot = buildDashboardSnapshot(
      hazardZones: const [],
      habitations: const [],
      incidents: incidents,
      alerts: const [],
      pendingSyncCount: 0,
      responderCount: 0,
      now: now,
    );

    expect(snapshot.activeIncidentCount, 3);
    expect(
      snapshot.activeIncidents.map((i) => i.id),
      ['critical-new', 'critical-old', 'low'],
    );
  });

  test(
    'COMMAND USER UNDERSTANDS CURRENT SITUATION — the acceptance criterion: '
    'active alerts respect validity, not just existence',
    () {
      final alerts = [
        alert(id: 'active', issuedAt: now, validUntil: now.add(const Duration(hours: 1))),
        alert(
          id: 'expired',
          issuedAt: now.subtract(const Duration(hours: 2)),
          validUntil: now.subtract(const Duration(hours: 1)),
        ),
        alert(id: 'cancelled', cancelledAt: now),
      ];

      final snapshot = buildDashboardSnapshot(
        hazardZones: const [],
        habitations: const [],
        incidents: const [],
        alerts: alerts,
        pendingSyncCount: 0,
        responderCount: 0,
        now: now,
      );

      expect(snapshot.activeAlertCount, 1);
      expect(snapshot.activeAlerts.single.id, 'active');
    },
  );

  test('pending sync count and responder count pass through unchanged', () {
    final snapshot = buildDashboardSnapshot(
      hazardZones: const [],
      habitations: const [],
      incidents: const [],
      alerts: const [],
      pendingSyncCount: 7,
      responderCount: 3,
      now: now,
    );

    expect(snapshot.pendingSyncCount, 7);
    expect(snapshot.responderCount, 3);
  });
}
