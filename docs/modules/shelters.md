# MODULE: Shelters

## Purpose

This module is the write path a Local Official uses to keep shelter data (location, total capacity, current occupancy, available facilities) current in the local cache. It answers "how many people can this shelter still take, and what does it offer." The read side of this data (shelter capacity/facilities feeding the risk/capacity-gap engine's shortfall calculations and the relocation engine's candidate ranking) already existed before this module — this module exists specifically so an official has a real screen to *write* that data rather than it only ever coming from the demo seeder.

## User-facing functionality

- **Local Official** (permission `manageSheltersResources`): opens "Shelters & Resources" (`ShelterManagementScreen`) and sees every registered shelter as a card (or a responsive grid on wide viewports) showing an occupancy progress bar (color-coded green/orange/red by fullness), an "X/Y occupied · Z available" line, and chips for its facilities (medical/food/transport/rescue). From each card the official can:
  - **Update occupancy** — a lightweight dialog that changes only the occupancy number, without re-entering every other field, "the one field that changes most often during an active response."
  - **Edit** — opens the full shelter form pre-filled with the existing values.
  - **Add shelter** (FAB) — opens the same form empty.
- The shelter form (`_ShelterFormScreen`) is a tap-to-place map (reusing `TaarakMapView`/`TaarakMapController` from the `map` module) plus name, total capacity, and a facility multi-select (`FilterChip` per `ShelterFacilityType`). Submitting is disabled until a location has been tapped, a name entered, and a numeric capacity entered.

## Entry points

- Route `/shelters/manage` in `lib/app/router.dart` → `ShelterManagementScreen`. Guarded in `lib/app/route_guard.dart`'s `defaultRoutePermissions` map by `Permission.manageSheltersResources` (`'/shelters/manage': Permission.manageSheltersResources`).
- Reachable from the home screen's quick-action grid (`context.push('/shelters/manage')`) for any role whose `rolePermissions` set includes `manageSheltersResources` (`UserRole.localOfficial`, per `user_role.dart`).
- The shelter-add/edit form (`_ShelterFormScreen`) is a private `MaterialPageRoute` push from within `ShelterManagementScreen` itself (`_openShelterForm`), not a named/guarded go_router route of its own.

## Architecture

Domain / application / presentation layering, no `data/` folder (persistence delegated to `LocalShelterRepository` in `lib/core/database/repositories/`, outside this module):

