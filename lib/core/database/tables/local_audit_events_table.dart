import 'package:drift/drift.dart';

/// Append-only audit trail — "Actor, action, object, time, old/new value
/// and reason" per the blueprint's own M19 spec, transcribed verbatim.
/// M13 (verification) is the first module that needs to write to this,
/// since its own acceptance criterion requires a real audit entry per
/// state change; M19 will build the full audit review UI on top of this
/// same table later, not replace it.
///
/// Deliberately has no update/delete access anywhere in the app — see
/// [[AuditLogDao]] — matching the blueprint's restriction that audit
/// records must never be silently altered.
class LocalAuditEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actorId => text()();
  TextColumn get action => text()();
  TextColumn get objectType => text()();
  TextColumn get objectId => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
}
