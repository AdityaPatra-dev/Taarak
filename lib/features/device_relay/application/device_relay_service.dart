import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/device_relay/application/device_relay_engine.dart';
import 'package:taarak/features/device_relay/application/relay_transport.dart';
import 'package:taarak/features/device_relay/domain/device_relay_outcome.dart';
import 'package:taarak/features/sms_prototype/application/emergency_packet_codec.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';

/// Orchestrates M23: originating this device's own packet onto the relay,
/// and — the module's actual new behavior — deciding whether an incoming
/// packet from a peer should be re-broadcast onward, tracking what's
/// already been relayed so the same packet is never re-sent twice.
class DeviceRelayService {
  final RelayTransport _transport;
  final EmergencyPacketCodec _codec;
  final DeviceRelayEngine _relayEngine;
  final Set<String> _relayedIds = {};

  DeviceRelayService({
    required RelayTransport transport,
    EmergencyPacketCodec? codec,
    DeviceRelayEngine? relayEngine,
  }) : _transport = transport,
       _codec = codec ?? EmergencyPacketCodec(),
       _relayEngine = relayEngine ?? DeviceRelayEngine();

  /// Read-only view of what this device has already relayed, for a
  /// caller (e.g. a UI list) that wants to explain "already seen".
  Set<String> get relayedIds => Set.unmodifiable(_relayedIds);

  Future<Result<void>> broadcastOwnPacket(EmergencyPacket packet) =>
      _transport.broadcast(_codec.encode(packet));

  /// The relay decision, for exactly one incoming raw broadcast. Returns
  /// null for anything that doesn't decode as a TAARAK packet — a stray
  /// nearby broadcast is not this module's concern.
  Future<DeviceRelayOutcome?> handleIncoming(
    String raw, {
    required String thisDeviceId,
    DateTime? now,
  }) async {
    final packet = _codec.decode(raw);
    if (packet == null) return null;

    final occurredAt = now ?? DateTime.now();
    final decision = _relayEngine.evaluate(
      packet: packet,
      thisDeviceId: thisDeviceId,
      alreadyRelayedIds: _relayedIds,
      now: occurredAt,
    );

    if (decision.shouldRelay) {
      _relayedIds.add(packet.id);
      await _transport.broadcast(raw);
    }

    return DeviceRelayOutcome(
      packet: packet,
      wasRelayed: decision.shouldRelay,
      reason: decision.reason,
    );
  }

  Stream<String> get incomingBroadcasts => _transport.incomingBroadcasts;
}
