import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_environmental_observation_repository.dart';
import 'package:taarak/features/environmental/application/environmental_data_service.dart';
import 'package:taarak/features/environmental/application/environmental_data_source.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/susceptibility/application/deterministic_hazard_susceptibility_model.dart';

import '../../support/sqlite3_test_setup.dart';

class _UnusedDataSource implements EnvironmentalDataSource {
  @override
  Future<List<RawEnvironmentalReading>> fetchReadings({
    required double latitude,
    required double longitude,
    DateTime? now,
  }) async => const [];
}

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late LocalEnvironmentalObservationRepository repository;
  late DeterministicHazardSusceptibilityModel model;
  final now = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = LocalEnvironmentalObservationRepository(db);
    model = DeterministicHazardSusceptibilityModel(
      environmentalDataService: EnvironmentalDataService(
        dataSource: _UnusedDataSource(),
        repository: repository,
      ),
    );
  });

  tearDown(() => db.close());

  Future<void> seed({
    required String habitationId,
    double? rainfall24h,
    double? soilMoisture,
    DateTime? observedAt,
    double confidence = 0.7,
  }) async {
    if (rainfall24h != null) {
      await repository.save(
        LocalEnvironmentalObservation(
          id: '$habitationId-rainfall_24h',
          habitationId: habitationId,
          parameter: 'rainfall_24h',
          value: rainfall24h,
          source: 'test',
          observedAt: observedAt ?? now,
          fetchedAt: now,
          confidence: confidence,
          version: 1,
        ),
      );
    }
    if (soilMoisture != null) {
      await repository.save(
        LocalEnvironmentalObservation(
          id: '$habitationId-soil_moisture',
          habitationId: habitationId,
          parameter: 'soil_moisture',
          value: soilMoisture,
          source: 'test',
          observedAt: observedAt ?? now,
          fetchedAt: now,
          confidence: confidence,
          version: 1,
        ),
      );
    }
  }

  test('empty cache returns null rather than a fabricated safe score', () async {
    final prediction = await model.predict(
      habitationId: 'hab-empty',
      latitude: 1,
      longitude: 1,
      hazardType: HazardType.landslide,
      now: now,
    );

    expect(prediction, isNull);
  });

  test('landslide score at full saturation + 100mm rainfall reaches 1.0', () async {
    await seed(habitationId: 'hab-1', rainfall24h: 100, soilMoisture: 1.0);

    final prediction = await model.predict(
      habitationId: 'hab-1',
      latitude: 1,
      longitude: 1,
      hazardType: HazardType.landslide,
      now: now,
    );

    expect(prediction, isNotNull);
    expect(prediction!.score, closeTo(1.0, 1e-9));
    expect(prediction.featureContributions['soilMoisture'], closeTo(1.0, 1e-9));
    expect(prediction.featureContributions['rainfall24h'], closeTo(1.0, 1e-9));
  });

  test('flood score at 150mm rainfall (no soil signal) is dominated by rainfall alone', () async {
    await seed(habitationId: 'hab-2', rainfall24h: 150);

    final prediction = await model.predict(
      habitationId: 'hab-2',
      latitude: 1,
      longitude: 1,
      hazardType: HazardType.flood,
      now: now,
    );

    expect(prediction, isNotNull);
    expect(prediction!.score, closeTo(1.0, 1e-9));
    expect(prediction.featureContributions.containsKey('soilMoisture'), isFalse);
  });

  test('a reading older than the 24h freshness threshold is excluded', () async {
    await seed(
      habitationId: 'hab-3',
      rainfall24h: 150,
      observedAt: now.subtract(const Duration(hours: 25)),
    );

    final prediction = await model.predict(
      habitationId: 'hab-3',
      latitude: 1,
      longitude: 1,
      hazardType: HazardType.flood,
      now: now,
    );

    expect(prediction, isNull);
  });

  test('a reading exactly at the 24h threshold is still fresh (boundary inclusive)', () async {
    await seed(
      habitationId: 'hab-4',
      rainfall24h: 150,
      observedAt: now.subtract(const Duration(hours: 24)),
    );

    final prediction = await model.predict(
      habitationId: 'hab-4',
      latitude: 1,
      longitude: 1,
      hazardType: HazardType.flood,
      now: now,
    );

    expect(prediction, isNotNull);
  });

  test('only one of two parameters present discounts confidence by 0.7x', () async {
    await seed(habitationId: 'hab-5', rainfall24h: 150, confidence: 0.75);

    final prediction = await model.predict(
      habitationId: 'hab-5',
      latitude: 1,
      longitude: 1,
      hazardType: HazardType.flood,
      now: now,
    );

    expect(prediction, isNotNull);
    expect(prediction!.confidence, closeTo(0.75 * 0.7, 1e-9));
  });

  test('both parameters present uses their plain average confidence, no discount', () async {
    await seed(habitationId: 'hab-6', rainfall24h: 150, soilMoisture: 0.5, confidence: 0.8);

    final prediction = await model.predict(
      habitationId: 'hab-6',
      latitude: 1,
      longitude: 1,
      hazardType: HazardType.flood,
      now: now,
    );

    expect(prediction, isNotNull);
    expect(prediction!.confidence, closeTo(0.8, 1e-9));
  });
}
