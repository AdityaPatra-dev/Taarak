import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_environmental_observation_repository.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/environmental/application/environmental_data_source.dart';
import 'package:taarak/features/environmental/application/environmental_risk_engine.dart';
import 'package:taarak/features/environmental/domain/environmental_risk_adjustment.dart';

/// Orchestrates M24: pulls readings from [[EnvironmentalDataSource]],
/// caches them locally (one current row per habitation/parameter pair —
/// "connected mode uses richer... data; offline mode retains cached...
/// data"), and computes the risk adjustment M07 layers on top.
class EnvironmentalDataService {
  final EnvironmentalDataSource _dataSource;
  final LocalEnvironmentalObservationRepository _repository;
  final EnvironmentalRiskEngine _engine;

  EnvironmentalDataService({
    required EnvironmentalDataSource dataSource,
    required LocalEnvironmentalObservationRepository repository,
    EnvironmentalRiskEngine? engine,
  }) : _dataSource = dataSource,
       _repository = repository,
       _engine = engine ?? EnvironmentalRiskEngine();

  static String _rowId(String habitationId, String parameterStorageValue) =>
      '$habitationId-$parameterStorageValue';

  Future<List<LocalEnvironmentalObservation>> refreshForHabitation({
    required String habitationId,
    required double latitude,
    required double longitude,
    DateTime? now,
  }) async {
    final occurredAt = now ?? DateTime.now();
    final readings = await _dataSource.fetchReadings(
      latitude: latitude,
      longitude: longitude,
      now: occurredAt,
    );

    final saved = <LocalEnvironmentalObservation>[];
    for (final reading in readings) {
      final existing = await _repository.getById(
        _rowId(habitationId, reading.parameter.storageValue),
      );
      final row = LocalEnvironmentalObservation(
        id: _rowId(habitationId, reading.parameter.storageValue),
        habitationId: habitationId,
        parameter: reading.parameter.storageValue,
        value: reading.value,
        source: reading.source,
        observedAt: reading.observedAt,
        fetchedAt: occurredAt,
        confidence: reading.confidence,
        version: (existing.dataOrNull?.version ?? 0) + 1,
      );
      final saveResult = await _repository.save(row);
      if (saveResult case Success<LocalEnvironmentalObservation>(:final data)) {
        saved.add(data);
      }
    }
    return saved;
  }

  Future<List<LocalEnvironmentalObservation>> observationsFor(String habitationId) async {
    final result = await _repository.getAll();
    return (result.dataOrNull ?? const [])
        .where((observation) => observation.habitationId == habitationId)
        .toList();
  }

  Future<EnvironmentalRiskAdjustment> adjustmentFor(
    String habitationId, {
    DateTime? now,
  }) async {
    final observations = await observationsFor(habitationId);
    return _engine.evaluate(observations: observations, now: now ?? DateTime.now());
  }
}
