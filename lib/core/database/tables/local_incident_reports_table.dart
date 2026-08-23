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
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get severity => text().withDefault(const Constant('unknown'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
