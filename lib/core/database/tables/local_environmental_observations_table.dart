import 'package:drift/drift.dart';

/// M24's connected-mode environmental readings, cached locally so a risk
/// assessment computed offline still has the last-known values available
/// — same offline-first discipline as every other data type. `id` is a
/// deterministic `'<habitationId>-<parameter>'` composite (see
/// [[EnvironmentalDataService]]), so refreshing a parameter overwrites its
/// previous reading rather than accumulating an unbounded history.
class LocalEnvironmentalObservations extends Table {
  TextColumn get id => text()();
  TextColumn get habitationId => text()();

  /// One of [EnvironmentalParameter]'s storage values.
  TextColumn get parameter => text()();

  RealColumn get value => real()();

  /// Free-text attribution — "IMD", "CWC River Gauge", etc. — the
  /// "visible provenance" the acceptance criterion asks for.
  TextColumn get source => text()();

  /// When the source itself took this reading — distinct from when this
  /// device fetched it, and what [[EnvironmentalRiskEngine]]'s freshness
  /// check is measured against ("do not present stale environmental data
  /// as current without freshness information").
  DateTimeColumn get observedAt => dateTime()();
  DateTimeColumn get fetchedAt => dateTime()();

  RealColumn get confidence => real().withDefault(const Constant(0.7))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
