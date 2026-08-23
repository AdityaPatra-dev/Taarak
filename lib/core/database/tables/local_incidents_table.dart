import 'package:drift/drift.dart';

/// Confirmed/active incidents (post ground-truth fusion, M14). `isSynced`
/// lets an offline-created incident render locally before it's made it to
/// the backend.
class LocalIncidents extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get status => text()();
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
