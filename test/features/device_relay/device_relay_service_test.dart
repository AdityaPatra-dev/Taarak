import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/device_relay/application/device_relay_service.dart';
import 'package:taarak/features/device_relay/application/relay_transport.dart';
import 'package:taarak/features/sms_prototype/application/emergency_packet_codec.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet_priority.dart';

void main() {
  final codec = EmergencyPacketCodec();
  final now = DateTime.utc(2026, 1, 1, 12);

  late LoopbackRelayTransport transport;
  late DeviceRelayService service;

  EmergencyPacket packetFrom(String originId, {DateTime? expiresAt, String id = 'PKT001'}) =>
      EmergencyPacket(
        id: id,
        originId: originId,
        priority: EmergencyPacketPriority.sos,
        type: 'sos',
        latitude: 10,
        longitude: 10,
        expiresAt: expiresAt ?? now.add(const Duration(hours: 1)),
      );

  setUp(() {
    transport = LoopbackRelayTransport();
    service = DeviceRelayService(transport: transport);
  });

  tearDown(() => transport.dispose());

  test('broadcastOwnPacket encodes and sends through the transport', () async {
    final packet = packetFrom('this-device');
    await service.broadcastOwnPacket(packet);

    expect(transport.broadcastLog, hasLength(1));
    expect(codec.decode(transport.broadcastLog.single)?.id, packet.id);
  });

  test(
    'NEARBY-DEVICE RELAY WITH TTL/ORIGIN/VERSION AND DUPLICATE SUPPRESSION — the '
    'acceptance criterion, through the service: a peer packet is decoded and relayed',
    () async {
      final raw = codec.encode(packetFrom('peer-device'));

      final outcome = await service.handleIncoming(raw, thisDeviceId: 'this-device', now: now);

      expect(outcome, isNotNull);
      expect(outcome!.wasRelayed, isTrue);
      expect(transport.broadcastLog, contains(raw));
      expect(service.relayedIds, contains(outcome.packet.id));
    },
  );

  test('the same packet arriving twice is only relayed once', () async {
    final raw = codec.encode(packetFrom('peer-device'));

    final first = await service.handleIncoming(raw, thisDeviceId: 'this-device', now: now);
    final second = await service.handleIncoming(raw, thisDeviceId: 'this-device', now: now);

    expect(first!.wasRelayed, isTrue);
    expect(second!.wasRelayed, isFalse);
    expect(second.reason, 'already relayed');
    expect(transport.broadcastLog, hasLength(1)); // not re-broadcast the second time
  });

  test('this device does not relay a packet it originated itself', () async {
    final raw = codec.encode(packetFrom('this-device'));

    final outcome = await service.handleIncoming(raw, thisDeviceId: 'this-device', now: now);

    expect(outcome!.wasRelayed, isFalse);
    expect(outcome.reason, 'own broadcast');
    expect(transport.broadcastLog, isEmpty);
  });

  test('an expired packet is not relayed', () async {
    final raw = codec.encode(
      packetFrom('peer-device', expiresAt: now.subtract(const Duration(minutes: 1))),
    );

    final outcome = await service.handleIncoming(raw, thisDeviceId: 'this-device', now: now);

    expect(outcome!.wasRelayed, isFalse);
    expect(outcome.reason, 'expired');
  });

  test('a non-TAARAK message is ignored, returning null', () async {
    final outcome = await service.handleIncoming(
      'not a real packet',
      thisDeviceId: 'this-device',
      now: now,
    );
    expect(outcome, isNull);
  });

  test(
    'a full relay chain: device A broadcasts, device B relays it, and device B\'s '
    'own re-broadcast is what a third device would see',
    () async {
      final deviceBTransport = LoopbackRelayTransport();
      final deviceBService = DeviceRelayService(transport: deviceBTransport);

      final originalPacket = packetFrom('device-A');
      final encoded = codec.encode(originalPacket);

      final outcome = await deviceBService.handleIncoming(
        encoded,
        thisDeviceId: 'device-B',
        now: now,
      );

      expect(outcome!.wasRelayed, isTrue);
      expect(deviceBTransport.broadcastLog.single, encoded);

      deviceBTransport.dispose();
    },
  );
}
