import 'package:drift/drift.dart';

/// One row per habitation: its current ranked relocation candidates. Same
/// shape/rationale as [[LocalRiskAssessments]] — one current row per
/// habitation, not a history table.
class LocalRelocationPlans extends Table {
  TextColumn get habitationId => text()();
  IntColumn get populationToRelocate => integer()();

  /// JSON list of {shelterId, shelterName, availableCapacity,
  /// distanceMeters, distanceScore, capacityScore, accessScore,
  /// facilitiesScore, compositeScore, reasons} — ranked best-first.
  TextColumn get rankedCandidatesJson => text()();

  TextColumn get modelVersion => text()();
  DateTimeColumn get plannedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {habitationId};
}
