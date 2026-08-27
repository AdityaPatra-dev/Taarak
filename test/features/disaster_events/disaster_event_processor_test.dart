import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/features/disaster_events/application/disaster_event_processor.dart';
import 'package:taarak/features/disaster_events/domain/disaster_event.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';

import '../../support/sqlite3_test_setup.dart';

void main() {
  configureSqlite3ForLocalTests();

  late AppDatabase db;
  late DisasterEventProcessor processor;
  final now = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    processor = DisasterEventProcessor(
      hazardIngestionService: HazardIngestionService(
        normalizer: HazardNormalizer(),
        repository: LocalHazardZoneRepository(db),
      ),
    );
  });

  tearDown(() => db.close());

  DisasterEvent event({
    DisasterEventType type = DisasterEventType.landslide,
    double? latitude = 28.5,
    double? longitude = 77.1,
    String severity = 'high',
  }) => DisasterEvent(
    id: 'event-1',
    type: type,
    source: 'test-source',
    timestamp: now,
    latitude: latitude,
    longitude: longitude,
    severity: severity,
  );

  test('a landslide event is ingested as a hazard zone', () async {
    final outcome = await processor.process(event(), now: now);

    expect(
      outcome.status,
      DisasterEventProcessingStatus.ingestedAsHazardZone,
    );
    final saved = await (db.select(
      db.localHazardZones,
    )..where((t) => t.id.equals('event-1'))).getSingle();
    expect(saved.hazardType, 'landslide');
    expect(saved.severity, 'high');
  });

  test('a riverRise event is ingested as a flood hazard zone', () async {
    final outcome = await processor.process(
      event(type: DisasterEventType.riverRise),
      now: now,
    );

    expect(
      outcome.status,
      DisasterEventProcessingStatus.ingestedAsHazardZone,
    );
    final saved = await (db.select(
      db.localHazardZones,
    )..where((t) => t.id.equals('event-1'))).getSingle();
    expect(saved.hazardType, 'flood');
  });

  test('a heavyRainfall event is left not-actionable rather than faked into a zone', () async {
    final outcome = await processor.process(
      event(type: DisasterEventType.heavyRainfall),
      now: now,
    );

    expect(outcome.status, DisasterEventProcessingStatus.notActionable);
    final rows = await db.select(db.localHazardZones).get();
    expect(rows, isEmpty);
  });

  test('an event with no coordinates is left not-actionable', () async {
    final outcome = await processor.process(
      event(latitude: null, longitude: null),
      now: now,
    );

    expect(outcome.status, DisasterEventProcessingStatus.notActionable);
    final rows = await db.select(db.localHazardZones).get();
    expect(rows, isEmpty);
  });
}
