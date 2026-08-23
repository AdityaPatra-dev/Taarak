import 'package:drift/drift.dart';

/// Cached hazard layer data for offline map rendering. Kept deliberately
/// minimal — M06 (Hazard Engine) owns the real domain model and will grow
/// this schema as it lands; `geometryJson` holds whatever shape data it
/// needs in the meantime without forcing early column churn.
class LocalHazardZones extends Table {
  TextColumn get id => text()();
  TextColumn get hazardType => text()();
  TextColumn get severity => text()();
  TextColumn get geometryJson => text()();
  TextColumn get source => text()();
  DateTimeColumn get observedAt => dateTime()();
  RealColumn get confidence => real().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
