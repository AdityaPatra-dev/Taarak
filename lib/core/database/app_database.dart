import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:taarak/core/database/tables/local_alert_acknowledgements_table.dart';
import 'package:taarak/core/database/tables/local_alerts_table.dart';
import 'package:taarak/core/database/tables/local_audit_events_table.dart';
import 'package:taarak/core/database/tables/local_capacity_assessments_table.dart';
import 'package:taarak/core/database/tables/local_habitations_table.dart';
import 'package:taarak/core/database/tables/local_hazard_zones_table.dart';
import 'package:taarak/core/database/tables/local_incident_reports_table.dart';
import 'package:taarak/core/database/tables/local_incidents_table.dart';
import 'package:taarak/core/database/tables/local_relocation_plans_table.dart';
import 'package:taarak/core/database/tables/local_risk_assessments_table.dart';
import 'package:taarak/core/database/tables/local_routes_table.dart';
import 'package:taarak/core/database/tables/local_shelters_table.dart';
import 'package:taarak/core/database/tables/local_users_table.dart';
import 'package:taarak/core/database/tables/local_vulnerability_assessments_table.dart';
import 'package:taarak/core/database/tables/sync_queue_table.dart';

part 'app_database.g.dart';

/// The offline-first local database (M03). Feature modules read/write it
/// through the typed repositories in core/database/repositories/ rather
/// than querying tables directly.
@DriftDatabase(
  tables: [
    LocalUsers,
    LocalHazardZones,
    LocalIncidents,
    LocalIncidentReports,
    LocalShelters,
    LocalRoutes,
    LocalHabitations,
    LocalRiskAssessments,
    LocalVulnerabilityAssessments,
    LocalCapacityAssessments,
    LocalRelocationPlans,
    LocalAuditEvents,
    LocalAlerts,
    LocalAlertAcknowledgements,
    SyncQueueEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'taarak_local'));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Pre-release: the schema has been growing quickly as modules land
      // (M07-M10 each added tables/columns) without the version being
      // bumped each time, so devices/emulators that installed an earlier
      // build are stuck on an old, incomplete schema — "no such table"
      // at runtime is the symptom. There's no real user data yet worth
      // preserving, so the fix is to drop and recreate everything rather
      // than write per-version migrations for schema history that was
      // never actually released. Once the schema stabilizes toward a
      // real release, replace this with proper data-preserving
      // migrations.
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
    },
  );
}
