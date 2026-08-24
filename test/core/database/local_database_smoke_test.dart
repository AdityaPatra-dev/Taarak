import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_incident_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('taarak_db_test');
    dbFile = File('${tempDir.path}${Platform.pathSeparator}test.sqlite');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test(
    'an incident written while offline is still readable after an app restart',
    () async {
      // "Session 1": the app is running, offline, and a citizen submits a
      // report that becomes a local incident.
      var db = AppDatabase(NativeDatabase(dbFile));
      var repo = LocalIncidentRepository(db);

      final incident = LocalIncident(
        id: 'incident-1',
        type: 'landslide',
        status: 'active',
        latitude: 12.34,
        longitude: 56.78,
        description: 'Blocked road near Habitation 12',
        severity: 'high',
        independentSourceCount: 1,
        confidence: 0.5,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
        version: 1,
        isSynced: false,
      );

      final saveResult = await repo.save(incident);
      expect(saveResult.isSuccess, isTrue);

      await db.close(); // simulate the app process ending

      // "Session 2": the app restarts and reopens the same on-disk file.
      db = AppDatabase(NativeDatabase(dbFile));
      repo = LocalIncidentRepository(db);

      final readResult = await repo.getById('incident-1');
      expect(readResult.isSuccess, isTrue);
      expect(
        readResult.dataOrNull?.description,
        'Blocked road near Habitation 12',
      );
      expect(readResult.dataOrNull?.isSynced, isFalse);

      await db.close();
    },
  );

  group('LocalShelterRepository (in-memory)', () {
    late AppDatabase db;
    late LocalShelterRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = LocalShelterRepository(db);
    });

    tearDown(() => db.close());

    test('saves, lists and deletes shelters', () async {
      final shelter = LocalShelter(
        id: 'shelter-1',
        name: 'Community Hall',
        latitude: 10,
        longitude: 20,
        capacityTotal: 200,
        occupancy: 40,
        facilitiesJson: '["medical","food"]',
        updatedAt: DateTime.utc(2026, 1, 1),
        version: 1,
      );
      await repo.save(shelter);

      final all = await repo.getAll();
      expect(all.dataOrNull?.map((s) => s.id), contains('shelter-1'));

      await repo.delete('shelter-1');
      final afterDelete = await repo.getById('shelter-1');
      expect(afterDelete.isFailure, isTrue);
    });
  });

  group('SyncQueueDao (in-memory)', () {
    late AppDatabase db;
    late SyncQueueDao dao;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dao = SyncQueueDao(db);
    });

    tearDown(() => db.close());

    test('an enqueued change is pending until marked synced', () async {
      final enqueueResult = await dao.enqueue(
        entityTable: 'local_incidents',
        entityId: 'incident-1',
        operation: 'create',
        payloadJson: '{"id":"incident-1"}',
      );
      expect(enqueueResult.isSuccess, isTrue);
      final queueId = enqueueResult.dataOrNull!;

      final pendingBefore = await dao.listPending();
      expect(pendingBefore.dataOrNull, hasLength(1));

      await dao.markSynced(queueId);

      final pendingAfter = await dao.listPending();
      expect(pendingAfter.dataOrNull, isEmpty);
    });
  });
}
