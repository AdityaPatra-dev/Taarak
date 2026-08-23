import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/config/app_config.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_incident_report_repository.dart';
import 'package:taarak/core/database/repositories/local_incident_repository.dart';
import 'package:taarak/core/database/repositories/local_route_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/core/database/repositories/local_user_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/location/administrative_context.dart';
import 'package:taarak/core/location/geo_tag_service.dart';
import 'package:taarak/core/location/geolocator_location_service.dart';
import 'package:taarak/core/location/location_service.dart';
import 'package:taarak/core/network/api_client.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/storage/secure_key_value_store.dart';

/// Cross-cutting wiring shared by every feature. Feature-specific providers
/// (auth, hazards, incidents, ...) build on top of these.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.development());

final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    config: ref.watch(appConfigProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final secureKeyValueStoreProvider = Provider<SecureKeyValueStore>(
  (ref) => const FlutterSecureKeyValueStore(),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final localUserRepositoryProvider = Provider<LocalUserRepository>(
  (ref) => LocalUserRepository(ref.watch(appDatabaseProvider)),
);

final localHazardZoneRepositoryProvider = Provider<LocalHazardZoneRepository>(
  (ref) => LocalHazardZoneRepository(ref.watch(appDatabaseProvider)),
);

final localIncidentRepositoryProvider = Provider<LocalIncidentRepository>(
  (ref) => LocalIncidentRepository(ref.watch(appDatabaseProvider)),
);

final localIncidentReportRepositoryProvider =
    Provider<LocalIncidentReportRepository>(
      (ref) => LocalIncidentReportRepository(ref.watch(appDatabaseProvider)),
    );

final localShelterRepositoryProvider = Provider<LocalShelterRepository>(
  (ref) => LocalShelterRepository(ref.watch(appDatabaseProvider)),
);

final localRouteRepositoryProvider = Provider<LocalRouteRepository>(
  (ref) => LocalRouteRepository(ref.watch(appDatabaseProvider)),
);

final syncQueueDaoProvider = Provider<SyncQueueDao>(
  (ref) => SyncQueueDao(ref.watch(appDatabaseProvider)),
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => GeolocatorLocationService(),
);

final administrativeContextResolverProvider =
    Provider<AdministrativeContextResolver>(
      (ref) => const UnresolvedAdministrativeContextResolver(),
    );

final geoTagServiceProvider = Provider<GeoTagService>(
  (ref) => GeoTagService(
    locationService: ref.watch(locationServiceProvider),
    contextResolver: ref.watch(administrativeContextResolverProvider),
  ),
);
