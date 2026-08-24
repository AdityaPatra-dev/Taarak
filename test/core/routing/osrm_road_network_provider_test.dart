import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/routing/osrm_road_network_provider.dart';

class _FakeNetworkInfo implements NetworkInfo {
  bool connected;
  _FakeNetworkInfo({this.connected = true});

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();
}

/// A [Dio] wired to resolve/reject every request from a script instead of
/// making a real network call — no live OSRM traffic in tests.
Dio scriptedDio(void Function(RequestOptions options, RequestInterceptorHandler handler) onRequest) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  return dio;
}

void main() {
  const origin = LatLng(12.9716, 77.5946);
  const destination = LatLng(12.98, 77.60);

  Map<String, dynamic> okResponse({
    List<List<double>> coordinates = const [
      [77.5946, 12.9716],
      [77.595, 12.975],
      [77.60, 12.98],
    ],
    double distance = 950.5,
    double duration = 180.2,
  }) => {
    'code': 'Ok',
    'routes': [
      {
        'geometry': {'coordinates': coordinates},
        'distance': distance,
        'duration': duration,
      },
    ],
  };

  test(
    'FIX ROUTING SO ROUTES REPRESENT ACTUAL ROADS — the acceptance criterion: a '
    'successful OSRM response decodes into real, ordered lat/lng points',
    () async {
      final dio = scriptedDio((options, handler) {
        handler.resolve(Response(requestOptions: options, statusCode: 200, data: okResponse()));
      });
      final provider = OsrmRoadNetworkProvider(
        networkInfo: _FakeNetworkInfo(),
        dio: dio,
      );

      final result = await provider.fetchRoute(origin: origin, destination: destination);

      expect(result.isSuccess, isTrue);
      final route = result.dataOrNull!;
      expect(route.points, [
        const LatLng(12.9716, 77.5946),
        const LatLng(12.975, 77.595),
        const LatLng(12.98, 77.60),
      ]);
      expect(route.distanceMeters, 950.5);
      expect(route.etaSeconds, 180); // rounded from 180.2
    },
  );

  test('coordinates with whole-number values (decoded as int by JSON) are handled safely', () async {
    final dio = scriptedDio((options, handler) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: okResponse(
            coordinates: const [
              [78, 13], // whole numbers -> Dart's json decoder gives int, not double
              [79, 14],
            ],
          ),
        ),
      );
    });
    final provider = OsrmRoadNetworkProvider(networkInfo: _FakeNetworkInfo(), dio: dio);

    final result = await provider.fetchRoute(origin: origin, destination: destination);

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull!.points, [const LatLng(13, 78), const LatLng(14, 79)]);
  });

  test('offline: never even attempts the request', () async {
    var requested = false;
    final dio = scriptedDio((options, handler) {
      requested = true;
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: okResponse()));
    });
    final provider = OsrmRoadNetworkProvider(
      networkInfo: _FakeNetworkInfo(connected: false),
      dio: dio,
    );

    final result = await provider.fetchRoute(origin: origin, destination: destination);

    expect(result.isFailure, isTrue);
    expect(requested, isFalse);
  });

  test('a non-Ok OSRM response code fails cleanly', () async {
    final dio = scriptedDio((options, handler) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'code': 'NoRoute', 'routes': []},
        ),
      );
    });
    final provider = OsrmRoadNetworkProvider(networkInfo: _FakeNetworkInfo(), dio: dio);

    final result = await provider.fetchRoute(origin: origin, destination: destination);

    expect(result.isFailure, isTrue);
  });

  test('an empty routes list fails cleanly', () async {
    final dio = scriptedDio((options, handler) {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: {'code': 'Ok', 'routes': []}),
      );
    });
    final provider = OsrmRoadNetworkProvider(networkInfo: _FakeNetworkInfo(), dio: dio);

    final result = await provider.fetchRoute(origin: origin, destination: destination);

    expect(result.isFailure, isTrue);
  });

  test('a DioException (network error, timeout) fails cleanly rather than throwing', () async {
    final dio = scriptedDio((options, handler) {
      handler.reject(
        DioException(requestOptions: options, type: DioExceptionType.connectionTimeout),
      );
    });
    final provider = OsrmRoadNetworkProvider(networkInfo: _FakeNetworkInfo(), dio: dio);

    final result = await provider.fetchRoute(origin: origin, destination: destination);

    expect(result.isFailure, isTrue);
  });

  test('a malformed response body (unexpected shape) fails cleanly rather than throwing', () async {
    final dio = scriptedDio((options, handler) {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: 'not even json'),
      );
    });
    final provider = OsrmRoadNetworkProvider(networkInfo: _FakeNetworkInfo(), dio: dio);

    final result = await provider.fetchRoute(origin: origin, destination: destination);

    expect(result.isFailure, isTrue);
  });
}
