import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_environmental_observation_repository.dart';
import 'package:taarak/features/environmental/application/demo_environmental_data_source.dart';
import 'package:taarak/features/environmental/application/environmental_data_service.dart';
import 'package:taarak/features/environmental/application/environmental_data_source.dart';
import 'package:taarak/features/environmental/domain/environmental_parameter.dart';

import '../../support/sqlite3_test_setup.dart';

class _FixedDataSource implements EnvironmentalDataSource {
  final List<RawEnvironmentalReading> readings;
  _FixedDataSource(this.readings);

  @override
  Future<List<RawEnvironmentalReading>> fetchReadings({
    required double latitude,
    required double longitude,
    DateTime? now,
  }) async => readings;
}

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  final now = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('refreshForHabitation caches one row per parameter for that habitation', () async {
    final service = EnvironmentalDataService(
      dataSource: DemoEnvironmentalDataSource(),
      repository: LocalEnvironmentalObservationRepository(db),
    );

    final saved = await service.refreshForHabitation(
      habitationId: 'hab-1',
      latitude: 10,
      longitude: 10,
      now: now,
    );

    expect(saved, hasLength(EnvironmentalParameter.values.length));
    expect(saved.every((o) => o.habitationId == 'hab-1'), isTrue);
  });

  test('refreshing again overwrites the same row rather than accumulating history', () async {
    final repository = LocalEnvironmentalObservationRepository(db);

    final firstReading = RawEnvironmentalReading(
      parameter: EnvironmentalParameter.rainfall24h,
      value: 50,
      source: 'test',
      observedAt: now,
    );
    final firstService = EnvironmentalDataService(
      dataSource: _FixedDataSource([firstReading]),
      repository: repository,
    );
    await firstService.refreshForHabitation(
      habitationId: 'hab-1',
      latitude: 10,
      longitude: 10,
      now: now,
    );

    final secondReading = RawEnvironmentalReading(
      parameter: EnvironmentalParameter.rainfall24h,
      value: 90,
      source: 'test',
      observedAt: now.add(const Duration(hours: 1)),
    );
    final secondService = EnvironmentalDataService(
      dataSource: _FixedDataSource([secondReading]),
      repository: repository,
    );
    await secondService.refreshForHabitation(
      habitationId: 'hab-1',
      latitude: 10,
      longitude: 10,
      now: now.add(const Duration(hours: 1)),
    );

    final all = await repository.getAll();
    expect(all.dataOrNull, hasLength(1));
    expect(all.dataOrNull!.single.value, 90);
    expect(all.dataOrNull!.single.version, 2);
  });

  test('observationsFor only returns rows for the requested habitation', () async {
    final repository = LocalEnvironmentalObservationRepository(db);
    final service = EnvironmentalDataService(
      dataSource: DemoEnvironmentalDataSource(),
      repository: repository,
    );

    await service.refreshForHabitation(
      habitationId: 'hab-1',
      latitude: 10,
      longitude: 10,
      now: now,
    );
    await service.refreshForHabitation(
      habitationId: 'hab-2',
      latitude: 20,
      longitude: 20,
      now: now,
    );

    final forHab1 = await service.observationsFor('hab-1');
    expect(forHab1.every((o) => o.habitationId == 'hab-1'), isTrue);
    expect(forHab1, hasLength(EnvironmentalParameter.values.length));
  });

  test(
    'EXTERNAL DATA CAN INFLUENCE RISK WITH VISIBLE PROVENANCE — the acceptance '
    'criterion, through the service: adjustmentFor reflects what was refreshed',
    () async {
      final service = EnvironmentalDataService(
        dataSource: _RainOnlyDataSource(),
        repository: LocalEnvironmentalObservationRepository(db),
      );

      await service.refreshForHabitation(
        habitationId: 'hab-1',
        latitude: 10,
        longitude: 10,
        now: now,
      );

      final adjustment = await service.adjustmentFor('hab-1', now: now);

      expect(adjustment.adjustment, greaterThan(0));
      expect(adjustment.influencing, hasLength(1));
      expect(adjustment.influencing.single.source, 'IMD (test feed)');
    },
  );

  test('a habitation with no cached observations gets zero adjustment', () async {
    final service = EnvironmentalDataService(
      dataSource: DemoEnvironmentalDataSource(),
      repository: LocalEnvironmentalObservationRepository(db),
    );

    final adjustment = await service.adjustmentFor('never-refreshed', now: now);
    expect(adjustment.adjustment, 0);
  });
}

class _RainOnlyDataSource implements EnvironmentalDataSource {
  @override
  Future<List<RawEnvironmentalReading>> fetchReadings({
    required double latitude,
    required double longitude,
    DateTime? now,
  }) async => [
    RawEnvironmentalReading(
      parameter: EnvironmentalParameter.rainfall24h,
      value: 150,
      source: 'IMD (test feed)',
      observedAt: now ?? DateTime.now(),
      confidence: 0.9,
    ),
  ];
}
