import 'package:drift/drift.dart';

/// M16's per-user acknowledgement of a broadcast alert. `id` is a
/// deterministic `'$alertId:$userId'` composite (built by the DAO) so
/// acknowledging twice updates the same row instead of creating
/// duplicates — a user can only have acknowledged an alert once.
class LocalAlertAcknowledgements extends Table {
  TextColumn get id => text()();
  TextColumn get alertId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get acknowledgedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
