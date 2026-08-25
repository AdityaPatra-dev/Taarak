import 'dart:convert';

import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/hazards/application/hazard_normalizer.dart';
import 'package:taarak/features/hazards/domain/normalized_hazard_zone.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';

/// The front door for getting hazard data into the local cache: normalize,
/// then persist. Anything that produces hazard signals — a real backend
/// sync (M17), an official's manual entry, a dev seeder — goes through
/// this rather than writing to [LocalHazardZoneRepository] directly, so
/// nothing bypasses normalization.
class HazardIngestionService {
  final HazardNormalizer _normalizer;
  final LocalHazardZoneRepository _repository;
  final SyncQueueDao? _syncQueueDao;

  HazardIngestionService({
    required HazardNormalizer normalizer,
    required LocalHazardZoneRepository repository,
    SyncQueueDao? syncQueueDao,
  }) : _normalizer = normalizer,
       _repository = repository,
       _syncQueueDao = syncQueueDao;

  Future<Result<LocalHazardZone>> ingest({
    required String id,
    required RawHazardObservation observation,
    DateTime? now,
  }) async {
    final normalizedResult = _normalizer.normalize(observation, now: now);
    if (normalizedResult case Failed<NormalizedHazardZone>(:final failure)) {
      return Result.failure(failure);
    }
    final normalized = normalizedResult.dataOrNull!;

    // Version increments on re-ingestion of the same id, so a repeated
    // observation for an already-known zone is traceable as an update
    // rather than silently overwriting it — and is exactly what M17's
    // sync transport uses to resolve a push conflict against another
    // device's ingestion of the same zone.
    final existing = await _repository.getById(id);
    final nextVersion = (existing.dataOrNull?.version ?? 0) + 1;

    final row = LocalHazardZone(
      id: id,
      hazardType: normalized.hazardType.storageValue,
      severity: normalized.severity.storageValue,
      geometryJson: encodePolygonPoints(normalized.boundaryPoints),
      source: normalized.source,
      observedAt: normalized.observedAt,
      confidence: normalized.confidence,
      updatedAt: now ?? DateTime.now(),
      version: nextVersion,
    );
    final saveResult = await _repository.save(row);
    if (saveResult case Success<LocalHazardZone>()) {
      await _syncQueueDao?.enqueue(
        entityTable: 'local_hazard_zones',
        entityId: row.id,
        operation: 'create',
        payloadJson: jsonEncode({
          'hazardType': row.hazardType,
          'severity': row.severity,
          'geometryJson': row.geometryJson,
          'source': row.source,
          'observedAt': row.observedAt.toIso8601String(),
          'confidence': row.confidence,
          'version': row.version,
        }),
      );
    }
    return saveResult;
  }
}
