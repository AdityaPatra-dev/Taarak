import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/location/geo_tag.dart';
import 'package:taarak/core/location/location_permission_status.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/core/repository/result.dart';

class LocationStatus {
  final LocationPermissionStatus permission;
  final GeoTag? geoTag;

  const LocationStatus({required this.permission, this.geoTag});
}

final locationStatusProvider =
    AsyncNotifierProvider<LocationStatusController, LocationStatus>(
      LocationStatusController.new,
    );

class LocationStatusController extends AsyncNotifier<LocationStatus> {
  @override
  Future<LocationStatus> build() async {
    final permission = await ref
        .watch(locationServiceProvider)
        .checkPermission();
    return LocationStatus(permission: permission);
  }

  /// Prompts for permission if needed, then captures a fresh geotag.
  /// Returns the [Result] so the screen can show a specific error message
  /// on failure, the same pattern used for login/register.
  Future<Result<GeoTag>> refresh() async {
    final permission = await ref
        .read(locationServiceProvider)
        .requestPermission();
    state = AsyncData(
      LocationStatus(permission: permission, geoTag: state.valueOrNull?.geoTag),
    );

    final result = await ref.read(geoTagServiceProvider).captureGeoTag();
    result.when(
      success: (geoTag) =>
          state = AsyncData(LocationStatus(permission: permission, geoTag: geoTag)),
      failure: (_) {},
    );
    return result;
  }
}
