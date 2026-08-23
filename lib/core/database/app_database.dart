import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:taarak/core/database/tables/local_hazard_zones_table.dart';
import 'package:taarak/core/database/tables/local_incident_reports_table.dart';
import 'package:taarak/core/database/tables/local_incidents_table.dart';
import 'package:taarak/core/database/tables/local_routes_table.dart';
import 'package:taarak/core/database/tables/local_shelters_table.dart';
import 'package:taarak/core/database/tables/local_users_table.dart';
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
    SyncQueueEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'taarak_local'));

  @override
  int get schemaVersion => 1;
}
