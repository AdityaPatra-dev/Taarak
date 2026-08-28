import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/features/shelters/application/shelter_management_service.dart';
import 'package:taarak/features/shelters/domain/shelter_facility_type.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late ShelterManagementService service;
  late LocalShelterRepository repository;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = LocalShelterRepository(db);
    service = ShelterManagementService(
      shelterRepository: repository,
      auditLogDao: AuditLogDao(db),
    );
  });

  tearDown(() => db.close());

  group('upsertShelter', () {
    test('creates a new shelter with the given facilities', () async {
      final result = await service.upsertShelter(
        name: 'Community Hall',
        latitude: 10,
        longitude: 20,
        capacityTotal: 200,
        facilities: {ShelterFacilityType.medical, ShelterFacilityType.food},
        officialId: 'official-1',
        now: now,
      );

      expect(result.isSuccess, isTrue);
      final shelter = result.dataOrNull!;
      expect(shelter.capacityTotal, 200);
      expect(shelter.occupancy, 0);
      expect(
        service.facilitiesOf(shelter),
        {ShelterFacilityType.medical, ShelterFacilityType.food},
      );

      final saved = await repository.getById(shelter.id);
      expect(saved.dataOrNull?.name, 'Community Hall');
    });

    test('updating an existing shelter preserves occupancy unless overridden', () async {
      final created = await service.upsertShelter(
        name: 'Community Hall',
        latitude: 10,
        longitude: 20,
        capacityTotal: 200,
        occupancy: 50,
        officialId: 'official-1',
        now: now,
      );
      final shelterId = created.dataOrNull!.id;

      final updated = await service.upsertShelter(
        id: shelterId,
        name: 'Community Hall (Renamed)',
        latitude: 10,
        longitude: 20,
        capacityTotal: 250,
        officialId: 'official-1',
        now: now,
      );

      expect(updated.dataOrNull?.name, 'Community Hall (Renamed)');
      expect(updated.dataOrNull?.capacityTotal, 250);
      expect(updated.dataOrNull?.occupancy, 50);
      expect(updated.dataOrNull?.version, 2);
    });

    test('writes an audit entry for the creation', () async {
      final result = await service.upsertShelter(
        name: 'Community Hall',
        latitude: 10,
        longitude: 20,
        capacityTotal: 200,
        officialId: 'official-1',
        now: now,
      );

      final auditDao = AuditLogDao(db);
      final trail = await auditDao.listForObject('shelter', result.dataOrNull!.id);
      expect(trail.dataOrNull, hasLength(1));
      expect(trail.dataOrNull!.first.action, 'shelter.created');
    });
  });

  group('updateOccupancy', () {
    test('changes only the occupancy field and writes an audit entry', () async {
      final created = await service.upsertShelter(
        name: 'Community Hall',
        latitude: 10,
        longitude: 20,
        capacityTotal: 200,
        officialId: 'official-1',
        now: now,
      );
      final shelterId = created.dataOrNull!.id;

      final result = await service.updateOccupancy(
        shelterId: shelterId,
        occupancy: 120,
        officialId: 'official-2',
        now: now,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.occupancy, 120);
      expect(result.dataOrNull?.capacityTotal, 200);

      final auditDao = AuditLogDao(db);
      final trail = await auditDao.listForObject('shelter', shelterId);
      expect(trail.dataOrNull, hasLength(2));
      expect(trail.dataOrNull!.first.action, 'shelter.occupancy_updated');
      expect(jsonDecode(trail.dataOrNull!.first.oldValue!)['occupancy'], 0);
      expect(jsonDecode(trail.dataOrNull!.first.newValue!)['occupancy'], 120);
    });

    test('fails cleanly for an unknown shelter', () async {
      final result = await service.updateOccupancy(
        shelterId: 'missing',
        occupancy: 10,
        officialId: 'official-1',
        now: now,
      );
      expect(result.isFailure, isTrue);
    });
  });

  group('removeShelter', () {
    test('deletes the shelter and writes an audit entry', () async {
      final created = await service.upsertShelter(
        name: 'Community Hall',
        latitude: 10,
        longitude: 20,
        capacityTotal: 200,
        officialId: 'official-1',
        now: now,
      );
      final shelterId = created.dataOrNull!.id;

      final result = await service.removeShelter(
        shelterId: shelterId,
        officialId: 'official-2',
        now: now,
      );

      expect(result.isSuccess, isTrue);
      final afterDelete = await repository.getById(shelterId);
      expect(afterDelete.isFailure, isTrue);

      final auditDao = AuditLogDao(db);
      final trail = await auditDao.listForObject('shelter', shelterId);
      expect(trail.dataOrNull!.first.action, 'shelter.removed');
    });

    test('fails cleanly for an unknown shelter', () async {
      final result = await service.removeShelter(
        shelterId: 'missing',
        officialId: 'official-1',
        now: now,
      );
      expect(result.isFailure, isTrue);
    });
  });
}
