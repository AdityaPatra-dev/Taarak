import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/location/administrative_context.dart';
import 'package:taarak/core/location/geo_tag_service.dart';
import 'package:taarak/core/location/gps_fix.dart';
import 'package:taarak/core/location/location_permission_status.dart';
import 'package:taarak/core/location/location_service.dart';
import 'package:taarak/core/repository/result.dart';

class _FakeLocationService implements LocationService {
  final Result<GpsFix> fixResult;

  _FakeLocationService(this.fixResult);

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<Result<GpsFix>> getCurrentFix() async => fixResult;
}

class _RecordingContextResolver implements AdministrativeContextResolver {
  int callCount = 0;

  @override
  Future<AdministrativeContext?> resolve(double latitude, double longitude) async {
    callCount++;
    return const AdministrativeContext(id: 'region-1', name: 'Test Region');
  }
}

void main() {
  test('captureGeoTag attaches administrative context to a successful fix', () async {
    final fix = GpsFix(
      latitude: 12.9,
      longitude: 77.6,
      accuracyMeters: 8,
      capturedAt: DateTime.utc(2026, 1, 1),
    );
    final resolver = _RecordingContextResolver();
    final service = GeoTagService(
      locationService: _FakeLocationService(Result.success(fix)),
      contextResolver: resolver,
    );

    final result = await service.captureGeoTag();

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.fix, fix);
    expect(result.dataOrNull?.administrativeContext?.name, 'Test Region');
    expect(resolver.callCount, 1);
  });

  test('captureGeoTag propagates a location failure without resolving context', () async {
    final resolver = _RecordingContextResolver();
    final service = GeoTagService(
      locationService: _FakeLocationService(
        const Result.failure(LocationFailure('Location permission not granted')),
      ),
      contextResolver: resolver,
    );

    final result = await service.captureGeoTag();

    expect(result.isFailure, isTrue);
    result.when(
      success: (_) => fail('expected failure'),
      failure: (failure) => expect(failure, isA<LocationFailure>()),
    );
    expect(resolver.callCount, 0);
  });
}
