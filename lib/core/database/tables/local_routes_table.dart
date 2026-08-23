import 'package:drift/drift.dart';

/// Last-known route between two points, cached so navigation (M11) still
/// has something to show when a fresh route can't be computed offline.
class LocalRoutes extends Table {
  TextColumn get id => text()();
  RealColumn get originLat => real()();
  RealColumn get originLng => real()();
  RealColumn get destLat => real()();
  RealColumn get destLng => real()();
  TextColumn get polylineJson => text()();
  RealColumn get distanceMeters => real().withDefault(const Constant(0))();
  IntColumn get etaSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get cachedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
