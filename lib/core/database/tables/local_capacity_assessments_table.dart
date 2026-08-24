import 'package:drift/drift.dart';

/// One row per habitation: its current carrying-capacity comparison. Same
/// shape/rationale as [[LocalRiskAssessments]] — one current row per
/// habitation, not a history table.
class LocalCapacityAssessments extends Table {
  TextColumn get habitationId => text()();
  IntColumn get exposedPopulation => integer()();
  IntColumn get availableSafeCapacity => integer()();

  /// exposedPopulation - availableSafeCapacity. Positive means a shortfall.
  IntColumn get capacityGap => integer()();
  BoolColumn get hasSufficientCapacity => boolean()();

  /// JSON list of {shelterId, shelterName, availableCapacity,
  /// distanceMeters} for the safe, in-range shelters this figure counted.
  TextColumn get contributingSheltersJson => text()();

  RealColumn get accessibleRadiusMeters => real()();
  TextColumn get modelVersion => text()();
  DateTimeColumn get assessedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {habitationId};
}
