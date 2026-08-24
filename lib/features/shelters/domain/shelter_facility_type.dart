/// The four resource categories the blueprint names explicitly for M15
/// ("medical/food/transport/rescue resources"). Stored as a JSON list of
/// [storageValue]s in [LocalShelters.facilitiesJson] — the same column
/// M10's relocation engine already reads to score candidate shelters, so
/// formalizing the vocabulary here doesn't require a schema change.
enum ShelterFacilityType {
  medical,
  food,
  transport,
  rescue;

  String get storageValue => switch (this) {
    ShelterFacilityType.medical => 'medical',
    ShelterFacilityType.food => 'food',
    ShelterFacilityType.transport => 'transport',
    ShelterFacilityType.rescue => 'rescue',
  };

  String get label => switch (this) {
    ShelterFacilityType.medical => 'Medical',
    ShelterFacilityType.food => 'Food',
    ShelterFacilityType.transport => 'Transport',
    ShelterFacilityType.rescue => 'Rescue',
  };

  static ShelterFacilityType? fromStorageValue(String value) {
    for (final type in ShelterFacilityType.values) {
      if (type.storageValue == value) return type;
    }
    return null;
  }
}
