import 'package:drift/drift.dart';

/// Cached shelter/facility data for offline display, capacity comparisons
/// (M09) and relocation ranking (M10).
class LocalShelters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get capacityTotal => integer().withDefault(const Constant(0))();
  IntColumn get occupancy => integer().withDefault(const Constant(0))();
  TextColumn get facilitiesJson => text().withDefault(const Constant('[]'))();

  /// M10's "access" factor: 0.0 (easy road access) – 1.0 (difficult),
  /// configured the same way as a habitation's indicators (M08) — null
  /// means "not yet surveyed", not "assumed easy".
  RealColumn get accessQuality => real().nullable()();

  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
