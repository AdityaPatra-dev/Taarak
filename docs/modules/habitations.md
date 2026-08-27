# MODULE: Habitations

## Purpose

This module is the front door for getting a real, official-registered "vulnerable habitation" (a settlement/locality) into the local cache — the literal subject the whole app's problem statement is named after ("Vulnerable Habitations"). It answers "which populated places exist, where, how many people, and how exposed/hard-to-reach are they." Its own doc comment is direct about why it exists: "Until this existed, `LocalHabitation` rows only ever came from a demo seeder; [the risk/capacity/relocation engines'] engines were real but had nothing an official actually registered to run against." This module is deliberately narrow — registration only. It does not compute risk, carrying capacity, or relocation plans itself; those engines (documented elsewhere, out of this module's scope) read the `LocalHabitation` rows this module writes.

## User-facing functionality

- **Local Official** and **District/Command** (permission `manageHabitations` — granted to `UserRole.localOfficial`, `UserRole.districtCommand`, and `UserRole.stateAdmin` in `user_role.dart`): opens "Register Habitation" (`RegisterHabitationScreen`) and:
  1. Taps a point on a map (reusing `TaarakMapView`/`TaarakMapController` from the `map` module) to mark the habitation's location — its own doc comment notes this "mirrors ReportHazardZoneScreen's map-tap-then-form shape."
  2. Fills in a name, population (numeric), an optional administrative-region name, and two dropdown-selected quality indicators: "Access to the habitation" (easy/moderate/difficult, mapped to 0.2/0.5/0.8) and "Infrastructure quality" (robust/average/fragile, same 0.2/0.5/0.8 mapping).
  3. Submits — the button is disabled until a location is tapped, a name is entered, and population parses as a number.
  4. Below the form, every already-registered habitation renders in a scrollable list showing name and population.
