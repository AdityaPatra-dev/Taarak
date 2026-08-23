import 'package:taarak/core/location/administrative_context.dart';
import 'package:taarak/core/location/gps_fix.dart';

/// What actually gets attached to a citizen/responder report (M12) so it's
/// "reliably geotagged" — the fix plus whatever administrative context
/// could be resolved for it.
class GeoTag {
  final GpsFix fix;
  final AdministrativeContext? administrativeContext;

  const GeoTag({required this.fix, this.administrativeContext});

  Map<String, dynamic> toJson() => {
    'latitude': fix.latitude,
    'longitude': fix.longitude,
    'accuracyMeters': fix.accuracyMeters,
    'capturedAt': fix.capturedAt.toIso8601String(),
    if (administrativeContext != null)
      'administrativeRegionId': administrativeContext!.id,
    if (administrativeContext != null)
      'administrativeRegionName': administrativeContext!.name,
  };
}
