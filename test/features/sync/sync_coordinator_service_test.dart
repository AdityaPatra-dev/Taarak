import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/sync/application/sync_coordinator_service.dart';
import 'package:taarak/features/sync/application/sync_transport.dart';
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

  _ScriptedTransport(this._scripts);

  @override
  Future<Result<SyncPushOutcome>> push(SyncQueueEntry entry) async {
    pushedEntityIds.add(entry.entityId);
    final script = _scripts[entry.entityId];
    if (script == null) return const Result.success(SyncPushOutcome.accepted());
    return script();
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

  group('OFFLINE DATA SYNCHRONIZES SAFELY AFTER RECONNECTION — the acceptance criterion', () {
    test('while offline, nothing is pushed and entries stay pending', () async {
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
    });

    test('once reconnected, a pending entry is pushed and marked synced', () async {
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
    });
  });

  test('a transport failure marks the entry failed but keeps it queued for retry', () async {
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
  });

  test('a failed entry still inside its backoff window is not retried yet', () async {
    await enqueue();
    final transport = _ScriptedTransport({
      'report-1': () => const Result.failure(NetworkFailure()),
    });
    final service = SyncCoordinatorService(
      syncQueueDao: syncQueueDao,
      networkInfo: _FakeNetworkInfo(),
      transport: transport,
    );

    await service.syncPendingEntries(now: now); // 1st attempt: fails, attemptCount -> 1
    transport.pushedEntityIds.clear();

    final summary = await service.syncPendingEntries(
      now: now.add(const Duration(seconds: 1)), // still within the backoff window
    );

    expect(transport.pushedEntityIds, isEmpty);
    expect(summary.failedCount, 0);
    expect(summary.syncedCount, 0);
  });

  test('an entry that exhausts its max attempts is abandoned, not retried forever', () async {
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
  });

  group('conflict resolution', () {
    test('server-wins conflict is treated as already-synced, not an error', () async {
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
    });

    test('local-wins conflict is kept queued for retry, not silently dropped', () async {
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
    });
  });

  group('deduplication', () {
    test('only the latest of two queued edits to the same entity is pushed', () async {
      await enqueue(entityId: 'report-1', payload: {'version': 1});
      final secondId = await enqueue(entityId: 'report-1', payload: {'version': 2});

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
    });
  });

  group('priority', () {
    test('an SOS entry is pushed before a routine one queued earlier', () async {
      await enqueue(entityId: 'routine', payload: {'reportType': 'flood'});
      await enqueue(entityId: 'sos', payload: {'reportType': 'sos', 'severity': 'critical'});

      final transport = _ScriptedTransport(const {});
      final service = SyncCoordinatorService(
        syncQueueDao: syncQueueDao,
        networkInfo: _FakeNetworkInfo(),
        transport: transport,
      );

      await service.syncPendingEntries(now: now);

      expect(transport.pushedEntityIds.first, 'sos');
    });
  });
}
