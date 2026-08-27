# MODULE: Command

## Purpose

Command gives a District/Command official the three "act on it" screens that follow from the Dashboard's situational picture: assign field responders to incidents, track physical response resources (vehicles, medical supplies, personnel counts), and trigger relocation for habitations that another module (Relocation Planning, M10) has already identified as needing to move, generating a real routed evacuation path for the top candidate shelter. It does not compute risk or relocation priority itself — it is the operational front-end that turns those already-computed recommendations into an assignment or a route.

## User-facing functionality

- **District/Command** (`Permission.manageResponders`, screen `ManageRespondersScreen` at `/command/responders`): sees every tracked incident as a card with a severity chip and status, each with a dropdown to assign (or unassign) a Field Responder account. If no Field Responder accounts exist yet, shows an explicit message telling the official to promote one from Manage Accounts first.
- **District/Command** (`Permission.manageResources`, screen `ManageResourcesScreen` at `/command/resources`): a list of tracked resources (name, type, quantity) with a floating "Add resource" button and a per-row edit icon, both opening the same `AlertDialog` form (name/type/quantity text fields).
- **District/Command** (`Permission.manageRelocation`, screen `ManageRelocationScreen` at `/command/relocation`): lists only habitations whose `relocationPlan.populationToRelocate > 0`, each showing the population needing relocation and the best-ranked shelter candidate (name + distance in km, decoded from `rankedCandidatesJson`). An "Confirm relocation & route" button triggers real evacuation-route planning and navigates to `/map` to show the resulting route.

## Entry points

Grepped from `lib/app/router.dart` and `lib/app/route_guard.dart`:

| Route | Screen | Permission required |
|---|---|---|
| `/command/responders` | `ManageRespondersScreen` | `Permission.manageResponders` |
| `/command/resources` | `ManageResourcesScreen` | `Permission.manageResources` |
| `/command/relocation` | `ManageRelocationScreen` | `Permission.manageRelocation` |

All three are flat routes (no path params), granted only to `UserRole.districtCommand` by default (State/Admin also independently holds `Permission.manageRelocation`, per `rolePermissions` in `user_role.dart`, so `/command/relocation` is reachable by that role too even though `/command/responders` and `/command/resources` are not).

## Architecture

- **`application/`** — `command_providers.dart` (Riverpod wiring: `resourceManagementServiceProvider`, `resourcesProvider`, `fieldRespondersProvider`) and `resource_management_service.dart` (the only genuine service this module owns — CRUD + audit + sync-enqueue for `LocalResource`).
- **`presentation/`** — three `ConsumerWidget` screens, none of which owns its own Riverpod state beyond local dialog/form controllers; they read providers from this module (`resourcesProvider`, `fieldRespondersProvider`) and from three *other* modules directly (`incidentsProvider`/`habitationsOverviewProvider` from Map, `incidentVerificationServiceProvider` from Verification, `routingServiceProvider`/`routesProvider` from Routing).
- No `domain/` or `data/` folder — the module's only real domain object (`LocalResource`) is a shared Drift table (`lib/core/database/tables/local_resources_table.dart`), and responder assignment / relocation planning are entirely delegated to other modules' services (Verification's `assignResponder`, Routing's `planEvacuationRoute`) rather than reimplemented here. Command is intentionally thin — a coordination layer over Map, Verification, Routing, and Admin.

## Files in this module

### `lib/features/command/application/resource_management_service.dart`
- **Purpose**: District/Command's write path for tracked response resources — list all, and a single create-or-update (`upsertResource`) keyed on an optional `id` (omitted = create), following the same shape the doc comment says is shared with `ShelterManagementService.upsertShelter`.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `ResourceManagementService` (constructor DI: `LocalResourceRepository`, `AuditLogDao`, optional `SyncQueueDao`); `listResources()`; `upsertResource({id, name, type, quantity, shelterId, officialId, now})` — looks up the previous version if updating, bumps `version`, saves via the repository, enqueues a sync-queue "create" op (JSON payload — note: always `'create'` even on update, see Known Limitations), writes an audit record (`resource.created` or `resource.updated`).
- **Notable imports**: `uuid`, `core/database/app_database.dart`, `core/database/audit_log_dao.dart`, `core/database/repositories/local_resource_repository.dart`, `core/database/sync_queue_dao.dart`, `core/repository/result.dart`.
- **Depends on**: `LocalResourceRepository`, `AuditLogDao`, optional `SyncQueueDao`.
- **Depended on by**: `command_providers.dart` (`resourceManagementServiceProvider`), `ManageResourcesScreen`.
- **State read/written**: reads/writes `local_resources`; writes `audit_log`; writes `sync_queue` when a DAO is supplied.
- **External communication**: none directly — local Drift only, sync-queue is the hook for later remote propagation.
- **Mock/demo content**: none.

