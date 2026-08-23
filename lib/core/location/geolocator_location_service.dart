import 'package:geolocator/geolocator.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/location/gps_fix.dart';
import 'package:taarak/core/location/location_permission_status.dart';
import 'package:taarak/core/location/location_service.dart';
import 'package:taarak/core/logging/app_logger.dart';
import 'package:taarak/core/repository/result.dart';

class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }
    return _mapPermission(await Geolocator.checkPermission());
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return _mapPermission(permission);
  }

  @override
  Future<Result<GpsFix>> getCurrentFix() async {
    final status = await checkPermission();
    if (status == LocationPermissionStatus.serviceDisabled) {
      return const Result.failure(
        LocationFailure('Location services are turned off'),
      );
    }
    if (status != LocationPermissionStatus.granted) {
      return const Result.failure(
        LocationFailure('Location permission not granted'),
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return Result.success(
        GpsFix(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
          capturedAt: position.timestamp,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get current position', error, stackTrace);
      return const Result.failure(LocationFailure());
    }
  }

  LocationPermissionStatus _mapPermission(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse => LocationPermissionStatus.granted,
        LocationPermission.deniedForever =>
          LocationPermissionStatus.deniedForever,
        LocationPermission.denied ||
        LocationPermission.unableToDetermine =>
          LocationPermissionStatus.denied,
      };
}