- **domain/** — `ShelterFacilityType` enum (the four resource categories the blueprint names: medical/food/transport/rescue).
- **application/** — `ShelterManagementService` (the write orchestration: upsert, occupancy-only update, both audited and sync-queued), `shelter_management_providers.dart` (Riverpod wiring).
- **presentation/** — `ShelterManagementScreen` (list/grid + occupancy dialog) and its private `_ShelterFormScreen` (add/edit form with tap-to-place map).

## Files in this module

### `lib/features/shelters/application/shelter_management_providers.dart`
- **Purpose:** Riverpod wiring for `ShelterManagementService`.
- **Status:** IMPLEMENTED.
- **Key providers:** `shelterManagementServiceProvider`.
- **Depends on:** `core/providers/core_providers.dart` (`localShelterRepositoryProvider`, `auditLogDaoProvider`, `syncQueueDaoProvider`). **Depended on by:** `ShelterManagementScreen` and `_ShelterFormScreen`.

### `lib/features/shelters/application/shelter_management_service.dart`
- **Purpose:** The write path: `upsertShelter` creates a new shelter (when `id` is omitted) or updates an existing one from the same entry point, preserving `occupancy` from the existing row unless explicitly overridden; `updateOccupancy` is the lighter-weight, occupancy-only path. Every change is audited via `AuditLogDao`, matching the verification module's pattern of a real audit entry for every state-affecting action rather than a silent write, and enqueued to the sync queue (best-effort — `SyncQueueDao` is an optional constructor param).
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `ShelterManagementService` — `listShelters()` → `Result<List<LocalShelter>>`; `upsertShelter({id?, name, latitude, longitude, capacityTotal, occupancy?, accessQuality?, facilities, officialId, now?})` → `Result<LocalShelter>` (increments `version`, writes audit action `shelter.created`/`shelter.updated`); `updateOccupancy({shelterId, occupancy, officialId, now?})` → `Result<LocalShelter>` (audit action `shelter.occupancy_updated`, records old/new occupancy in the audit entry's `oldValue`/`newValue` JSON); `facilitiesOf(shelter)` — decodes `facilitiesJson` back into a `Set<ShelterFacilityType>`, tolerant of malformed JSON (`FormatException` → empty set, not a crash).
- **Notable imports:** `AuditLogDao`, `SyncQueueDao` (both `core/database/`), `uuid` (new shelter ids).
- **Depends on:** `LocalShelterRepository`, `AuditLogDao`, `SyncQueueDao?`, `ShelterFacilityType`. **Depended on by:** `shelter_management_providers.dart`, `ShelterManagementScreen`/`_ShelterFormScreen` directly, and — proven by a dedicated cross-module test (`shelter_capacity_feeds_relocation_test.dart`) — the `relocation` module's `RelocationPlanningService`, which reads the same `LocalShelters` rows this service writes.
- **State:** writes `local_shelters` (via repository), `sync_queue`, `audit_log`.
- **External communication:** none directly (local Drift only); sync propagation to Firestore's `local_shelters` collection is the sync module's (M17) concern, reached only via the enqueued sync-queue entry, not synchronously from this service.
- **Demo/mock content:** none — this is the real write path (distinct from `DemoMapDataSeeder` in the `map` module, which writes `LocalShelter` rows directly via Drift `batch()`, bypassing this service entirely — no audit entry, no sync-queue entry, for whatever the seeder inserts).

### `lib/features/shelters/domain/shelter_facility_type.dart`
- **Purpose:** The four resource categories the blueprint names explicitly for shelter management ("medical/food/transport/rescue resources"), stored as a JSON list of `storageValue` strings in `LocalShelters.facilitiesJson` — the same column the relocation module's engine already reads to score candidate shelters, so this enum formalizes an existing vocabulary rather than requiring a schema change.
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `ShelterFacilityType` (`medical`, `food`, `transport`, `rescue`) — `storageValue`, `label`, `fromStorageValue(String)` (returns `null` for unrecognized values).
- **Depended on by:** `ShelterManagementService`, `ShelterManagementScreen`/`_ShelterFormScreen`.

### `lib/features/shelters/presentation/shelter_management_screen.dart`
- **Purpose:** The only UI in this module. `ShelterManagementScreen` — list/grid of shelters with an occupancy bar, facility chips, and per-card actions. `_ShelterCard` — one shelter's card. `_ShelterFormScreen`/`_ShelterFormScreenState` — the add/edit form, described in User-facing functionality above; its own doc comment notes it "mirrors [ReportHazardZoneScreen]'s pattern" of asking an official to tap a map rather than type raw latitude/longitude, "exactly the kind of friction/error surface a tap-to-place map avoids."
- **Status:** IMPLEMENTED and wired to the real service (`_submit`/`_showOccupancyDialog` call `shelterManagementServiceProvider` for real, not a mock).
- **Key classes:** `ShelterManagementScreen` (stateless, `ConsumerWidget`), `_ShelterCard` (`ConsumerWidget`), `_ShelterFormScreen`/`_ShelterFormScreenState` (stateful).
- **Notable imports:** `google_maps_flutter` directly (for the single location marker), `map/application/map_data_providers.dart` (`sheltersProvider` — reads from the `map` module, invalidated after every write so the map's shelter layer updates immediately), `map/presentation/widgets/taarak_map_controller.dart`/`taarak_map_view.dart` (the `map` module's shared base map, reused for the tap-to-place form).
- **Depends on:** `shelterManagementServiceProvider`, `sheltersProvider` (map module), `locationStatusProvider` (profile module, for the form's fallback map center), `currentUserProvider` (auth module, for `officialId`). **Depended on by:** router (`/shelters/manage` route).
- **State:** reads `sheltersProvider`; writes via `shelterManagementServiceProvider.upsertShelter`/`updateOccupancy`, invalidating `sheltersProvider` after every write.
- **External communication:** Google Maps SDK (tap-to-place marker), device GPS indirectly via `locationStatusProvider` (fallback map center only — not required to submit the form).
- **Demo/mock content:** none.

## Data Models

- **`ShelterFacilityType`** — enum `medical`/`food`/`transport`/`rescue`, with `storageValue`/`label`.
- **`LocalShelter`** (Drift row, `core/database/tables/local_shelters_table.dart`) — `id`, `name`, `latitude`, `longitude`, `capacityTotal` (default 0), `occupancy` (default 0), `facilitiesJson` (default `'[]'`), `accessQuality: double?` (M10's "access" factor, 0.0 easy–1.0 difficult; null means "not yet surveyed," not "assumed easy" — per the table's own doc comment), `updatedAt`, `version`.

## Services / Repositories

- **`ShelterManagementService`** — the sole service in this module; upsert + occupancy-update + facility-decoding, each audited and sync-queued. See Files above for full detail.
- **`LocalShelterRepository`** (outside this module, in `core/database/repositories/`) — the actual Drift persistence layer this service writes through.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/shelters/manage` | `ShelterManagementScreen` | `Permission.manageSheltersResources` | Home screen quick actions (Local Official). |

`_ShelterFormScreen` (add/edit) is not a separate go_router path — it's pushed as a `MaterialPageRoute` from within `ShelterManagementScreen`, inheriting the same permission gate implicitly (a user can only reach it by first being on `/shelters/manage`).

## Module Data Flow

A Local Official updates a shelter's occupancy after a headcount:

```
ShelterManagementScreen  (route: /shelters/manage, guarded by Permission.manageSheltersResources)
  ref.watch(sheltersProvider)   [map module]  → LocalShelterRepository.getAll()  → shelter cards render

_ShelterCard._showOccupancyDialog()
  → AlertDialog collects a new occupancy number
  → ref.read(shelterManagementServiceProvider).updateOccupancy(
        shelterId, occupancy, officialId: currentUserProvider.id)
      ShelterManagementService.updateOccupancy()
        → LocalShelterRepository.getById(shelterId)          (fetch existing, for old-value audit + version)
        → LocalShelterRepository.save(updated)                (occupancy + version + updatedAt changed)
        → SyncQueueDao.enqueue(entityTable: 'local_shelters', operation: 'create', payloadJson: {...})
        → AuditLogDao.record(action: 'shelter.occupancy_updated', oldValue: {...}, newValue: {...})
        → Result.success(updated)
  → ref.invalidate(sheltersProvider)   [map module]  → shelter card + Risk Map shelter marker both refresh
  → snackbar: "Occupancy updated"

Downstream (relocation module, out of this module's documented scope, proven by
shelter_capacity_feeds_relocation_test.dart):
  RelocationPlanningService.planForHabitation()
    → reads the same LocalShelters row this service just wrote
    → a shelter at full occupancy drops out as a relocation candidate immediately
```

## Current Status

**Working.** The full write path (screen → service → repository → audit log → sync queue) is real, tested end-to-end with an in-memory Drift database, and — notably — proven to actually affect a downstream module's output: `shelter_capacity_feeds_relocation_test.dart` demonstrates that filling a shelter to capacity through `ShelterManagementService` removes it as a relocation candidate in the `relocation` module's `RelocationPlanningService`, and freeing capacity back up restores it — a genuine cross-module integration test, not just two modules sharing a schema.

## Known Limitations

- `upsertShelter` treats "creates new" vs. "updates existing" purely by whether an `id` is passed in — there is no separate confirmation step or duplicate-name detection; two shelters with the same name and different ids are allowed.
- `updateOccupancy` accepts any non-negative integer with no validation that it doesn't exceed `capacityTotal` — the UI's progress bar clamps its *display* fraction to `[0.0, 1.0]` (`shelter_management_screen.dart`'s `occupancyFraction`), but the underlying stored `occupancy` value itself is not clamped or validated against `capacityTotal` at the service layer.
- `facilitiesOf` silently returns an empty set on malformed JSON rather than surfacing an error — a corrupted `facilitiesJson` value would make a shelter appear to have no facilities rather than flagging data corruption.
- No delete/deactivate path exists in this module — a shelter can be edited but not removed (removal, if needed, would be an admin content-moderation action outside this module's scope, mirroring how `hazards`/`verification` model their own delete paths).
- `_ShelterFormScreenState` does not validate that `capacityTotal` is non-negative — `int.tryParse` accepts a negative number as long as it parses.

## Test Coverage

`test/features/shelters/` contains two files:

- **`shelter_management_service_test.dart`** — `upsertShelter`: creates a new shelter with given facilities and confirms persistence; updating an existing shelter preserves occupancy unless explicitly overridden, and increments version; writes exactly one audit entry (`shelter.created`) on creation. `updateOccupancy`: changes only the occupancy field and writes an audit entry with correct old/new values; fails cleanly for an unknown shelter id.
- **`shelter_capacity_feeds_relocation_test.dart`** — the cross-module integration test described above: a shelter written/updated through this module changes what the `relocation` module's `RelocationPlanningService` recommends, both for capacity (a full shelter drops out, freeing it back up restores it — explicitly labeled "the acceptance criterion") and for the relocation ranking score itself (adding all four facilities to a shelter raises its `compositeScore` relative to a bare shelter with the same capacity/location).

**Not covered by any test in this module:** `ShelterManagementScreen`, `_ShelterCard`, and `_ShelterFormScreen` have no widget test in `test/features/shelters/` — the occupancy dialog, the tap-to-place map interaction, form validation (`_canSubmit`), and the list/grid responsive layout switch are all untested at this layer. `listShelters()` has no dedicated test (it is a thin pass-through to the repository, indirectly exercised by the other tests). `facilitiesOf`'s malformed-JSON tolerance path (`FormatException` → empty set) has no dedicated test.
