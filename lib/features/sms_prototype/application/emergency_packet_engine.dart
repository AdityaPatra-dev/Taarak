import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';

const String emergencyPacketModelVersion = '1.0.0';

/// M22's other deterministic core: given raw incoming packets (already
/// decoded by [[EmergencyPacketCodec]]), which ones are still worth
/// acting on and in what order — "IDs, TTL, deduplication and priority"
/// per the spec, as one pure function each.
class EmergencyPacketEngine {
  /// Same id seen more than once (a retransmit, or the same message
  /// relayed by two different paths) collapses to a single packet —
  /// first-seen wins, since a later duplicate carries no new information.
  List<EmergencyPacket> deduplicate(List<EmergencyPacket> packets) {
    final seenIds = <String>{};
    final result = <EmergencyPacket>[];
    for (final packet in packets) {
      if (seenIds.add(packet.id)) {
        result.add(packet);
      }
    }
    return result;
  }

  List<EmergencyPacket> excludeExpired(List<EmergencyPacket> packets, DateTime now) =>
      packets.where((packet) => !packet.isExpired(now)).toList();

  /// SOS first, then critical, then routine; oldest-expiring first within
  /// a tier as a tiebreaker (the one with the least time left is the most
  /// urgent to act on).
  List<EmergencyPacket> prioritize(List<EmergencyPacket> packets) {
    final sorted = [...packets];
    sorted.sort((a, b) {
      final priorityCompare = a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      return a.expiresAt.compareTo(b.expiresAt);
    });
    return sorted;
  }

  /// The full inbound pipeline in one call: drop what's expired, collapse
  /// duplicates, then order by priority — what a receiving device should
  /// actually show, not just what arrived.
  List<EmergencyPacket> process(List<EmergencyPacket> incoming, DateTime now) =>
      prioritize(deduplicate(excludeExpired(incoming, now)));
}
