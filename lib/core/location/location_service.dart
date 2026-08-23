import 'package:taarak/core/location/gps_fix.dart';
import 'package:taarak/core/location/location_permission_status.dart';
import 'package:taarak/core/repository/result.dart';

abstract class LocationService {
  Future<LocationPermissionStatus> checkPermission();

  /// Prompts the OS permission dialog if not already decided. Returns
  /// [LocationPermissionStatus.serviceDisabled] without prompting if
  /// location services are off at the OS level — that can only be fixed
  /// in device settings, not through an in-app prompt.
  Future<LocationPermissionStatus> requestPermission();

  Future<Result<GpsFix>> getCurrentFix();
}
