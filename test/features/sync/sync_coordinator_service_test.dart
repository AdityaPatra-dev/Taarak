import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_incident_report_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/sync/application/sync_coordinator_service.dart';
import 'package:taarak/features/sync/application/sync_engine.dart';
import 'package:taarak/features/sync/application/sync_transport.dart';
import 'package:taarak/features/sync/domain/remote_sync_record.dart';
import 'package:taarak/features/sync/domain/sync_push_outcome.dart';

import '../../support/sqlite3_test_setup.dart';

class _FakeNetworkInfo implements NetworkInfo {
  bool connected;
  _FakeNetworkInfo({this.connected = true});

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();
}

/// Scripted transport: queues canned outcomes per entityId, and records
/// every push it received so tests can assert on push order/count.
class _ScriptedTransport implements SyncTransport {
  final Map<String, Result<SyncPushOutcome> Function()> _scripts;
  final List<String> pushedEntityIds = [];
  List<RemoteSyncRecord> remoteRecords = const [];

  _ScriptedTransport(this._scripts);

  @override
  Future<Result<SyncPushOutcome>> push(SyncQueueEntry entry) async {
    pushedEntityIds.add(entry.entityId);
    final script = _scripts[entry.entityId];
    if (script == null) return const Result.success(SyncPushOutcome.accepted());
    return script();
  }