### `lib/features/command/application/command_providers.dart`
- **Purpose**: Riverpod wiring for this module: constructs `ResourceManagementService`, exposes the resource list as a `FutureProvider.autoDispose` (swallows failure to `const []`), and derives the Field Responder picker list by filtering the System Admin's full user list.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `resourceManagementServiceProvider`; `resourcesProvider`; `fieldRespondersProvider` — per its own doc comment, deliberately reuses `adminUsersProvider.future` (System Admin's account-read path) rather than a second dedicated query, then filters client-side to `role == UserRole.fieldResponder`.
- **Notable imports**: `core/providers/core_providers.dart`, `features/admin/application/admin_providers.dart` (`adminUsersProvider` — cross-module dependency on Admin), `features/admin/domain/admin_user_summary.dart`, `features/auth/domain/user_role.dart`.
- **Depends on**: `ResourceManagementService`, `adminUsersProvider` (admin module).
- **Depended on by**: all three presentation screens.
- **State read/written**: none directly.
- **External communication**: none directly; `adminUsersProvider` ultimately reads Firebase-backed account data through the Admin module (not verified further here as out of scope).
- **Mock/demo content**: none.

### `lib/features/command/presentation/manage_responders_screen.dart`
- **Purpose**: Lets a District/Command official assign or unassign a Field Responder to each tracked incident via a per-row dropdown.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `ManageRespondersScreen`; private `_IncidentAssignmentRow` — renders one incident + a `DropdownButton<String?>` of responders (including an explicit "Unassigned" null option), calls `_assign` on change, which calls `incidentVerificationServiceProvider.assignResponder(incidentId, responderId, officialId)` and invalidates `incidentsProvider`. Guards against a dropdown showing a stale assignee: `assignedExists = responders.any((r) => r.uid == assignedId)` — if the previously assigned responder no longer appears in the current list, the dropdown falls back to `null` rather than showing a dangling id.
- **Notable imports**: `core/database/app_database.dart` (`LocalIncident`), `features/admin/domain/admin_user_summary.dart`, `features/auth/application/auth_controller.dart` (`currentUserProvider`), `command_providers.dart`, `features/map/application/map_data_providers.dart` (`incidentsProvider` — cross-module), `features/verification/application/verification_providers.dart` (`incidentVerificationServiceProvider` — cross-module; the actual assignment write lives in the Verification module, not here).
- **Depends on**: `incidentsProvider` (map), `fieldRespondersProvider` (this module), `incidentVerificationServiceProvider` (verification).
- **Depended on by**: routed at `/command/responders`.
- **State read/written**: no local state beyond the widget tree; writes go through `incidentVerificationServiceProvider.assignResponder`, which (per this file alone) presumably updates `local_incidents.assignedResponderId` — the actual persistence code lives in the Verification module, out of scope here.
- **External communication**: none directly in this file.
- **Mock/demo content**: none — the "no Field Responder accounts exist yet" message is a real empty-state guard, not a placeholder.

### `lib/features/command/presentation/manage_resources_screen.dart`
- **Purpose**: List + add/edit UI for `LocalResource` records.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `ManageResourcesScreen`; module-level `_showEditDialog(context, ref, {existing})` — shared add/edit `AlertDialog` with three `TextEditingController`s (name/type/quantity), validates quantity parses as `int` and name/type are non-empty before calling `resourceManagementServiceProvider.upsertResource(...)`, then invalidates `resourcesProvider` and shows a success/failure `SnackBar`.
- **Notable imports**: `core/database/app_database.dart` (`LocalResource`), `features/auth/application/auth_controller.dart`, `command_providers.dart`.
- **Depends on**: `resourcesProvider`, `resourceManagementServiceProvider`, `currentUserProvider`.
- **Depended on by**: routed at `/command/resources`.
- **State read/written**: writes `local_resources` via the service.
- **External communication**: none directly.
- **Mock/demo content**: none. Note: `_showEditDialog`'s call always passes `shelterId: null` implicitly (the parameter is never populated from the UI, despite `ResourceManagementService.upsertResource` accepting one) — every resource created through this screen is unlinked from any shelter even though the underlying data model supports the link; flagged under Known Limitations.

