/// State/Admin's ([Permission.managePolicyConfiguration]) configurable
/// values — starting with the two most concretely hardcoded options in
/// the app: how long a broadcast alert stays valid, and how large a
/// hazard zone's affected radius can be marked.
class AppPolicy {
  final List<Duration> alertValidityOptions;
  final List<double> hazardRadiusOptionsMeters;

  /// Automatic hazard-zone engine thresholds — disaster-response judgment
  /// calls ("how sure does the engine need to be before it warns/stands
  /// down"), same category as [hazardRadiusOptionsMeters], so they live
  /// here rather than in [TechnicalConfig]. See
  /// `decideAutoHazardAction` (hazard_automation module) for how these
  /// are used.
  final double autoHazardCreateThreshold;
  final double autoHazardDeleteThreshold;
  final int autoHazardDeleteConfirmationPolls;
  final double autoHazardRadiusMeters;

  const AppPolicy({
    required this.alertValidityOptions,
    required this.hazardRadiusOptionsMeters,
    this.autoHazardCreateThreshold = 0.6,
    this.autoHazardDeleteThreshold = 0.35,
    this.autoHazardDeleteConfirmationPolls = 2,
    this.autoHazardRadiusMeters = 1000.0,
  });

  static const defaults = AppPolicy(
    alertValidityOptions: [
      Duration(hours: 1),
      Duration(hours: 6),
      Duration(hours: 24),
    ],
    hazardRadiusOptionsMeters: [200, 500, 1000, 2000, 5000],
  );

  factory AppPolicy.fromFirestore(Map<String, dynamic> data) {
    final validityHours = (data['alertValidityHours'] as List?)
        ?.map((v) => (v as num).toInt())
        .toList();
    final radii = (data['hazardRadiusMeters'] as List?)
        ?.map((v) => (v as num).toDouble())
        .toList();
    final createThreshold = (data['autoHazardCreateThreshold'] as num?)?.toDouble();
    final deleteThreshold = (data['autoHazardDeleteThreshold'] as num?)?.toDouble();
    final deleteConfirmationPolls = (data['autoHazardDeleteConfirmationPolls'] as num?)?.toInt();
    final autoRadius = (data['autoHazardRadiusMeters'] as num?)?.toDouble();

    return AppPolicy(
      alertValidityOptions: validityHours == null || validityHours.isEmpty
          ? defaults.alertValidityOptions
          : [for (final hours in validityHours) Duration(hours: hours)],
      hazardRadiusOptionsMeters: radii == null || radii.isEmpty
          ? defaults.hazardRadiusOptionsMeters
          : radii,
      autoHazardCreateThreshold:
          createThreshold == null || createThreshold < 0 || createThreshold > 1
          ? defaults.autoHazardCreateThreshold
          : createThreshold,
      autoHazardDeleteThreshold:
          deleteThreshold == null || deleteThreshold < 0 || deleteThreshold > 1
          ? defaults.autoHazardDeleteThreshold
          : deleteThreshold,
      autoHazardDeleteConfirmationPolls:
          deleteConfirmationPolls == null || deleteConfirmationPolls < 1
          ? defaults.autoHazardDeleteConfirmationPolls
          : deleteConfirmationPolls,
      autoHazardRadiusMeters: autoRadius == null || autoRadius <= 0
          ? defaults.autoHazardRadiusMeters
          : autoRadius,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'alertValidityHours': [
      for (final duration in alertValidityOptions) duration.inHours,
    ],
    'hazardRadiusMeters': hazardRadiusOptionsMeters,
    'autoHazardCreateThreshold': autoHazardCreateThreshold,
    'autoHazardDeleteThreshold': autoHazardDeleteThreshold,
    'autoHazardDeleteConfirmationPolls': autoHazardDeleteConfirmationPolls,
    'autoHazardRadiusMeters': autoHazardRadiusMeters,
  };
}
