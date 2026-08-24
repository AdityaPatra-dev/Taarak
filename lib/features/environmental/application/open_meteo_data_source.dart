import 'package:dio/dio.dart';
import 'package:taarak/core/logging/app_logger.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/features/environmental/application/environmental_data_source.dart';
import 'package:taarak/features/environmental/domain/environmental_parameter.dart';

/// Real [EnvironmentalDataSource], backed by Open-Meteo — free, no API
/// key, good coverage for India. Replaces [[DemoEnvironmentalDataSource]]
/// as the default (that stays in the codebase as a fallback/test double).
///
/// Open-Meteo has no river-gauge product, so [EnvironmentalParameter.riverLevel]
/// is never returned here — an honest gap rather than a fabricated
/// reading. Rainfall comes from its daily precipitation sum (the most
/// recently *completed* 24h period); soil moisture from its hourly
/// shallow-depth model, picking the entry closest to now.
class OpenMeteoDataSource implements EnvironmentalDataSource {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  final Dio _dio;
  final NetworkInfo _networkInfo;

  OpenMeteoDataSource({required NetworkInfo networkInfo, Dio? dio})
    : _networkInfo = networkInfo,
      _dio = dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  @override
  Future<List<RawEnvironmentalReading>> fetchReadings({
    required double latitude,
    required double longitude,
    DateTime? now,
  }) async {
    if (!await _networkInfo.isConnected) return const [];

    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'daily': 'precipitation_sum',
          'hourly': 'soil_moisture_0_to_1cm',
          'past_days': 1,
          'forecast_days': 1,
          'timezone': 'UTC',
        },
      );
      return _parse(response.data, now ?? DateTime.now());
    } on DioException catch (error) {
      AppLogger.warning('Open-Meteo request failed: ${error.message}');
      return const [];
    } catch (error, stackTrace) {
      AppLogger.error('Could not parse Open-Meteo response', error, stackTrace);
      return const [];
    }
  }

  List<RawEnvironmentalReading> _parse(dynamic data, DateTime now) {
    if (data is! Map<String, dynamic>) return const [];
    final readings = <RawEnvironmentalReading>[];

    final rainfall = _parseRainfall(data['daily']);
    if (rainfall != null) readings.add(rainfall);

    final soilMoisture = _parseSoilMoisture(data['hourly'], now);
    if (soilMoisture != null) readings.add(soilMoisture);

    return readings;
  }

  /// [daily.precipitation_sum]'s first entry is yesterday's total (since
  /// the request asks for `past_days=1`) — the most recently *completed*
  /// 24-hour window, not today's still-accumulating partial total.
  RawEnvironmentalReading? _parseRainfall(dynamic daily) {
    if (daily is! Map<String, dynamic>) return null;
    final times = daily['time'];
    final sums = daily['precipitation_sum'];
    if (times is! List || sums is! List || times.isEmpty || sums.isEmpty) return null;

    // `timezone=UTC` was requested, so this date-only string is a UTC
    // calendar day — parsed explicitly as UTC (appending 'Z') rather than
    // left to default to this device's local timezone.
    final dayDate = DateTime.tryParse('${times.first}T00:00:00Z');
    final sum = sums.first;
    if (dayDate == null || sum == null) return null;

    return RawEnvironmentalReading(
      parameter: EnvironmentalParameter.rainfall24h,
      value: (sum as num).toDouble(),
      source: 'Open-Meteo',
      observedAt: dayDate.add(const Duration(hours: 23, minutes: 59)),
      confidence: 0.75,
    );
  }

  /// Picks the hourly soil-moisture entry closest to (but not after) now.
  RawEnvironmentalReading? _parseSoilMoisture(dynamic hourly, DateTime now) {
    if (hourly is! Map<String, dynamic>) return null;
    final times = hourly['time'];
    final values = hourly['soil_moisture_0_to_1cm'];
    if (times is! List || values is! List || times.isEmpty || values.isEmpty) return null;

    DateTime? bestTime;
    num? bestValue;
    for (var i = 0; i < times.length && i < values.length; i++) {
      // Same reasoning as above: `timezone=UTC` was requested, so these
      // hourly timestamps are UTC clock time, parsed explicitly as such.
      final time = DateTime.tryParse('${times[i]}Z');
      final value = values[i];
      if (time == null || value == null || time.isAfter(now)) continue;
      if (bestTime == null || time.isAfter(bestTime)) {
        bestTime = time;
        bestValue = value as num;
      }
    }
    if (bestTime == null || bestValue == null) return null;

    return RawEnvironmentalReading(
      parameter: EnvironmentalParameter.soilMoisture,
      value: bestValue.toDouble(),
      source: 'Open-Meteo',
      observedAt: bestTime,
      confidence: 0.6,
    );
  }
}
