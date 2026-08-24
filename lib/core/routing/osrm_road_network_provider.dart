import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/logging/app_logger.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/core/routing/road_network_provider.dart';
import 'package:taarak/core/routing/road_route.dart';

/// Real [RoadNetworkProvider] backed by OSRM's public demo routing server.
///
/// That server is explicitly documented (by its own operators) as being
/// for evaluation/demo traffic only, not production load — fine for this
/// app's current stage, but a real deployment should point [baseUrl] at a
/// self-hosted OSRM/Valhalla instance or a commercial Directions API
/// instead. Nothing downstream of [RoadNetworkProvider] needs to change
/// when that swap happens.
class OsrmRoadNetworkProvider implements RoadNetworkProvider {
  static const String defaultBaseUrl = 'https://router.project-osrm.org/route/v1/driving';

  final Dio _dio;
  final NetworkInfo _networkInfo;
  final String _baseUrl;

  OsrmRoadNetworkProvider({
    required NetworkInfo networkInfo,
    Dio? dio,
    String baseUrl = defaultBaseUrl,
  }) : _networkInfo = networkInfo,
       _baseUrl = baseUrl,
       _dio = dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 8),
               receiveTimeout: const Duration(seconds: 8),
             ),
           );

  @override
  Future<Result<RoadRoute>> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(NetworkFailure('No connectivity for road routing'));
    }

    final path =
        '$_baseUrl/${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';

    try {
      final response = await _dio.get(
        path,
        queryParameters: const {'overview': 'full', 'geometries': 'geojson'},
      );
      return _parse(response.data);
    } on DioException catch (error) {
      AppLogger.warning('OSRM route request failed: ${error.message}');
      return Result.failure(NetworkFailure(error.message ?? 'Road routing request failed'));
    } catch (error, stackTrace) {
      AppLogger.error('Could not parse OSRM response', error, stackTrace);
      return const Result.failure(UnknownFailure('Could not parse road routing response'));
    }
  }

  Result<RoadRoute> _parse(dynamic data) {
    if (data is! Map<String, dynamic> || data['code'] != 'Ok') {
      return const Result.failure(ServerFailure(message: 'OSRM returned no usable route'));
    }
    final routes = data['routes'];
    if (routes is! List || routes.isEmpty) {
      return const Result.failure(ServerFailure(message: 'OSRM returned no routes'));
    }
    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>?;
    final coordinates = geometry?['coordinates'];
    if (coordinates is! List || coordinates.length < 2) {
      return const Result.failure(ServerFailure(message: 'OSRM route geometry was empty'));
    }

    final points = [
      for (final coordinate in coordinates)
        LatLng(
          ((coordinate as List)[1] as num).toDouble(),
          (coordinate[0] as num).toDouble(),
        ),
    ];

    return Result.success(
      RoadRoute(
        points: points,
        distanceMeters: (route['distance'] as num).toDouble(),
        etaSeconds: (route['duration'] as num).round(),
      ),
    );
  }
}
