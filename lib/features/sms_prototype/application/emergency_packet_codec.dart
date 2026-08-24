import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet_priority.dart';

const String _protocolTag = 'TAARAK1';
const String _delimiter = '|';

/// M22's deterministic core: turns an [EmergencyPacket] into (and back
/// from) a pipe-delimited string short enough for a single GSM SMS
/// segment (160 7-bit characters). No I/O, no transport — this is the
/// wire format only, testable without sending anything anywhere.
class EmergencyPacketCodec {
  /// Conservative single-segment budget: leaves headroom below the 160
  /// character GSM-7 limit for carriers that count slightly differently.
  static const int maxEncodedLength = 140;

  String encode(EmergencyPacket packet) {
    final fixedFields = [
      _protocolTag,
      packet.id,
      packet.originId,
      packet.priority.code,
      packet.type,
      packet.latitude.toStringAsFixed(4),
      packet.longitude.toStringAsFixed(4),
      packet.expiresAt.millisecondsSinceEpoch ~/ 1000,
      packet.version,
    ].join(_delimiter);

    final budgetForNote =
        maxEncodedLength - fixedFields.length - _delimiter.length;
    final safeNote = packet.note.replaceAll(_delimiter, ' ');
    final note = budgetForNote <= 0
        ? ''
        : (safeNote.length > budgetForNote
              ? safeNote.substring(0, budgetForNote)
              : safeNote);

    return '$fixedFields$_delimiter$note';
  }

  /// Returns null for anything that isn't a well-formed TAARAK packet —
  /// a stray SMS, a corrupted transmission, or a future protocol version
  /// this build doesn't understand — rather than throwing.
  EmergencyPacket? decode(String raw) {
    final parts = raw.split(_delimiter);
    if (parts.length < 9 || parts[0] != _protocolTag) return null;

    final priority = EmergencyPacketPriority.fromCode(parts[3]);
    if (priority == null) return null;

    final latitude = double.tryParse(parts[5]);
    final longitude = double.tryParse(parts[6]);
    final expiresAtSeconds = int.tryParse(parts[7]);
    final version = int.tryParse(parts[8]);
    if (latitude == null ||
        longitude == null ||
        expiresAtSeconds == null ||
        version == null) {
      return null;
    }

    final note = parts.length > 9 ? parts.sublist(9).join(_delimiter) : '';

    return EmergencyPacket(
      id: parts[1],
      originId: parts[2],
      priority: priority,
      type: parts[4],
      latitude: latitude,
      longitude: longitude,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        expiresAtSeconds * 1000,
        isUtc: true,
      ),
      version: version,
      note: note,
    );
  }
}
