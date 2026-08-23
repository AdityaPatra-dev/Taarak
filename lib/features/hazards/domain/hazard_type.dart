/// Hazard types the normalizer currently accepts. Per the blueprint's "What
/// Not to Build First": "make landslide + flood strong and keep the schema
/// extensible" — a new value here plus a new [[HazardNormalizer]] case is
/// the whole extension path when a third hazard type is added.
enum HazardType {
  landslide,
  flood;

  static HazardType? fromStorageValue(String value) => switch (value) {
    'landslide' => HazardType.landslide,
    'flood' => HazardType.flood,
    _ => null,
  };

  String get storageValue => name;
}
