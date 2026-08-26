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

  /// M14's ground-truth fusion output: how many *independent* reporters
  /// (deduplicated by reporter id) have corroborated this incident, and
  /// the resulting confidence — both start at a single-source baseline
  /// and are recomputed each time another report is fused in.
  IntColumn get independentSourceCount =>
      integer().withDefault(const Constant(1))();
  RealColumn get confidence => real().withDefault(const Constant(0.5))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Set by District/Command's responder-assignment screen; read by a
  /// Field Responder's "my assigned incidents" list. Null means
  /// unassigned — not every incident needs a responder sent to it.
  TextColumn get assignedResponderId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
