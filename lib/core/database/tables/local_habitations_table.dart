import 'package:drift/drift.dart';

/// A vulnerable settlement/locality — the "Vulnerable Habitations" the PS
/// is named after. Kept minimal: M08 (Vulnerability) will add the
/// infrastructure/access indicators it needs; `administrativeRegionName`
/// is a plain string for now rather than a normalized region table, since
/// nothing yet needs to browse/filter by region hierarchy.
class LocalHabitations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get population => integer().withDefault(const Constant(0))();
  TextColumn get administrativeRegionName => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
