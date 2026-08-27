import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_capacity_assessment_repository.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_relocation_plan_repository.dart';
import 'package:taarak/core/database/repositories/local_risk_assessment_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/features/capacity/application/capacity_assessment_service.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';
import 'package:taarak/features/relocation/application/relocation_planning_service.dart';
import 'package:taarak/features/relocation/application/relocation_priority_service.dart';
import 'package:taarak/features/relocation/domain/relocation_priority_tier.dart';
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
  late RelocationPriorityService service;
  late HazardIngestionService hazardIngestionService;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    hazardIngestionService = HazardIngestionService(
      normalizer: HazardNormalizer(),
      repository: LocalHazardZoneRepository(db),
    );
    service = RelocationPriorityService(
      habitationRepository: LocalHabitationRepository(db),
      hazardZoneRepository: LocalHazardZoneRepository(db),
      riskAssessmentService: RiskAssessmentService(
        habitationRepository: LocalHabitationRepository(db),
        hazardZoneRepository: LocalHazardZoneRepository(db),
        assessmentRepository: LocalRiskAssessmentRepository(db),
        vulnerabilityProvider: const _FixedVulnerabilityProvider(0.5),
      ),
      capacityAssessmentService: CapacityAssessmentService(
        habitationRepository: LocalHabitationRepository(db),
        hazardZoneRepository: LocalHazardZoneRepository(db),
        shelterRepository: LocalShelterRepository(db),
        assessmentRepository: LocalCapacityAssessmentRepository(db),
      ),
      relocationPlanningService: RelocationPlanningService(
        habitationRepository: LocalHabitationRepository(db),
        hazardZoneRepository: LocalHazardZoneRepository(db),
        shelterRepository: LocalShelterRepository(db),
        planRepository: LocalRelocationPlanRepository(db),
      ),
    );
  });

  tearDown(() => db.close());

  test('an empty habitation table produces an empty queue', () async {
    final queue = await service.buildQueue(now: now);
    expect(queue, isEmpty);
  });

  test(
    'a habitation inside a hazard zone with no nearby shelter ranks first, '
    'and its hazard zone source is carried into the reasoning',
    () async {
      await db
          .into(db.localHabitations)
          .insert(
            LocalHabitationsCompanion.insert(
              id: 'hab-exposed',
              name: 'Exposed Village',
              latitude: 10,
              longitude: 10,
              population: const Value(500),
              updatedAt: now,
            ),
          );
      await db
          .into(db.localHabitations)
          .insert(
            LocalHabitationsCompanion.insert(
              id: 'hab-safe',
              name: 'Safe Village',
              latitude: 40,
              longitude: 40,
              population: const Value(500),
              updatedAt: now,
            ),
          );

      await hazardIngestionService.ingest(
        id: 'zone-1',
        observation: RawHazardObservation(
          hazardType: 'landslide',
          severityScore: 0.9,
          boundaryPoints: const [
            LatLng(9.99, 9.99),
            LatLng(9.99, 10.01),
            LatLng(10.01, 10.01),
            LatLng(10.01, 9.99),
          ],
          source: 'Geological Survey of India',
          observedAt: now,
        ),
        now: now,
      );

      final queue = await service.buildQueue(now: now);

      expect(queue, hasLength(2));
      expect(queue.first.habitationId, 'hab-exposed');
      expect(queue.first.priorityTier, RelocationPriorityTier.immediate);
      expect(
        queue.first.reasoning.any(
          (r) => r.contains('Geological Survey of India'),
        ),
        isTrue,
      );
      expect(queue.last.habitationId, 'hab-safe');
      expect(
        queue.last.reasoning.any((r) => r.contains('Hazard data source')),
        isFalse,
      );
    },
  );
}
