import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_incident_report_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/location/administrative_context.dart';
import 'package:taarak/core/location/geo_tag_service.dart';
import 'package:taarak/core/location/gps_fix.dart';
import 'package:taarak/core/location/location_permission_status.dart';
import 'package:taarak/core/location/location_service.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/reporting/application/citizen_report_submission_service.dart';
import 'package:taarak/features/reporting/domain/citizen_report_draft.dart';
import 'package:taarak/features/reporting/domain/citizen_report_type.dart';

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
  late LocalIncidentReportRepository reportRepository;
  late SyncQueueDao syncQueueDao;
  final now = DateTime.utc(2026, 1, 1);

  GpsFix fix() => GpsFix(
    latitude: 12.9,
    longitude: 77.6,
    accuracyMeters: 5,
    capturedAt: now,
  );

  CitizenReportSubmissionService serviceWithFix(Result<GpsFix> fixResult) {
    return CitizenReportSubmissionService(
      reportRepository: reportRepository,
      syncQueueDao: syncQueueDao,
      geoTagService: GeoTagService(
        locationService: _FakeLocationService(fixResult),
        contextResolver: _NoOpContextResolver(),
      ),
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    reportRepository = LocalIncidentReportRepository(db);
    syncQueueDao = SyncQueueDao(db);
  });

  tearDown(() => db.close());

  test(
    'OFFLINE REPORT IS SAVED LOCALLY AND MARKED PENDING SYNC — the acceptance criterion',
    () async {
      final service = serviceWithFix(Result.success(fix()));

      final result = await service.submitReport(
        const CitizenReportDraft(
          type: CitizenReportType.landslide,
          description: 'Debris on the road',
          severity: 'high',
          affectedPeopleCount: 12,
        ),
        reporterId: 'citizen-1',
        now: now,
      );

      expect(result.isSuccess, isTrue);

      // Saved locally...
      final saved = await reportRepository.getById(result.dataOrNull!.id);
      expect(saved.isSuccess, isTrue);
      expect(saved.dataOrNull?.isSynced, isFalse); // ...and marked pending sync.
      expect(saved.dataOrNull?.reportType, 'landslide');
      expect(saved.dataOrNull?.latitude, 12.9);
      expect(saved.dataOrNull?.affectedPeopleCount, 12);

      // ...and queued for the future sync pass (M17).
      final pending = await syncQueueDao.listPending();
      expect(pending.dataOrNull, hasLength(1));
      expect(pending.dataOrNull!.single.entityId, result.dataOrNull!.id);
      expect(pending.dataOrNull!.single.entityTable, 'local_incident_reports');
    },
  );

  test('a report without a location fix fails without writing anything', () async {
    final service = serviceWithFix(
      const Result.failure(LocationFailure('no fix')),
    );

    final result = await service.submitReport(
      const CitizenReportDraft(type: CitizenReportType.other),
      reporterId: 'citizen-1',
      now: now,
    );

    expect(result.isFailure, isTrue);
    final rows = await reportRepository.getAll();
    expect(rows.dataOrNull, isEmpty);
    final pending = await syncQueueDao.listPending();
    expect(pending.dataOrNull, isEmpty);
  });

  test('submitSos records a critical, sos-typed report', () async {
    final service = serviceWithFix(Result.success(fix()));

    final result = await service.submitSos(
      note: 'Trapped near the bridge',
      reporterId: 'citizen-1',
      now: now,
    );

    expect(result.dataOrNull?.reportType, 'sos');
    expect(result.dataOrNull?.severity, 'critical');
    expect(result.dataOrNull?.description, 'Trapped near the bridge');
    expect(result.dataOrNull?.isSynced, isFalse);
  });

  test('submitSafeStatus records a safe_status report with no severity implied', () async {
    final service = serviceWithFix(Result.success(fix()));

    final result = await service.submitSafeStatus(
      reporterId: 'citizen-1',
      now: now,
    );

    expect(result.dataOrNull?.reportType, 'safe_status');
    expect(result.dataOrNull?.isSynced, isFalse);
  });

  test('each submitted report gets a distinct id', () async {
    final service = serviceWithFix(Result.success(fix()));

    final first = await service.submitSafeStatus(reporterId: 'citizen-1', now: now);
    final second = await service.submitSafeStatus(reporterId: 'citizen-1', now: now);

    expect(first.dataOrNull!.id, isNot(second.dataOrNull!.id));
  });
}
