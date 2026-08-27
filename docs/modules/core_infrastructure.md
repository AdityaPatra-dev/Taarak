# CORE MODULE: Infrastructure (config, error, gis, location, logging, media, network, providers, repository, routing, storage)

Every non-database file under `lib/core/` outside `lib/core/database/`. One dossier per file, grouped by subdirectory. (The Drift/SQLite layer is documented separately in `docs/modules/core_database.md`.)

---

## `lib/core/config/` (2 files)

### `lib/core/config/environment.dart`
- **Purpose**: A single three-value enum (`development`, `staging`, `production`) used to tag which backend environment `AppConfig` describes.
- **Status**: IMPLEMENTED, but trivially — only `.development` is ever constructed anywhere in the app (see `AppConfig.development()` below); `staging`/`production` are unused values reserved for a future per-environment config that doesn't exist yet.
- **Key classes/functions**: `Environment` enum.
- **Depends on**: nothing.
- **Depended on by**: `app_config.dart`.

### `lib/core/config/app_config.dart`
- **Purpose**: Central app configuration — which backend to talk to, API timeout, and two feature flags (`useMockAuth`, `useFirebaseAuth`) that gate which auth/data path the app takes.
- **Status**: IMPLEMENTED, but with a load-bearing hardcoded value: `AppConfig.development()` is the *only* factory ever called in the app (see `core_providers.dart`'s `appConfigProvider`), and it hardcodes `apiBaseUrl: 'http://localhost:8080/api'` (a never-deployed placeholder — see `network/api_client.dart` and `sync_transport.dart`) alongside `useFirebaseAuth: true`. There is no environment-variable or build-flavor mechanism that changes this at build/run time.
- **Key classes/functions**: `AppConfig` (fields: `environment`, `apiBaseUrl`, `apiTimeout` (default 20s), `useMockAuth` (default false), `useFirebaseAuth` (default false)); factory `AppConfig.development()`; `isProduction` getter (always false in practice); `isDevMode` getter — tied to Flutter's real `kReleaseMode` rather than `environment`, specifically so dev-only screens (SMS/device-relay prototypes) can never leak into a release build even though `environment` itself never varies.
- **Notable imports**: `flutter/foundation.dart` for `kReleaseMode`.
- **Depends on**: `environment.dart`.
- **Depended on by**: `core_providers.dart` (`appConfigProvider`), `network/api_client.dart`, `features/sync/application/sync_providers.dart` (branches `useFirebaseAuth` to choose `FirestoreSyncTransport` vs `ApiSyncTransport`).
- **Hardcoded/demo content flagged**: `apiBaseUrl` points at a `localhost:8080` backend that, per comments elsewhere in the codebase (`sync_transport.dart`), was never actually built/deployed — any code path still routed through `ApiClient`/`ApiSyncTransport` genuinely fails against this address rather than reaching a real service.

---

## `lib/core/error/` (2 files)

### `lib/core/error/app_exception.dart`
- **Purpose**: Internal exception hierarchy thrown by data sources (API client, local database) before a repository catches and translates it into a `Failure`. Never meant to cross into UI/domain code.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `AppException` (base, has `message`), `NetworkException`, `ServerException` (carries `statusCode`), `CacheException`, `NotFoundException`, `UnauthorizedException`.
- **Depends on**: nothing.
- **Depended on by**: every repository/DAO in `core/database/`, `network/api_client.dart`.

### `lib/core/error/failure.dart`
- **Purpose**: The user-facing/domain-facing error type — the counterpart `AppException` gets mapped into. Every `Result<T>` failure branch carries one of these.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: sealed `Failure` (base, `message`), `NetworkFailure`, `ServerFailure` (carries `statusCode`), `CacheFailure`, `ValidationFailure`, `NotFoundFailure`, `UnauthorizedFailure`, `LocationFailure`, `UnknownFailure`.
- **Depends on**: nothing.
- **Depended on by**: `core/repository/result.dart`, `network/api_client.dart`, `core/database/database_result_guard.dart`, `location/*`, `routing/osrm_road_network_provider.dart`, essentially everything that produces a `Result`.

---

## `lib/core/gis/` (6 files)

### `lib/core/gis/circle_geometry.dart`
- **Purpose**: Approximates a circle of a given radius around a center point as a closed polygon (24-sided by default), for hazard zones drawn as "epicenter + radius" rather than freehand.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `circlePolygonPoints(center, radiusMeters, {segments = 24}) -> List<LatLng>`.
- **Notable imports**: `latlong2`.
- **Depends on**: nothing else in `core/`.
- **Depended on by**: not traced beyond this directory (likely hazard-drawing UI, out of this module's scope).

### `lib/core/gis/default_map_center.dart`
- **Purpose**: The fallback map center/zoom used only when no real GPS fix is available (geographic center of India).
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `defaultMapCenter` (`LatLng(20.5937, 78.9629)`), `defaultMapZoom` (`5`).
- **Hardcoded content flagged**: these constants are intentionally hardcoded fallback values, not a bug — the doc comment is explicit that every map screen should prefer a real GPS fix over this.

### `lib/core/gis/geometry_codec.dart`
- **Purpose**: Encode/decode the polygon point lists stored in `LocalHazardZones.geometryJson` as a simple `[[lat,lng], ...]` JSON array — deliberately not full GeoJSON.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `decodePolygonPoints(String) -> List<LatLng>` (returns `const []` on any malformed input rather than throwing); `encodePolygonPoints(List<LatLng>) -> String`.
- **Notable imports**: `dart:convert`, `latlong2`.
- **Depends on**: nothing else in `core/`.
- **Depended on by**: `gis/hazard_exposure.dart`; `core/database` table doc comments reference it for `LocalHazardZones.geometryJson` and `LocalAlerts.geometryJson`.
- **Test coverage**: `test/core/gis/geometry_codec_test.dart` — round-trip encode/decode, and three malformed-input cases (non-JSON, wrong shape, short point).

### `lib/core/gis/hazard_exposure.dart`
- **Purpose**: Whether a point currently falls inside any of a list of hazard zones — shared containment check used by capacity-gap and relocation-candidate logic so both use identical exposure determination.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `isPointHazardExposed(LatLng, List<LocalHazardZone>) -> bool`.
- **Notable imports**: `core/database/app_database.dart` (for `LocalHazardZone`), `geometry_codec.dart`, `point_in_polygon.dart`.
- **Depends on**: `geometry_codec.dart`, `point_in_polygon.dart`, the database's generated `LocalHazardZone` model.

### `lib/core/gis/point_in_polygon.dart`
- **Purpose**: Standard ray-casting point-in-polygon test, the base primitive for hazard-zone containment checks anywhere in the app.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `isPointInPolygon(LatLng point, List<LatLng> polygon) -> bool` (returns false for fewer than 3 polygon points).
- **Notable imports**: `latlong2`.
- **Depended on by**: `hazard_exposure.dart`, and (per its own doc comment) referenced by the alert-targeting and risk-engine logic elsewhere in the app.
- **Test coverage**: `test/core/gis/point_in_polygon_test.dart` — inside/outside/degenerate-polygon cases.

### `lib/core/gis/severity_palette.dart`
- **Purpose**: The single shared hazard/incident/alert severity → color mapping, so the map legend, risk displays, and command dashboard stay visually consistent.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `severityColor(String severity) -> Color` — case-insensitive switch over `critical`/`high`/`medium`/`low`, falling back to grey for anything else.
- **Notable imports**: `flutter/material.dart`.
- **Depended on by**: `shared/widgets/severity_chip.dart` directly; referenced by table doc comments across `core/database/tables/` as the shared vocabulary for `severity` columns.
- **Test coverage**: `test/core/gis/severity_palette_test.dart` — four known severities map to distinct colors, case-insensitivity, unknown-severity fallback.

---

## `lib/core/location/` (7 files)

### `lib/core/location/location_permission_status.dart`
- **Purpose**: The app's own simplified permission-state enum, kept separate from the `geolocator` package's own enum so only `GeolocatorLocationService` ever depends on that package's types directly.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `LocationPermissionStatus` enum — `granted`, `denied`, `deniedForever`, `serviceDisabled`.

### `lib/core/location/gps_fix.dart`
- **Purpose**: A single GPS reading with enough metadata (`accuracyMeters`, `capturedAt`) for a consumer to judge freshness/reliability rather than blindly trusting coordinates.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `GpsFix` (fields: `latitude`, `longitude`, `accuracyMeters`, `capturedAt`); `ageAsOf(now) -> Duration`; `isFreshAsOf(now, {maxAge = 5min}) -> bool`.
- **Test coverage**: `test/core/location/gps_fix_test.dart` — fresh vs. stale relative to an injected `now`.

### `lib/core/location/administrative_context.dart`
- **Purpose**: Which administrative region/habitation a coordinate falls into. Real resolution needs boundary data that doesn't exist yet, so a no-op stand-in is provided.
- **Status**: PARTIALLY IMPLEMENTED / PLACEHOLDER for the real resolver — `UnresolvedAdministrativeContextResolver` always returns `null`, and it's the only implementation wired anywhere (`core_providers.dart`'s `administrativeContextResolverProvider`). The doc comment is explicit that real resolution "lands with M05's GIS layers and the Geography backend module," which has not happened.
- **Key classes/functions**: `AdministrativeContext` (id, name); abstract `AdministrativeContextResolver.resolve(lat, lng)`; `UnresolvedAdministrativeContextResolver` (the only concrete implementation, always resolves to `null`).
- **Depended on by**: `geo_tag_service.dart`, `core_providers.dart`.

### `lib/core/location/geo_tag.dart`
- **Purpose**: What actually gets attached to a citizen/responder report so it's "reliably geotagged" — a `GpsFix` plus whatever administrative context could be resolved.
- **Status**: IMPLEMENTED (structurally complete; the `administrativeContext` half is always `null` in practice today because of the placeholder resolver above).
- **Key classes/functions**: `GeoTag` (fields: `fix`, `administrativeContext?`); `toJson()`.
- **Depends on**: `administrative_context.dart`, `gps_fix.dart`.

### `lib/core/location/location_service.dart`
- **Purpose**: Abstract contract for permission checks + capturing a GPS fix, so the rest of the app never depends on the `geolocator` package directly.
- **Status**: IMPLEMENTED (interface).
- **Key classes/functions**: abstract `LocationService` — `checkPermission()`, `requestPermission()`, `getCurrentFix() -> Result<GpsFix>`.
- **Depended on by**: `geo_tag_service.dart`, implemented by `geolocator_location_service.dart`.

### `lib/core/location/geolocator_location_service.dart`
- **Purpose**: The real `LocationService` implementation, backed by the `geolocator` plugin.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `GeolocatorLocationService` — `checkPermission()`/`requestPermission()` map `geolocator`'s permission enum onto `LocationPermissionStatus` (service-disabled checked first, before the permission itself); `getCurrentFix()` requests a high-accuracy fix with a 15-second time limit, returns `LocationFailure` on missing permission/service or any thrown error (logged via `AppLogger.error`).
- **Notable imports**: `geolocator`.
- **Depends on**: `error/failure.dart`, `gps_fix.dart`, `location_permission_status.dart`, `location_service.dart`, `logging/app_logger.dart`, `repository/result.dart`.
- **Depended on by**: `core_providers.dart` (`locationServiceProvider`) — the only `LocationService` wired in the running app.

### `lib/core/location/geo_tag_service.dart`
- **Purpose**: The one call a report/SOS/"I am safe" feature needs to reliably geotag itself: capture a fix, then attach whatever administrative context is resolvable.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `GeoTagService` (constructor DI of `LocationService` + `AdministrativeContextResolver`); `captureGeoTag() -> Result<GeoTag>` — short-circuits with the location failure if the fix itself fails, without ever calling the context resolver.
- **Depends on**: `administrative_context.dart`, `geo_tag.dart`, `gps_fix.dart`, `location_service.dart`, `repository/result.dart`.
- **Depended on by**: `core_providers.dart` (`geoTagServiceProvider`); referenced by `alerts.md`'s module doc as used by `AlertBroadcastService.activeAlertsForCurrentLocation`.
- **Test coverage**: `test/core/location/geo_tag_service_test.dart` — successful fix attaches context (and the resolver is called exactly once); a location failure propagates without ever calling the context resolver.

---

## `lib/core/logging/` (1 file)

### `lib/core/logging/app_logger.dart`
- **Purpose**: App-wide logging facade over the `logger` package, so output format/verbosity/destination is controlled in one place instead of scattered `print` calls.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `AppLogger` (static-only, private constructor) — `debug`, `info`, `warning`, `error(message, [error, stackTrace])`.
- **Notable imports**: `logger` package, configured with `PrettyPrinter` (no method-call traces, 5-frame error traces, 100-char lines, colors, emojis on).
- **Depended on by**: widely — `database_result_guard.dart`, `network/api_client.dart`, `location/geolocator_location_service.dart`, `routing/osrm_road_network_provider.dart`, and (per grep-confirmed usage across the app) most error paths.

---

## `lib/core/media/` (5 files)

### `lib/core/media/compressed_image.dart`
- **Purpose**: Result type of a compression call — the output file path plus before/after byte sizes so a caller can judge whether compression was worth it.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `CompressedImage` (fields: `path`, `originalSizeBytes`, `compressedSizeBytes`).

### `lib/core/media/image_compressor.dart`
- **Purpose**: Abstract contract for resize/re-encode behavior, decoupling feature code from a specific codec so it's swappable and testable.
- **Status**: IMPLEMENTED (interface).
- **Key classes/functions**: abstract `ImageCompressor.compress(sourcePath, {maxDimension = 1024, quality = 60}) -> Future<CompressedImage>` — documented to throw (not return a `Result`) on undecodable input, leaving the throw/catch decision to the caller.
- **Depended on by**: `package_image_compressor.dart` (the implementation).

### `lib/core/media/package_image_compressor.dart`
- **Purpose**: The real `ImageCompressor`, built on the pure-Dart `image` package (not a native codec) so behavior is identical across every target platform including web and under `flutter test`.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `PackageImageCompressor.compress(...)` — decodes, resizes only if the longest side exceeds `maxDimension` (never upscales, preserves aspect ratio), re-encodes as JPEG, writes the output alongside the source file as `<name>_compressed.jpg`.
- **Notable imports**: `dart:io`, `image` package, `path` package.
- **Test coverage**: `test/core/media/package_image_compressor_test.dart` — a real synthetic 2000×1200 JPEG is genuinely shrunk and resized (not just relabeled), aspect ratio preserved; a smaller-than-target image is not upscaled; an unreadable path throws.

### `lib/core/media/media_picker_service.dart`
- **Purpose**: Abstracts photo attachment behind the app's own interface instead of calling `image_picker` directly from feature code.
- **Status**: IMPLEMENTED (interface).
- **Key classes/functions**: `MediaPickerSource` enum (`camera`, `gallery`); abstract `MediaPickerService.pickPhoto({required source}) -> Future<String?>` (null = user cancelled).
- **Depended on by**: `image_picker_media_service.dart` (the implementation).

### `lib/core/media/image_picker_media_service.dart`
- **Purpose**: The real `MediaPickerService`, backed by the `image_picker` plugin.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `ImagePickerMediaService.pickPhoto(...)` — max width 1600, JPEG quality 85 at pick time (separate from/before `PackageImageCompressor`'s own later compression pass).
- **Notable imports**: `image_picker`.

---

## `lib/core/network/` (2 files)

### `lib/core/network/network_info.dart`
- **Purpose**: Connectivity abstraction the rest of the app uses to decide connected vs. offline-mode behavior, including a change stream the sync coordinator listens to for reconnect-triggered syncs.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: abstract `NetworkInfo` — `isConnected -> Future<bool>`, `onConnectivityChanged -> Stream<bool>`; `NetworkInfoImpl` (real implementation, backed by `connectivity_plus`) — `isConnected` true if any reported result isn't `ConnectivityResult.none`.
- **Notable imports**: `connectivity_plus`.
- **Depended on by**: `network/api_client.dart`, `routing/osrm_road_network_provider.dart`, `core_providers.dart` (`networkInfoProvider`), `features/sync/application/sync_providers.dart` (`syncOnReconnectTriggerProvider` listens to `onConnectivityChanged` directly — see `docs/modules/sync.md`).

### `lib/core/network/api_client.dart`
- **Purpose**: Thin `Dio` wrapper centralizing base URL/timeout config, a bearer-token interceptor, request logging, a pre-flight connectivity check, and Dio-exception-to-`Failure` mapping, so per-entity remote repositories only ever deal in `Result<T>`.
- **Status**: IMPLEMENTED as infrastructure, but its real-world reach is limited: `AppConfig.development().apiBaseUrl` (`http://localhost:8080/api`) is a never-deployed placeholder, so any caller still routed through this client (rather than through Firebase/Firestore) genuinely fails with a `NetworkFailure`/`ServerFailure` in practice, not just in theory.
- **Key classes/functions**: `ApiClient` (constructor takes `AppConfig` + `NetworkInfo`); `attachTokenProvider(Future<String?> Function())` — lets the auth feature supply the session token without `core/` depending on `features/auth`; `get<T>`/`post<T>` (each takes a `parser`); internal `_request` (pre-flight `networkInfo.isConnected` check, try/catch around the call), `_mapDioException`, `_mapExceptionToFailure`.
- **Notable imports**: `dio`.
- **Depends on**: `config/app_config.dart`, `error/app_exception.dart`, `error/failure.dart`, `logging/app_logger.dart`, `network_info.dart`, `repository/result.dart`.
- **Depended on by**: `core_providers.dart` (`apiClientProvider`), `features/sync/application/sync_transport.dart`'s `ApiSyncTransport`.
- **Test coverage**: `test/core/foundation_smoke_test.dart` — offline request fails fast with `NetworkFailure` without attempting the call.

---

## `lib/core/providers/` (1 file)

### `lib/core/providers/core_providers.dart`
- **Purpose**: The single file wiring every cross-cutting, feature-agnostic dependency into Riverpod — the composition root that every feature module builds on. Constructs `AppConfig`, `NetworkInfo`, `ApiClient`, `SecureKeyValueStore`, the shared `AppDatabase` instance, all 14 `LocalRepository` implementations, the 3 DAOs, `LocationService`, `AdministrativeContextResolver`, and `GeoTagService`.
- **Status**: IMPLEMENTED.
- **Key classes/functions** (all plain Riverpod `Provider`s, non-autoDispose — live for the app's lifetime once first read): `appConfigProvider`, `networkInfoProvider`, `apiClientProvider`, `secureKeyValueStoreProvider`, `appDatabaseProvider` (disposes the database via `ref.onDispose(db.close)`), one provider per repository/DAO (`localUserRepositoryProvider`, `localHazardZoneRepositoryProvider`, `localIncidentRepositoryProvider`, `localIncidentReportRepositoryProvider`, `localShelterRepositoryProvider`, `localRouteRepositoryProvider`, `localHabitationRepositoryProvider`, `localRiskAssessmentRepositoryProvider`, `localVulnerabilityAssessmentRepositoryProvider`, `localCapacityAssessmentRepositoryProvider`, `localEnvironmentalObservationRepositoryProvider`, `localRelocationPlanRepositoryProvider`, `localDamageReportRepositoryProvider`, `localResourceRepositoryProvider`, `syncQueueDaoProvider`, `auditLogDaoProvider`, `localAlertRepositoryProvider`, `alertAcknowledgementDaoProvider`), `locationServiceProvider`, `administrativeContextResolverProvider` (wires the always-null `UnresolvedAdministrativeContextResolver`), `geoTagServiceProvider`.
- **Notable imports**: every repository/DAO in `core/database/`, plus `location/*`, `network/*`, `storage/secure_key_value_store.dart`.
- **Depends on**: nearly all of `core/`.
- **Depended on by**: every feature's own provider file across `lib/features/`, `features/sync/application/sync_providers.dart`, `app/router.dart` (transitively via feature providers).

---

## `lib/core/repository/` (3 files)

### `lib/core/repository/result.dart`
- **Purpose**: The `Result<T>`/`Failure` outcome type used everywhere instead of exceptions crossing layer boundaries — the pattern this whole codebase is built on.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: sealed `Result<T>` with `Result.success`/`Result.failure` factories, `isSuccess`/`isFailure`, `when({success, failure})`, `dataOrNull`; `Success<T>`, `Failed<T>` concrete subtypes.
- **Depends on**: `error/failure.dart`.
- **Depended on by**: essentially every file in the app that performs I/O.

### `lib/core/repository/local_repository.dart`
- **Purpose**: The generic contract every local (Drift-backed) repository implements — `getById`, `getAll`, `save`, `delete` — kept deliberately separate from `RemoteRepository` so offline mode keeps working with only this half available.
- **Status**: IMPLEMENTED (interface), implemented by 14 concrete classes in `core/database/repositories/` (see `docs/modules/core_database.md`).
- **Key classes/functions**: abstract `LocalRepository<T, ID>`.

### `lib/core/repository/remote_repository.dart`
- **Purpose**: The generic contract for server-backed access to an entity, meant to be combined with `LocalRepository` per-entity as backend modules come online.
- **Status**: DEFINED BUT UNIMPLEMENTED — no concrete class implementing `RemoteRepository<T, ID>` was found anywhere in `lib/core/` or `lib/features/sync/`. The app's actual remote-sync path (`SyncTransport`/`FirestoreSyncTransport`/`ApiSyncTransport` in `features/sync/`) is a parallel, differently-shaped abstraction that does not use this interface at all. This should be flagged to a handover engineer as either dead scaffolding or a contract intended for a not-yet-built per-entity remote layer.
- **Key classes/functions**: abstract `RemoteRepository<T, ID>` — `fetchById`, `fetchAll`, `create`, `update`, `delete`.
- **Depends on**: `result.dart`.
- **Depended on by**: nothing found.

---

## `lib/core/routing/` (3 files)

### `lib/core/routing/road_route.dart`
- **Purpose**: A real, road-following path between two points as returned by a `RoadNetworkProvider` — distinct from the app's own straight-line fallback geometry (which lives in a risk/routing engine outside this module's scope).
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `RoadRoute` (fields: `points`, `distanceMeters`, `etaSeconds`).

### `lib/core/routing/road_network_provider.dart`
- **Purpose**: Abstract contract for fetching real route geometry, decoupling the routing engine from a specific provider.
- **Status**: IMPLEMENTED (interface).
- **Key classes/functions**: abstract `RoadNetworkProvider.fetchRoute({origin, destination}) -> Future<Result<RoadRoute>>`.
- **Depended on by**: `osrm_road_network_provider.dart` (the implementation); referenced by `core/database/tables/local_routes_table.dart`'s doc comment for `isRoadSnapped`.

### `lib/core/routing/osrm_road_network_provider.dart`
- **Purpose**: The real `RoadNetworkProvider`, backed by OSRM's **public demo routing server** (`router.project-osrm.org`).
- **Status**: IMPLEMENTED, but explicitly flagged in its own doc comment as pointed at infrastructure **not meant for production traffic**: "that server is explicitly documented (by its own operators) as being for evaluation/demo traffic only, not production load ... a real deployment should point `baseUrl` at a self-hosted OSRM/Valhalla instance or a commercial Directions API instead." This is a genuine, called-out limitation, not an oversight — flag prominently to anyone taking this to production.
- **Key classes/functions**: `OsrmRoadNetworkProvider` (constructor DI of `NetworkInfo` + optional `Dio`/`baseUrl`, 8s connect/receive timeout); `fetchRoute(...)` — pre-flight connectivity check, GET with `overview=full&geometries=geojson`, parses OSRM's GeoJSON `[lng, lat]` coordinate order into `LatLng(lat, lng)`; `_parse` handles non-`'Ok'` codes, empty route lists, and malformed geometry as clean `Result.failure`s rather than throwing.
- **Notable imports**: `dio`, `latlong2`.
- **Depends on**: `error/failure.dart`, `logging/app_logger.dart`, `network/network_info.dart`, `repository/result.dart`, `road_network_provider.dart`, `road_route.dart`.
- **Test coverage**: `test/core/routing/osrm_road_network_provider_test.dart` — successful decode with correct point order/distance/rounded ETA; whole-number (int, not double) JSON coordinates handled safely; offline short-circuits before any request is attempted; non-`Ok` code, empty routes list, `DioException`, and a malformed (non-map) body all fail cleanly rather than throwing.

---

## `lib/core/storage/` (1 file)

### `lib/core/storage/secure_key_value_store.dart`
- **Purpose**: Encrypted key/value storage for security-sensitive data (the auth session token) — explicitly separate from the general Drift database, which isn't encrypted by default and is meant for bulk entity caching, not credentials.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: abstract `SecureKeyValueStore` — `write`, `read`, `delete`; `FlutterSecureKeyValueStore` (real implementation, backed by `flutter_secure_storage`, defaults to a `const FlutterSecureStorage()`).
- **Notable imports**: `flutter_secure_storage`.
- **Depended on by**: `core_providers.dart` (`secureKeyValueStoreProvider`); presumably `features/auth/` for session persistence (outside this module's scope to confirm further).

---

## Cross-cutting observations

- **The `Result<T>`/`Failure` discipline is consistent everywhere in this directory** — no file in `core/` (outside generated code) throws an exception across its own public API boundary; every I/O-touching method returns `Result<T>`.
- **Two genuine placeholders exist in this directory**: `AdministrativeContextResolver`'s only wired implementation always returns `null` (no real geography data yet), and `RemoteRepository` is a fully-defined but entirely unused interface.
- **Two genuine "not production-ready" infrastructure choices are explicitly self-documented in code comments**: `AppConfig.development().apiBaseUrl` pointing at an undeployed `localhost:8080` backend, and `OsrmRoadNetworkProvider` pointing at OSRM's public demo server.
