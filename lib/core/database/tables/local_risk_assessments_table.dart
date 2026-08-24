import 'package:drift/drift.dart';

/// One row per habitation: its current risk assessment. Not a history
/// table — re-assessing overwrites the previous row for that habitation
/// (versioned via `version`), since "reproducible" only requires that the
/// same inputs produce the same output, not that every past run is kept.
/// Full historical audit trail is M19's concern.
class LocalRiskAssessments extends Table {
  /// Same as the habitation's id — one current assessment per habitation.
  TextColumn get habitationId => text()();
  RealColumn get hazardExposure => real()();
  RealColumn get vulnerabilityIndex => real()();
  RealColumn get riskScore => real()();
  TextColumn get riskClass => text()();
  TextColumn get modelVersion => text()();
  TextColumn get contributingHazardZoneIdsJson =>
      text().withDefault(const Constant('[]'))();
  DateTimeColumn get assessedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {habitationId};
}
