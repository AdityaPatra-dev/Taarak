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

  /// M24: how much [[EnvironmentalRiskEngine]] nudged the score above the
  /// hazard/vulnerability base — 0.0 when no fresh environmental data was
  /// available for this habitation. Kept separate from `hazardExposure`
  /// rather than folded into it, so the UI can show "here's what external
  /// data added" as its own, visibly-attributed line.
  RealColumn get environmentalAdjustment =>
      real().withDefault(const Constant(0))();

  /// JSON list of {parameter, value, source, observedAt} for the fresh
  /// observations that actually contributed — the "visible provenance"
  /// the acceptance criterion asks for.
  TextColumn get environmentalProvenanceJson =>
      text().withDefault(const Constant('[]'))();

  DateTimeColumn get assessedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {habitationId};
}
