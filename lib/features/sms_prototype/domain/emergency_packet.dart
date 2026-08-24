import 'package:taarak/features/sms_prototype/domain/emergency_packet_priority.dart';

/// M22's minimal emergency payload — the "compact packet" the spec asks
/// for, small enough to fit a single SMS segment (~140 usable bytes after
/// encoding overhead). Deliberately not the full [[CitizenReportDraft]]
/// shape: this is a last-resort fallback for when there's no data
/// connection at all, so every field is one an SMS budget can afford.
class EmergencyPacket {
  /// Short, not a full UUID — see [[EmergencyPacketCodec]] for how it's
  /// generated. Used for deduplication: the same emergency re-sent (e.g.
  /// a retry) carries the same id.
  final String id;

  final String originId;
  final EmergencyPacketPriority priority;

  /// Free-form but short — 'sos', 'safe_status', or a hazard type like
  /// 'landslide'/'flood', matching [[CitizenReportType]]'s storage values.
  final String type;

  final double latitude;
  final double longitude;

  /// When this packet stops being worth acting on or relaying — M23's
  /// future device relay reuses this same TTL field per the spec's
  /// "TTL/origin/version" wording.
  final DateTime expiresAt;

  final int version;
  final String note;

  const EmergencyPacket({
    required this.id,
    required this.originId,
    required this.priority,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.expiresAt,
    this.version = 1,
    this.note = '',
  });

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);
}
