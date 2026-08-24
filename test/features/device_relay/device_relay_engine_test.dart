import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/device_relay/application/device_relay_engine.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet_priority.dart';

void main() {
  final engine = DeviceRelayEngine();
  final now = DateTime.utc(2026, 1, 1, 12);

  EmergencyPacket packet({
    String id = 'ABC123',
    String originId = 'peer-device',
    DateTime? expiresAt,
  }) => EmergencyPacket(
    id: id,
    originId: originId,
    priority: EmergencyPacketPriority.sos,
    type: 'sos',
    latitude: 10,
    longitude: 10,
    expiresAt: expiresAt ?? now.add(const Duration(hours: 1)),
  );

  test(
    'NEARBY-DEVICE RELAY WITH TTL/ORIGIN/VERSION AND DUPLICATE SUPPRESSION — the '
    'acceptance criterion: a fresh packet from a peer is relayed',
    () {
      final result = engine.evaluate(
        packet: packet(),
        thisDeviceId: 'this-device',
        alreadyRelayedIds: {},
        now: now,
      );

      expect(result.shouldRelay, isTrue);
      expect(result.reason, 'relayed');
    },
  );

  test('an expired packet is never relayed', () {
    final result = engine.evaluate(
      packet: packet(expiresAt: now.subtract(const Duration(minutes: 1))),
      thisDeviceId: 'this-device',
      alreadyRelayedIds: {},
      now: now,
    );

    expect(result.shouldRelay, isFalse);
    expect(result.reason, 'expired');
  });

  test('this device never relays its own broadcast back into the mesh', () {
    final result = engine.evaluate(
      packet: packet(originId: 'this-device'),
      thisDeviceId: 'this-device',
      alreadyRelayedIds: {},
      now: now,
    );

    expect(result.shouldRelay, isFalse);
    expect(result.reason, 'own broadcast');
  });

  test('a packet already relayed by this device is not relayed again', () {
    final result = engine.evaluate(
      packet: packet(id: 'ABC123'),
      thisDeviceId: 'this-device',
      alreadyRelayedIds: {'ABC123'},
      now: now,
    );

    expect(result.shouldRelay, isFalse);
    expect(result.reason, 'already relayed');
  });

  test('a different packet id from the same already-relayed set is still relayed', () {
    final result = engine.evaluate(
      packet: packet(id: 'XYZ789'),
      thisDeviceId: 'this-device',
      alreadyRelayedIds: {'ABC123'},
      now: now,
    );

    expect(result.shouldRelay, isTrue);
  });

  test('expiry is checked before origin/dedup, so an expired own-packet still reports expired', () {
    final result = engine.evaluate(
      packet: packet(originId: 'this-device', expiresAt: now.subtract(const Duration(minutes: 1))),
      thisDeviceId: 'this-device',
      alreadyRelayedIds: {},
      now: now,
    );

    expect(result.reason, 'expired');
  });
}
