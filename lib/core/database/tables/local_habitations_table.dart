import 'package:drift/drift.dart';

/// A vulnerable settlement/locality — the "Vulnerable Habitations" the PS
/// is named after. `administrativeRegionName` is a plain string for now
/// rather than a normalized region table, since nothing yet needs to
/// browse/filter by region hierarchy.
class LocalHabitations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get population => integer().withDefault(const Constant(0))();
  TextColumn get administrativeRegionName => text().nullable()();

  /// M08's "configured indicators": 0.0 (robust/easy) – 1.0
  /// (fragile/remote), set manually by an official once that data-entry
  /// flow exists. Null means "not yet configured" — the vulnerability
  /// engine falls back to a neutral value rather than treating unset data
  /// as either safe or unsafe.
  RealColumn get infrastructureQuality => real().nullable()();
  RealColumn get accessQuality => real().nullable()();

  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
