# MODULE: Dashboard

## Purpose

Dashboard (blueprint milestone "M18") is the single situational-awareness screen for a District/Command user: one place to see red (high/critical) hazard zones, high-risk habitations, shelter capacity shortfalls, active incidents, active alerts, cached field-responder count, and pending offline-sync backlog — all pulled from data other modules already collect (hazards, risk, capacity, incidents, alerts, sync), not a new source of truth. It also provides the "drill into an incident" detail view referenced by the acceptance criterion.

## User-facing functionality

- **District/Command** (`Permission.monitorZones`, screen `CommandDashboardScreen` at `/dashboard`): sees a KPI row (red zones, vulnerable habitations, capacity gap, active incidents, active alerts, pending sync — each a colored count card), a read-only situational map (hazard zone polygons, shelters, incidents, habitations plotted via `TaarakMapView`), and two columns of list panels: left = Red zones / Vulnerable habitations / Capacity gap; right = Incidents (tappable, each row pushes to incident detail) / Alerts / Responders. A refresh icon in the app bar invalidates and re-fetches the whole snapshot. Layout adapts responsively: single scrolling column on mobile, two-column "situation room" layout on wide viewports.
- Same screen is reused, retitled "Cross-District Oversight," at `/state/oversight` for the State/Admin role (`Permission.crossDistrictOversight`) — this is the exact same `CommandDashboardScreen` widget with a different `title` constructor argument; there is no state-specific filtering logic in this module, so the state view shows identical district-level data (a known limitation, see below).
- Tapping any incident row navigates to `IncidentDetailScreen` (`/dashboard/incidents/:incidentId`), which shows the full incident record (type, severity chip, status, description, coordinates, independent-source confirmation count/confidence, assigned responder name), its damage reports, and its audit trail — read-only ("drills into incidents" half of the acceptance criterion, distinct from Verification's action-oriented screens).

## Entry points

Grepped from `lib/app/router.dart` and `lib/app/route_guard.dart`:

| Route | Screen | Permission required |
|---|---|---|
| `/dashboard` | `CommandDashboardScreen` (default title "Command Dashboard") | `Permission.monitorZones` |
| `/dashboard/incidents/:incidentId` | `IncidentDetailScreen(incidentId: ...)` | Not in `defaultRoutePermissions` map directly — `route_guard.dart` special-cases any path starting with `dashboardIncidentDetailPrefix = '/dashboard/incidents/'` to require `Permission.monitorZones` (same permission as the parent dashboard) |
| `/state/oversight` | `CommandDashboardScreen(title: 'Cross-District Oversight')` — same widget, reused | `Permission.crossDistrictOversight` |

## Architecture

- **`domain/`** — `dashboard_snapshot.dart`: a plain immutable data class, no logic beyond derived getters.
- **`application/`** — `dashboard_aggregator.dart`: a pure function (`buildDashboardSnapshot`) with zero IO, taking already-fetched lists from every contributing module and filtering/sorting/summing them; `dashboard_providers.dart`: the IO half — a single `FutureProvider.autoDispose` that reads six other providers/services from other feature modules (map, alerts, sync, core) and feeds their output into the pure aggregator.
- **`presentation/`** — two screens: `command_dashboard_screen.dart` (KPI/map/panels, reused for two routes) and `incident_detail_screen.dart` (drill-down, defines two of its own private `FutureProvider.autoDispose.family` providers inline rather than in `application/`).
- Deliberately introduces no new persistence — everything is read-only aggregation across `LocalHazardZoneRepository`/`hazardZonesProvider`, `habitationsOverviewProvider`, `incidentsProvider`, `AlertBroadcastService.history()`, `pendingSyncCountProvider`, and `LocalUserRepository`.

## Files in this module

### `lib/features/dashboard/domain/dashboard_snapshot.dart`
- **Purpose**: Immutable holder for everything the dashboard renders in one pass: red zones, vulnerable habitations, total capacity gap, active incidents, active alerts, pending sync count, responder count, plus four derived `int` count getters used directly by the KPI cards and section badges.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `DashboardSnapshot` (const constructor); getters `redZoneCount`, `vulnerableHabitationCount`, `activeIncidentCount`, `activeAlertCount`.
- **Notable imports**: `core/database/app_database.dart` (`LocalHazardZone`, `LocalIncident`, `LocalAlert`), `map/domain/habitation_overview.dart` (`HabitationOverview` — cross-module dependency on Map feature's combined habitation+risk+capacity view).
- **Depends on**: nothing beyond those model types.
- **Depended on by**: `dashboard_aggregator.dart`, `dashboard_providers.dart`, `command_dashboard_screen.dart`, the dashboard test.
- **State read/written**: none — pure data holder.
- **External communication**: none.
- **Mock/demo content**: none.

### `lib/features/dashboard/application/dashboard_aggregator.dart`
- **Purpose**: The module's pure "deterministic core" (per its own doc comment) — turns raw lists into the `DashboardSnapshot` the UI renders, with no clock/IO reads of its own so it is directly unit-testable.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `buildDashboardSnapshot({hazardZones, habitations, incidents, alerts, pendingSyncCount, responderCount, now, alertEngine})` — red zones = hazard zones with `severity` `high`/`critical`; vulnerable habitations = those whose `riskAssessment.riskClass` parses to `RiskClass.high` or `RiskClass.red`; total capacity gap = sum of `capacityAssessment.capacityGap` over habitations where `hasSufficientCapacity == false`; active incidents = those whose `IncidentVerificationStatus` is neither `rejected` nor `resolved`, sorted by a hardcoded severity rank map (`critical=4 > high=3 > medium=2 > low=1`) then by `createdAt` descending; active alerts = those for which `AlertEngine.isActive(alert, now)` is true (reuses the Alerts module's engine, injectable for tests, defaults to `AlertEngine()`).
- **Notable imports**: `core/database/app_database.dart`, `features/alerts/application/alert_engine.dart` (direct cross-module reuse of `AlertEngine`), `features/map/domain/habitation_overview.dart`, `features/risk/domain/risk_class.dart` (`RiskClass.values.byName`), `features/verification/domain/incident_verification_status.dart` (`IncidentVerificationStatus.fromStorageValue`).
- **Depends on**: `AlertEngine` (alerts module), `RiskClass` (risk module), `IncidentVerificationStatus` (verification module) — this file is a genuine cross-module integration point, not self-contained.
- **Depended on by**: `dashboard_providers.dart`, `dashboard_aggregator_test.dart`.
- **State read/written**: none — pure function.
- **External communication**: none.
- **Mock/demo content**: none.

### `lib/features/dashboard/application/dashboard_providers.dart`
- **Purpose**: The IO half of M18 — one `FutureProvider.autoDispose<DashboardSnapshot>` that awaits five other providers/service calls (from the Map, Alerts, Sync, and core-database layers) in sequence and hands the results to `buildDashboardSnapshot`.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `dashboardSnapshotProvider` — awaits `hazardZonesProvider.future`, `habitationsOverviewProvider.future`, `incidentsProvider.future` (all from `map/application/map_data_providers.dart`), `alertBroadcastServiceProvider.history()` (alerts module), `pendingSyncCountProvider.future` (`sync/application/sync_providers.dart`), and `localUserRepositoryProvider.getAll()` (core), then locally filters users where `role == 'fieldResponder'` to compute `responderCount`.
- **Notable imports**: `core/providers/core_providers.dart`, `features/alerts/application/alert_providers.dart`, `features/map/application/map_data_providers.dart`, `features/sync/application/sync_providers.dart`.
- **Depends on**: `hazardZonesProvider`, `habitationsOverviewProvider`, `incidentsProvider` (map), `alertBroadcastServiceProvider` (alerts), `pendingSyncCountProvider` (sync), `localUserRepositoryProvider` (core) — five cross-module dependencies.
- **Depended on by**: `command_dashboard_screen.dart`.
- **State read/written**: reads `local_hazard_zones`, habitation/risk/capacity tables (via `habitationsOverviewProvider`), `local_incidents`, `local_alerts` (via alert history), `sync_queue` (via pending count), `local_users`. Writes nothing.
- **External communication**: none directly — all reads are local Drift via the composed providers; note this module does not itself talk to Firestore.
- **Mock/demo content**: none. The `role == 'fieldResponder'` string comparison against the `LocalUser.role` column is a literal string match, not an enum comparison — worth flagging as a fragile-but-real (not mock) implementation detail.

### `lib/features/dashboard/presentation/command_dashboard_screen.dart`
- **Purpose**: The main dashboard UI — KPI row, situational map, and left/right list panels, responsive between a single mobile column and a two-column desktop "situation room."
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `CommandDashboardScreen` (`ConsumerWidget`, takes an optional `title`, defaulting to `'Command Dashboard'`, reused with `'Cross-District Oversight'` for `/state/oversight`); `_leftSections`/`_rightSections` (build the six `_SectionCard` panels); private widgets `_SituationMap` (wraps `TaarakMapView` with hazard/shelter/incident/habitation overlay layers from `features/map/presentation/widgets/map_overlay_layers.dart`), `_KpiRow`/`_KpiCard` (six colored stat cards), `_SectionCard` (generic titled/counted collapsible list card).
- **Notable imports**: `go_router` (`context.push` for incident drill-down), `latlong2`, `core/gis/default_map_center.dart` + `severity_palette.dart`, `dashboard_providers.dart`, `dashboard_snapshot.dart`, `features/map/application/map_data_providers.dart` (`sheltersProvider`, `hazardZonesProvider`, `incidentsProvider`, `habitationsOverviewProvider`), `features/map/presentation/widgets/*` (map view + overlay builders — cross-module reuse of the Map feature's rendering), `features/profile/application/location_status_controller.dart` (`locationStatusProvider` — used only to center the map on the viewer's own GPS fix, falling back to `defaultMapCenter`), `features/risk/presentation/risk_class_color.dart` + `domain/risk_class.dart`.
- **Depends on**: `dashboardSnapshotProvider`, four Map-feature providers, `locationStatusProvider` (Profile feature), `RiskClass`/`riskClassColor` (Risk feature) — heavily cross-module for a "dashboard."
- **Depended on by**: routed at `/dashboard` and `/state/oversight`.
- **State read/written**: none directly; purely reads providers.
- **External communication**: none directly.
- **Mock/demo content**: none — every panel renders real snapshot data; empty states use real `emptyText` strings (e.g. `"No high/critical hazard zones currently tracked."`), not lorem-ipsum placeholders.

### `lib/features/dashboard/presentation/incident_detail_screen.dart`
- **Purpose**: Read-only drill-down for a single incident: full record, its damage reports, and its audit trail, reached by tapping an incident row on the dashboard.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `IncidentDetailScreen({required incidentId})`; two module-private providers defined inline (not in `application/`): `_incidentProvider` (`FutureProvider.autoDispose.family`, reads `localIncidentRepositoryProvider.getById(id)`), `_auditTrailProvider` (reads `incidentVerificationServiceProvider.auditTrailFor(id)`, cross-module dependency on the Verification feature).
- **Notable imports**: `core/providers/core_providers.dart`, `features/command/application/command_providers.dart` (imported but its only visible use in this file is not apparent from a first read — see note below), `features/field_response/application/field_response_providers.dart` (`fieldRespondersProvider`, `damageReportsForIncidentProvider` — cross-module dependency on Field Response), `features/verification/application/verification_providers.dart` (`incidentVerificationServiceProvider` — cross-module dependency on Verification).
- **Depends on**: `localIncidentRepositoryProvider` (core), `incidentVerificationServiceProvider` (verification), `fieldRespondersProvider` + `damageReportsForIncidentProvider` (field_response). The import of `features/command/application/command_providers.dart` appears unused in the visible widget tree/provider code of this file — likely leftover from a refactor; flagged under Known Limitations rather than assumed.
- **Depended on by**: routed at `/dashboard/incidents/:incidentId`.
- **State read/written**: reads `local_incidents` (by id), `audit_log`/verification audit trail, field-response damage reports, cached field-responder list. Writes nothing — purely a viewer.
- **External communication**: none directly.
- **Mock/demo content**: none — the "no responder assigned yet" and "Incident not found" states are real empty/null-guard branches, not stubs.

### `test/features/dashboard/dashboard_aggregator_test.dart`
- **Purpose**: Pure unit tests of `buildDashboardSnapshot` using hand-built Drift model fixtures (`zone`, `habitation`, `riskAssessment`, `capacityAssessment`, `incident`, `alert` helper functions) — no database, no widget pump, no IO.
- **Status**: IMPLEMENTED.
- **Key classes/functions/tests**: "red zones are hazard zones with high or critical severity only"; "vulnerable habitations are those risk-classified high or red" (including an unassessed habitation correctly excluded); "total capacity gap sums only habitations with an actual shortfall" (a negative gap/surplus correctly excluded from the sum); "active incidents exclude rejected/resolved, sorted by severity then recency"; a test literally named `'COMMAND USER UNDERSTANDS CURRENT SITUATION — the acceptance criterion: active alerts respect validity, not just existence'` (active/expired/cancelled alerts, only the truly-active one counted); "pending sync count and responder count pass through unchanged."
- **Notable imports**: `flutter_test`, `core/database/app_database.dart`, `dashboard_aggregator.dart`, `features/map/domain/habitation_overview.dart`.
- **External communication**: none.

## Data Models

`DashboardSnapshot` (`lib/features/dashboard/domain/dashboard_snapshot.dart`):
- `redZones: List<LocalHazardZone>` — hazard zones with severity high/critical.
- `vulnerableHabitations: List<HabitationOverview>` — habitations risk-classified high/red.
- `totalCapacityGap: int` — summed shortfall across under-capacity habitations.
- `activeIncidents: List<LocalIncident>` — non-rejected, non-resolved, severity+recency sorted.
- `activeAlerts: List<LocalAlert>` — currently-active alerts per `AlertEngine.isActive`.
- `pendingSyncCount: int` — passthrough from the sync module.
- `responderCount: int` — count of cached local users with `role == 'fieldResponder'`.
- Derived getters: `redZoneCount`, `vulnerableHabitationCount`, `activeIncidentCount`, `activeAlertCount`.

No other domain models are defined in this module — it consumes `LocalHazardZone`, `LocalIncident`, `LocalAlert`, `HabitationOverview` (all owned by other modules).

## Services / Repositories

This module owns no repository or DAO — it is a pure read/aggregation layer. Its only "service" is the function `buildDashboardSnapshot` (application/dashboard_aggregator.dart), which is deliberately not a class since it needs no state or DI beyond its parameters and an optional injectable `AlertEngine`.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/dashboard` | `CommandDashboardScreen` | `Permission.monitorZones` | District/Command home/menu navigation (outside this module) |
| `/dashboard/incidents/:incidentId` | `IncidentDetailScreen` | `Permission.monitorZones` (via `dashboardIncidentDetailPrefix` special-case in `route_guard.dart`) | Tapping an incident row on `CommandDashboardScreen` |
| `/state/oversight` | `CommandDashboardScreen(title: 'Cross-District Oversight')` | `Permission.crossDistrictOversight` | State/Admin home/menu navigation (outside this module) |

## Module Data Flow

**Command user opens the dashboard (the acceptance criterion — understanding current situation, then drilling into an incident):**

```
CommandDashboardScreen.build()
  -> ref.watch(dashboardSnapshotProvider)
    -> await hazardZonesProvider.future           [map module -> reads local_hazard_zones]
    -> await habitationsOverviewProvider.future    [map module -> reads habitations + risk + capacity tables]
    -> await incidentsProvider.future              [map module -> reads local_incidents]
    -> await alertBroadcastServiceProvider.history()   [alerts module -> reads local_alerts]
    -> await pendingSyncCountProvider.future       [sync module -> reads sync_queue]
    -> await localUserRepositoryProvider.getAll()  [core -> reads local_users, filtered to role=='fieldResponder']
    -> buildDashboardSnapshot(...)                 [pure: filter red zones, vulnerable habitations, sum capacity gap,
                                                      sort active incidents, filter active alerts via AlertEngine.isActive]
    <- DashboardSnapshot
  renders _KpiRow, _SituationMap (TaarakMapView + overlay layers), _leftSections, _rightSections

user taps an incident ListTile
  -> context.push('/dashboard/incidents/${incident.id}')
    -> route_guard.dart: '/dashboard/incidents/' prefix -> requires Permission.monitorZones
    -> IncidentDetailScreen(incidentId)
       -> _incidentProvider(id) -> localIncidentRepositoryProvider.getById(id)   [reads local_incidents]
       -> _auditTrailProvider(id) -> incidentVerificationServiceProvider.auditTrailFor(id)  [verification module]
       -> fieldRespondersProvider, damageReportsForIncidentProvider(id)          [field_response module]
    renders full record + damage reports + audit trail, read-only
```

## Current Status

**Working.** Evidence: the pure aggregation logic (`buildDashboardSnapshot`) has full unit-test coverage including an explicitly-named acceptance-criterion test; both screens are wired to real providers with no placeholder data; the module correctly composes six other already-working modules rather than introducing new state.

## Known Limitations

- `/state/oversight` reuses the identical `CommandDashboardScreen` widget and the identical `dashboardSnapshotProvider` as `/dashboard` — there is no district-scoping or state-wide-vs-single-district filtering anywhere in this module's code. A State/Admin user sees the exact same aggregate data a District/Command user would, just under a different title string. If genuine cross-district aggregation is expected, it does not exist in this module.
- `incident_detail_screen.dart` imports `features/command/application/command_providers.dart` but no provider from it is visibly referenced in the widget/provider code read — a likely dead/leftover import (does not affect behavior since Dart only errors on unused imports as a lint, not a compile failure, and this codebase's lint config was not checked here).
- `dashboard_providers.dart` derives `responderCount` via a raw string comparison (`user.role == 'fieldResponder'`) against the Drift-stored role column rather than parsing into the `UserRole` enum used elsewhere in the app — functionally correct today but fragile if the stored string representation ever changes independently of the enum.
- No widget/screen-level test exists for either presentation file — only the pure aggregator is tested.

## Test Coverage

- `test/features/dashboard/dashboard_aggregator_test.dart` — thorough coverage of `buildDashboardSnapshot`: red-zone severity filter, vulnerable-habitation risk-class filter (including "not yet assessed" exclusion), capacity-gap summation (including surplus exclusion), active-incident status filter + severity/recency sort, active-alert validity filter (the named acceptance-criterion test), and passthrough of `pendingSyncCount`/`responderCount`.
- **Not covered by any test**: `dashboard_providers.dart` (the IO composition — no test exercises `dashboardSnapshotProvider` itself, e.g. via a provider-container test), `command_dashboard_screen.dart` (no widget test — responsive layout switching, KPI rendering, map overlay composition are all unverified by automated tests), `incident_detail_screen.dart` (no widget test — the two inline `_incidentProvider`/`_auditTrailProvider` providers are untested, including the "incident not found" branch and the assigned-responder name lookup).
