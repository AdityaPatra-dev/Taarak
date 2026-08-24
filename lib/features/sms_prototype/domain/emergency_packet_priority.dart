/// M22's compact priority tier — reuses the same three-level scheme M17's
/// sync queue already prioritizes by (SOS > critical > routine), so a
/// packet's urgency means the same thing whether it travels over the
/// internet sync queue or this SMS fallback.
enum EmergencyPacketPriority {
  sos,
  critical,
  routine;

  /// Single-character code — every byte counts in a 160-character SMS.
  String get code => switch (this) {
    EmergencyPacketPriority.sos => 'S',
    EmergencyPacketPriority.critical => 'C',
    EmergencyPacketPriority.routine => 'R',
  };

  static EmergencyPacketPriority? fromCode(String code) {
    for (final priority in EmergencyPacketPriority.values) {
      if (priority.code == code) return priority;
    }
    return null;
  }
}
