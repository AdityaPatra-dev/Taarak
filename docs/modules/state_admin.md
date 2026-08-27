# MODULE: State Admin

## Purpose

State Admin gives the State/Admin role two things: a way to configure app-wide policy values that used to be hardcoded constants elsewhere in the app (how long a broadcast alert stays valid, how large a hazard-zone radius can be marked), and a read-only statewide statistics view aggregating incidents, citizen reports, alerts, shelters, and hazard zones — the same "tally what other modules already computed" pattern used by the Dashboard module, but without any offline-first local persistence: policy configuration is deliberately Firestore-only, always-online, no Drift table involved.

## User-facing functionality

- **State/Admin** (`Permission.managePolicyConfiguration`, screen `PolicyConfigurationScreen` at `/state/policy`): sees two editable lists rendered as deletable `Chip`s — "Alert validity options" (hours) and "Hazard zone radius options" (meters/km) — each with a text field + "Add" button to append a new option and a chip's built-in delete (×) icon to remove one. Every add/remove immediately writes the full policy document back to Firestore and invalidates the provider so the UI reflects the saved state (not optimistic local state).
- **State/Admin** (`Permission.viewReports`, screen `StateReportsScreen` at `/state/reports`): a read-only grid of nine stat cards — total/active/resolved incidents, total/unresolved citizen reports, total/active alerts issued, total shelters tracked, total hazard zones — with a manual refresh button in the app bar.

## Entry points

Grepped from `lib/app/router.dart` and `lib/app/route_guard.dart`:

| Route | Screen | Permission required |
|---|---|---|
| `/state/reports` | `StateReportsScreen` | `Permission.viewReports` |
| `/state/policy` | `PolicyConfigurationScreen` | `Permission.managePolicyConfiguration` |

Both routes are flat (no path params). Note that `/state/oversight` (the third `/state/*` route in the router) belongs to the Dashboard module (it reuses `CommandDashboardScreen`), not to this one — it is out of scope for this document even though it shares the `/state/` prefix.

## Architecture

