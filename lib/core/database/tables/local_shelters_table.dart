import 'package:drift/drift.dart';

/// Cached shelter/facility data for offline display and, later, capacity
/// comparisons (M09).
class LocalShelters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get capacityTotal => integer().withDefault(const Constant(0))();
  IntColumn get occupancy => integer().withDefault(const Constant(0))();
  TextColumn get facilitiesJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