### `lib/features/command/presentation/manage_relocation_screen.dart`
- **Purpose**: Surfaces habitations that already have a computed relocation plan with `populationToRelocate > 0` (from the Relocation Planning module, M10) and lets the official trigger the "act on it" step: generate a real routed evacuation path to the top-ranked shelter candidate.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `ManageRelocationScreen`; private `_RelocationCard` — decodes `plan.rankedCandidatesJson` (raw JSON list, cast via `jsonDecode(...) as List` then `.first as Map<String, dynamic>`), displays the top candidate's `shelterName` and `distanceMeters` (converted to km), and on button tap calls `ref.read(routingServiceProvider).planEvacuationRoute(item.habitation.id)`; on `Success<RoutePlan>` it invalidates `routesProvider` and pushes to `/map`; on `Failed` it shows the failure message in a `SnackBar`.
- **Notable imports**: `dart:convert` (`jsonDecode`), `go_router` (`context.push`), `core/repository/result.dart`, `features/map/application/map_data_providers.dart` (`habitationsOverviewProvider` — cross-module), `features/map/domain/habitation_overview.dart`, `features/routing/application/routing_providers.dart` (`routingServiceProvider`, `routesProvider` — cross-module, the actual routing computation lives in the Routing module), `features/routing/domain/route_candidate.dart` (`RoutePlan`).
- **Depends on**: `habitationsOverviewProvider` (map), `routingServiceProvider`/`routesProvider` (routing).
- **Depended on by**: routed at `/command/relocation`.
- **State read/written**: no local persistence in this file — triggers `RoutingService.planEvacuationRoute`, whose actual write target (likely `local_routes`) lives in the Routing module, out of scope here.
- **External communication**: none directly in this file.
- **Mock/demo content**: none — the `top == null` guard (empty candidate list) correctly disables the confirm button rather than crashing on `.first`.

## Data Models

`LocalResource` (Drift-generated from `lib/core/database/tables/local_resources_table.dart`, table `local_resources`):
- `id` (text, PK)
- `name` (text)
- `type` (text) — free-text, e.g. "vehicle", "medical", "personnel" (placeholder hint text in the UI, not an enum)
- `quantity` (int, default 0)
- `shelterId` (text, nullable) — optional link to a shelter; a resource can be tracked without one (e.g. a district-wide vehicle pool)
- `updatedAt` (DateTime)
- `version` (int, default 1)

