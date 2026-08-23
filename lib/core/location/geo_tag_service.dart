import 'package:taarak/core/location/administrative_context.dart';
import 'package:taarak/core/location/geo_tag.dart';
import 'package:taarak/core/location/gps_fix.dart';
import 'package:taarak/core/location/location_service.dart';
import 'package:taarak/core/repository/result.dart';

/// The one call a report/SOS/"I am safe" feature needs to reliably geotag
/// itself: capture a fix, then attach whatever administrative context is
/// resolvable for it.
class GeoTagService {
  final LocationService _locationService;
  final AdministrativeContextResolver _contextResolver;

  GeoTagService({
    required LocationService locationService,
    required AdministrativeContextResolver contextResolver,
  }) : _locationService = locationService,
       _contextResolver = contextResolver;

  Future<Result<GeoTag>> captureGeoTag() async {
    final fixResult = await _locationService.getCurrentFix();
    if (fixResult case Failed<GpsFix>(:final failure)) {
      return Result.failure(failure);
    }
    final fix = fixResult.dataOrNull!;
    final context = await _contextResolver.resolve(fix.latitude, fix.longitude);
    return Result.success(GeoTag(fix: fix, administrativeContext: context));
  }
}
