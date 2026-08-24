import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/alert_acknowledgement_dao.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_alert_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_incident_report_repository.dart';
import 'package:taarak/core/database/repositories/local_incident_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/core/location/administrative_context.dart';
import 'package:taarak/core/location/geo_tag_service.dart';
import 'package:taarak/core/location/gps_fix.dart';
import 'package:taarak/core/location/location_permission_status.dart';
import 'package:taarak/core/location/location_service.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/alerts/application/alert_broadcast_service.dart';
import 'package:taarak/features/audit/application/audit_log_filter.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';
import 'package:taarak/features/shelters/application/shelter_management_service.dart';
import 'package:taarak/features/verification/application/incident_verification_service.dart';

import '../../support/sqlite3_test_setup.dart';

class _NoOpContextResolver implements AdministrativeContextResolver {
  @override
  Future<AdministrativeContext?> resolve(double latitude, double longitude) async =>
      null;
}

class _FixedLocationService implements LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<Result<GpsFix>> getCurrentFix() async => Result.success(
    GpsFix(
      latitude: 50,
      longitude: 50,
      accuracyMeters: 5,
      capturedAt: DateTime.utc(2026, 1, 1),
    ),
  );
}

/// M19's acceptance criterion, proven across three unrelated modules that
/// each write to the one shared [AuditLogDao] (M13's incident lifecycle,
/// M15's shelter management, M16's alert broadcast) — a System Admin
/// browsing the audit log should be able to find and understand any of
/// them, not just the one module's own audit trail.
void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late AuditLogDao auditLogDao;
  final now = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    auditLogDao = AuditLogDao(db);
  });

  tearDown(() => db.close());

  test(
    'CRITICAL CHANGES ARE TRACEABLE — the acceptance criterion, across modules',
    () async {
      // M13/M14: an official acknowledges a citizen report into an incident.
      final reportRepository = LocalIncidentReportRepository(db);
      await reportRepository.save(
        LocalIncidentReport(
          id: 'report-1',
          incidentId: null,
          reporterId: 'citizen-1',
          latitude: 10,
          longitude: 10,
          reportType: 'landslide',
          description: 'Debris on the road',
          severity: 'high',
          affectedPeopleCount: null,
          mediaPath: null,
          createdAt: now,
          updatedAt: now,
          version: 1,
          isSynced: false,
        ),
      );
      final verificationService = IncidentVerificationService(
        reportRepository: reportRepository,
        incidentRepository: LocalIncidentRepository(db),
        auditLogDao: auditLogDao,
      );
      await verificationService.acknowledgeReport(
        reportId: 'report-1',
        officialId: 'official-1',
        reason: 'Confirmed by field call',
        now: now,
      );

      // M15: a Local Official records a shelter's occupancy.
      final shelterService = ShelterManagementService(
        shelterRepository: LocalShelterRepository(db),
        auditLogDao: auditLogDao,
      );
      await shelterService.upsertShelter(
        name: 'Community Hall',
        latitude: 20,
        longitude: 20,
        capacityTotal: 100,
        officialId: 'official-2',
        now: now.add(const Duration(minutes: 5)),
      );

      // M16: an official broadcasts an alert to a hazard zone.
      final hazardZoneRepository = LocalHazardZoneRepository(db);
      await HazardIngestionService(
        normalizer: HazardNormalizer(),
        repository: hazardZoneRepository,
      ).ingest(
        id: 'zone-1',
        observation: RawHazardObservation(
          hazardType: 'landslide',
          severityScore: 0.8,
          boundaryPoints: const [
            LatLng(49.99, 49.99),
            LatLng(49.99, 50.01),
            LatLng(50.01, 50.01),
            LatLng(50.01, 49.99),
          ],
          source: 'test',
          observedAt: now,
        ),
        now: now,
      );
      final alertService = AlertBroadcastService(
        alertRepository: LocalAlertRepository(db),
        hazardZoneRepository: hazardZoneRepository,
        acknowledgementDao: AlertAcknowledgementDao(db),
        auditLogDao: auditLogDao,
        geoTagService: GeoTagService(
          locationService: _FixedLocationService(),
          contextResolver: _NoOpContextResolver(),
        ),
      );
      await alertService.broadcastToZone(
        zoneId: 'zone-1',
        title: 'Landslide warning',
        message: 'Move to higher ground',
        severity: 'high',
        validFor: const Duration(hours: 6),
        officialId: 'official-3',
        now: now.add(const Duration(minutes: 10)),
      );

      // A System Admin reviewing the whole log sees all three, every
      // required field populated, most recent first.
      final allEvents = await auditLogDao.getAll();
      expect(allEvents.dataOrNull, hasLength(3));
      for (final event in allEvents.dataOrNull!) {
        expect(event.actorId, isNotEmpty);
        expect(event.action, isNotEmpty);
        expect(event.objectType, isNotEmpty);
        expect(event.objectId, isNotEmpty);
      }

      final ordered = filterAuditEvents(allEvents.dataOrNull!);
      expect(ordered.map((e) => e.objectType), ['alert', 'shelter', 'incident']);

      // Traceable specifically means findable by what changed, not just present.
      final shelterOnly = filterAuditEvents(allEvents.dataOrNull!, objectType: 'shelter');
      expect(shelterOnly, hasLength(1));
      expect(shelterOnly.single.action, 'shelter.created');

      final byActor = filterAuditEvents(allEvents.dataOrNull!, actorId: 'official-3');
      expect(byActor, hasLength(1));
      expect(byActor.single.objectType, 'alert');

      final byReason = filterAuditEvents(allEvents.dataOrNull!, query: 'field call');
      expect(byReason, hasLength(1));
      expect(byReason.single.action, 'incident.acknowledged');
    },
  );
}
