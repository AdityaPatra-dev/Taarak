import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/sync/domain/sync_queue_summary.dart';

void main() {
  group('SyncQueueSummary', () {
    test('an empty summary reports isEmpty and a zero total', () {
      const summary = SyncQueueSummary();
      expect(summary.isEmpty, isTrue);
      expect(summary.totalCount, 0);
    });

    test('totalCount sums all three categories', () {
      const summary = SyncQueueSummary(pendingCount: 1, retryingCount: 2, stalledCount: 3);
      expect(summary.totalCount, 6);
      expect(summary.isEmpty, isFalse);
    });
  });

  group('syncQueueSummaryMessage', () {
    test(
      'FIX SYNC SO IT DOES NOT LIE TO THE USER — the acceptance criterion: a purely '
      'pending queue reads as routine, not as a failure',
      () {
        const summary = SyncQueueSummary(pendingCount: 3);
        expect(syncQueueSummaryMessage(summary), '3 items queued, will send when possible');
      },
    );

    test('a singular pending item is grammatically correct', () {
      const summary = SyncQueueSummary(pendingCount: 1);
      expect(syncQueueSummaryMessage(summary), '1 item queued, will send when possible');
    });

    test('a retrying queue is distinguished from a merely-pending one', () {
      const summary = SyncQueueSummary(pendingCount: 2, retryingCount: 1);
      expect(
        syncQueueSummaryMessage(summary),
        '1 item waiting — having trouble reaching the server',
      );
    });

    test(
      'stalled items take priority over retrying and pending ones — the most '
      'urgent true thing is said, not the first thing counted',
      () {
        const summary = SyncQueueSummary(pendingCount: 5, retryingCount: 3, stalledCount: 2);
        expect(
          syncQueueSummaryMessage(summary),
          "2 items couldn't be sent after repeated attempts",
        );
      },
    );

    test('a single stalled item is grammatically correct', () {
      const summary = SyncQueueSummary(stalledCount: 1);
      expect(syncQueueSummaryMessage(summary), "1 item couldn't be sent after repeated attempts");
    });
  });
}
