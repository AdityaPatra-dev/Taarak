import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/alert_acknowledgement_dao.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_alert_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/location/administrative_context.dart';
import 'package:taarak/core/location/geo_tag_service.dart';
import 'package:taarak/core/location/gps_fix.dart';
import 'package:taarak/core/location/location_permission_status.dart';
import 'package:taarak/core/location/location_service.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/alerts/application/alert_broadcast_service.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';

import '../../support/sqlite3_test_setup.dart';

class _FakeLocationService implements LocationService {
  final Result<GpsFix> fixResult;
  _FakeLocationService(this.fixResult);

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<Result<GpsFix>> getCurrentFix() async => fixResult;
}

class _NoOpContextResolver implements AdministrativeContextResolver {
  @override
  Future<AdministrativeContext?> resolve(double latitude, double longitude) async =>
      null;
}

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late LocalAlertRepository alertRepository;
  late HazardIngestionService hazardIngestionService;
  final now = DateTime.utc(2026, 1, 1, 12);

  GpsFix fixAt(double lat, double lng) =>
      GpsFix(latitude: lat, longitude: lng, accuracyMeters: 5, capturedAt: now);

  AlertBroadcastService serviceAt(double lat, double lng) => AlertBroadcastService(
    alertRepository: alertRepository,
    hazardZoneRepository: LocalHazardZoneRepository(db),
    acknowledgementDao: AlertAcknowledgementDao(db),
    auditLogDao: AuditLogDao(db),
    geoTagService: GeoTagService(
      locationService: _FakeLocationService(Result.success(fixAt(lat, lng))),
      contextResolver: _NoOpContextResolver(),
    ),
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    alertRepository = LocalAlertRepository(db);
    hazardIngestionService = HazardIngestionService(
      normalizer: HazardNormalizer(),
      repository: LocalHazardZoneRepository(db),
    );

    await hazardIngestionService.ingest(
      id: 'zone-1',
      observation: RawHazardObservation(
        hazardType: 'landslide',
        severityScore: 0.8,
        boundaryPoints: const [
          LatLng(9.99, 9.99),
          LatLng(9.99, 10.01),
          LatLng(10.01, 10.01),
          LatLng(10.01, 9.99),
        ],
        source: 'test',
        observedAt: now,
      ),
      now: now,
    );
  });

  tearDown(() => db.close());

  group('broadcastToZone', () {
    test(
      'OFFICIAL CAN BROADCAST TO SELECTED ZONE — the acceptance criterion',
      () async {
        final service = serviceAt(10, 10);
        final result = await service.broadcastToZone(
          zoneId: 'zone-1',
          title: 'Landslide warning',
          message: 'Move to higher ground',
          severity: 'high',
          validFor: const Duration(hours: 6),
          officialId: 'official-1',
          now: now,
        );

        expect(result.isSuccess, isTrue);
        final alert = result.dataOrNull!;
        expect(alert.zoneId, 'zone-1');
        expect(alert.validUntil, now.add(const Duration(hours: 6)));

        final auditDao = AuditLogDao(db);
        final trail = await auditDao.listForObject('alert', alert.id);
        expect(trail.dataOrNull, hasLength(1));
        expect(trail.dataOrNull!.first.action, 'alert.broadcast');
      },
    );

    test('fails cleanly for an unknown zone', () async {
      final service = serviceAt(10, 10);
      final result = await service.broadcastToZone(
        zoneId: 'missing-zone',
        title: 'Test',
        message: 'Test',
        severity: 'high',
        validFor: const Duration(hours: 1),
        officialId: 'official-1',
        now: now,
      );
      expect(result.isFailure, isTrue);
    });
  });

  group('activeAlertsForCurrentLocation', () {
    test('a citizen inside the broadcast zone sees the active alert', () async {
      final broadcaster = serviceAt(0, 0);
      await broadcaster.broadcastToZone(
        zoneId: 'zone-1',
        title: 'Landslide warning',
        message: 'Move to higher ground',
        severity: 'high',
        validFor: const Duration(hours: 6),
        officialId: 'official-1',
        now: now,
      );

      final citizenInZone = serviceAt(10, 10);
      final result = await citizenInZone.activeAlertsForCurrentLocation(now: now);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, hasLength(1));
      expect(result.dataOrNull!.first.title, 'Landslide warning');
    });

    test('a citizen outside the broadcast zone sees nothing', () async {
      final broadcaster = serviceAt(0, 0);
      await broadcaster.broadcastToZone(
        zoneId: 'zone-1',
        title: 'Landslide warning',
        message: 'Move to higher ground',
        severity: 'high',
        validFor: const Duration(hours: 6),
        officialId: 'official-1',
        now: now,
      );

      final citizenOutsideZone = serviceAt(50, 50);
      final result = await citizenOutsideZone.activeAlertsForCurrentLocation(now: now);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    });

    test('an expired alert no longer appears as active', () async {
      final broadcaster = serviceAt(0, 0);
      await broadcaster.broadcastToZone(
        zoneId: 'zone-1',
        title: 'Landslide warning',
        message: 'Move to higher ground',
        severity: 'high',
        validFor: const Duration(hours: 6),
        officialId: 'official-1',
        now: now,
      );

      final citizenInZone = serviceAt(10, 10);
      final result = await citizenInZone.activeAlertsForCurrentLocation(
        now: now.add(const Duration(hours: 7)),
      );

      expect(result.dataOrNull, isEmpty);
    });
  });

  group('cancelAlert', () {
    test('a cancelled alert no longer applies to citizens in its zone', () async {
      final broadcaster = serviceAt(0, 0);
      final broadcastResult = await broadcaster.broadcastToZone(
        zoneId: 'zone-1',
        title: 'Landslide warning',
        message: 'Move to higher ground',
        severity: 'high',
        validFor: const Duration(hours: 6),
        officialId: 'official-1',
        now: now,
      );

      await broadcaster.cancelAlert(
        alertId: broadcastResult.dataOrNull!.id,
        officialId: 'official-1',
        reason: 'False alarm',
        now: now.add(const Duration(minutes: 5)),
      );

      final citizenInZone = serviceAt(10, 10);
      final result = await citizenInZone.activeAlertsForCurrentLocation(
        now: now.add(const Duration(minutes: 10)),
      );
      expect(result.dataOrNull, isEmpty);

      final auditDao = AuditLogDao(db);
      final trail = await auditDao.listForObject('alert', broadcastResult.dataOrNull!.id);
      expect(trail.dataOrNull!.map((e) => e.action), contains('alert.cancelled'));
    });
  });

  group('acknowledge', () {
    test('acknowledging twice from the same user does not duplicate', () async {
      final service = serviceAt(10, 10);
      final broadcastResult = await service.broadcastToZone(
        zoneId: 'zone-1',
        title: 'Landslide warning',
        message: 'Move to higher ground',
        severity: 'high',
        validFor: const Duration(hours: 6),
        officialId: 'official-1',
        now: now,
      );
      final alertId = broadcastResult.dataOrNull!.id;

      await service.acknowledge(alertId: alertId, userId: 'citizen-1', now: now);
      await service.acknowledge(alertId: alertId, userId: 'citizen-1', now: now);
      await service.acknowledge(alertId: alertId, userId: 'citizen-2', now: now);

      final acks = await service.acknowledgementsFor(alertId);
      expect(acks.dataOrNull, hasLength(2));
    });
  });

  group('history', () {
    test('returns every broadcast alert, most recent first', () async {
      final service = serviceAt(10, 10);
      await service.broadcastToZone(
        zoneId: 'zone-1',
        title: 'First',
        message: 'First',
        severity: 'medium',
        validFor: const Duration(hours: 1),
        officialId: 'official-1',
        now: now,
      );
      await service.broadcastToZone(
        zoneId: 'zone-1',
        title: 'Second',
        message: 'Second',
        severity: 'critical',
        validFor: const Duration(hours: 1),
        officialId: 'official-1',
        now: now.add(const Duration(minutes: 10)),
      );

      final history = await service.history();
      expect(history.dataOrNull?.map((a) => a.title), ['Second', 'First']);
    });
  });
}
