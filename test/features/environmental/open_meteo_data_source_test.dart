import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/features/environmental/application/open_meteo_data_source.dart';
import 'package:taarak/features/environmental/domain/environmental_parameter.dart';

class _FakeNetworkInfo implements NetworkInfo {
  bool connected;
  _FakeNetworkInfo({this.connected = true});

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();
}

Dio scriptedDio(void Function(RequestOptions options, RequestInterceptorHandler handler) onRequest) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  return dio;
}

void main() {
  final now = DateTime.utc(2026, 1, 2, 10); // 10:00 UTC on the "forecast_days" day

  Map<String, dynamic> okResponse({
    List<String> dailyTimes = const ['2026-01-01', '2026-01-02'],
    List<num> precipitationSums = const [42.5, 3.0],
    List<String> hourlyTimes = const [
      '2026-01-02T08:00',
      '2026-01-02T09:00',
      '2026-01-02T10:00',
      '2026-01-02T11:00', // in the future relative to `now`
    ],
    List<num> soilMoisture = const [0.20, 0.22, 0.25, 0.30],
  }) => {
    'daily': {'time': dailyTimes, 'precipitation_sum': precipitationSums},
    'hourly': {'time': hourlyTimes, 'soil_moisture_0_to_1cm': soilMoisture},
  };

  test(
    'REPLACE FAKE ENVIRONMENTAL DATA WITH A REAL SOURCE — the acceptance criterion: a '
    'real Open-Meteo response produces rainfall and soil-moisture readings',
    () async {
      final dio = scriptedDio((options, handler) {
        handler.resolve(Response(requestOptions: options, statusCode: 200, data: okResponse()));
      });
      final source = OpenMeteoDataSource(networkInfo: _FakeNetworkInfo(), dio: dio);

      final readings = await source.fetchReadings(latitude: 12.97, longitude: 77.59, now: now);

      expect(readings.map((r) => r.parameter).toSet(), {
        EnvironmentalParameter.rainfall24h,
        EnvironmentalParameter.soilMoisture,
      });
      expect(readings.every((r) => r.source == 'Open-Meteo'), isTrue);
    },
  );

  test('river level is never returned — Open-Meteo has no gauge data for it', () async {
    final dio = scriptedDio((options, handler) {
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: okResponse()));
    });
    final source = OpenMeteoDataSource(networkInfo: _FakeNetworkInfo(), dio: dio);

    final readings = await source.fetchReadings(latitude: 12.97, longitude: 77.59, now: now);

    expect(readings.any((r) => r.parameter == EnvironmentalParameter.riverLevel), isFalse);
  });

  test('rainfall uses the most recently completed 24h day, not the still-accumulating one', () async {
    final dio = scriptedDio((options, handler) {
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: okResponse()));
    });
    final source = OpenMeteoDataSource(networkInfo: _FakeNetworkInfo(), dio: dio);

    final readings = await source.fetchReadings(latitude: 12.97, longitude: 77.59, now: now);

    final rainfall = readings.firstWhere((r) => r.parameter == EnvironmentalParameter.rainfall24h);
    expect(rainfall.value, 42.5); // yesterday's total, not today's 3.0
  });

  test('soil moisture picks the hourly entry closest to now, never a future one', () async {
    final dio = scriptedDio((options, handler) {
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: okResponse()));
    });
    final source = OpenMeteoDataSource(networkInfo: _FakeNetworkInfo(), dio: dio);

    final readings = await source.fetchReadings(latitude: 12.97, longitude: 77.59, now: now);

    final soil = readings.firstWhere((r) => r.parameter == EnvironmentalParameter.soilMoisture);
    expect(soil.value, 0.25); // the 10:00 entry, not the 11:00 (future) one
    expect(soil.observedAt, DateTime.utc(2026, 1, 2, 10));
  });

  test('offline: never even attempts the request, returns an empty list', () async {
    var requested = false;
    final dio = scriptedDio((options, handler) {
      requested = true;
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: okResponse()));
    });
    final source = OpenMeteoDataSource(networkInfo: _FakeNetworkInfo(connected: false), dio: dio);

    final readings = await source.fetchReadings(latitude: 12.97, longitude: 77.59, now: now);

    expect(readings, isEmpty);
    expect(requested, isFalse);
  });

  test(
    'a network failure returns an empty list rather than throwing — a caller can '
    'keep using whatever was cached before',
    () async {
      final dio = scriptedDio((options, handler) {
        handler.reject(
          DioException(requestOptions: options, type: DioExceptionType.connectionTimeout),
        );
      });
      final source = OpenMeteoDataSource(networkInfo: _FakeNetworkInfo(), dio: dio);

      final readings = await source.fetchReadings(latitude: 12.97, longitude: 77.59, now: now);

      expect(readings, isEmpty);
    },
  );

  test('a malformed response body returns an empty list rather than throwing', () async {
    final dio = scriptedDio((options, handler) {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: 'not even json'),
      );
    });
    final source = OpenMeteoDataSource(networkInfo: _FakeNetworkInfo(), dio: dio);

    final readings = await source.fetchReadings(latitude: 12.97, longitude: 77.59, now: now);

    expect(readings, isEmpty);
  });

  test('missing daily/hourly blocks degrade to whichever reading is still parseable', () async {
    final dio = scriptedDio((options, handler) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'hourly': {
              'time': ['2026-01-02T10:00'],
              'soil_moisture_0_to_1cm': [0.4],
            },
          },
        ),
      );
    });
    final source = OpenMeteoDataSource(networkInfo: _FakeNetworkInfo(), dio: dio);

    final readings = await source.fetchReadings(latitude: 12.97, longitude: 77.59, now: now);

    expect(readings, hasLength(1));
    expect(readings.single.parameter, EnvironmentalParameter.soilMoisture);
  });
}
