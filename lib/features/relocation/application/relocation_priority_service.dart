import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/features/capacity/application/capacity_assessment_service.dart';
import 'package:taarak/features/capacity/domain/capacity_gap_result.dart';
import 'package:taarak/features/relocation/application/relocation_planning_service.dart';
import 'package:taarak/features/relocation/application/relocation_priority_engine.dart';
import 'package:taarak/features/relocation/domain/relocation_candidate.dart';
import 'package:taarak/features/relocation/domain/relocation_priority_result.dart';
import 'package:taarak/features/risk/application/risk_assessment_service.dart';
import 'package:taarak/features/risk/domain/risk_assessment_result.dart';

/// Orchestrates the priority queue: re-runs M07/M09/M10 for every cached
/// habitation (reusing their existing `assessAllHabitations`/
/// `planForAllHabitations` batch methods directly — nothing new to
/// compute at that layer), then combines each habitation's three results
/// through [RelocationPriorityEngine]. Ranked highest-priority first.
class RelocationPriorityService {
  final LocalHabitationRepository _habitationRepository;
  final RiskAssessmentService _riskAssessmentService;
  final CapacityAssessmentService _capacityAssessmentService;
  final RelocationPlanningService _relocationPlanningService;
  final RelocationPriorityEngine _engine;

  RelocationPriorityService({
    required LocalHabitationRepository habitationRepository,
    required RiskAssessmentService riskAssessmentService,
    required CapacityAssessmentService capacityAssessmentService,
    required RelocationPlanningService relocationPlanningService,
    RelocationPriorityEngine? engine,
  }) : _habitationRepository = habitationRepository,
       _riskAssessmentService = riskAssessmentService,
       _capacityAssessmentService = capacityAssessmentService,
       _relocationPlanningService = relocationPlanningService,
       _engine = engine ?? RelocationPriorityEngine();

  Future<List<RelocationPriorityResult>> buildQueue({DateTime? now}) async {
    final habitationsResult = await _habitationRepository.getAll();
    final habitations = habitationsResult.dataOrNull ?? const [];
    if (habitations.isEmpty) return const [];

    final riskResults = await _riskAssessmentService.assessAllHabitations(
      now: now,
    );
    final capacityResults = await _capacityAssessmentService
        .assessAllHabitations(now: now);
    final relocationPlans = await _relocationPlanningService
        .planForAllHabitations(now: now);

    final riskById = <String, RiskAssessmentResult>{
      for (final r in riskResults) r.habitationId: r,
    };
    final capacityById = <String, CapacityGapResult>{
      for (final c in capacityResults) c.habitationId: c,
    };
    final planById = <String, RelocationPlan>{
      for (final p in relocationPlans) p.habitationId: p,
    };

    final queue = <RelocationPriorityResult>[];
    for (final habitation in habitations) {
      final risk = riskById[habitation.id];
      final capacity = capacityById[habitation.id];
      final plan = planById[habitation.id];
      // A habitation missing any of the three assessments (e.g. a
      // transient failure in one engine — see each service's own
      // best-effort batch behavior) is skipped rather than shown with a
      // fabricated score; the queue never invents a priority for data it
      // doesn't actually have.
      if (risk == null || capacity == null || plan == null) continue;

      queue.add(
        _engine.assess(
          habitation: habitation,
          risk: risk,
          capacity: capacity,
          relocationPlan: plan,
          now: now,
        ),
      );
    }

    queue.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return queue;
  }
}
