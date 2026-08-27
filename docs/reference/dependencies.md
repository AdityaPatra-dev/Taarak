# REFERENCE: Dependencies (`pubspec.yaml`)

Full dependency list as declared in `pubspec.yaml`, with the version constraint exactly as written there, and a note on where each is actually observed in use based on reading `lib/core/`, `lib/app/`, `lib/features/sync/`, `lib/shared/`, and `lib/main.dart`. A "not observed in core/app layer" note means grepping those directories found no `import 'package:<name>'` — the package may still be used inside other `lib/features/` modules that were outside this document's read scope; it does not mean the dependency is unused by the app as a whole.

Package name: `taarak`, version `1.0.0+1`, SDK constraint `^3.12.2` (Dart 3).

## `dependencies`

| Package | Version constraint | Usage observed in core/app layer |
|---|---|---|
| `flutter` | (sdk) | The framework itself — every file. |
| `cupertino_icons` | `^1.0.8` | Not observed in `lib/core`, `lib/app`, or `lib/features/sync` (no `CupertinoIcons` reference found anywhere in `lib/`, in fact — likely a template leftover from `flutter create`, or used only for an icon reference not grepped for by name). |
| `flutter_riverpod` | `^2.6.1` | Core state-management/DI layer for the whole app. Used in `core/providers/core_providers.dart` (every provider), `app/app.dart` (`ConsumerWidget`, root-level `ref.watch`s), `app/router.dart` (`Provider`s, `ChangeNotifier` bridge), `features/sync/application/sync_providers.dart`. |
| `go_router` | `^14.6.2` | Declarative routing. Used in `app/router.dart` (the entire route table + redirect wiring) and `shared/widgets/taarak_app_bar.dart` (`GoRouter.maybeOf`, `context.pop()`). |
| `dio` | `^5.7.0` | HTTP client. Used in `core/network/api_client.dart` and `core/routing/osrm_road_network_provider.dart`. |
| `logger` | `^2.5.0` | Structured logging. Used in `core/logging/app_logger.dart` (the sole wrapper — nothing else in the app should call it directly). |
| `connectivity_plus` | `^6.1.0` | Connectivity detection. Used in `core/network/network_info.dart` (`NetworkInfoImpl`), which backs `features/sync/application/sync_providers.dart`'s reconnect trigger. |
| `flutter_secure_storage` | `^9.2.2` | Encrypted key/value storage. Used in `core/storage/secure_key_value_store.dart` (`FlutterSecureKeyValueStore`), intended for the auth session token. |
| `drift` | `^2.31.0` | Typed SQLite ORM — the entire local database layer. Used throughout `core/database/` (tables, generated code, all repositories/DAOs). |
| `drift_flutter` | `^0.3.1` | Flutter-specific Drift platform glue. Used once, in `core/database/app_database.dart`'s constructor (`driftDatabase(...)`, `DriftWebOptions` for the web/WASM SQLite setup). |
| `geolocator` | `^13.0.2` | Device GPS + location permissions. Used in `core/location/geolocator_location_service.dart` (the sole real `LocationService` implementation). |
| `latlong2` | `^0.9.1` | Coordinate type (`LatLng`) used app-wide as the canonical lat/lng representation. Used in `core/gis/*`, `core/location/*` (indirectly, via `GpsFix`), `core/routing/*`. Per a comment in `core/routing/road_network_provider.dart`, only map-rendering widgets convert to `google_maps_flutter`'s own `LatLng` at the UI boundary — everywhere else in the app stays on this package's type. |
| `uuid` | `^4.5.1` | Not observed in `lib/core`, `lib/app`, or `lib/features/sync` — but confirmed used across nine feature-layer files (`features/alerts/`, `features/hazards/`, `features/habitations/`, `features/verification/`, `features/field_response/`, `features/command/`, `features/reporting/`, `features/shelters/`, `features/disaster_events/`) for generating globally-unique ids on citizen/official-created entities before they reach the backend. |
| `image_picker` | `^1.1.2` | Photo attachment. Used in `core/media/image_picker_media_service.dart` (the sole real `MediaPickerService` implementation). |
| `image` | `^4.3.0` | Pure-Dart image decode/resize/encode. Used in `core/media/package_image_compressor.dart` (the sole real `ImageCompressor` implementation) — chosen specifically to avoid a native codec dependency so behavior is identical across platforms including web and under `flutter test`. |
| `path` | `^1.9.0` | Filesystem path manipulation. Used in `core/media/package_image_compressor.dart` to build the compressed-output filename alongside the source file. |
| `firebase_core` | `^4.14.0` | Firebase app bootstrap. Used in `lib/main.dart` (`Firebase.initializeApp`, with the retry-on-web-race workaround) and consumes `lib/firebase_options.dart`. |
| `firebase_auth` | `^6.6.0` | Not observed in `lib/core`, `lib/app`, or `lib/features/sync` — confirmed used in `lib/features/auth/data/firebase_auth_remote_data_source.dart`, i.e. it backs the real auth path selected whenever `AppConfig.useFirebaseAuth` is true (which it always is, per `AppConfig.development()`'s hardcoded value — see `docs/modules/core_infrastructure.md`), but the auth feature itself is outside this document's read scope. |
| `cloud_firestore` | `^6.9.0` | Used directly in `lib/features/sync/application/firestore_sync_transport.dart` (`FirestoreSyncTransport`, the sync transport actually active in the running app — see `docs/modules/sync.md`). Not used anywhere in `lib/core` or `lib/app` directly; the sync feature is the sole direct Firestore client in the scope read for this handover. |
| `google_maps_flutter` | `^2.18.0` | Not observed in `lib/core`, `lib/app`, or `lib/features/sync`. Per the pubspec's own comment, this backs map rendering (presumably in a `features/map/` module outside this scope), using "a real (but unrestricted-by-app-identity) Google Maps API key already embedded in `android/app/src/main/AndroidManifest.xml` and `web/index.html`" — the pubspec comment itself flags this key as not locked down and points to the README's "Google Maps API key" section for what to do before a public release. |
| `flutter_local_notifications` | `^22.3.0` | Not observed in `lib/core` or `lib/app` directly, but `app/app.dart` watches a `notificationWatcherProvider` from `lib/features/notifications/` (outside this scope) at the app root, which is presumably this package's consumer — local (client-only, no server push) notifications for new alerts/incidents. |

## `dev_dependencies`

| Package | Version constraint | Usage observed |
|---|---|---|
| `flutter_test` | (sdk) | Test framework — every file under `test/`. |
| `drift_dev` | `^2.21.0` | Code generator for `core/database/app_database.g.dart` (invoked via `build_runner`, not imported directly by app code). |
| `build_runner` | `^2.4.13` | Runs `drift_dev`'s code generation (`dart run build_runner build`). |
| `sqlite3` | `^3.5.2` | Used directly by tests for an in-memory/on-disk native database (`NativeDatabase`) — confirmed via `test/core/database/local_database_smoke_test.dart` and `test/features/sync/sync_coordinator_service_test.dart`, both routed through `test/support/sqlite3_test_setup.dart`'s `configureSqlite3ForLocalTests()`. Per the pubspec comment, its native library resolves automatically via Dart's native-assets build hooks with nothing to configure per machine. |
| `fake_cloud_firestore` | `^4.2.0` | In-memory Firestore fake. Confirmed used in `test/features/sync/firestore_sync_transport_test.dart` (`FakeFirebaseFirestore`) — lets the Firestore-backed sync transport tests run fast and without a live Firebase project. |
| `firebase_auth_mocks` | `^0.15.2` | Not observed in `test/core` or `test/features/sync` — presumably used in `test/features/auth/` (outside this scope) alongside `firebase_auth_remote_data_source.dart`. |
| `mock_exceptions` | `^0.8.2` | Not observed in `test/core` or `test/features/sync` — likely paired with `fake_cloud_firestore`/`firebase_auth_mocks` elsewhere to script exception scenarios against the fakes. |
| `flutter_lints` | `^6.0.0` | Lint rule set, activated via `analysis_options.yaml` (not itself read in this pass) — not imported by any Dart file, applies at analysis time. |
| `flutter_launcher_icons` | `^0.14.3` | Build-time tool (`dart run flutter_launcher_icons`), configured entirely within `pubspec.yaml`'s own `flutter_launcher_icons:` section (source images `assets/icon/icon_master.png` and `assets/icon/icon_foreground.png`); generates platform launcher icons for Android (with adaptive-icon foreground/background split), iOS, web, macOS, and Windows. Not imported by any Dart file. |

## Notable non-dependency observations from `pubspec.yaml` itself

- **`flutter_launcher_icons` config** documents that `icon_foreground.png` already bakes in Android's adaptive-icon safe-zone padding (~62% canvas occupancy), so the tool's own default 16% inset is deliberately disabled (`adaptive_icon_foreground_inset: 0`) to avoid double-padding.
- **Assets**: only `assets/icon/` is declared under `flutter: assets:` — no other bundled asset directory exists in the app as of this pubspec.
- **No custom fonts** are declared — consistent with `app/theme.dart`'s explicit choice to avoid `google_fonts` (network dependency, offline-first conflict) or a bundled font asset, relying on the platform's own system font plus a defined type scale instead.
- A comment on the `firebase_core`/`firebase_auth`/`cloud_firestore` block states these "replace the old local `backend/` stub (kept in `backend/` for reference, no longer used by the app)" and that the app is "already configured against the live `taakrak-d9ed0` Firebase project ... and selected unconditionally (`AppConfig.development().useFirebaseAuth` is always true) — no setup needed for a fresh clone to talk to it." This directly corroborates the `AppConfig`/`ApiSyncTransport` dead-path finding documented in `docs/modules/core_infrastructure.md` and `docs/modules/sync.md`.
