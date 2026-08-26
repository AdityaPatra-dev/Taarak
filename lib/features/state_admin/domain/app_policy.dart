/// State/Admin's ([Permission.managePolicyConfiguration]) configurable
/// values — starting with the two most concretely hardcoded options in
/// the app: how long a broadcast alert stays valid, and how large a
/// hazard zone's affected radius can be marked.
class AppPolicy {
  final List<Duration> alertValidityOptions;
  final List<double> hazardRadiusOptionsMeters;

  const AppPolicy({
    required this.alertValidityOptions,
    required this.hazardRadiusOptionsMeters,
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

    return AppPolicy(
      alertValidityOptions: validityHours == null || validityHours.isEmpty
          ? defaults.alertValidityOptions
          : [for (final hours in validityHours) Duration(hours: hours)],
      hazardRadiusOptionsMeters: radii == null || radii.isEmpty
          ? defaults.hazardRadiusOptionsMeters
          : radii,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'alertValidityHours': [
      for (final duration in alertValidityOptions) duration.inHours,
    ],
    'hazardRadiusMeters': hazardRadiusOptionsMeters,
  };
}
