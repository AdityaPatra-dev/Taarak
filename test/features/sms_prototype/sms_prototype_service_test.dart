import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/sms_prototype/application/sms_prototype_service.dart';
import 'package:taarak/features/sms_prototype/application/sms_transport.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet_priority.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);

  late LoopbackSmsTransport transport;
  late SmsPrototypeService service;

  setUp(() {
    transport = LoopbackSmsTransport();
    service = SmsPrototypeService(transport: transport);
  });

  tearDown(() => transport.dispose());

  group('buildPacket', () {
    test('produces a packet with a short id and the requested fields', () {
      final packet = service.buildPacket(
        originId: 'citizen-1',
        priority: EmergencyPacketPriority.sos,
        type: 'sos',
        latitude: 12.9,
        longitude: 77.6,
        note: 'Trapped',
        now: now,
      );

      expect(packet.id.length, 6);
      expect(packet.originId, 'citizen-1');
      expect(packet.priority, EmergencyPacketPriority.sos);
      expect(packet.latitude, 12.9);
      expect(packet.expiresAt, now.add(const Duration(hours: 6)));
    });

    test('two packets built back-to-back get different ids', () {
      final first = service.buildPacket(
        originId: 'citizen-1',
        priority: EmergencyPacketPriority.sos,
        type: 'sos',
        latitude: 0,
        longitude: 0,
        now: now,
      );
      final second = service.buildPacket(
        originId: 'citizen-1',
        priority: EmergencyPacketPriority.sos,
        type: 'sos',
        latitude: 0,
        longitude: 0,
        now: now,
      );
      expect(first.id, isNot(second.id));
    });
  });

  test(
    'CONTROLLED PROTOTYPE EXCHANGES A MINIMAL EMERGENCY PACKET — the acceptance '
    'criterion, end to end through the service and loopback transport',
    () async {
      final packet = service.buildPacket(
        originId: 'citizen-1',
        priority: EmergencyPacketPriority.sos,
        type: 'sos',
        latitude: 12.9,
        longitude: 77.6,
        note: 'Trapped near the bridge',
        now: now,
      );

      final sendResult = await service.sendPacket(packet: packet, toNumber: '112');
      expect(sendResult.isSuccess, isTrue);
      expect(transport.sentMessages, hasLength(1));
      expect(transport.sentMessages.single.toNumber, '112');

      // "Another device" receives the exact bytes that were sent.
      final received = service.receiveMessages(
        [transport.sentMessages.single.body],
        now: now,
      );

      expect(received, hasLength(1));
      expect(received.single.id, packet.id);
      expect(received.single.note, 'Trapped near the bridge');
    },
  );

  test('receiveMessages silently ignores anything that is not a TAARAK packet', () {
    final result = service.receiveMessages(['Your OTP is 1234', 'hello'], now: now);
    expect(result, isEmpty);
  });

  test('receiveMessages dedupes against packets already seen in an earlier batch', () async {
    final packet = service.buildPacket(
      originId: 'citizen-1',
      priority: EmergencyPacketPriority.sos,
      type: 'sos',
      latitude: 0,
      longitude: 0,
      now: now,
    );
    final encoded = (await service.sendPacket(packet: packet, toNumber: '112')).dataOrNull!;

    final firstBatch = service.receiveMessages([encoded], now: now);
    expect(firstBatch, hasLength(1));

    // The same packet arrives again (a retransmit) — it's already known.
    final secondBatch = service.receiveMessages(
      [encoded],
      alreadySeen: firstBatch,
      now: now,
    );
    expect(secondBatch, hasLength(1));
    expect(secondBatch.single.id, packet.id);
  });

  test(
    'the incoming raw-message stream surfaces whatever is simulated as arriving',
    () async {
      final received = <String>[];
      final subscription = service.incomingRawMessages.listen(received.add);

      transport.simulateIncoming('TAARAK1|XYZ999|citizen-2|S|sos|10.00|20.00|1900000000|1|help');
      await Future<void>.delayed(Duration.zero);

      expect(received, ['TAARAK1|XYZ999|citizen-2|S|sos|10.00|20.00|1900000000|1|help']);
      await subscription.cancel();
    },
  );
}
