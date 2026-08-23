/// Which administrative region/habitation a coordinate falls into —
/// the `AdministrativeRegion`/`Habitation` link from blueprint section 8.
class AdministrativeContext {
  final String id;
  final String name;

  const AdministrativeContext({required this.id, required this.name});
}

/// Resolves a coordinate to its administrative context. Real resolution
/// needs habitation/region boundary data that doesn't exist yet (it lands
/// with M05's GIS layers and the Geography backend module) — see
/// [[UnresolvedAdministrativeContextResolver]] for the stand-in used until
/// then.
abstract class AdministrativeContextResolver {
  Future<AdministrativeContext?> resolve(double latitude, double longitude);
}

class UnresolvedAdministrativeContextResolver
    implements AdministrativeContextResolver {
  const UnresolvedAdministrativeContextResolver();

  @override
  Future<AdministrativeContext?> resolve(double latitude, double longitude) async =>
      null;
}