  @override
  Future<Result<List<RemoteSyncRecord>>> pullAll(String table) async {
    return Result.success(remoteRecords);
  }
}

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late SyncQueueDao syncQueueDao;
  final now = DateTime.utc(2026, 1, 1, 12);

  Future<int> enqueue({
    String entityId = 'report-1',
    Map<String, dynamic> payload = const {},
  }) async {
    final result = await syncQueueDao.enqueue(
      entityTable: 'local_incident_reports',
      entityId: entityId,
      operation: 'create',
      payloadJson: jsonEncode(payload),
    );
    return result.dataOrNull!;
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    syncQueueDao = SyncQueueDao(db);
  });

  tearDown(() => db.close());

  group(
    'OFFLINE DATA SYNCHRONIZES SAFELY AFTER RECONNECTION — the acceptance criterion',
    () {
      test(
        'while offline, nothing is pushed and entries stay pending',
        () async {
          await enqueue();
          final transport = _ScriptedTransport(const {});
          final service = SyncCoordinatorService(
            syncQueueDao: syncQueueDao,
            networkInfo: _FakeNetworkInfo(connected: false),
            transport: transport,
          );

          final summary = await service.syncPendingEntries(now: now);

          expect(summary.skippedOffline, isTrue);
          expect(transport.pushedEntityIds, isEmpty);
          final pending = await syncQueueDao.listPending();
          expect(pending.dataOrNull, hasLength(1));
        },
      );

      test(
        'once reconnected, a pending entry is pushed and marked synced',
        () async {
          final id = await enqueue();
          final transport = _ScriptedTransport(const {});
          final service = SyncCoordinatorService(
            syncQueueDao: syncQueueDao,
            networkInfo: _FakeNetworkInfo(connected: true),
            transport: transport,
          );

          final summary = await service.syncPendingEntries(now: now);

          expect(summary.syncedCount, 1);
          expect(transport.pushedEntityIds, ['report-1']);

          final row = await (db.select(
            db.syncQueueEntries,
          )..where((t) => t.id.equals(id))).getSingle();
          expect(row.status, 'synced');
        },
      );
    },
  );

  test(
    'a transport failure marks the entry failed but keeps it queued for retry',
    () async {
      final id = await enqueue();
      final transport = _ScriptedTransport({
        'report-1': () => const Result.failure(NetworkFailure()),
      });
      final service = SyncCoordinatorService(
        syncQueueDao: syncQueueDao,
        networkInfo: _FakeNetworkInfo(),
        transport: transport,
      );

      final summary = await service.syncPendingEntries(now: now);

      expect(summary.failedCount, 1);
      final row = await (db.select(
        db.syncQueueEntries,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(row.status, 'failed');
      expect(row.attemptCount, 1);
    },
  );

  test(
    'a failed entry still inside its backoff window is not retried yet',
    () async {
      await enqueue();
      final transport = _ScriptedTransport({
        'report-1': () => const Result.failure(NetworkFailure()),
      });
      final service = SyncCoordinatorService(
        syncQueueDao: syncQueueDao,
        networkInfo: _FakeNetworkInfo(),
        transport: transport,
      );

      await service.syncPendingEntries(
        now: now,
      ); // 1st attempt: fails, attemptCount -> 1
      transport.pushedEntityIds.clear();

      final summary = await service.syncPendingEntries(
        now: now.add(
          const Duration(seconds: 1),
        ), // still within the backoff window
      );

      expect(transport.pushedEntityIds, isEmpty);
      expect(summary.failedCount, 0);
      expect(summary.syncedCount, 0);
    },
  );

  test(
    'an entry that exhausts its max attempts is abandoned, not retried forever',
    () async {
      final id = await enqueue();
      final transport = _ScriptedTransport({
        'report-1': () => const Result.failure(NetworkFailure()),
      });
      final service = SyncCoordinatorService(
        syncQueueDao: syncQueueDao,
        networkInfo: _FakeNetworkInfo(),
        transport: transport,
      );

      var attemptTime = now;
      for (var i = 0; i < 5; i++) {
        await service.syncPendingEntries(now: attemptTime);
        attemptTime = attemptTime.add(const Duration(minutes: 10));
      }

      transport.pushedEntityIds.clear();
      final finalSummary = await service.syncPendingEntries(now: attemptTime);

      expect(finalSummary.abandonedCount, 1);
      expect(transport.pushedEntityIds, isEmpty);

      // Still queued, not deleted — an official could still inspect/retry it manually later.
      final row = await (db.select(
        db.syncQueueEntries,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(row.status, 'failed');
    },
  );

  group('conflict resolution', () {
    test(
      'server-wins conflict is treated as already-synced, not an error',
      () async {
        await enqueue(payload: {'version': 1});
        final transport = _ScriptedTransport({
          'report-1': () => const Result.success(SyncPushOutcome.conflict(5)),
        });
        final service = SyncCoordinatorService(
          syncQueueDao: syncQueueDao,
          networkInfo: _FakeNetworkInfo(),
          transport: transport,
        );

        final summary = await service.syncPendingEntries(now: now);

        expect(summary.conflictCount, 1);
        final pending = await syncQueueDao.listPending();
        expect(pending.dataOrNull, isEmpty); // marked synced, not left pending
      },
    );

    test(
      'local-wins conflict is kept queued for retry, not silently dropped',
      () async {
        final id = await enqueue(payload: {'version': 9});
        final transport = _ScriptedTransport({
          'report-1': () => const Result.success(SyncPushOutcome.conflict(2)),
        });
        final service = SyncCoordinatorService(
          syncQueueDao: syncQueueDao,
          networkInfo: _FakeNetworkInfo(),
          transport: transport,
        );

        final summary = await service.syncPendingEntries(now: now);

        expect(summary.conflictCount, 1);
        final row = await (db.select(
          db.syncQueueEntries,
        )..where((t) => t.id.equals(id))).getSingle();
        expect(row.status, 'failed');
      },
    );
  });

  group('deduplication', () {
    test(
      'only the latest of two queued edits to the same entity is pushed',
      () async {
        await enqueue(entityId: 'report-1', payload: {'version': 1});
        final secondId = await enqueue(
          entityId: 'report-1',
          payload: {'version': 2},
        );

        final transport = _ScriptedTransport(const {});
        final service = SyncCoordinatorService(
          syncQueueDao: syncQueueDao,
          networkInfo: _FakeNetworkInfo(),
          transport: transport,
        );

        final summary = await service.syncPendingEntries(now: now);

        expect(transport.pushedEntityIds, ['report-1']);
        expect(summary.syncedCount, 1);

        final rows = await db.select(db.syncQueueEntries).get();
        expect(rows.every((r) => r.status == 'synced'), isTrue);
        expect(
          rows.firstWhere((r) => r.id == secondId).payloadJson,
          contains('"version":2'),
        );
      },
    );
  });

  group('priority', () {
    test(
      'an SOS entry is pushed before a routine one queued earlier',
      () async {
        await enqueue(entityId: 'routine', payload: {'reportType': 'flood'});
        await enqueue(
          entityId: 'sos',
          payload: {'reportType': 'sos', 'severity': 'critical'},
        );

        final transport = _ScriptedTransport(const {});
        final service = SyncCoordinatorService(
          syncQueueDao: syncQueueDao,
          networkInfo: _FakeNetworkInfo(),
          transport: transport,
        );

        await service.syncPendingEntries(now: now);

        expect(transport.pushedEntityIds.first, 'sos');
      },
    );
  });

  group(
    'CRITICAL TEXT/GPS CAN SYNC EVEN IF MEDIA FAILS — the M21 acceptance criterion',
    () {
      test(
        "a report's own entry still syncs even though its media attachment's push fails",
        () async {
          final reportId = await enqueue(
            entityId: 'report-1',
            payload: {'reportType': 'landslide', 'severity': 'high'},
          );
          final mediaResult = await syncQueueDao.enqueue(
            entityTable: SyncEngine.mediaAttachmentsTable,
            entityId: 'report-1-media',
            operation: 'create',
            payloadJson: jsonEncode({'reportId': 'report-1'}),
          );
          final mediaId = mediaResult.dataOrNull!;

          final transport = _ScriptedTransport({
            'report-1-media': () => const Result.failure(NetworkFailure()),
          });
          final service = SyncCoordinatorService(
            syncQueueDao: syncQueueDao,
            networkInfo: _FakeNetworkInfo(),
            transport: transport,
          );

          final summary = await service.syncPendingEntries(now: now);

          // The report — critical text/GPS — synced despite the media failure.
          expect(summary.syncedCount, 1);
          expect(summary.failedCount, 1);
          final reportRow = await (db.select(
            db.syncQueueEntries,
          )..where((t) => t.id.equals(reportId))).getSingle();
          expect(reportRow.status, 'synced');

          // The media attachment is independently retryable, not lost.
          final mediaRow = await (db.select(
            db.syncQueueEntries,
          )..where((t) => t.id.equals(mediaId))).getSingle();
          expect(mediaRow.status, 'failed');

          // And it was pushed after the report, per priority.
          expect(transport.pushedEntityIds, ['report-1', 'report-1-media']);
        },
      );
    },
  );

  group(
    'A CITIZEN REPORT PUSHED FROM ONE DEVICE IS VISIBLE ON ANOTHER — the multi-device acceptance criterion',
    () {
      late LocalIncidentReportRepository reportRepository;

      setUp(() => reportRepository = LocalIncidentReportRepository(db));

      Map<String, dynamic> remotePayload({
        String reportType = 'flood',
        String severity = 'high',
        int version = 1,
      }) => {
        'reporterId': 'citizen-b',
        'latitude': 12.9,
        'longitude': 77.6,
        'reportType': reportType,
        'description': 'seen from another device',
        'severity': severity,
        'affectedPeopleCount': 3,
        'createdAt': now.toIso8601String(),
        'version': version,
      };

      test('a report nobody has locally is pulled in and saved', () async {
        final transport = _ScriptedTransport(const {})
          ..remoteRecords = [
            RemoteSyncRecord(
              entityId: 'remote-report-1',
              payloadJson: jsonEncode(remotePayload()),
              version: 1,
            ),
          ];
        final service = SyncCoordinatorService(
          syncQueueDao: syncQueueDao,
          networkInfo: _FakeNetworkInfo(),
          transport: transport,
          incidentReportRepository: reportRepository,
        );

        final summary = await service.syncPendingEntries(now: now);

        expect(summary.pulledCount, 1);
        final saved = await reportRepository.getById('remote-report-1');
        expect(saved.dataOrNull?.reportType, 'flood');
        expect(saved.dataOrNull?.reporterId, 'citizen-b');
      });

      test(
        'a remote record no newer than what is already local is skipped',
        () async {
          await reportRepository.save(
            LocalIncidentReport(
              id: 'shared-report',
              incidentId: null,
              reporterId: 'citizen-a',
              latitude: 1,
              longitude: 1,
              reportType: 'flood',
              description: 'local version',
              severity: 'high',
              affectedPeopleCount: null,
              mediaPath: null,
              createdAt: now,
              updatedAt: now,
              version: 3,
              isSynced: true,
            ),
          );
          final transport = _ScriptedTransport(const {})
            ..remoteRecords = [
              RemoteSyncRecord(
                entityId: 'shared-report',
                payloadJson: jsonEncode(remotePayload(version: 2)),
                version: 2,
              ),
            ];
          final service = SyncCoordinatorService(
            syncQueueDao: syncQueueDao,
            networkInfo: _FakeNetworkInfo(),
            transport: transport,
            incidentReportRepository: reportRepository,
          );

          final summary = await service.syncPendingEntries(now: now);

          expect(summary.pulledCount, 0);
          final saved = await reportRepository.getById('shared-report');
          expect(saved.dataOrNull?.description, 'local version');
        },
      );

      test(
        'without a wired repository, pulling is a no-op rather than a crash',
        () async {
          final transport = _ScriptedTransport(const {})
            ..remoteRecords = [
              RemoteSyncRecord(
                entityId: 'remote-report-2',
                payloadJson: jsonEncode(remotePayload()),
                version: 1,
              ),
            ];
          final service = SyncCoordinatorService(
            syncQueueDao: syncQueueDao,
            networkInfo: _FakeNetworkInfo(),
            transport: transport,
          );

          final summary = await service.syncPendingEntries(now: now);

          expect(summary.pulledCount, 0);
        },
      );
    },
  );

  group(
    'A SHELTER REMOVED ON ONE DEVICE IS REMOVED ON ANOTHER — shelter delete propagation',
    () {
      late LocalShelterRepository shelterRepository;

      setUp(() => shelterRepository = LocalShelterRepository(db));

      LocalShelter localShelter(String id, {int version = 1}) => LocalShelter(
        id: id,
        name: 'Community Hall',
        latitude: 10,
        longitude: 20,
        capacityTotal: 100,
        occupancy: 0,
        facilitiesJson: '[]',
        accessQuality: null,
        updatedAt: now,
        version: version,
      );

      test(
        'a shelter cached locally but absent from the remote set is deleted',
        () async {
          await shelterRepository.save(localShelter('shelter-1'));
          final transport = _ScriptedTransport(const {})
            ..remoteRecords = const [];
          final service = SyncCoordinatorService(
            syncQueueDao: syncQueueDao,
            networkInfo: _FakeNetworkInfo(),
            transport: transport,
            shelterRepository: shelterRepository,
          );

          final summary = await service.syncPendingEntries(now: now);

          expect(summary.pulledCount, 1);
          final saved = await shelterRepository.getById('shelter-1');
          expect(saved.isFailure, isTrue);
        },
      );

      test(
        'a shelter whose creation push just failed is kept, not deleted as missing',
        () async {
          await shelterRepository.save(localShelter('shelter-pending'));
          await syncQueueDao.enqueue(
            entityTable: 'local_shelters',
            entityId: 'shelter-pending',
            operation: 'create',
            payloadJson: jsonEncode({'name': 'Community Hall'}),
          );
          final transport = _ScriptedTransport({
            'shelter-pending': () => const Result.failure(NetworkFailure()),
          })..remoteRecords = const [];
          final service = SyncCoordinatorService(
            syncQueueDao: syncQueueDao,
            networkInfo: _FakeNetworkInfo(),
            transport: transport,
            shelterRepository: shelterRepository,
          );

          await service.syncPendingEntries(now: now);

          final saved = await shelterRepository.getById('shelter-pending');
          expect(saved.isSuccess, isTrue);
        },
      );
    },
  );
}
