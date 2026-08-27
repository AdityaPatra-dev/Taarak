import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/features/habitations/application/habitation_registration_service.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late HabitationRegistrationService service;
  late SyncQueueDao syncQueueDao;
  late AuditLogDao auditLogDao;
  final now = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    syncQueueDao = SyncQueueDao(db);
    auditLogDao = AuditLogDao(db);
    service = HabitationRegistrationService(
      repository: LocalHabitationRepository(db),
      syncQueueDao: syncQueueDao,
      auditLogDao: auditLogDao,
    );
  });

  tearDown(() => db.close());

  test(
    'a new habitation is saved locally, queued for sync, and audited',
    () async {
      final result = await service.register(
        id: 'hab-1',
        name: 'Riverside Colony',
        latitude: 28.5,
        longitude: 77.1,
        population: 340,
        administrativeRegionName: 'Ward 4',
        infrastructureQuality: 0.5,
        accessQuality: 0.2,
        officialId: 'official-1',
        now: now,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.version, 1);

      final pending = await syncQueueDao.listPending();
      expect(pending.dataOrNull, hasLength(1));
      expect(pending.dataOrNull!.single.entityId, 'hab-1');
      expect(pending.dataOrNull!.single.entityTable, 'local_habitations');
      expect(pending.dataOrNull!.single.operation, 'create');

      final logged = await auditLogDao.listForObject('habitation', 'hab-1');
      expect(
        logged.dataOrNull?.any((e) => e.action == 'habitation.registered'),
        isTrue,
      );
    },
  );

  test('re-registering the same id increments its version and logs an update', () async {
    await service.register(
      id: 'hab-2',
      name: 'Hillside Settlement',
      latitude: 30.1,
      longitude: 78.9,
      population: 120,
      officialId: 'official-1',
      now: now,
    );

    final result = await service.register(
      id: 'hab-2',
      name: 'Hillside Settlement',
      latitude: 30.1,
      longitude: 78.9,
      population: 150,
      officialId: 'official-1',
      now: now.add(const Duration(days: 1)),
    );

    expect(result.dataOrNull?.version, 2);
    expect(result.dataOrNull?.population, 150);

    final pending = await syncQueueDao.listPending();
    expect(pending.dataOrNull, hasLength(2));
    expect(pending.dataOrNull!.last.operation, 'update');

    final logged = await auditLogDao.listForObject('habitation', 'hab-2');
    expect(
      logged.dataOrNull?.any((e) => e.action == 'habitation.updated'),
      isTrue,
    );
  });

  test('listAll returns every registered habitation', () async {
    await service.register(
      id: 'hab-3',
      name: 'Colony A',
      latitude: 1,
      longitude: 1,
      population: 50,
      officialId: 'official-1',
      now: now,
    );
    await service.register(
      id: 'hab-4',
      name: 'Colony B',
      latitude: 2,
      longitude: 2,
      population: 75,
      officialId: 'official-1',
      now: now,
    );

    final all = await service.listAll();

    expect(all.isSuccess, isTrue);
    expect(all.dataOrNull, hasLength(2));
  });
}
