import 'package:drift/drift.dart';

/// M16's geo-targeted broadcast. `geometryJson` is a snapshot of the
/// target [LocalHazardZones] polygon taken at broadcast time — deliberately
/// denormalized so an alert's target area stays fixed even if the source
/// hazard zone is later re-surveyed or resolved, matching M07's snapshot
/// philosophy for factor breakdowns.
class LocalAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();

  /// low/medium/high/critical — same vocabulary as
  /// [LocalHazardZones.severity] and [LocalIncidents.severity], so
  /// [severityColor] applies unchanged.
  TextColumn get severity => text()();

  TextColumn get zoneId => text()();
  TextColumn get zoneLabel => text()();
  TextColumn get geometryJson => text()();

  TextColumn get issuedBy => text()();
  DateTimeColumn get issuedAt => dateTime()();

  /// The end of the alert's validity window (spec: "severity, validity,
  /// acknowledgement and history"). An alert with `validUntil` in the past
  /// is no longer active but is never deleted — it stays in the table as
  /// part of the broadcast history.
  DateTimeColumn get validUntil => dateTime()();

  /// Set when an official ends an alert early, distinct from simply
  /// expiring — both make [AlertEngine.isActive] false, but only
  /// cancellation is a deliberate act worth its own audit action.
  DateTimeColumn get cancelledAt => dateTime().nullable()();

  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
