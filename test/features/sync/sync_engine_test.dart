import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/sync/application/sync_engine.dart';
import 'package:taarak/features/sync/domain/sync_conflict_resolution.dart';

void main() {
  final engine = SyncEngine();
  final now = DateTime.utc(2026, 1, 1, 12);

  SyncQueueEntry entry({
    required int id,
    String entityTable = 'local_incident_reports',
    String entityId = 'report-1',
    String operation = 'create',
    Map<String, dynamic> payload = const {},
    DateTime? createdAt,
    int attemptCount = 0,
    DateTime? lastAttemptAt,
    String status = 'pending',
  }) => SyncQueueEntry(
    id: id,
    entityTable: entityTable,
    entityId: entityId,
    operation: operation,
    payloadJson: jsonEncode(payload),
    createdAt: createdAt ?? now,
    attemptCount: attemptCount,
    lastAttemptAt: lastAttemptAt,
    status: status,
  );

  group('dedupe', () {
    test('keeps only the latest entry per entity, marking earlier ones superseded', () {
      final older = entry(id: 1, entityId: 'report-1', createdAt: now);
      final newer = entry(
        id: 2,
        entityId: 'report-1',
        createdAt: now.add(const Duration(minutes: 1)),
      );
      final other = entry(id: 3, entityId: 'report-2');

      final result = engine.dedupe([older, newer, other]);

      expect(result.toPush.map((e) => e.id), containsAll([2, 3]));
      expect(result.toPush, hasLength(2));
      expect(result.superseded.map((e) => e.id), [1]);
    });

    test('a single entry per entity is never marked superseded', () {
      final only = entry(id: 1);
      final result = engine.dedupe([only]);
      expect(result.toPush, [only]);
      expect(result.superseded, isEmpty);
    });
  });

  group('prioritize', () {
    test('an SOS report jumps ahead of a routine report queued earlier', () {
      final routine = entry(
        id: 1,
        entityId: 'report-routine',
        payload: {'reportType': 'landslide', 'severity': 'medium'},
        createdAt: now,
      );
      final sos = entry(
        id: 2,
        entityId: 'report-sos',
        payload: {'reportType': 'sos', 'severity': 'critical'},
        createdAt: now.add(const Duration(minutes: 5)),
      );

      final ordered = engine.prioritize([routine, sos]);

      expect(ordered.first.entityId, 'report-sos');
    });

    test('a critical-severity report outranks a routine one but not an SOS', () {
      final routine = entry(
        id: 1,
        payload: {'reportType': 'flood', 'severity': 'low'},
        createdAt: now,
      );
      final critical = entry(
        id: 2,
        payload: {'reportType': 'flood', 'severity': 'critical'},
        createdAt: now.add(const Duration(minutes: 1)),
      );
      final sos = entry(
        id: 3,
        payload: {'reportType': 'sos', 'severity': 'critical'},
        createdAt: now.add(const Duration(minutes: 2)),
      );

      final ordered = engine.prioritize([routine, critical, sos]);

      expect(ordered.map((e) => e.id), [3, 2, 1]);
    });

    test('within the same priority, oldest-first is preserved', () {
      final first = entry(id: 1, createdAt: now);
      final second = entry(id: 2, createdAt: now.add(const Duration(minutes: 1)));

      final ordered = engine.prioritize([second, first]);

      expect(ordered.map((e) => e.id), [1, 2]);
    });
  });

  group('backoffDelay / isReadyToRetry', () {
    test('backoff grows exponentially with attempt count, capped at maxBackoff', () {
      expect(engine.backoffDelay(0), const Duration(seconds: 2));
      expect(engine.backoffDelay(1), const Duration(seconds: 4));
      expect(engine.backoffDelay(2), const Duration(seconds: 8));
      expect(engine.backoffDelay(20), SyncEngine.maxBackoff);
    });

    test('a pending entry (never attempted) is always ready to retry', () {
      expect(engine.isReadyToRetry(entry(id: 1, status: 'pending'), now), isTrue);
    });

    test('a failed entry still inside its backoff window is not ready yet', () {
      final failing = entry(
        id: 1,
        status: 'failed',
        attemptCount: 1,
        lastAttemptAt: now,
      );
      expect(engine.isReadyToRetry(failing, now.add(const Duration(seconds: 1))), isFalse);
    });

    test('a failed entry past its backoff window is ready to retry', () {
      final failing = entry(
        id: 1,
        status: 'failed',
        attemptCount: 1,
        lastAttemptAt: now,
      );
      expect(engine.isReadyToRetry(failing, now.add(const Duration(seconds: 10))), isTrue);
    });
  });

  group('shouldGiveUp', () {
    test('an entry under the max attempt count is not given up on', () {
      expect(engine.shouldGiveUp(entry(id: 1, attemptCount: 4)), isFalse);
    });

    test('an entry at the max attempt count is given up on', () {
      expect(engine.shouldGiveUp(entry(id: 1, attemptCount: 5)), isTrue);
    });
  });

  group('resolveConflict', () {
    test('a strictly newer local version wins and should be retried', () {
      expect(
        engine.resolveConflict(localVersion: 3, serverVersion: 2),
        SyncConflictResolution.localWins,
      );
    });

    test('an equal or newer server version wins — the local push is redundant', () {
      expect(
        engine.resolveConflict(localVersion: 2, serverVersion: 2),
        SyncConflictResolution.serverWins,
      );
      expect(
        engine.resolveConflict(localVersion: 1, serverVersion: 2),
        SyncConflictResolution.serverWins,
      );
    });
  });

  group('localVersionOf', () {
    test('reads the version out of the queued payload', () {
      expect(engine.localVersionOf(entry(id: 1, payload: {'version': 3})), 3);
    });

    test('defaults to 1 when the payload has no version', () {
      expect(engine.localVersionOf(entry(id: 1, payload: const {})), 1);
    });
  });
}
