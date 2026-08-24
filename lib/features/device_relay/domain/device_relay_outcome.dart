import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';

/// What [DeviceRelayService.handleIncoming] did with one incoming
/// broadcast — surfaced to the UI so a demo can show *why* a packet was
/// or wasn't relayed, not just that something arrived.
class DeviceRelayOutcome {
  final EmergencyPacket packet;
  final bool wasRelayed;
  final String reason;

  const DeviceRelayOutcome({
    required this.packet,
    required this.wasRelayed,
    required this.reason,
  });
}
