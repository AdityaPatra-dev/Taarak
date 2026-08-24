import 'package:taarak/core/database/app_database.dart';

/// M19's deterministic core: which audit events match a Command/System
/// Admin's filter, in the order they should read them. No I/O — the
/// screen supplies whatever [AuditLogDao.getAll] returned.
List<LocalAuditEvent> filterAuditEvents(
  List<LocalAuditEvent> events, {
  String? objectType,
  String? actorId,
  String? query,
}) {
  final normalizedQuery = query?.trim().toLowerCase();

  final filtered = events.where((event) {
    if (objectType != null && event.objectType != objectType) return false;
    if (actorId != null && event.actorId != actorId) return false;
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      final haystack = [
        event.action,
        event.objectType,
        event.objectId,
        event.actorId,
        event.reason ?? '',
      ].join(' ').toLowerCase();
      if (!haystack.contains(normalizedQuery)) return false;
    }
    return true;
  }).toList();

  filtered.sort((a, b) {
    final byTime = b.occurredAt.compareTo(a.occurredAt);
    if (byTime != 0) return byTime;
    return b.id.compareTo(a.id);
  });

  return filtered;
}
