import 'dart:convert';

import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_risk_assessment_repository.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/environmental/application/environmental_data_service.dart';
import 'package:taarak/features/environmental/application/risk_environmental_merge.dart';
import 'package:taarak/features/risk/application/risk_engine.dart';
import 'package:taarak/features/risk/domain/risk_assessment_result.dart';
import 'package:taarak/features/risk/domain/vulnerability_provider.dart';

/// Orchestrates M07: pulls a habitation, the current hazard zones and a
/// vulnerability index, runs [RiskEngine], and persists the result — one
/// current assessment per habitation (see the table's doc comment).
///
/// M24 layers in as an optional collaborator: when
/// [[EnvironmentalDataService]] is supplied, its cached observations for
/// this habitation nudge the score via [mergeEnvironmentalAdjustment]
/// after the base hazard/vulnerability assessment runs; when it isn't,
/// behavior is identical to before M24 existed.
class RiskAssessmentService {
  final LocalHabitationRepository _habitationRepository;
  final LocalHazardZoneRepository _hazardZoneRepository;
  final LocalRiskAssessmentRepository _assessmentRepository;
  final VulnerabilityProvider _vulnerabilityProvider;
  final RiskEngine _engine;
  final EnvironmentalDataService? _environmentalDataService;

  RiskAssessmentService({
    required LocalHabitationRepository habitationRepository,
    required LocalHazardZoneRepository hazardZoneRepository,
    required LocalRiskAssessmentRepository assessmentRepository,
    required VulnerabilityProvider vulnerabilityProvider,
    RiskEngine? engine,
    EnvironmentalDataService? environmentalDataService,
  }) : _habitationRepository = habitationRepository,
       _hazardZoneRepository = hazardZoneRepository,
       _assessmentRepository = assessmentRepository,
       _vulnerabilityProvider = vulnerabilityProvider,
       _engine = engine ?? RiskEngine(),
       _environmentalDataService = environmentalDataService;

  Future<Result<RiskAssessmentResult>> assessHabitation(
    String habitationId, {
    DateTime? now,
  }) async {
    final habitationResult = await _habitationRepository.getById(habitationId);
    if (habitationResult case Failed<LocalHabitation>(:final failure)) {
      return Result.failure(failure);
    }
    final habitation = habitationResult.dataOrNull!;

    final hazardZonesResult = await _hazardZoneRepository.getAll();
    if (hazardZonesResult case Failed<List<LocalHazardZone>>(:final failure)) {
      return Result.failure(failure);
    }
    final hazardZones = hazardZonesResult.dataOrNull!;

    final vulnerabilityIndex = await _vulnerabilityProvider.vulnerabilityIndexFor(
      habitationId,
    );

    final baseAssessment = _engine.assess(
      habitation: habitation,
      hazardZones: hazardZones,
      vulnerabilityIndex: vulnerabilityIndex,
      now: now,
    );

    final environmentalService = _environmentalDataService;
    final assessment = environmentalService == null
        ? baseAssessment
        : mergeEnvironmentalAdjustment(
            baseAssessment,
            await environmentalService.adjustmentFor(habitationId, now: now),
          );

    final existing = await _assessmentRepository.getById(habitationId);
    final nextVersion = (existing.dataOrNull?.version ?? 0) + 1;

    final saveResult = await _assessmentRepository.save(
      LocalRiskAssessment(
        habitationId: habitationId,
        hazardExposure: assessment.hazardExposure,
        vulnerabilityIndex: assessment.vulnerabilityIndex,
        riskScore: assessment.riskScore,
        riskClass: assessment.riskClass.name,
        modelVersion: assessment.modelVersion,
        contributingHazardZoneIdsJson: jsonEncode(
          assessment.contributingHazardZoneIds,
        ),
        environmentalAdjustment: assessment.environmentalAdjustment,
        environmentalProvenanceJson: jsonEncode([
          for (final observation in assessment.environmentalProvenance)
            {
              'parameter': observation.parameter,
              'value': observation.value,
              'source': observation.source,
              'observedAt': observation.observedAt.toIso8601String(),
            },
        ]),
        assessedAt: assessment.assessedAt,
        version: nextVersion,
      ),
    );
    if (saveResult case Failed<LocalRiskAssessment>(:final failure)) {
      return Result.failure(failure);
    }

    return Result.success(assessment);
  }

  /// Assesses every currently cached habitation. Failures for individual
  /// habitations are logged (via the repository's own error guard) and
  /// skipped rather than aborting the whole batch.
  Future<List<RiskAssessmentResult>> assessAllHabitations({DateTime? now}) async {
    final habitationsResult = await _habitationRepository.getAll();
    final habitations = habitationsResult.dataOrNull ?? const [];

    final results = <RiskAssessmentResult>[];
    for (final habitation in habitations) {
      final result = await assessHabitation(habitation.id, now: now);
      if (result case Success<RiskAssessmentResult>(:final data)) {
        results.add(data);
      }
    }
    return results;
  }
}
