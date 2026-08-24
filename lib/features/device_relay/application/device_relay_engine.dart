import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';

const String deviceRelayModelVersion = '1.0.0';

/// M23's deterministic core: whether *this* device should re-broadcast an
/// incoming packet to other nearby devices. Reuses M22's
/// [EmergencyPacket]/TTL exactly per the spec's "TTL/origin/version" —
/// the only new rule this module adds is relay-specific duplicate
/// suppression (a device never re-relays the same packet twice, and
/// never relays its own broadcast back into the mesh).
class DeviceRelayEngine {
  ({bool shouldRelay, String reason}) evaluate({
    required EmergencyPacket packet,
    required String thisDeviceId,
    required Set<String> alreadyRelayedIds,
    required DateTime now,
  }) {
    if (packet.isExpired(now)) {
      return (shouldRelay: false, reason: 'expired');
    }
    if (packet.originId == thisDeviceId) {
      return (shouldRelay: false, reason: 'own broadcast');
    }
    if (alreadyRelayedIds.contains(packet.id)) {
      return (shouldRelay: false, reason: 'already relayed');
    }
    return (shouldRelay: true, reason: 'relayed');
  }
}
