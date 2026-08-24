import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/audit_log_dao.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_relocation_plan_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/features/relocation/application/relocation_planning_service.dart';
import 'package:taarak/features/shelters/application/shelter_management_service.dart';
import 'package:taarak/features/shelters/domain/shelter_facility_type.dart';

import '../../support/sqlite3_test_setup.dart';

/// M15's own acceptance criterion, wired end to end: a write made through
/// [ShelterManagementService] (this module) changes what M10's
/// [RelocationPlanningService] recommends, since both read/write the same
/// [LocalShelters] row — proving the data actually feeds relocation rather
/// than just asserting the two tables share a schema.
void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late ShelterManagementService shelterService;
  late RelocationPlanningService relocationService;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    shelterService = ShelterManagementService(
      shelterRepository: LocalShelterRepository(db),
      auditLogDao: AuditLogDao(db),
    );
    relocationService = RelocationPlanningService(
      habitationRepository: LocalHabitationRepository(db),
      hazardZoneRepository: LocalHazardZoneRepository(db),
      shelterRepository: LocalShelterRepository(db),
      planRepository: LocalRelocationPlanRepository(db),
    );

    await db
        .into(db.localHabitations)
        .insert(
          LocalHabitationsCompanion.insert(
            id: 'hab-1',
            name: 'Ridge Colony',
            latitude: 10,
            longitude: 10,
            updatedAt: now,
          ),
        );
  });

  tearDown(() => db.close());

  test(
    'CAPACITY DATA FEEDS RELOCATION — the acceptance criterion',
    () async {
      final created = await shelterService.upsertShelter(
        name: 'Nearby Shelter',
        latitude: 10.02,
        longitude: 10.02,
        capacityTotal: 100,
        facilities: {ShelterFacilityType.medical, ShelterFacilityType.food},
        officialId: 'official-1',
        now: now,
      );
      final shelterId = created.dataOrNull!.id;

      final beforeFull = await relocationService.planForHabitation(
        'hab-1',
        populationOverride: 50,
        now: now,
      );
      expect(
        beforeFull.dataOrNull?.rankedCandidates.map((c) => c.shelterId),
        contains(shelterId),
      );

      // A Local Official reports the shelter has since filled up entirely.
      await shelterService.updateOccupancy(
        shelterId: shelterId,
        occupancy: 100,
        officialId: 'official-1',
        now: now,
      );

      final afterFull = await relocationService.planForHabitation(
        'hab-1',
        populationOverride: 50,
        now: now,
      );
      expect(
        afterFull.dataOrNull?.rankedCandidates.map((c) => c.shelterId),
        isNot(contains(shelterId)),
        reason: 'a shelter with zero remaining capacity must drop out as a candidate',
      );

      // Freeing capacity back up brings it back as a candidate.
      await shelterService.updateOccupancy(
        shelterId: shelterId,
        occupancy: 20,
        officialId: 'official-1',
        now: now,
      );

      final afterFreed = await relocationService.planForHabitation(
        'hab-1',
        populationOverride: 50,
        now: now,
      );
      expect(
        afterFreed.dataOrNull?.rankedCandidates.map((c) => c.shelterId),
        contains(shelterId),
      );
    },
  );

  test('a facilities update through M15 changes the relocation ranking score', () async {
    final bare = await shelterService.upsertShelter(
      name: 'Bare Shelter',
      latitude: 10.02,
      longitude: 10.02,
      capacityTotal: 100,
      officialId: 'official-1',
      now: now,
    );

    final planBefore = await relocationService.planForHabitation(
      'hab-1',
      populationOverride: 50,
      now: now,
    );
    final scoreBefore = planBefore.dataOrNull!.rankedCandidates
        .firstWhere((c) => c.shelterId == bare.dataOrNull!.id)
        .compositeScore;

    await shelterService.upsertShelter(
      id: bare.dataOrNull!.id,
      name: 'Bare Shelter',
      latitude: 10.02,
      longitude: 10.02,
      capacityTotal: 100,
      facilities: {
        ShelterFacilityType.medical,
        ShelterFacilityType.food,
        ShelterFacilityType.transport,
        ShelterFacilityType.rescue,
      },
      officialId: 'official-1',
      now: now,
    );

    final planAfter = await relocationService.planForHabitation(
      'hab-1',
      populationOverride: 50,
      now: now.add(const Duration(minutes: 1)),
    );
    final scoreAfter = planAfter.dataOrNull!.rankedCandidates
        .firstWhere((c) => c.shelterId == bare.dataOrNull!.id)
        .compositeScore;

    expect(scoreAfter, greaterThan(scoreBefore));
  });
}
