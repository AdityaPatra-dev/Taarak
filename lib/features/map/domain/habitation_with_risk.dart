import 'package:taarak/core/database/app_database.dart';

/// A habitation paired with its latest risk assessment, if one has been
/// run yet — the shape the map's habitation layer actually needs.
class HabitationWithRisk {
  final LocalHabitation habitation;
  final LocalRiskAssessment? assessment;

  const HabitationWithRisk({required this.habitation, this.assessment});
}
