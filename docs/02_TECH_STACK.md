# Technology Stack

Verified against `pubspec.yaml`, `lib/main.dart`, `lib/core/config/app_config.dart`, and direct code inspection. Every entry below reflects what the code actually imports and calls — not what a generic Flutter starter template would include.

## Frontend framework

**Flutter** (Dart 3, SDK constraint `^3.12.2` in `pubspec.yaml`). Single codebase targeting Android, iOS, Web, macOS, Linux, and Windows (all six platform directories exist at the repo root — `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`). The app has actually been built and deployed for Android (APK) and Web (Firebase Hosting) this session; macOS/Linux/Windows/iOS platform folders exist from `flutter create` scaffolding but have not been verified as built or run — **UNKNOWN — requires verification** whether they currently build cleanly.

## Programming language

Dart 3, using modern pattern-matching syntax (`switch` expressions, `case` patterns like `Success<T>(:final data)`) extensively throughout the domain/application layers — this is a deliberate, consistently-applied style choice, not incidental.

## State management

**Riverpod** (`flutter_riverpod: ^2.6.1`). Every feature's `application/` folder defines one or more `Provider`, `FutureProvider.autoDispose`, `StateNotifierProvider`, or `AsyncNotifierProvider`. There is no other state-management system in the app (no Bloc, no Provider package, no GetX, no raw `setState`-only screens except for pure local UI state like text field controllers and "is this button busy" flags). Full detail in `05_STATE_MANAGEMENT.md`.

## Navigation / routing

**go_router** (`^14.6.2`), declaratively configured in `lib/app/router.dart` as a single flat `GoRoute` list (no nested/shell routes), with a centralized `redirect:` callback (`computeRedirect` in `lib/app/route_guard.dart`) that gates every route by a required `Permission`. Full detail in `06_ROUTING.md`.

## Local database

**Drift** (`drift: ^2.31.0`, `drift_flutter: ^0.3.1`, codegen via `drift_dev` + `build_runner`) on top of SQLite — a typed, compile-time-checked local database. This is the app's offline-first backbone: `lib/core/database/app_database.dart` defines the schema; every feature that needs persistent local data has a `LocalXRepository` wrapping Drift queries. Full detail in `09_DATABASE_STORAGE.md` / `docs/modules/core_database.md`.

## Backend

**Firebase** — `firebase_core: ^4.14.0`, `firebase_auth: ^6.6.0`, `cloud_firestore: ^6.9.0` — is the real, live backend, configured against a project with hosting URL `taakrak-d9ed0.web.app` (per `lib/firebase_options.dart`'s generated config and this session's own deploy history). `AppConfig.development().useFirebaseAuth` is hardcoded `true`, so this is the only backend path a fresh clone actually exercises.

There is a **separate, second backend candidate** at `backend/` — a standalone Dart package (`shelf` + `shelf_router`) with its own `pubspec.yaml` describing itself as: *"Local backend stub for validating TAARAK's auth + sync client contract end to end. Not a production service."* `AppConfig.apiBaseUrl` (`http://localhost:8080/api`) points at this stub's expected address, and `ApiAuthRemoteDataSource`/`ApiSyncTransport` classes exist to talk to it — but per the pubspec.yaml dependency comment (`# Real, hosted auth + database — replaces the old local backend/ stub ... kept in backend/ for reference, no longer used by the app`), **this stub is not used by the running app** in its current configuration. Status: **UNUSED / DEAD CODE** as far as the shipped app is concerned, but the code paths that *could* talk to it (`ApiAuthRemoteDataSource`, `ApiSyncTransport`) remain in the codebase — see `docs/modules/core_infrastructure.md` and `docs/modules/sync.md`.

## Authentication

**Firebase Authentication**, email/password provider. Login/register/forgot-password/logout are all real, live Firebase Auth calls (`FirebaseAuthRemoteDataSource`). A separate **mock authentication path** (`DevMockAuthRemoteDataSource`, an in-memory directory of seeded demo accounts) exists purely for local development and is selected only when `AppConfig.useMockAuth` is true — which it is not, in the app's only constructed config (`AppConfig.development()`). Full detail in `10_AUTHENTICATION.md`.

## Maps

