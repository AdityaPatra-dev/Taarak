import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/sms_prototype/application/emergency_packet_engine.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet_priority.dart';

void main() {
  final engine = EmergencyPacketEngine();
  final now = DateTime.utc(2026, 1, 1, 12);

  EmergencyPacket packet({
    required String id,
    EmergencyPacketPriority priority = EmergencyPacketPriority.routine,
    DateTime? expiresAt,
    String originId = 'citizen-1',
  }) => EmergencyPacket(
    id: id,
    originId: originId,
    priority: priority,
    type: 'sos',
    latitude: 10,
    longitude: 10,
    expiresAt: expiresAt ?? now.add(const Duration(hours: 1)),
  );

  group('deduplicate', () {
    test('a repeated id collapses to the first occurrence', () {
      final first = packet(id: 'A', originId: 'first-seen');
      final duplicate = packet(id: 'A', originId: 'retransmit');
      final other = packet(id: 'B');

      final result = engine.deduplicate([first, duplicate, other]);

      expect(result.map((p) => p.id), ['A', 'B']);
      expect(result.first.originId, 'first-seen');
    });

    test('no duplicates means nothing is dropped', () {
      final packets = [packet(id: 'A'), packet(id: 'B'), packet(id: 'C')];
      expect(engine.deduplicate(packets), hasLength(3));
    });
  });

  group('excludeExpired', () {
    test('an expired packet is dropped', () {
      final expired = packet(id: 'A', expiresAt: now.subtract(const Duration(minutes: 1)));
      final active = packet(id: 'B', expiresAt: now.add(const Duration(minutes: 1)));

      final result = engine.excludeExpired([expired, active], now);

      expect(result.map((p) => p.id), ['B']);
    });

    test('a packet expiring at exactly now is treated as expired', () {
      final atLimit = packet(id: 'A', expiresAt: now);
      expect(engine.excludeExpired([atLimit], now), isEmpty);
    });
  });

  group('prioritize', () {
    test('SOS sorts before critical, which sorts before routine', () {
      final routine = packet(id: 'routine', priority: EmergencyPacketPriority.routine);
      final sos = packet(id: 'sos', priority: EmergencyPacketPriority.sos);
      final critical = packet(id: 'critical', priority: EmergencyPacketPriority.critical);

      final result = engine.prioritize([routine, critical, sos]);

      expect(result.map((p) => p.id), ['sos', 'critical', 'routine']);
    });

    test('within the same priority, the packet expiring soonest comes first', () {
      final expiresLater = packet(
        id: 'later',
        expiresAt: now.add(const Duration(hours: 2)),
      );
      final expiresSooner = packet(
        id: 'sooner',
        expiresAt: now.add(const Duration(minutes: 10)),
      );

      final result = engine.prioritize([expiresLater, expiresSooner]);

      expect(result.map((p) => p.id), ['sooner', 'later']);
    });
  });

  test(
    'CONTROLLED PROTOTYPE EXCHANGES A MINIMAL EMERGENCY PACKET — the acceptance '
    'criterion: process() combines TTL, dedup and priority in one pass',
    () {
      final expired = packet(id: 'expired', expiresAt: now.subtract(const Duration(hours: 1)));
      final duplicateSos = packet(id: 'sos-1', priority: EmergencyPacketPriority.sos);
      final sos = packet(id: 'sos-1', priority: EmergencyPacketPriority.sos);
      final routine = packet(id: 'routine', priority: EmergencyPacketPriority.routine);

      final result = engine.process([expired, routine, duplicateSos, sos], now);

      expect(result.map((p) => p.id), ['sos-1', 'routine']);
    },
  );
}