- **`domain/`** — two plain immutable data classes: `AppPolicy` (with Firestore (de)serialization methods embedded directly on the model, and a `static const defaults`) and `StateReportSummary` (pure tally holder, no logic).
- **`data/`** — `app_policy_data_source.dart`: the module's only data source, talking directly to Cloud Firestore (not routed through Drift or the sync queue at all — a deliberate, documented exception to the app's usual offline-first pattern, per the file's own doc comment: "app-wide configuration is small, always-online, read-by-everyone data, not an offline-cacheable entity worth routing through M17's sync pipeline").
- **`application/`** — `state_report_aggregator.dart` (pure function, same shape as Dashboard's `buildDashboardSnapshot`) and `state_admin_providers.dart` (Riverpod wiring for both the policy data source and the report summary, the latter composing providers from three other modules).
- **`presentation/`** — two independent `ConsumerWidget`/`ConsumerStatefulWidget` screens, no shared widgets beyond common `shared/widgets/*`.
- Unlike every other module documented in this handover package, State Admin's policy half has **no local repository, no Drift table, and no sync-queue entry** — `AppPolicyDataSource` reads/writes Cloud Firestore directly and swallows failures into `AppPolicy.defaults` on read.

## Files in this module

### `lib/features/state_admin/domain/app_policy.dart`
- **Purpose**: The configurable policy value-object — currently exactly two fields: alert validity duration options and hazard-zone radius options (meters). Includes `static const defaults` (1h/6h/24h validity; 200/500/1000/2000/5000m radius) and Firestore (de)serialization.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `AppPolicy` (const constructor); `AppPolicy.defaults`; `AppPolicy.fromFirestore(Map<String, dynamic>)` — tolerant parse, falls back per-field to `defaults` if the corresponding Firestore array is missing or empty; `toFirestore()` — encodes durations as plain integer hours (`alertValidityHours`) and radii as a raw double list (`hazardRadiusMeters`).
- **Notable imports**: none beyond core Dart — no Firestore import here (kept in the data source).
- **Depends on**: nothing.
- **Depended on by**: `app_policy_data_source.dart`, `state_admin_providers.dart`, `policy_configuration_screen.dart`, and cross-module by `features/alerts/presentation/broadcast_alert_screen.dart` (reads `appPolicyProvider` for its validity dropdown) and (per this file's own doc comment) `report_hazard_zone_screen.dart` for the radius options.
- **State read/written**: none — pure value object.
- **External communication**: none directly (Firestore field-name mapping only, no I/O here).
- **Mock/demo content**: `defaults` is a real, intentional fallback (not a placeholder) — used whenever Firestore is unreachable or the doc doesn't exist, so the app never blocks on policy config being absent.

### `lib/features/state_admin/domain/state_report_summary.dart`
- **Purpose**: Immutable holder for nine aggregate counts shown on `StateReportsScreen`.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `StateReportSummary` (const constructor, nine required `int` fields, no derived getters — unlike `DashboardSnapshot`, all values are precomputed by the aggregator rather than derived lazily on the model).
- **Notable imports**: none.
- **Depends on**: nothing.
- **Depended on by**: `state_report_aggregator.dart`, `state_admin_providers.dart`, `state_reports_screen.dart`.
- **State read/written**: none.
- **External communication**: none.
- **Mock/demo content**: none.

### `lib/features/state_admin/data/app_policy_data_source.dart`
- **Purpose**: The sole read/write path to the app's policy configuration, stored as a single Firestore document at `config/policy`. Deliberately bypasses Drift/local caching/sync-queue — every read and write goes straight to the network.
- **Status**: IMPLEMENTED. EXTERNAL DEPENDENCY (Cloud Firestore) — this is the one file in the module that performs real network I/O.
- **Key classes/functions**: `AppPolicyDataSource` (constructor accepts an injectable `FirebaseFirestore`, defaults to `FirebaseFirestore.instance`); `read()` — `Future<Result<AppPolicy>>`, catches all exceptions and always returns `Result.success(AppPolicy.defaults)` on any failure or missing doc (read failures are never surfaced as `Result.failure` — a deliberate "never block on this" design per the doc comment, but it also means a genuine permissions error or malformed doc is indistinguishable from "no policy configured yet"); `write(AppPolicy)` — `Future<Result<void>>`, uses `SetOptions(merge: true)`, returns `Result.failure(NetworkFailure('Unable to save policy'))` on any exception (write failures ARE surfaced, unlike read failures).
- **Notable imports**: `cloud_firestore`, `core/error/failure.dart` (`NetworkFailure`), `core/repository/result.dart`.
- **Depends on**: `FirebaseFirestore.instance` directly — no repository abstraction layer in between.
- **Depended on by**: `state_admin_providers.dart` (`appPolicyDataSourceProvider`), `policy_configuration_screen.dart` (calls `write` directly, bypassing any provider indirection for the mutation).
- **State read/written**: reads/writes the Firestore document `config/policy` — **the only Firestore path this whole module touches**.
- **External communication**: real Cloud Firestore network calls — `_firestore.doc('config/policy').get()` and `.set(..., SetOptions(merge: true))`.
- **Mock/demo content**: none — this is a real Firestore integration, not a mock, though it has no corresponding fake/mock implementation for tests (see Test Coverage — there is none for this file, and no `FakeFirebaseFirestore` or similar is used anywhere in this module).

### `lib/features/state_admin/application/state_report_aggregator.dart`
- **Purpose**: Pure tally function — the module's equivalent of Dashboard's `buildDashboardSnapshot`. Same "no I/O, callers supply the raw data" design.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `buildStateReportSummary({incidents, reports, alerts, shelters, hazardZones, now})` — `activeIncidents`/`resolvedIncidents` counted via raw string match against `incident.status` (`'active'`/`'resolved'`, which do correspond to real `IncidentVerificationStatus.storageValue`s per `features/verification/domain/incident_verification_status.dart`, though note this counts only the literal `active` status, not `acknowledged`/`verified`/`reported` incidents, which fall into neither active nor resolved bucket and are simply not reflected in either count — only in `totalIncidents`); `unresolvedReports` = reports whose `incidentId == null` (not yet fused into a tracked incident); `activeAlerts` = alerts not cancelled and still within `validUntil` (duplicate logic to `AlertEngine.isActive`, reimplemented inline rather than reused — see Known Limitations); `totalShelters`/`totalHazardZones` are plain `.length`.
- **Notable imports**: `core/database/app_database.dart`, `state_report_summary.dart`.
- **Depends on**: nothing beyond the passed-in lists and Drift model types.
- **Depended on by**: `state_admin_providers.dart` (`stateReportSummaryProvider`).
- **State read/written**: none — pure function.
- **External communication**: none.
- **Mock/demo content**: none.

### `lib/features/state_admin/application/state_admin_providers.dart`
- **Purpose**: Riverpod wiring for both halves of the module — the Firestore-backed policy provider and the read-only report-summary provider, the latter composing data from four other modules/tables.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `appPolicyDataSourceProvider`; `appPolicyProvider` (`FutureProvider.autoDispose<AppPolicy>`, falls back to `AppPolicy.defaults` on failure — consistent with the data source's own fallback, so this is a double-layer fallback); `stateReportSummaryProvider` (`FutureProvider.autoDispose<StateReportSummary>`) — awaits `incidentsProvider.future` (map module), `localIncidentReportRepositoryProvider.getAll()` (core), `alertHistoryProvider.future` (alerts module), `sheltersProvider.future` (map module), `hazardZonesProvider.future` (map module), then calls `buildStateReportSummary`.
- **Notable imports**: `core/providers/core_providers.dart`, `features/alerts/application/alert_providers.dart` (cross-module), `features/map/application/map_data_providers.dart` (cross-module, three providers), `state_report_aggregator.dart`, `app_policy_data_source.dart`, both domain files.
- **Depends on**: `AppPolicyDataSource`, `incidentsProvider`/`sheltersProvider`/`hazardZonesProvider` (map), `alertHistoryProvider` (alerts), `localIncidentReportRepositoryProvider` (core).
- **Depended on by**: both presentation screens, and cross-module by `broadcast_alert_screen.dart` (alerts module reads `appPolicyProvider`).
- **State read/written**: none directly; composes reads from `local_incidents`, `local_incident_reports`, `local_alerts`, `local_shelters`, `local_hazard_zones`, plus the Firestore `config/policy` doc.
- **External communication**: indirectly, via `AppPolicyDataSource`, real Firestore reads.
- **Mock/demo content**: none.

### `lib/features/state_admin/presentation/policy_configuration_screen.dart`
- **Purpose**: Add/remove UI for both policy option lists, writing the full `AppPolicy` back to Firestore on every single add/remove action (not batched — each chip add or delete is its own Firestore write).
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `PolicyConfigurationScreen`/`_PolicyConfigurationScreenState` — two `TextEditingController`s, one `_isSaving` bool disabling the Add buttons mid-save; `_save(AppPolicy)` — sets `_isSaving`, calls `appPolicyDataSourceProvider.write(policy)` directly (bypassing `AlertBroadcastService`-style layering — the screen talks straight to the data source, not through an intermediate application service), invalidates `appPolicyProvider`; `_addValidityOption`/`_removeValidityOption`/`_addRadiusOption`/`_removeRadiusOption` — each builds a new `AppPolicy` with the modified list and calls `_save`.
- **Notable imports**: `app/spacing.dart`, `state_admin_providers.dart`, `app_policy.dart`, shared widgets (`responsive`, `section_header`, `taarak_app_bar`) — notably does NOT import `async_state_views.dart`, so its loading/error states are ad-hoc (`CircularProgressIndicator` / plain `Text('Unable to load policy')`) rather than the shared `LoadingView`/`ErrorView` widgets other screens in this codebase use.
- **Depends on**: `appPolicyProvider`, `appPolicyDataSourceProvider`.
- **Depended on by**: routed at `/state/policy`.
- **State read/written**: writes the Firestore `config/policy` doc via every add/remove action.
- **External communication**: real Firestore writes, one per user action (no debounce/batch — e.g. adding 3 options in a row triggers 3 separate `set()` calls).
- **Mock/demo content**: none — this is real, functioning Firestore CRUD, just with a write-per-action UX pattern that is a real (not mock) limitation.

### `lib/features/state_admin/presentation/state_reports_screen.dart`
- **Purpose**: Read-only statewide statistics dashboard — nine stat cards in a `Wrap` layout, with a manual refresh action.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `StateReportsScreen`; private `_StatCard` (label + numeric value tile, purely presentational).
- **Notable imports**: `state_admin_providers.dart`, shared widgets (`async_state_views` — uses `ErrorView` with `onRetry`, unlike the policy screen).
- **Depends on**: `stateReportSummaryProvider`.
- **Depended on by**: routed at `/state/reports`.
- **State read/written**: none — pure read/display.
- **External communication**: none directly (indirectly via the provider's composed reads, none of which are Firestore — all local Drift/alert-history reads).
- **Mock/demo content**: none.

## Data Models

`AppPolicy` (`lib/features/state_admin/domain/app_policy.dart`) — NOT a Drift model, plain Dart class, Firestore-serialized:
- `alertValidityOptions: List<Duration>` — default `[1h, 6h, 24h]`.
- `hazardRadiusOptionsMeters: List<double>` — default `[200, 500, 1000, 2000, 5000]`.
- Firestore document shape (`config/policy`): `{ alertValidityHours: List<int>, hazardRadiusMeters: List<double> }`.

`StateReportSummary` (`lib/features/state_admin/domain/state_report_summary.dart`) — plain Dart class, not persisted anywhere, recomputed on every provider read:
- `totalIncidents`, `activeIncidents`, `resolvedIncidents`, `totalReports`, `unresolvedReports`, `totalAlertsIssued`, `activeAlerts`, `totalShelters`, `totalHazardZones` — all `int`.

## Services / Repositories

- **`AppPolicyDataSource`** — the module's only "repository-shaped" class, but talks directly to Cloud Firestore rather than through the app's usual `LocalRepository`/`RemoteRepository` split (`lib/core/repository/`); it is not a `RemoteRepository` subclass/implementation, it's a bespoke Firestore wrapper local to this module.
- **`buildStateReportSummary`** — pure aggregation function, not a class (same style as Dashboard's aggregator).
- No Drift repository, no DAO, and no sync-queue involvement anywhere in this module.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/state/reports` | `StateReportsScreen` | `Permission.viewReports` | State/Admin menu/navigation (outside this module) |
| `/state/policy` | `PolicyConfigurationScreen` | `Permission.managePolicyConfiguration` | State/Admin menu/navigation (outside this module) |

## Module Data Flow

**Configure policy (add a validity option):**
```
PolicyConfigurationScreen -> ref.watch(appPolicyProvider)
  -> AppPolicyDataSource.read() -> Firestore.doc('config/policy').get()
    -> exists: AppPolicy.fromFirestore(data)  |  missing/error: AppPolicy.defaults
user types hours, taps "Add"
  -> _addValidityOption -> builds new AppPolicy(alertValidityOptions: [...old, Duration(hours: n)])
  -> _save(newPolicy) -> AppPolicyDataSource.write(newPolicy)
     -> Firestore.doc('config/policy').set(policy.toFirestore(), merge:true)
  -> ref.invalidate(appPolicyProvider) -> re-reads from Firestore -> chips re-render
```

**View statewide reports:**
```
StateReportsScreen -> ref.watch(stateReportSummaryProvider)
  -> incidentsProvider.future            [map module -> local_incidents]
  -> localIncidentReportRepositoryProvider.getAll()  [core -> local_incident_reports]
  -> alertHistoryProvider.future         [alerts module -> local_alerts, via AlertBroadcastService.history()]
  -> sheltersProvider.future             [map module -> local_shelters]
  -> hazardZonesProvider.future          [map module -> local_hazard_zones]
  -> buildStateReportSummary(...)        [pure: counts/filters]
  <- StateReportSummary
  renders 9 _StatCard tiles
```

## Current Status

**Working** for both screens, with real Firestore integration for policy configuration and real local-data aggregation for reports. No local/offline caching exists for policy — this is by design, documented in the source, not an oversight.

## Known Limitations

- **No local/offline support for policy configuration.** `AppPolicyDataSource` talks directly to Firestore with no Drift cache and no sync-queue entry — if the device is offline, `read()` silently falls back to `AppPolicy.defaults` (not the last-known Firestore value) and `write()` fails outright with `NetworkFailure`. This is an explicit, documented design choice ("always-online... not an offline-cacheable entity"), but it does mean State/Admin cannot configure policy while offline, unlike nearly every other write-path in the app.
- `AppPolicyDataSource.read()` collapses every failure mode (missing doc, permission-denied, malformed data, network error) into the same success-with-defaults result — a genuine Firestore security-rule rejection is indistinguishable in the UI from "no policy configured yet." Only `write()` surfaces a real `Failure`.
- `policy_configuration_screen.dart` issues one Firestore write per add/remove action rather than batching — rapid successive edits produce redundant network round-trips (a real inefficiency, not a bug).
- `state_report_aggregator.dart` reimplements alert-active-checking logic inline (`alert.cancelledAt == null && currentTime.isBefore(alert.validUntil)`) instead of reusing `AlertEngine.isActive` from the Alerts module, which does the exact same check — a duplicated-logic risk if the two definitions ever drift apart.
- `activeIncidents`/`resolvedIncidents` in the summary only count incidents whose status string is exactly `'active'` or `'resolved'` — incidents in `reported`/`acknowledged`/`verified` states are counted in `totalIncidents` but in neither of the two narrower buckets, so the two counts do not sum to the total; this may be intentional (only fully-active or fully-closed incidents are "trend-worthy") but is not explained in the source and could read as a bug to an unfamiliar maintainer.
- `policy_configuration_screen.dart` uses ad-hoc loading/error UI instead of the shared `LoadingView`/`ErrorView` widgets (`async_state_views.dart`) that `state_reports_screen.dart` and most other screens in the app use — a minor UI-consistency gap.

## Test Coverage

**None.** `test/features/state_admin/` does not exist — confirmed by directory listing of `test/features/` (entries present: `admin, alerts, audit, auth, capacity, dashboard, device_relay, disaster_events, environmental, fusion, habitations, hazards, map, profile, relocation, reporting, risk, routing, shelters, sms_prototype, sync, verification, vulnerability` — no `state_admin`). There is no unit test for `buildStateReportSummary`, no test for `AppPolicy.fromFirestore`/`toFirestore` round-tripping, no test (mocked or otherwise) for `AppPolicyDataSource` against a fake Firestore, and no widget test for either `PolicyConfigurationScreen` or `StateReportsScreen`. This is a complete, explicit test gap for the entire module.