**google_maps_flutter** (`^2.18.0`). Renders the interactive risk map (hazard zones as polygons, shelters/habitations/incidents as markers, evacuation routes as polylines). Requires a real Google Maps API key, embedded in `android/app/src/main/AndroidManifest.xml` and `web/index.html` (per the pubspec.yaml comment, this key exists and is functional but not locked down to the app's package/domain identity — see `15_SECURITY_AUDIT.md`).

## Location

**geolocator** (`^13.0.2`) for GPS fix + runtime location-permission handling, wrapped by `lib/core/location/`.

## GIS / geometry

**latlong2** (`^0.9.1`) is the canonical coordinate type (`LatLng`) used throughout the domain/application layers; `lib/core/gis/` holds pure-Dart geometry helpers (e.g. point-in-polygon, circle-as-polygon approximation for hazard-zone radii). Conversion to `google_maps_flutter`'s own `LatLng` type happens only at the map-widget boundary, not throughout the business logic — a deliberate isolation documented in the code's own comments.

## Networking / HTTP

**dio** (`^5.7.0`) is the HTTP client, wrapped by `lib/core/network/api_client.dart`. Used by the (currently unreached) `ApiAuthRemoteDataSource`/`ApiSyncTransport` classes and by whichever module calls a real external weather API (verify in `docs/modules/environmental.md` for the exact provider and endpoint).

## Local secure storage

**flutter_secure_storage** (`^9.2.2`) — the auth session token is persisted here (`AuthLocalDataSource`), not in plain SharedPreferences.

## Serialization

No code-generation serialization package (no `json_serializable`, no `freezed`). Firestore document (de)serialization is hand-written `Map<String, dynamic>` mapping in each data source / `fromFirestore`/`toFirestore()` method pattern — verified across multiple data sources this session (e.g. `AppPolicy.fromFirestore`, `RolePermissionOverrides.fromFirestore`).

## Notifications

**flutter_local_notifications** (`^22.3.0`) — client-only local notifications (no server-side push/FCM wiring observed in `lib/features/notifications/`; verify in that module's doc).

## IDs

**uuid** (`^4.5.1`) generates client-side unique ids for citizen reports and other locally-created records, so ids from different offline devices don't collide once synced to the shared backend.

## Media

**image_picker** (`^1.1.2`) for photo attachment on citizen incident reports; **image** (`^4.3.0`) for client-side resize/re-encode before upload (per the pubspec comment, "M21").

## Connectivity

**connectivity_plus** (`^6.1.0`) — network-reachability detection, feeding the sync engine's offline/online transition logic.

## Logging

**logger** (`^2.5.0`), wrapped by `lib/core/logging/` (single file — verify actual usage breadth in `docs/modules/core_infrastructure.md`).

## AI / ML

**No AI/ML package or SDK is present in `pubspec.yaml`.** There is no `google_generative_ai`, no `tflite`, no on-device inference runtime, no cloud LLM client library of any kind. Any "AI" or "ML" concept referenced in code comments (e.g. a `HazardSusceptibilityModel` abstraction) is, per direct code inspection this session, a documented extension point with **no trained model wired in** — its only implementation (`UnavailableHazardSusceptibilityModel`) always returns `null`, by design, with a doc comment explicitly framing this as deliberate honesty rather than an oversight. Verify current state in `docs/modules/susceptibility.md`.

## Build tools

Standard Flutter/Dart toolchain: `flutter build web`, `flutter build apk`, `flutter test`, `flutter analyze`. `build_runner` + `drift_dev` regenerate `app_database.g.dart` (and any other `.g.dart` files) after a schema change. `flutter_launcher_icons` (`^0.14.3`) regenerates platform app icons from `assets/icon/` source images via `dart run flutter_launcher_icons`.

## Testing framework

`flutter_test` (bundled with the Flutter SDK) for unit/widget tests. Dev-only test-support packages: `sqlite3` (native SQLite for genuinely exercising Drift against an in-memory database in tests, not a fake), `fake_cloud_firestore` + `firebase_auth_mocks` + `mock_exceptions` (in-memory fakes so Firebase-backed tests run without a live project). Full detail in `13_TESTING.md`.

## Package manager

`pub` (Dart's native package manager), via `flutter pub get` / `flutter pub upgrade`.

## Deployment

**Firebase Hosting** for the web build (`firebase deploy --only hosting`, project `taakrak-d9ed0`, confirmed live at `https://taakrak-d9ed0.web.app` as of this session's deploys) and **Firestore security rules** deployment (`firebase deploy --only firestore:rules`, `firestore.rules` at repo root). Android is built as a release/debug APK via standard `flutter build apk`; no CI/CD pipeline configuration (no `.github/workflows/`, no `codemagic.yaml`, no other CI config) was found in the repository — **deployment today is manual, developer-run `firebase deploy` and `flutter build`, not automated.**

## Dependency injection

No DI framework (no `get_it`, no `injectable`). Riverpod's own `Provider` graph *is* the dependency-injection mechanism — every repository/service/data source is itself a `Provider<T>` that composes other providers via `ref.watch(...)` in its constructor call, wired in each feature's `<feature>_providers.dart` file.
