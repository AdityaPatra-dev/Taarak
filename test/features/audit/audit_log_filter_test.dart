import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/audit/application/audit_log_filter.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);

  LocalAuditEvent event({
    required int id,
    String actorId = 'official-1',
    String action = 'incident.acknowledged',
    String objectType = 'incident',
    String objectId = 'obj-1',
    String? oldValue,
    String? newValue,
    String? reason,
    DateTime? occurredAt,
  }) => LocalAuditEvent(
    id: id,
    actorId: actorId,
    action: action,
    objectType: objectType,
    objectId: objectId,
    oldValue: oldValue,
    newValue: newValue,
    reason: reason,
    occurredAt: occurredAt ?? now,
  );

  test('with no filters, every event is returned, most recent first', () {
    final events = [
      event(id: 1, occurredAt: now),
      event(id: 2, occurredAt: now.add(const Duration(minutes: 5))),
    ];

    final result = filterAuditEvents(events);

    expect(result.map((e) => e.id), [2, 1]);
  });

  test('a tie in occurredAt breaks by id, highest (most recently written) first', () {
    final events = [event(id: 1, occurredAt: now), event(id: 2, occurredAt: now)];

    final result = filterAuditEvents(events);

    expect(result.map((e) => e.id), [2, 1]);
  });

  test('filters by objectType', () {
    final events = [
      event(id: 1, objectType: 'incident'),
      event(id: 2, objectType: 'shelter'),
      event(id: 3, objectType: 'alert'),
    ];

    final result = filterAuditEvents(events, objectType: 'shelter');

    expect(result.map((e) => e.id), [2]);
  });

  test('filters by actorId', () {
    final events = [
      event(id: 1, actorId: 'official-1'),
      event(id: 2, actorId: 'official-2'),
    ];

    final result = filterAuditEvents(events, actorId: 'official-2');

    expect(result.map((e) => e.id), [2]);
  });

  test(
    'CRITICAL CHANGES ARE TRACEABLE — the acceptance criterion: a free-text query '
    'matches action, object, actor and reason',
    () {
      final events = [
        event(id: 1, action: 'shelter.occupancy_updated', reason: 'Headcount from field team'),
        event(id: 2, action: 'alert.cancelled', reason: 'False alarm'),
      ];

      expect(filterAuditEvents(events, query: 'occupancy').map((e) => e.id), [1]);
      expect(filterAuditEvents(events, query: 'false alarm').map((e) => e.id), [2]);
      expect(filterAuditEvents(events, query: 'headcount').map((e) => e.id), [1]);
    },
  );

  test('a query is case-insensitive', () {
    final events = [event(id: 1, action: 'shelter.created')];
    expect(filterAuditEvents(events, query: 'SHELTER').map((e) => e.id), [1]);
  });

  test('an empty or blank query behaves like no query at all', () {
    final events = [event(id: 1), event(id: 2)];
    expect(filterAuditEvents(events, query: '').length, 2);
    expect(filterAuditEvents(events, query: '   ').length, 2);
  });

  test('filters combine — objectType and query both must match', () {
    final events = [
      event(id: 1, objectType: 'incident', action: 'incident.acknowledged'),
      event(id: 2, objectType: 'shelter', action: 'shelter.created'),
    ];

    final result = filterAuditEvents(events, objectType: 'incident', query: 'shelter');

    expect(result, isEmpty);
  });
}
