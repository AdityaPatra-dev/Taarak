import 'package:drift/drift.dart';

/// Per-device bookkeeping for [[AutoHazardScanService]]'s hysteresis —
/// "how many consecutive polls has this habitation/hazard-type pair been
/// below the delete threshold" — so a single noisy reading can't retract
/// a zone the moment conditions dip. Deliberately local-only, not synced:
/// the actual create/delete *decisions* this state drives already
/// propagate cross-device through [[HazardIngestionService]]'s existing
/// sync-queue path, so nothing about cross-device consistency depends on
/// this table itself syncing. `id` is a deterministic
/// `'<habitationId>-<hazardType>'` composite, matching the auto-created
/// hazard zone's own id scheme (`'auto-<habitationId>-<hazardType>'`).
class LocalHazardAutomationStates extends Table {
  TextColumn get id => text()();
  TextColumn get habitationId => text()();
  TextColumn get hazardType => text()();

  RealColumn get lastScore => real()();
  IntColumn get consecutiveBelowDeleteThreshold =>
      integer().withDefault(const Constant(0))();
  BoolColumn get zoneActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastEvaluatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