This module does not define `LocalIncident`, `HabitationOverview`, or `LocalRelocationPlan` — it only consumes them from Map/Verification/Relocation modules. Relevant fields consumed: `LocalRelocationPlan.populationToRelocate` (int) and `.rankedCandidatesJson` (text — JSON array of candidate maps with at least `shelterName` and `distanceMeters` keys, per the UI's decode).

## Services / Repositories

- **`ResourceManagementService`** — this module's only service; full CRUD-by-upsert for `LocalResource`, with audit logging and sync-queue enqueueing.
- No repository is defined in this module — it reuses the shared `LocalResourceRepository` from `lib/core/database/repositories/`.
- Two of the three screens (responders, relocation) perform no writes of their own — they delegate entirely to `IncidentVerificationService.assignResponder` (Verification module) and `RoutingService.planEvacuationRoute` (Routing module) respectively.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/command/responders` | `ManageRespondersScreen` | `Permission.manageResponders` | District/Command menu/navigation (outside this module) |
| `/command/resources` | `ManageResourcesScreen` | `Permission.manageResources` | District/Command menu/navigation (outside this module) |
| `/command/relocation` | `ManageRelocationScreen` | `Permission.manageRelocation` | District/Command menu/navigation; also reachable to State/Admin, which independently holds `manageRelocation` |

## Module Data Flow

**Assign a responder:**
```
ManageRespondersScreen -> ref.watch(incidentsProvider) [map module]
                        -> ref.watch(fieldRespondersProvider) [this module -> filters adminUsersProvider by role]
_IncidentAssignmentRow dropdown change
  -> IncidentVerificationService.assignResponder(incidentId, responderId, officialId)  [verification module — writes local_incidents.assignedResponderId]
  -> ref.invalidate(incidentsProvider) -> list refreshes
```

**Add/edit a resource:**
```
ManageResourcesScreen -> ref.watch(resourcesProvider) -> ResourceManagementService.listResources() [reads local_resources]
FAB / edit icon -> _showEditDialog -> ResourceManagementService.upsertResource(...)
  -> LocalResourceRepository.save(resource)     [writes local_resources]
  -> SyncQueueDao.enqueue(operation:'create')    [writes sync_queue]
  -> AuditLogDao.record(action:'resource.created'|'resource.updated')  [writes audit_log]
ref.invalidate(resourcesProvider) -> list refreshes
```

**Confirm relocation & route (the module's most distinctive flow):**
```
ManageRelocationScreen -> ref.watch(habitationsOverviewProvider) [map module]
  -> filter: h.relocationPlan.populationToRelocate > 0
_RelocationCard decodes plan.rankedCandidatesJson -> top candidate
"Confirm relocation & route" tap
  -> RoutingService.planEvacuationRoute(habitation.id)   [routing module — computes a real RoutePlan, likely writes local_routes]
  -> Success -> ref.invalidate(routesProvider); context.push('/map')  [shows the new route on the map]
  -> Failed -> SnackBar(failure.message)
```

## Current Status

**Working**, but with no automated test coverage anywhere in this module (see below). Evidence of a working implementation: all three screens are fully wired to real Riverpod providers and real services (no TODO/stub bodies, no hardcoded lists), `ResourceManagementService` performs real Drift persistence with audit logging and sync-queue enqueueing, and the relocation screen correctly guards against an empty candidate list before enabling its action button.

## Known Limitations

- **No test directory exists for this module.** `test/features/command/` does not exist at all — confirmed by directory listing (`ls test/features` lists `admin, alerts, audit, auth, capacity, dashboard, device_relay, disaster_events, environmental, fusion, habitations, hazards, map, profile, relocation, reporting, risk, routing, shelters, sms_prototype, sync, verification, vulnerability` — no `command` entry). None of `ResourceManagementService`, `command_providers.dart`, or the three screens has any automated test.
- `ResourceManagementService._enqueueSync` always enqueues with `operation: 'create'`, even when `upsertResource` is actually performing an update (the surrounding code correctly distinguishes create vs. update for the *audit* action string `resource.created`/`resource.updated`, but not for the sync-queue operation) — a real inconsistency that could cause a sync consumer expecting operation-specific handling (e.g. insert-vs-upsert semantics) to mishandle resource updates.
- `manage_resources_screen.dart`'s add/edit dialog never lets the user set `shelterId`, even though `LocalResource` and `upsertResource` both support linking a resource to a shelter — every resource created via this UI is shelter-unlinked.
- `manage_responders_screen.dart` and `manage_relocation_screen.dart` perform no writes themselves; all persistence for assignment and routing lives in other modules (Verification, Routing), so this module's own responsibility is thin coordination — accurate to document, but means "Command" as a feature folder is not self-contained.
- The relocation screen's candidate decode (`jsonDecode(plan.rankedCandidatesJson) as List` then `.first as Map<String, dynamic>`) has no try/catch — a malformed or differently-shaped JSON payload from the Relocation Planning module would throw an unhandled exception rather than surfacing a `Result.failure`.

## Test Coverage

**None.** `test/features/command/` does not exist. There is no unit test for `ResourceManagementService`, no test for the Riverpod providers in `command_providers.dart`, and no widget test for `ManageRespondersScreen`, `ManageResourcesScreen`, or `ManageRelocationScreen`. This is an explicit gap, not an oversight of this documentation — it was verified by directory listing that the path is simply absent from `test/features/`.
