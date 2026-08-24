import 'package:taarak/core/database/app_database.dart';

/// A habitation paired with its latest risk (M07), carrying-capacity (M09)
/// and relocation (M10) assessments, if they've been run yet — the shape
/// the map's habitation layer actually needs. Vulnerability (M08) isn't
/// included separately since it's already folded into the risk
/// assessment's `vulnerabilityIndex`.
class HabitationOverview {
  final LocalHabitation habitation;
  final LocalRiskAssessment? riskAssessment;
  final LocalCapacityAssessment? capacityAssessment;
  final LocalRelocationPlan? relocationPlan;

  const HabitationOverview({
    required this.habitation,
    this.riskAssessment,
    this.capacityAssessment,
    this.relocationPlan,
  });
}
