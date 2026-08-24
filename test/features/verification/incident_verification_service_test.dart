import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_incident_report_repository.dart';
import 'package:taarak/core/database/repositories/local_incident_repository.dart';
import 'package:taarak/features/verification/application/incident_verification_service.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late IncidentVerificationService service;
  late LocalIncidentReportRepository reportRepository;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    reportRepository = LocalIncidentReportRepository(db);
    service = IncidentVerificationService(
      reportRepository: reportRepository,
      incidentRepository: LocalIncidentRepository(db),
      auditLogDao: AuditLogDao(db),
    );

    await db
        .into(db.localIncidentReports)
        .insert(
          LocalIncidentReportsCompanion.insert(
            id: 'report-1',
            latitude: 10,
            longitude: 10,
            reportType: 'landslide',
            description: const Value('Debris on the road'),
            severity: const Value('high'),
            reporterId: const Value('reporter-1'),
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() => db.close());

  group('acknowledgeReport', () {
    test('creates an acknowledged incident and links the report back to it', () async {
      final result = await service.acknowledgeReport(
        reportId: 'report-1',
        officialId: 'official-1',
        now: now,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.status, 'acknowledged');
      expect(result.dataOrNull?.type, 'landslide');

      final report = await reportRepository.getById('report-1');
      expect(report.dataOrNull?.incidentId, result.dataOrNull?.id);
    });

    test('fails cleanly for an unknown report', () async {
      final result = await service.acknowledgeReport(
        reportId: 'missing',
        officialId: 'official-1',
        now: now,
      );
      expect(result.isFailure, isTrue);
    });

    test('no longer appears in pendingReports once acknowledged', () async {
      expect((await service.pendingReports()).dataOrNull, hasLength(1));
      await service.acknowledgeReport(
        reportId: 'report-1',
        officialId: 'official-1',
        now: now,
      );
      expect((await service.pendingReports()).dataOrNull, isEmpty);
    });
  });

  group('transitionIncident', () {
    late String incidentId;

    setUp(() async {
      final result = await service.acknowledgeReport(
        reportId: 'report-1',
        officialId: 'official-1',
        now: now,
      );
      incidentId = result.dataOrNull!.id;
    });

    test(
      'AUTHORIZED OFFICIAL CHANGES INCIDENT STATE WITH AUDIT ENTRY — the acceptance criterion',
      () async {
        final result = await service.transitionIncident(
          incidentId: incidentId,
          to: IncidentVerificationStatus.verified,
          officialId: 'official-1',
          reason: 'Confirmed by a second report',
          evidence: 'photo-123.jpg',
          now: now,
        );

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.status, 'verified');

        final auditTrail = await service.auditTrailFor(incidentId);
        expect(auditTrail.isSuccess, isTrue);
        // One entry from acknowledgeReport, one from this transition.
        expect(auditTrail.dataOrNull, hasLength(2));

        final latest = auditTrail.dataOrNull!.first;
        expect(latest.actorId, 'official-1');
        expect(latest.action, 'incident.status_changed');
        expect(latest.objectType, 'incident');
        expect(latest.objectId, incidentId);
        expect(latest.reason, 'Confirmed by a second report');
        expect(jsonDecode(latest.oldValue!)['status'], 'acknowledged');
        expect(jsonDecode(latest.newValue!)['status'], 'verified');
        expect(jsonDecode(latest.newValue!)['evidence'], 'photo-123.jpg');
      },
    );

    test('rejects an invalid transition and writes no audit entry for it', () async {
      final auditBefore = await service.auditTrailFor(incidentId);
      final countBefore = auditBefore.dataOrNull!.length;

      final result = await service.transitionIncident(
        incidentId: incidentId,
        to: IncidentVerificationStatus.resolved, // acknowledged -> resolved is not allowed
        officialId: 'official-1',
        now: now,
      );

      expect(result.isFailure, isTrue);
      final auditAfter = await service.auditTrailFor(incidentId);
      expect(auditAfter.dataOrNull!.length, countBefore);
    });

    test('a full verified path accumulates one audit entry per step', () async {
      await service.transitionIncident(
        incidentId: incidentId,
        to: IncidentVerificationStatus.verified,
        officialId: 'official-1',
        now: now,
      );
      await service.transitionIncident(
        incidentId: incidentId,
        to: IncidentVerificationStatus.active,
        officialId: 'official-1',
        now: now,
      );
      await service.transitionIncident(
        incidentId: incidentId,
        to: IncidentVerificationStatus.resolved,
        officialId: 'official-1',
        now: now,
      );

      final auditTrail = await service.auditTrailFor(incidentId);
      // acknowledge + verify + activate + resolve
      expect(auditTrail.dataOrNull, hasLength(4));
    });

    test('fails cleanly for an unknown incident', () async {
      final result = await service.transitionIncident(
        incidentId: 'missing',
        to: IncidentVerificationStatus.verified,
        officialId: 'official-1',
        now: now,
      );
      expect(result.isFailure, isTrue);
    });
  });

  group('ground-truth fusion (M14) via acknowledgeReport', () {
    setUp(() async {
      await db
          .into(db.localIncidentReports)
          .insert(
            LocalIncidentReportsCompanion.insert(
              id: 'report-2',
              latitude: 10.001,
              longitude: 10.001,
              reportType: 'landslide',
              description: const Value('Same slide, seen from further down'),
              severity: const Value('critical'),
              reporterId: const Value('reporter-2'),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    test(
      'a second nearby report of the same type merges into the first incident',
      () async {
        final first = await service.acknowledgeReport(
          reportId: 'report-1',
          officialId: 'official-1',
          now: now,
        );
        final incidentId = first.dataOrNull!.id;

        final second = await service.acknowledgeReport(
          reportId: 'report-2',
          officialId: 'official-2',
          now: now,
        );

        expect(second.isSuccess, isTrue);
        expect(second.dataOrNull?.id, incidentId);
        expect(second.dataOrNull?.independentSourceCount, 2);
        // Severity escalates to the worse of 'high' and 'critical'.
        expect(second.dataOrNull?.severity, 'critical');

        final secondReport = await reportRepository.getById('report-2');
        expect(secondReport.dataOrNull?.incidentId, incidentId);
      },
    );

    test('the merge is recorded as incident.report_merged in the audit trail', () async {
      final first = await service.acknowledgeReport(
        reportId: 'report-1',
        officialId: 'official-1',
        now: now,
      );
      final incidentId = first.dataOrNull!.id;

      await service.acknowledgeReport(
        reportId: 'report-2',
        officialId: 'official-2',
        now: now,
      );

      final auditTrail = await service.auditTrailFor(incidentId);
      expect(auditTrail.dataOrNull, hasLength(2));
      expect(auditTrail.dataOrNull!.first.action, 'incident.report_merged');
      expect(
        jsonDecode(auditTrail.dataOrNull!.first.newValue!)['independentSourceCount'],
        2,
      );
    });

    test('a report far away starts its own incident instead of merging', () async {
      await db
          .into(db.localIncidentReports)
          .insert(
            LocalIncidentReportsCompanion.insert(
              id: 'report-far',
              latitude: 40,
              longitude: 40,
              reportType: 'landslide',
              reporterId: const Value('reporter-3'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final first = await service.acknowledgeReport(
        reportId: 'report-1',
        officialId: 'official-1',
        now: now,
      );
      final farAway = await service.acknowledgeReport(
        reportId: 'report-far',
        officialId: 'official-1',
        now: now,
      );

      expect(farAway.dataOrNull?.id, isNot(first.dataOrNull?.id));
      expect(farAway.dataOrNull?.independentSourceCount, 1);
    });
  });
}
