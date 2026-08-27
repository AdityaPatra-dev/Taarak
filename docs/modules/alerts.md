# MODULE: Alerts

## Purpose

Alerts is TAARAK's official emergency-broadcast mechanism (blueprint milestone "M16"). It lets an authorized official push a geo-targeted warning ("landslide expected, move to higher ground") to everyone whose current location falls inside a specific, already-surveyed hazard zone, and lets any citizen see which of those broadcasts currently apply to them. It also keeps a permanent, auditable history of every broadcast, cancellation, and acknowledgement, and provides a delete path for content moderation, all going through the local Drift database first (offline-first) with a sync-queue hook for later propagation to the backend.

## User-facing functionality

- **Citizen** (`Permission.viewAlerts`, screen `AlertsScreen`): sees two lists — "Active for your location" (alerts whose target zone geometry currently contains the citizen's live GPS fix, computed via `GeoTagService`) and "History" (every alert ever broadcast, most recent first, regardless of location). Each active alert can be acknowledged with a single tap ("Acknowledge" button becomes "Acknowledged" once tapped); acknowledgement is idempotent per user. Pull-to-refresh re-fetches both lists.
- **Local Official** (`Permission.sendBroadcast`, screen `BroadcastAlertScreen`): picks a target hazard zone from a dropdown (fed by the already-ingested `LocalHazardZones` table via `hazardZonesProvider`), enters a title/message, picks a severity (low/medium/high/critical), picks a validity duration (options come from `AppPolicy.alertValidityOptions`, state-admin configurable, default 6 hours pre-selected when available), and taps "Broadcast." The screen also lists every alert ever broadcast with a live acknowledgement count per alert and a "Cancel alert" action for any still-active alert.
- Deletion (moderation) is exposed only through `AlertBroadcastService.deleteAlert` — there is no screen in this module that calls it; it is presumably invoked from the admin content-moderation feature (outside this module's scope).

## Entry points

Grepped from `lib/app/router.dart` and `lib/app/route_guard.dart`:

| Route | Screen | Permission required |
|---|---|---|
| `/alerts` | `AlertsScreen` | `Permission.viewAlerts` |
| `/alerts/broadcast` | `BroadcastAlertScreen` | `Permission.sendBroadcast` |

Both routes are flat (no path params) and are wired directly into `appRouterProvider`'s route list; `computeRedirect` in `route_guard.dart` sends an unauthenticated session to `/login` and an authenticated session lacking the required permission to `/unauthorized`.

## Architecture

Standard three-layer split used across the app:
- **`application/`** — business logic and Riverpod wiring. `alert_engine.dart` is a pure, IO-free domain engine (validity/geometry checks only). `alert_broadcast_service.dart` is the orchestration layer that talks to Drift repositories/DAOs, the sync queue, and the audit log, and returns `Result<T>`. `alert_providers.dart` wires both into Riverpod (`Provider`, `FutureProvider.autoDispose`).
- **`presentation/`** — two `ConsumerWidget`/`ConsumerStatefulWidget` screens that read the providers and call back into `AlertBroadcastService` for mutations.
- No `domain/` or `data/` subfolder inside `lib/features/alerts/` itself — the domain model (`LocalAlert`) lives in the shared Drift schema (`lib/core/database/tables/local_alerts_table.dart` / generated `lib/core/database/app_database.g.dart`), and persistence goes through the shared `LocalAlertRepository`, `LocalHazardZoneRepository`, `AlertAcknowledgementDao`, `AuditLogDao`, and `SyncQueueDao` in `lib/core/database/`.

## Files in this module

### `lib/features/alerts/application/alert_engine.dart`
- **Purpose**: Pure deterministic core answering two questions: is a given `LocalAlert` currently active (not cancelled, within `[issuedAt, validUntil)`), and does an alert's target-zone polygon contain a given point. Deliberately has no clock/IO access so "is this alert active" is a pure function of `(LocalAlert, DateTime)`.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `AlertEngine.isActive(alert, now)`; `AlertEngine.appliesToLocation(alert, point)` (delegates to `isPointInPolygon`/`decodePolygonPoints` from `core/gis`); `AlertEngine.activeAlertsForLocation({alerts, point, now})` — combines both checks over a list.
- **Notable imports**: `latlong2` (LatLng), `core/database/app_database.dart` (LocalAlert generated model), `core/gis/geometry_codec.dart` + `core/gis/point_in_polygon.dart` (polygon decode/containment, shared GIS utilities).
- **Depends on**: nothing feature-specific; pure GIS/DB-model utilities only.
- **Depended on by**: `AlertBroadcastService` (default engine when none injected), both test files.
- **State read/written**: none — pure function, no IO.
- **External communication**: none.
- **Mock/demo content**: none.

### `lib/features/alerts/application/alert_broadcast_service.dart`
- **Purpose**: Orchestrates the full alert lifecycle — broadcast to a zone, cancel, admin-delete, acknowledge, list history, and compute "active alerts for the citizen's current location." Every method returns `Result<T>` and short-circuits on the first failure via Dart pattern-matching on `Failed<T>`.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `AlertBroadcastService` constructor (DI of all repos/DAOs/engine, `syncQueueDao` optional); `broadcastToZone(...)` — the acceptance-criterion method, snapshots the target zone's geometry/label into the new `LocalAlert` row, saves it, enqueues a sync-queue "create" op (JSON payload), and writes an `alert.broadcast` audit record; `cancelAlert(...)` — soft-cancel (`cancelledAt` set, `version` bumped), separate `alert.cancelled` audit action, still enqueues sync; `deleteAlert(...)` — hard delete (only path used by System Admin moderation, per the doc comment, though no in-module caller exists), enqueues a sync-queue "delete" op, `alert.removed` audit action; `acknowledge(...)`/`acknowledgementsFor(...)` — thin delegation to `AlertAcknowledgementDao`; `history()` — all alerts sorted by `issuedAt` descending; `activeAlertsForCurrentLocation(...)` — captures a live `GeoTag` via `GeoTagService`, fails with the location failure if the fix can't be captured (explicitly does NOT silently return an empty list), then runs `AlertEngine.activeAlertsForLocation`.
- **Notable imports**: `drift` (`Value` for nullable-column updates), `latlong2`, `uuid` (id generation), five `core/database` symbols (`AlertAcknowledgementDao`, `AppDatabase`/`LocalAlert`, `AuditLogDao`, `LocalAlertRepository`, `LocalHazardZoneRepository`, `SyncQueueDao`), `core/location/geo_tag.dart` + `geo_tag_service.dart`, `core/repository/result.dart`.
- **Depends on**: `AlertEngine` (injectable, defaults to `AlertEngine()`), `LocalAlertRepository`, `LocalHazardZoneRepository`, `AlertAcknowledgementDao`, `AuditLogDao`, `GeoTagService`, optional `SyncQueueDao`.
- **Depended on by**: `alert_providers.dart` (`alertBroadcastServiceProvider`), both presentation screens (indirectly via providers), both test files.
- **State read/written**: reads/writes the `local_alerts` Drift table (via `LocalAlertRepository`), reads `local_hazard_zones` (to snapshot geometry), writes `local_alert_acknowledgements`, writes `audit_log` (via `AuditLogDao.record`), writes `sync_queue` (when a `SyncQueueDao` is supplied).
- **External communication**: no direct Firestore/network calls — all writes go to local SQLite via Drift; the `sync_queue` insert is the *hook* for a later background sync process to push to Firestore, but this file does not perform that push itself.
- **Mock/demo content**: none — real Drift persistence, real audit trail.

### `lib/features/alerts/application/alert_providers.dart`
- **Purpose**: Riverpod wiring — constructs `AlertEngine` and `AlertBroadcastService` with their real dependencies pulled from `core/providers/core_providers.dart`, and exposes two `FutureProvider.autoDispose` reads (`alertHistoryProvider`, `activeAlertsForCurrentLocationProvider`) that both silently fall back to `const []` on failure (`result.dataOrNull ?? const []`) rather than surfacing the error to `AsyncValue.error` — meaning UI history/active-alert lists never show a Drift error state, only "empty."
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `alertEngineProvider`, `alertBroadcastServiceProvider`, `alertHistoryProvider`, `activeAlertsForCurrentLocationProvider`.
- **Notable imports**: `flutter_riverpod`, `core/database/app_database.dart`, `core/providers/core_providers.dart` (supplies the shared repository/DAO providers).
- **Depends on**: `AlertBroadcastService`, `AlertEngine`, `core_providers.dart`.
- **Depended on by**: `AlertsScreen`, `BroadcastAlertScreen`.
- **State read/written**: none directly; wraps calls into the service.
- **External communication**: none directly.
- **Mock/demo content**: none. Note the swallowed-failure pattern above is a real limitation, not mock content — worth flagging under Known Limitations.

### `lib/features/alerts/presentation/alerts_screen.dart`
- **Purpose**: Citizen-facing screen. Shows active-for-my-location alerts (with an acknowledge action) above the full broadcast history (read-only). Handles the three `AsyncValue` states (loading/data/error) for the location-scoped query explicitly, including a location-permission-specific error message.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `AlertsScreen` (`ConsumerWidget`); private `_AlertCard` (`ConsumerStatefulWidget`) — renders one alert, holds local `_acknowledged` bool UI state, calls `alertBroadcastServiceProvider.acknowledge(...)` on tap.
- **Notable imports**: `flutter_riverpod`, `app/spacing.dart`, `core/database/app_database.dart` (LocalAlert), `alert_providers.dart`, `auth/application/auth_controller.dart` (`currentUserProvider` for the acknowledging user's id), shared widgets (`async_state_views`, `responsive`, `section_header`, `severity_chip`, `taarak_app_bar`).
- **Depends on**: `activeAlertsForCurrentLocationProvider`, `alertHistoryProvider`, `alertBroadcastServiceProvider`, `currentUserProvider`.
- **Depended on by**: routed at `/alerts`.
- **State read/written**: local widget state only (`_acknowledged` bool per card, reset on rebuild); triggers a write via `acknowledge()`.
- **External communication**: none directly (through providers → service → Drift).
- **Mock/demo content**: none.

### `lib/features/alerts/presentation/broadcast_alert_screen.dart`
- **Purpose**: Official-facing screen to compose and send a new zone-targeted broadcast, and to manage (cancel) previously sent alerts, each shown with a live acknowledgement count.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `BroadcastAlertScreen`/`_BroadcastAlertScreenState` — form state (zone/title/message/severity/validity), `_broadcast(validFor)` calls `AlertBroadcastService.broadcastToZone`, then invalidates `alertHistoryProvider` and shows a `SnackBar` on success/failure; private `_AlertHistoryCard` — per-alert card with a "Cancel alert" `TextButton` calling `cancelAlert`; private `_alertAcknowledgementCountProvider` (`FutureProvider.autoDispose.family<int, String>`) — count of acknowledgements per alert id, defaults to 0 on failure.
- **Notable imports**: `flutter_riverpod`, `app/spacing.dart`, `core/database/app_database.dart`, `alert_providers.dart`, `auth/application/auth_controller.dart`, `map/application/map_data_providers.dart` (`hazardZonesProvider` — cross-module dependency on the Map feature for the zone dropdown), `state_admin/application/state_admin_providers.dart` + `state_admin/domain/app_policy.dart` (`appPolicyProvider`, `AppPolicy.defaults.alertValidityOptions` — cross-module dependency on State/Admin's policy config), shared widgets.
- **Depends on**: `alertBroadcastServiceProvider`, `alertHistoryProvider`, `hazardZonesProvider` (map feature), `appPolicyProvider` (state_admin feature), `currentUserProvider`.
- **Depended on by**: routed at `/alerts/broadcast`.
- **State read/written**: local form-field state; triggers `broadcastToZone` / `cancelAlert` writes.
- **External communication**: none directly.
- **Mock/demo content**: the "Broadcast" button is disabled (`onPressed: null`) whenever `zones.isEmpty` — i.e. the screen has a real empty-state guard, not a stub. No hardcoded/demo data.

### `test/features/alerts/alert_broadcast_service_test.dart`
- **Purpose**: Integration-style test against a real in-memory Drift `AppDatabase` (`NativeDatabase.memory()`), a fake `LocationService` (`_FakeLocationService`, returns a canned `Result<GpsFix>`), and a no-op `AdministrativeContextResolver`. Ingests one real hazard zone via `HazardIngestionService` in `setUp`, then exercises `AlertBroadcastService` end to end.
- **Status**: IMPLEMENTED (real test, not a stub).
- **Key classes/functions**: `_FakeLocationService`, `_NoOpContextResolver`, `serviceAt(lat,lng)` helper. Test groups: `broadcastToZone` (including the literal acceptance-criterion test named `'OFFICIAL CAN BROADCAST TO SELECTED ZONE — the acceptance criterion'`, plus an unknown-zone failure case), `activeAlertsForCurrentLocation` (in-zone / out-of-zone / expired), `cancelAlert` (cancellation removes the alert from citizen view, audit trail has `alert.cancelled`), `acknowledge` (double-acknowledge from same user does not duplicate), `history` (sorted most-recent-first).
- **Notable imports**: `drift/native`, `flutter_test`, `latlong2`, five `core/database` symbols, `core/location/*` (administrative_context, geo_tag_service, gps_fix, location_permission_status, location_service), `core/repository/result.dart`, `AlertBroadcastService`, `features/hazards/application/hazard_ingestion_service.dart` + `hazard_normalizer.dart`, `features/hazards/domain/raw_hazard_observation.dart`, `test/support/sqlite3_test_setup.dart`.
- **Depends on / tests**: `AlertBroadcastService`, transitively `AlertEngine`, `LocalAlertRepository`, `LocalHazardZoneRepository`, `AlertAcknowledgementDao`, `AuditLogDao`, `GeoTagService`, `HazardIngestionService`.
- **External communication**: none — fully in-memory Drift, no network/Firestore.

### `test/features/alerts/alert_engine_test.dart`
- **Purpose**: Pure unit tests of `AlertEngine` with hand-built `LocalAlert` fixtures (`alertWith(...)` helper) — no database, no IO.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `alertWith(...)` fixture builder; groups `isActive` (within window / before issued / past validity / cancelled-overrides-window), `appliesToLocation` (point inside/outside polygon), `activeAlertsForLocation` (including a test explicitly named to restate the acceptance criterion from the citizen side, and an "inactive alert never applies" case).
- **Notable imports**: `flutter_test`, `latlong2`, `core/database/app_database.dart`, `core/gis/geometry_codec.dart` (`encodePolygonPoints` to build the test zone polygon), `AlertEngine`.
- **External communication**: none.

## Data Models

`LocalAlert` (Drift-generated from `lib/core/database/tables/local_alerts_table.dart`, table `local_alerts`):
- `id` (text, PK) — UUID v4.
- `title` (text)
- `message` (text)
- `severity` (text) — `low | medium | high | critical`, same vocabulary as hazard zones/incidents.
- `zoneId` (text) — FK-like reference to the source `LocalHazardZones.id`.
- `zoneLabel` (text) — denormalized display label, e.g. `"landslide zone"`, snapshotted at broadcast time.
- `geometryJson` (text) — denormalized polygon snapshot of the target zone's geometry at broadcast time, so later re-surveys of the zone don't retroactively change what the alert covered.
- `issuedBy` (text) — official's user id.
- `issuedAt` (DateTime)
- `validUntil` (DateTime) — end of the validity window.
- `cancelledAt` (DateTime, nullable) — set on early cancellation, distinct from natural expiry.
- `version` (int, default 1) — bumped on cancel.

`LocalAlertAcknowledgement` — Drift model from `core/database/tables/local_alert_acknowledgements_table.dart` (not read in full for this module but referenced via `AlertAcknowledgementDao.acknowledge`/`listForAlert`); holds at minimum `alertId`, `userId`, and a timestamp, keyed so a repeat acknowledgement from the same user does not duplicate (verified by test).

## Services / Repositories

- **`AlertEngine`** — pure domain logic: active/applies-to-location checks (see above).
- **`AlertBroadcastService`** — the module's only application service; full lifecycle orchestration (broadcast/cancel/delete/acknowledge/history/active-for-location), audit logging, and sync-queue enqueueing. This is the sole write path into the `local_alerts` table used by this module.
- Shared (outside this module, but load-bearing for it): `LocalAlertRepository`, `LocalHazardZoneRepository`, `AlertAcknowledgementDao`, `AuditLogDao`, `SyncQueueDao`, `GeoTagService` (all in `lib/core/`).

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/alerts` | `AlertsScreen` | `Permission.viewAlerts` (citizen role) | Home screen navigation / citizen menu (outside this module's files) |
| `/alerts/broadcast` | `BroadcastAlertScreen` | `Permission.sendBroadcast` (Local Official role) | Official menu / home screen navigation (outside this module's files) |

## Module Data Flow

**Broadcast → citizen sees it (the acceptance criterion):**

```
BroadcastAlertScreen (official picks zone/title/message/severity/validity, taps Broadcast)
  -> ref.read(alertBroadcastServiceProvider).broadcastToZone(zoneId, title, message, severity, validFor, officialId)
    -> AlertBroadcastService.broadcastToZone
       -> LocalHazardZoneRepository.getById(zoneId)          [reads local_hazard_zones]
       -> builds LocalAlert (uuid v4, snapshots zone.geometryJson + zoneLabel)
       -> LocalAlertRepository.save(alert)                    [writes local_alerts]
       -> SyncQueueDao.enqueue(entityTable: 'local_alerts', operation: 'create')  [writes sync_queue — later synced to Firestore by a background process outside this module]
       -> AuditLogDao.record(action: 'alert.broadcast')       [writes audit_log]
    <- Result<LocalAlert>.success(alert)
  ref.invalidate(alertHistoryProvider) -> BroadcastAlertScreen history list refreshes

AlertsScreen (citizen, separately, on screen load / pull-to-refresh)
  -> ref.watch(activeAlertsForCurrentLocationProvider)
    -> AlertBroadcastService.activeAlertsForCurrentLocation()
       -> GeoTagService.captureGeoTag()                       [device GPS via LocationService]
       -> LocalAlertRepository.getAll()                       [reads local_alerts]
       -> AlertEngine.activeAlertsForLocation(alerts, point, now)   [pure: isActive + point-in-polygon against alert.geometryJson]
    <- Result<List<LocalAlert>>.success(matches)
  citizen taps "Acknowledge" -> AlertBroadcastService.acknowledge(alertId, userId) -> AlertAcknowledgementDao [writes local_alert_acknowledgements]
```

## Current Status

**Working**, with strong test coverage on the two application-layer files. Evidence: `alert_broadcast_service_test.dart` exercises the full lifecycle against a real in-memory Drift database (not mocks), including the literal acceptance criterion; `alert_engine_test.dart` covers all branches of the pure logic. Both screens are fully wired to real providers/services with no placeholder UI.

## Known Limitations

- `alert_providers.dart`'s `alertHistoryProvider` and `activeAlertsForCurrentLocationProvider` both collapse any `Failed` result to an empty list (`result.dataOrNull ?? const []`) instead of surfacing the failure through `AsyncValue.error` — a genuine Drift read error looks identical in the UI to "no alerts," except for the separately-handled location-fix failure in `AlertsScreen`, which does still show `ErrorView` because the location-specific `FutureProvider` itself throws via `ref.watch(...).when(... error: ...)` — actually re-checking: the provider itself swallows the failure into `const []` too, so the `error` branch of `.when` in `AlertsScreen` is realistically unreachable via this path; the only way it fires is an exception escaping `activeAlertsForCurrentLocation()` itself (e.g. an unexpected throw), not a modeled `Failed<T>`.
- `AlertBroadcastService.deleteAlert` (moderation hard-delete) has no caller anywhere inside this module — it is presumably invoked from `features/admin/` content moderation, which is out of scope here, so its integration cannot be verified from this module alone.
- Sync-queue enqueueing only happens when a `SyncQueueDao` is injected (`_syncQueueDao` is nullable and defaults to `null` unless the provider wires one — `alert_providers.dart` does wire a real one via `core_providers.dart`, so in the running app this is populated, but any caller constructing `AlertBroadcastService` without it silently skips sync entirely).
- No screen in this module surfaces `deleteAlert`, so alert removal-for-moderation is untested from a UI perspective within `lib/features/alerts/`.

## Test Coverage

- `test/features/alerts/alert_broadcast_service_test.dart` — covers `broadcastToZone` (success + unknown-zone failure), `activeAlertsForCurrentLocation` (in-zone, out-of-zone, expired), `cancelAlert` (removes from citizen view + audit trail), `acknowledge` (idempotent per user), `history` (sort order). Uses a real in-memory SQLite Drift database, not mocks, so this is close to an integration test for the service layer.
- `test/features/alerts/alert_engine_test.dart` — covers `isActive` (all four branches: active/pre-issue/post-expiry/cancelled) and `appliesToLocation`/`activeAlertsForLocation` (inside/outside polygon, inactive-alert exclusion).
- **Not covered by any test**: `AlertBroadcastService.deleteAlert` (moderation hard-delete path) — no test references it. Neither presentation screen (`AlertsScreen`, `BroadcastAlertScreen`) has a widget test — only the application-layer service/engine are tested; no `test/features/alerts/` widget/screen test exists. `alert_providers.dart`'s failure-swallowing behavior (`dataOrNull ?? const []`) is not directly tested.
