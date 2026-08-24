import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_risk_assessment_repository.dart';
import 'package:taarak/features/risk/application/risk_assessment_service.dart';
import 'package:taarak/features/risk/domain/vulnerability_provider.dart';

import '../../support/sqlite3_test_setup.dart';

class _FixedVulnerabilityProvider implements VulnerabilityProvider {
  final double index;
  const _FixedVulnerabilityProvider(this.index);

  @override
  Future<double> vulnerabilityIndexFor(String habitationId) async => index;
}

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late RiskAssessmentService service;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    service = RiskAssessmentService(
      habitationRepository: LocalHabitationRepository(db),
      hazardZoneRepository: LocalHazardZoneRepository(db),
      assessmentRepository: LocalRiskAssessmentRepository(db),
      vulnerabilityProvider: const _FixedVulnerabilityProvider(0.5),
    );

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

  test('assessing a known habitation persists a risk assessment row', () async {
    final result = await service.assessHabitation('hab-1', now: now);

    expect(result.isSuccess, isTrue);
    final saved = await (db.select(
      db.localRiskAssessments,
    )..where((t) => t.habitationId.equals('hab-1'))).getSingle();
    expect(saved.vulnerabilityIndex, closeTo(0.5, 0.001));
    expect(saved.version, 1);
  });

  test('assessing an unknown habitation fails without writing anything', () async {
    final result = await service.assessHabitation('does-not-exist', now: now);

    expect(result.isFailure, isTrue);
    final rows = await db.select(db.localRiskAssessments).get();
    expect(rows, isEmpty);
  });

  test('re-assessing the same habitation increments the assessment version', () async {
    await service.assessHabitation('hab-1', now: now);
    await service.assessHabitation('hab-1', now: now.add(const Duration(hours: 1)));

    final saved = await (db.select(
      db.localRiskAssessments,
    )..where((t) => t.habitationId.equals('hab-1'))).getSingle();
    expect(saved.version, 2);
  });

  test('assessAllHabitations covers every cached habitation', () async {
    await db
        .into(db.localHabitations)
        .insert(
          LocalHabitationsCompanion.insert(
            id: 'hab-2',
            name: 'Second Habitation',
            latitude: 20,
            longitude: 20,
            updatedAt: now,
          ),
        );

    final results = await service.assessAllHabitations(now: now);

    expect(results.map((r) => r.habitationId), containsAll(['hab-1', 'hab-2']));
    final rows = await db.select(db.localRiskAssessments).get();
    expect(rows, hasLength(2));
  });

  test('the same inputs reproduce the same score on repeated assessment', () async {
    final first = await service.assessHabitation('hab-1', now: now);
    final second = await service.assessHabitation('hab-1', now: now);

    expect(first.dataOrNull?.riskScore, second.dataOrNull?.riskScore);
    expect(first.dataOrNull?.riskClass, second.dataOrNull?.riskClass);
  });
}
