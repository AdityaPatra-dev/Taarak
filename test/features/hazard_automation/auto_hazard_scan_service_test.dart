import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_environmental_observation_repository.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_automation_state_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/features/environmental/application/environmental_data_service.dart';
import 'package:taarak/features/environmental/application/environmental_data_source.dart';
import 'package:taarak/features/hazard_automation/application/auto_hazard_scan_service.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';
import 'package:taarak/features/state_admin/domain/app_policy.dart';
import 'package:taarak/features/susceptibility/application/hazard_susceptibility_model.dart';
import 'package:taarak/features/susceptibility/domain/hazard_susceptibility_prediction.dart';

import '../../support/sqlite3_test_setup.dart';

class _NoOpDataSource implements EnvironmentalDataSource {
  @override
  Future<List<RawEnvironmentalReading>> fetchReadings({
    required double latitude,
    required double longitude,
    DateTime? now,
  }) async => const [];
}

/// A fully-controllable susceptibility model — the scan service's own
/// orchestration (id scheme, hysteresis wiring, which zones it touches)
/// is what's under test here, not the deterministic model's math (which
/// has its own test file).
class _ScriptedModel implements HazardSusceptibilityModel {
  final Map<String, double?> scoresByHabitationAndType;
  _ScriptedModel(this.scoresByHabitationAndType);

  @override
  Future<HazardSusceptibilityPrediction?> predict({
    required String habitationId,
    required double latitude,
    required double longitude,
    required HazardType hazardType,
    DateTime? now,
    String habitationName = '',
    int populationExposed = 0,
  }) async {
    final score = scoresByHabitationAndType['$habitationId-${hazardType.storageValue}'];
    if (score == null) return null;
    return HazardSusceptibilityPrediction(
      score: score,
      modelName: 'scripted',
      modelVersion: '0.0.0',
      featureContributions: const {},
      confidence: 0.9,
      predictedAt: now ?? DateTime.now(),
    );
  }
}

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late LocalHazardZoneRepository hazardZoneRepository;
  late LocalHazardAutomationStateRepository automationStateRepository;
  late AuditLogDao auditLogDao;
  late HazardIngestionService hazardIngestionService;
  final now = DateTime.utc(2026, 1, 1, 12);

  const policy = AppPolicy(
    alertValidityOptions: [],
    hazardRadiusOptionsMeters: [],
    autoHazardCreateThreshold: 0.6,
    autoHazardDeleteThreshold: 0.35,
    autoHazardDeleteConfirmationPolls: 2,
    autoHazardRadiusMeters: 1000,
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    hazardZoneRepository = LocalHazardZoneRepository(db);
    automationStateRepository = LocalHazardAutomationStateRepository(db);
    auditLogDao = AuditLogDao(db);
    hazardIngestionService = HazardIngestionService(
      normalizer: HazardNormalizer(),
      repository: hazardZoneRepository,
      auditLogDao: auditLogDao,
    );

    await db.into(db.localHabitations).insert(
      LocalHabitationsCompanion.insert(
        id: 'hab-1',
        name: 'Ridge Colony',
        latitude: 12.9,
        longitude: 77.5,
        updatedAt: now,
      ),
    );
  });

  tearDown(() => db.close());

  AutoHazardScanService serviceWithScores(Map<String, double?> scores) => AutoHazardScanService(
    habitationRepository: LocalHabitationRepository(db),
    environmentalDataService: EnvironmentalDataService(
      dataSource: _NoOpDataSource(),
      repository: LocalEnvironmentalObservationRepository(db),
    ),
    susceptibilityModel: _ScriptedModel(scores),
    hazardIngestionService: hazardIngestionService,
    automationStateRepository: automationStateRepository,
    auditLogDao: auditLogDao,
  );

  test('a qualifying poll creates exactly one auto-prefixed zone', () async {
    final service = serviceWithScores({'hab-1-landslide': 0.9});

    await service.scanAll(policy: policy, now: now);

    final zones = await (db.select(
      db.localHazardZones,
    )..where((t) => t.id.equals('auto-hab-1-landslide'))).get();
    expect(zones, hasLength(1));
    expect(zones.single.source, 'auto:open-meteo');
    expect(zones.single.hazardType, 'landslide');
  });

  test('re-scanning with the same high score upserts, does not duplicate', () async {
    final service = serviceWithScores({'hab-1-landslide': 0.9});

    await service.scanAll(policy: policy, now: now);
    await service.scanAll(policy: policy, now: now.add(const Duration(hours: 1)));

    final zones = await db.select(db.localHazardZones).get();
    expect(zones.where((z) => z.id == 'auto-hab-1-landslide'), hasLength(1));
    final zone = zones.firstWhere((z) => z.id == 'auto-hab-1-landslide');
    expect(zone.version, 2);
  });

  test('one below-threshold poll does not delete; two consecutive do', () async {
    final createService = serviceWithScores({'hab-1-landslide': 0.9});
    await createService.scanAll(policy: policy, now: now);

    final lowService = serviceWithScores({'hab-1-landslide': 0.1});
    await lowService.scanAll(policy: policy, now: now.add(const Duration(hours: 1)));

    var zones = await (db.select(
      db.localHazardZones,
    )..where((t) => t.id.equals('auto-hab-1-landslide'))).get();
    expect(zones, hasLength(1), reason: 'a single low poll must not delete');

    await lowService.scanAll(policy: policy, now: now.add(const Duration(hours: 2)));

    zones = await (db.select(
      db.localHazardZones,
    )..where((t) => t.id.equals('auto-hab-1-landslide'))).get();
    expect(zones, isEmpty, reason: 'two consecutive low polls must delete');

    final auditRows = await (db.select(db.localAuditEvents)
          ..where((t) => t.objectId.equals('auto-hab-1-landslide') & t.action.equals('hazard_zone.removed')))
        .get();
    expect(auditRows, hasLength(1));
    expect(auditRows.single.actorId, 'system:auto-hazard-engine');
  });

  test('a pre-seeded official-sourced zone is never touched, regardless of score', () async {
    await hazardIngestionService.ingest(
      id: 'official-zone-1',
      observation: RawHazardObservation(
        hazardType: 'landslide',
        severityScore: 0.9,
        boundaryPoints: const [LatLng(1, 1), LatLng(1, 2), LatLng(2, 2)],
        source: 'official:officer-1',
        observedAt: now,
      ),
      now: now,
    );

    final service = serviceWithScores({'hab-1-landslide': 0.0});
    await service.scanAll(policy: policy, now: now);
    await service.scanAll(policy: policy, now: now.add(const Duration(hours: 1)));

    final officialZone = await (db.select(
      db.localHazardZones,
    )..where((t) => t.id.equals('official-zone-1'))).getSingleOrNull();
    expect(officialZone, isNotNull, reason: 'the human-drawn zone must survive untouched');
    expect(officialZone!.source, 'official:officer-1');
  });

  test('a habitation with no fresh signal (null score) leaves an existing active zone untouched', () async {
    final createService = serviceWithScores({'hab-1-landslide': 0.9});
    await createService.scanAll(policy: policy, now: now);

    final outageService = serviceWithScores({'hab-1-landslide': null});
    await outageService.scanAll(policy: policy, now: now.add(const Duration(hours: 1)));

    final zones = await (db.select(
      db.localHazardZones,
    )..where((t) => t.id.equals('auto-hab-1-landslide'))).get();
    expect(zones, hasLength(1));
  });
}
