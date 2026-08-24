import 'dart:math';

import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/sms_prototype/application/emergency_packet_codec.dart';
import 'package:taarak/features/sms_prototype/application/emergency_packet_engine.dart';
import 'package:taarak/features/sms_prototype/application/sms_transport.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet_priority.dart';

const _idAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

/// Orchestrates M22: builds a compact [EmergencyPacket], sends it through
/// whatever [SmsTransport] is wired in (the loopback prototype today), and
/// turns raw incoming SMS bodies back into packets — running every one of
/// them through [EmergencyPacketEngine]'s TTL/dedup/priority pipeline
/// before a screen ever sees them.
class SmsPrototypeService {
  final SmsTransport _transport;
  final EmergencyPacketCodec _codec;
  final EmergencyPacketEngine _engine;
  final Random _random;

  SmsPrototypeService({
    required SmsTransport transport,
    EmergencyPacketCodec? codec,
    EmergencyPacketEngine? engine,
    Random? random,
  }) : _transport = transport,
       _codec = codec ?? EmergencyPacketCodec(),
       _engine = engine ?? EmergencyPacketEngine(),
       _random = random ?? Random();

  /// Six characters from a 36-symbol alphabet (~31 bits) is plenty to
  /// make id collisions between two real packets negligible while
  /// staying short enough to afford in a 140-character SMS budget.
  String _generateShortId() => List.generate(
    6,
    (_) => _idAlphabet[_random.nextInt(_idAlphabet.length)],
  ).join();

  EmergencyPacket buildPacket({
    required String originId,
    required EmergencyPacketPriority priority,
    required String type,
    required double latitude,
    required double longitude,
    String note = '',
    Duration ttl = const Duration(hours: 6),
    DateTime? now,
  }) {
    final occurredAt = now ?? DateTime.now();
    return EmergencyPacket(
      id: _generateShortId(),
      originId: originId,
      priority: priority,
      type: type,
      latitude: latitude,
      longitude: longitude,
      expiresAt: occurredAt.add(ttl),
      note: note,
    );
  }

  Future<Result<String>> sendPacket({
    required EmergencyPacket packet,
    required String toNumber,
  }) async {
    final encoded = _codec.encode(packet);
    final sendResult = await _transport.send(toNumber: toNumber, body: encoded);
    return sendResult.when(
      success: (_) => Result.success(encoded),
      failure: (failure) => Result.failure(failure),
    );
  }

  /// The full receive-side pipeline: decode whatever parses as a TAARAK
  /// packet (silently dropping anything that doesn't — a stray SMS is not
  /// an error), merge with [alreadySeen] so dedup spans multiple
  /// receive batches, then apply TTL/dedup/priority.
  List<EmergencyPacket> receiveMessages(
    List<String> rawMessages, {
    List<EmergencyPacket> alreadySeen = const [],
    DateTime? now,
  }) {
    final decoded = rawMessages
        .map(_codec.decode)
        .whereType<EmergencyPacket>()
        .toList();
    return _engine.process([...alreadySeen, ...decoded], now ?? DateTime.now());
  }

  Stream<String> get incomingRawMessages => _transport.incomingMessages;
}
