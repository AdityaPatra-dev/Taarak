import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/sms_prototype/application/emergency_packet_codec.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet_priority.dart';

void main() {
  final codec = EmergencyPacketCodec();
  final now = DateTime.utc(2026, 1, 1, 12);

  EmergencyPacket packet({
    String id = 'ABC123',
    String originId = 'citizen-1',
    EmergencyPacketPriority priority = EmergencyPacketPriority.sos,
    String type = 'sos',
    double latitude = 12.9716,
    double longitude = 77.5946,
    DateTime? expiresAt,
    String note = '',
  }) => EmergencyPacket(
    id: id,
    originId: originId,
    priority: priority,
    type: type,
    latitude: latitude,
    longitude: longitude,
    expiresAt: expiresAt ?? now.add(const Duration(hours: 6)),
    note: note,
  );

  test(
    'CONTROLLED PROTOTYPE EXCHANGES A MINIMAL EMERGENCY PACKET — the acceptance '
    'criterion: a packet round-trips through encode/decode unchanged',
    () {
      final original = packet(note: 'Trapped near the bridge');
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.id, original.id);
      expect(decoded.originId, original.originId);
      expect(decoded.priority, original.priority);
      expect(decoded.type, original.type);
      expect(decoded.latitude, closeTo(original.latitude, 0.0001));
      expect(decoded.longitude, closeTo(original.longitude, 0.0001));
      expect(decoded.expiresAt, original.expiresAt);
      expect(decoded.note, original.note);
    },
  );

  test('the encoded packet fits a single SMS segment', () {
    final encoded = codec.encode(packet(note: 'A' * 200));
    expect(encoded.length, lessThanOrEqualTo(EmergencyPacketCodec.maxEncodedLength));
  });

  test('a note longer than the remaining budget is truncated, not dropped entirely', () {
    final encoded = codec.encode(packet(note: 'B' * 200));
    final decoded = codec.decode(encoded)!;
    expect(decoded.note, isNotEmpty);
    expect(decoded.note.length, lessThan(200));
  });

  test('a pipe character in the note does not corrupt the other fields', () {
    final encoded = codec.encode(packet(note: 'help|now|please'));
    final decoded = codec.decode(encoded)!;
    expect(decoded.id, 'ABC123');
    expect(decoded.type, 'sos');
  });

  test('decoding a non-TAARAK message returns null instead of throwing', () {
    expect(codec.decode('Your OTP is 483920'), isNull);
    expect(codec.decode(''), isNull);
  });

  test('decoding a truncated/corrupted TAARAK message returns null', () {
    expect(codec.decode('TAARAK1|ABC123|citizen-1'), isNull);
  });

  test('decoding an unrecognized priority code returns null', () {
    expect(
      codec.decode('TAARAK1|ABC123|citizen-1|X|sos|12.97|77.59|1700000000|1|note'),
      isNull,
    );
  });

  test('each of the three priority codes round-trips correctly', () {
    for (final priority in EmergencyPacketPriority.values) {
      final decoded = codec.decode(codec.encode(packet(priority: priority)));
      expect(decoded!.priority, priority);
    }
  });
}
