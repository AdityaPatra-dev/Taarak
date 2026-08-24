import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_environmental_observation_repository.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_risk_assessment_repository.dart';
import 'package:taarak/features/environmental/application/environmental_data_service.dart';
import 'package:taarak/features/environmental/application/environmental_data_source.dart';
import 'package:taarak/features/environmental/domain/environmental_parameter.dart';
import 'package:taarak/features/risk/application/risk_assessment_service.dart';
import 'package:taarak/features/risk/domain/vulnerability_provider.dart';

import '../../support/sqlite3_test_setup.dart';

class _FixedVulnerabilityProvider implements VulnerabilityProvider {
  final double index;
  const _FixedVulnerabilityProvider(this.index);

  @override
  Future<double> vulnerabilityIndexFor(String habitationId) async => index;
}

class _HeavyRainDataSource implements EnvironmentalDataSource {
  @override
  Future<List<RawEnvironmentalReading>> fetchReadings({
    required double latitude,
    required double longitude,
    DateTime? now,
  }) async => [
    RawEnvironmentalReading(
      parameter: EnvironmentalParameter.rainfall24h,
      value: 190, // near the engine's own "extreme" reference
      source: 'IMD (test feed)',
      observedAt: now ?? DateTime.now(),
      confidence: 1.0,
    ),
  ];
}

/// M24's acceptance criterion proven end to end: a real
/// [EnvironmentalDataService] wired into [RiskAssessmentService] moves the
/// persisted risk score, and the persisted row carries the provenance
/// that explains why — while a [RiskAssessmentService] built *without*
/// one behaves exactly as it did before M24 existed.
void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  final now = DateTime.utc(2026, 1, 1, 12);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.localHabitations)
        .insert(
          LocalHabitationsCompanion.insert(
            id: 'hab-1',
            name: 'Test Habitation',
            latitude: 10,
            longitude: 10,
            updatedAt: now,
          ),
        );
  });

  tearDown(() => db.close());

  test(
    'EXTERNAL DATA CAN INFLUENCE RISK WITH VISIBLE PROVENANCE — the acceptance criterion',
    () async {
      final environmentalService = EnvironmentalDataService(
        dataSource: _HeavyRainDataSource(),
        repository: LocalEnvironmentalObservationRepository(db),
      );
      await environmentalService.refreshForHabitation(
        habitationId: 'hab-1',
        latitude: 10,
        longitude: 10,
        now: now,
      );

      final withoutEnvironmental = RiskAssessmentService(
        habitationRepository: LocalHabitationRepository(db),
        hazardZoneRepository: LocalHazardZoneRepository(db),
        assessmentRepository: LocalRiskAssessmentRepository(db),
        vulnerabilityProvider: const _FixedVulnerabilityProvider(0.5),
      );
      final baseline = await withoutEnvironmental.assessHabitation('hab-1', now: now);

      final withEnvironmental = RiskAssessmentService(
        habitationRepository: LocalHabitationRepository(db),
        hazardZoneRepository: LocalHazardZoneRepository(db),
        assessmentRepository: LocalRiskAssessmentRepository(db),
        vulnerabilityProvider: const _FixedVulnerabilityProvider(0.5),
        environmentalDataService: environmentalService,
      );
      final influenced = await withEnvironmental.assessHabitation('hab-1', now: now);

      expect(influenced.dataOrNull!.riskScore, greaterThan(baseline.dataOrNull!.riskScore));
      expect(influenced.dataOrNull!.environmentalAdjustment, greaterThan(0));

      final savedRow = await (db.select(
        db.localRiskAssessments,
      )..where((t) => t.habitationId.equals('hab-1'))).getSingle();
      expect(savedRow.environmentalAdjustment, greaterThan(0));
      expect(savedRow.environmentalProvenanceJson, contains('IMD (test feed)'));
    },
  );

  test(
    'without an environmental data service, RiskAssessmentService behaves exactly '
    'as it did before M24 — a regression guard, not just a feature test',
    () async {
      final service = RiskAssessmentService(
        habitationRepository: LocalHabitationRepository(db),
        hazardZoneRepository: LocalHazardZoneRepository(db),
        assessmentRepository: LocalRiskAssessmentRepository(db),
        vulnerabilityProvider: const _FixedVulnerabilityProvider(0.5),
      );

      final result = await service.assessHabitation('hab-1', now: now);

      expect(result.dataOrNull!.environmentalAdjustment, 0);
      expect(result.dataOrNull!.environmentalProvenance, isEmpty);

      final savedRow = await (db.select(
        db.localRiskAssessments,
      )..where((t) => t.habitationId.equals('hab-1'))).getSingle();
      expect(savedRow.environmentalAdjustment, 0);
      expect(savedRow.environmentalProvenanceJson, '[]');
    },
  );

  test('a stale-only environmental cache does not influence the score', () async {
    final repository = LocalEnvironmentalObservationRepository(db);
    await repository.save(
      LocalEnvironmentalObservation(
        id: 'hab-1-rainfall_24h',
        habitationId: 'hab-1',
        parameter: 'rainfall_24h',
        value: 190,
        source: 'IMD (test feed)',
        observedAt: now.subtract(const Duration(days: 5)),
        fetchedAt: now.subtract(const Duration(days: 5)),
        confidence: 1.0,
        version: 1,
      ),
    );

    final environmentalService = EnvironmentalDataService(
      dataSource: _HeavyRainDataSource(),
      repository: repository,
    );

    final service = RiskAssessmentService(
      habitationRepository: LocalHabitationRepository(db),
      hazardZoneRepository: LocalHazardZoneRepository(db),
      assessmentRepository: LocalRiskAssessmentRepository(db),
      vulnerabilityProvider: const _FixedVulnerabilityProvider(0.5),
      environmentalDataService: environmentalService,
    );

    final result = await service.assessHabitation('hab-1', now: now);

    expect(result.dataOrNull!.environmentalAdjustment, 0);
  });
}
