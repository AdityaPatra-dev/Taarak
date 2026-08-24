/// The environmental signals M24 tracks — a small, deliberately fixed set
/// rather than an open string, so [[EnvironmentalRiskEngine]]'s
/// normalization (what counts as "concerning" for each) is exhaustive and
/// type-checked instead of falling through a default case.
enum EnvironmentalParameter {
  rainfall24h,
  riverLevel,
  soilMoisture;

  String get storageValue => switch (this) {
    EnvironmentalParameter.rainfall24h => 'rainfall_24h',
    EnvironmentalParameter.riverLevel => 'river_level',
    EnvironmentalParameter.soilMoisture => 'soil_moisture',
  };

  String get label => switch (this) {
    EnvironmentalParameter.rainfall24h => '24h rainfall',
    EnvironmentalParameter.riverLevel => 'River level',
    EnvironmentalParameter.soilMoisture => 'Soil moisture',
  };

  String get unit => switch (this) {
    EnvironmentalParameter.rainfall24h => 'mm',
    EnvironmentalParameter.riverLevel => 'm',
    EnvironmentalParameter.soilMoisture => 'index',
  };

  static EnvironmentalParameter? fromStorageValue(String value) {
    for (final parameter in EnvironmentalParameter.values) {
      if (parameter.storageValue == value) return parameter;
    }
    return null;
  }
}
