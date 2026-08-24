import 'package:drift/drift.dart';

/// Raw ground observations (blueprint M12) before clustering/verification
/// turns them into an [LocalIncidents] row. `incidentId` is nullable
/// because a freshly submitted report may not be linked to a fused
/// incident yet.
class LocalIncidentReports extends Table {
  TextColumn get id => text()();
  TextColumn get incidentId => text().nullable()();
  TextColumn get reporterId => text().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();

  /// One of [CitizenReportType]'s storage values — landslide/flood/
  /// road_blockage/other for a hazard report, or 'sos'/'safe_status' for
  /// the two special-case citizen actions (M12).
  TextColumn get reportType => text()();

  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get severity => text().withDefault(const Constant('unknown'))();

  /// The reporting citizen's own estimate — not required for sos/safe_status.
  IntColumn get affectedPeopleCount => integer().nullable()();

  /// Local file path to an optionally-attached photo. Compression/upload
  /// prioritization for this is M21's job, not this module's.
  TextColumn get mediaPath => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// Always false at submission time — every report is written locally
  /// and queued first, regardless of current connectivity, and only M17's
  /// future sync pass flips this once the backend has it.
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
