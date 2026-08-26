import 'package:drift/drift.dart';

/// A Field Responder's on-site damage assessment for an assigned
/// [LocalIncidents] row. Kept as its own table rather than folded into
/// [LocalIncidentReports] — that table is a citizen's initial ground
/// observation feeding M14's fusion; this is an official's structured
/// follow-up once someone has actually been sent to look, with different
/// semantics (always tied to a specific responder and incident, never
/// itself fused into anything).
class LocalDamageReports extends Table {
  TextColumn get id => text()();
  TextColumn get incidentId => text()();
  TextColumn get responderId => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get severity => text().withDefault(const Constant('unknown'))();

  /// Local file path to an optionally-attached photo, same pattern as
  /// [LocalIncidentReports.mediaPath].
  TextColumn get mediaPath => text().nullable()();

  DateTimeColumn get submittedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