- There is no browse/edit/delete flow for an already-registered habitation in this module — re-registering (submitting the form again) with the same generated id would be the only way to update one, but the form itself never loads an existing habitation for editing (unlike, for example, the `shelters` module's form, which supports both create and edit from the same screen). Every submission through this screen creates a fresh habitation with a newly generated id.

## Entry points

- Route `/habitations/register` in `lib/app/router.dart` → `RegisterHabitationScreen`. Guarded in `lib/app/route_guard.dart`'s `defaultRoutePermissions` map by `Permission.manageHabitations` (`'/habitations/register': Permission.manageHabitations`).
- Reachable from the home screen's quick-action grid for any role whose `rolePermissions` set includes `manageHabitations` (`localOfficial`, `districtCommand`, `stateAdmin`).

## Architecture

Application / presentation layering only — **no `domain/` folder** in this module (it defines no domain value types of its own; it operates directly on the `LocalHabitation` Drift row), and no `data/` folder (persistence delegated to `LocalHabitationRepository` in `lib/core/database/repositories/`, outside this module):

- **application/** — `HabitationRegistrationService` (the one write-side service this module owns: register/update, list all — audited and sync-queued, explicitly noted as "mirrors [HazardIngestionService]'s shape"), `habitation_providers.dart` (Riverpod wiring).
- **presentation/** — `RegisterHabitationScreen` (tap-to-place map + form + registered-list).

## Files in this module

### `lib/features/habitations/application/habitation_providers.dart`
- **Purpose:** Riverpod wiring for the registration service and the list-all read provider.
- **Status:** IMPLEMENTED.
- **Key providers:** `habitationRegistrationServiceProvider`; `habitationsProvider` (`FutureProvider.autoDispose<List<LocalHabitation>>`, reads `listAll()` and degrades to empty list on failure).
- **Depends on:** `core/providers/core_providers.dart` (`localHabitationRepositoryProvider`, `syncQueueDaoProvider`, `auditLogDaoProvider`). **Depended on by:** `RegisterHabitationScreen`. Note: this module's `habitationsProvider` is distinct from the `map` module's `habitationsOverviewProvider` — this one returns bare `LocalHabitation` rows for the registration list; the map module's joins those rows with risk/capacity/relocation assessments for map rendering. Both ultimately read the same `local_habitations` table.

### `lib/features/habitations/application/habitation_registration_service.dart`
- **Purpose:** The write path: registers a new habitation (or re-registers/updates an existing one if the same `id` is passed) with location, population, and the optional administrative-region/quality-indicator fields. Every write is audited and sync-queued, mirroring the `hazards` module's `HazardIngestionService` shape (per this file's own doc comment) and the general pattern established across the app's write-side services.
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `HabitationRegistrationService` — `register({id?, name, latitude, longitude, population, administrativeRegionName?, infrastructureQuality?, accessQuality?, officialId, now?})` → `Result<LocalHabitation>` (computes `nextVersion` by checking for an existing row at the given/generated id — `existing.dataOrNull == null` determines whether the sync-queue operation is `'create'` or `'update'` and whether the audit action is `habitation.registered` or `habitation.updated`); `listAll()` → `Result<List<LocalHabitation>>`.
- **Notable imports:** `uuid` (new habitation ids when `id` is omitted).
- **Depends on:** `LocalHabitationRepository`, `SyncQueueDao?`, `AuditLogDao?` (both optional constructor params — the service degrades gracefully, silently skipping the sync/audit side effects, if either is omitted). **Depended on by:** `habitation_providers.dart`, `RegisterHabitationScreen` directly, and indirectly every downstream engine that reads `LocalHabitation` rows (risk assessment, capacity-gap, relocation, routing's evacuation-planning methods) — none of which are documented in this file, per this module's defined scope, but all of which have nothing real to run against without this module's write path.
- **State:** writes `local_habitations` (via repository), `sync_queue`, `audit_log`.
- **External communication:** none directly — sync propagation to Firestore's `local_habitations` collection is the sync module's concern, reached only via the enqueued sync-queue row.
- **Demo/mock content:** none — this is the real, only write path for habitations aside from the `map` module's `DemoMapDataSeeder`, which (see map.md) inserts `LocalHabitation` rows directly via Drift `batch()`, bypassing this service entirely (no audit entry, no sync-queue entry) — and which, as documented in map.md, is currently unreferenced dead code with no call site anywhere in the running app.

### `lib/features/habitations/presentation/register_habitation_screen.dart`
- **Purpose:** The only UI in this module, and — per its own doc comment — "the registration screen [the risk/capacity/relocation engines'] never had a front door for: until this existed, a `LocalHabitation` only ever came from a demo seeder, so the ... pipeline had nothing real to run against." Described in User-facing functionality above.
- **Status:** IMPLEMENTED and wired to the real service (`_submit` calls `habitationRegistrationServiceProvider.register` for real).
- **Key classes:** `RegisterHabitationScreen` (stateful) / `_RegisterHabitationScreenState`. `_canSubmit()` — gates the submit button on a tapped location, a non-empty name, and a parseable population. `_accessOptions`/`_infraOptions` — module-level `Map<double, String>` constants mapping the three quality bands (0.2/0.5/0.8) to their dropdown labels ("Easy access"/"Moderate access"/"Difficult access"; "Robust infrastructure"/"Average infrastructure"/"Fragile infrastructure").
- **Notable imports:** `google_maps_flutter` directly (for the single location marker), `map/presentation/widgets/taarak_map_controller.dart`/`taarak_map_view.dart` (the `map` module's shared base map, reused here for the tap-to-place form — this module does not import `map_data_providers.dart` or any map overlay-layer builder, only the base map widget itself).
- **Depends on:** `habitationRegistrationServiceProvider`, `habitationsProvider` (both this module's own), `locationStatusProvider` (profile module, for the form's fallback map center), `currentUserProvider` (auth module, for `officialId`). **Depended on by:** router (`/habitations/register` route).
- **State:** reads `habitationsProvider`; writes via `habitationRegistrationServiceProvider.register`, invalidating `habitationsProvider` and clearing the form on success.
- **External communication:** Google Maps SDK (tap-to-place marker), device GPS indirectly via `locationStatusProvider` (fallback map center only — not required to submit the form).
- **Demo/mock content:** none.

## Data Models

This module defines no domain value types of its own — it operates directly on:

- **`LocalHabitation`** (Drift row, `core/database/tables/local_habitations_table.dart`) — `id`, `name`, `latitude`, `longitude`, `population` (default 0), `administrativeRegionName: String?` ("a plain string for now rather than a normalized region table, since nothing yet needs to browse/filter by region hierarchy," per the table's own comment), `infrastructureQuality: double?` (0.0 robust/easy – 1.0 fragile/remote; null means "not yet configured," and the downstream vulnerability engine — out of this module's scope — falls back to a neutral value rather than treating unset data as either safe or unsafe, per the table's own comment), `accessQuality: double?` (same 0.0–1.0 scale, same null-means-unset semantics), `updatedAt`, `version`.

## Services / Repositories

- **`HabitationRegistrationService`** — the sole service in this module; register/re-register (audited, sync-queued) + list all. See Files above for full detail.
- **`LocalHabitationRepository`** (outside this module, in `core/database/repositories/`) — the actual Drift persistence layer this service writes through, and the same repository the `map` module's `habitationsOverviewProvider`, the `routing` module's evacuation-planning methods, and the (undocumented, out-of-scope) risk/capacity/relocation engines all read from.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/habitations/register` | `RegisterHabitationScreen` | `Permission.manageHabitations` | Home screen quick actions (Local Official, District/Command, State/Admin). |

## Module Data Flow

An official registers a new habitation:

```
RegisterHabitationScreen  (route: /habitations/register, guarded by Permission.manageHabitations)
  ref.watch(habitationsProvider) → HabitationRegistrationService.listAll()
                                    → LocalHabitationRepository.getAll()  → registered-list renders

Official taps the map to mark a location, fills in name/population/region/access/infrastructure, taps "Register habitation"
  → _submit()
      → ref.read(habitationRegistrationServiceProvider).register(
            name, latitude, longitude, population,
            administrativeRegionName, infrastructureQuality, accessQuality,
            officialId: currentUserProvider.id)
          HabitationRegistrationService.register()
            → id = uuid.v4()  (no id passed by this screen — every submission is a NEW habitation)
            → LocalHabitationRepository.getById(id)          (always misses for a fresh uuid → nextVersion = 1)
            → LocalHabitationRepository.save(LocalHabitation(...))
            → SyncQueueDao.enqueue(entityTable: 'local_habitations', operation: 'create', payload)
            → AuditLogDao.record(action: 'habitation.registered', newValue: {name, population})
            → Result.success(row)
  → ref.invalidate(habitationsProvider)   → registered-list refreshes; form fields clear
  → snackbar: "Habitation registered"

Downstream (out of this module's documented scope, but load-bearing for the app's core purpose):
  RiskAssessmentService.assessAllHabitations()     → reads this LocalHabitation row
  CapacityGapEngine.assess()                        → reads it against shelter capacity
  RelocationPlanningService.planForHabitation()     → reads it to rank relocation candidates
  RoutingService.planEvacuationRoute(habitationId)  → reads it (routing module) to plan an evacuation route
  map module's habitationsOverviewProvider          → joins it with the above engines' output for map rendering
```

## Current Status

**Working.** The registration write path (screen → service → repository → audit log → sync queue) is real, tested end-to-end with an in-memory Drift database, and is — per this module's own doc comments and the file structure itself — a deliberate fix for a real gap: before this module existed, every `LocalHabitation` row in the system came from `DemoMapDataSeeder` (the `map` module's dev-only, and currently unreferenced, seed data — see map.md), meaning the risk/capacity/relocation engines had correct logic but no real data to run against. This module is that missing entry point, and it is fully wired and functional.

## Known Limitations

- **No edit/update UI** — `HabitationRegistrationService.register()` supports re-registering an existing `id` (incrementing its version and logging `habitation.updated`), but `RegisterHabitationScreen` never passes an existing `id` — every form submission generates a fresh `uuid.v4()`, so in practice this module can only ever *create* new habitations through its UI, never edit one already registered. The update path exists at the service layer (and is tested) but has no UI caller.
- **No delete/deactivate path** — there is no way, through this module, to remove a habitation that was registered in error or no longer exists (e.g. the population relocated permanently). This would presumably be an admin content-moderation action, mirroring the `hazards`/`verification` modules' delete patterns, but no such action exists in this module.
- **`infrastructureQuality`/`accessQuality` are coarse three-point scales** (0.2/0.5/0.8 only, via a fixed dropdown), not a continuous input — an official cannot record a value between these bands even though the underlying column is a `double`.
- **No duplicate-detection** — registering a habitation with the same name and nearby coordinates as an already-registered one creates a second, entirely separate row; there is no proximity or name-similarity check.
- **Population has no upper/lower sanity bound** — `int.tryParse` accepts any non-negative-looking integer string; there's no validation against, e.g., an implausibly large population for a single habitation.

## Test Coverage

`test/features/habitations/` contains one file:

- **`habitation_registration_service_test.dart`** — a new habitation is saved locally, queued for sync (`entityTable: 'local_habitations'`, `operation: 'create'`), and audited (`habitation.registered`); re-registering the same id increments its version, logs `operation: 'update'` in the sync queue, and audits `habitation.updated`; `listAll` returns every registered habitation.

**Not covered by any test in this module:** `RegisterHabitationScreen` has no widget test in `test/features/habitations/` — the tap-to-place map interaction, form validation (`_canSubmit`), the dropdown quality-indicator mapping, and the registered-habitations list rendering are all untested at this layer. `habitation_providers.dart` has no dedicated provider-wiring test. There is no test in this module verifying the downstream engines (risk/capacity/relocation/routing) actually consume a `LocalHabitation` row written through this specific service — that kind of cross-module proof exists for the `shelters` module (`shelter_capacity_feeds_relocation_test.dart`, see shelters.md) but has no equivalent counterpart under `test/features/habitations/`.
