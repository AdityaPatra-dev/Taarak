# MODULE: Audit

## Purpose

This module is the accountability record for the app — a read-only viewer over an append-only log of every significant change other modules make. Concretely: whenever a Local Official acknowledges a citizen's incident report, records a shelter's occupancy, cancels an alert, or (in the Admin module) removes a hazard zone/incident/alert, that action writes one row — who did it, what action, what object, when, the before/after values if applicable, and an optional reason — into a local, on-device, append-only table. A System Admin (the only role granted `Permission.reviewAudit`) can open the Audit Log screen, search across every field (actor, action, object, reason), filter by object type, and see the full history, most recent first. The module's own code comments frame this directly against the project blueprint's requirement that "critical changes are traceable" and that audit records must never be silently altered — there is deliberately no update or delete capability exposed anywhere for this data, by anyone, including admins.

This module itself does not decide *what* gets audited or write any audit entries — that responsibility belongs to each feature module that has something worth auditing (incident verification, shelter management, alert broadcasting, hazard/content moderation, and others). This module is purely the *shared reader*: a filter function and a screen that can display whatever any of those modules already wrote.

## User-facing functionality

- **Audit Log screen** (`/audit`):
  - A free-text search field ("Search actor, action, object, reason") that filters live as the admin types, matching against a lowercased concatenation of action, object type, object ID, actor ID, and reason.
  - A row of filter chips — "All" plus one chip per distinct object type actually present in the current data (e.g. "incident", "shelter", "alert") — for narrowing to one object type at a time.
  - A refresh icon in the app bar that re-fetches the full event list.
  - Below the filters, a scrollable list of event cards, most-recent-first, each showing: the action name, a localized timestamp, the actor ID, the object type + object ID, the reason (if any), and a "Before: {oldValue}" / "After: {newValue}" block (if either was recorded).
  - An empty state ("No matching audit events... Try a different search term or filter") when the current filter/search combination matches nothing.

## Entry points

- Reachable only from the Home screen's "Quick actions" grid, via the "Audit Log" tile, shown only to a role with `Permission.reviewAudit` — in the default role/permission map, that's exclusively `UserRole.systemAdmin`.
- Direct URL/deep link to `/audit` also works, still gated by `computeRedirect` — any role without `reviewAudit` is redirected to `/unauthorized`.

## Architecture

The smallest layered module in scope — **no `domain/` or `data/` folder**. Just `application/` (two files: a pure filter function, and one Riverpod provider) and `presentation/` (one screen). The module has no data source of its own at all: it reads `AuditLogDao` (and the `LocalAuditEvent` Drift row type it returns), both of which are defined in `core/database/`, not in this module — this module only ever *reads* that shared table, it never writes to it.

## Files in this module

### `lib/features/audit/application/audit_log_filter.dart`
- **Purpose**: The module's one piece of real logic — a pure, side-effect-free function that filters and sorts a list of audit events by object type, actor ID, and/or a free-text query, most-recent-first (ties broken by insertion order via `id`).
- **Status**: IMPLEMENTED.
- **Key functions**: `filterAuditEvents(events, {objectType, actorId, query})` — filters, then sorts by `occurredAt` descending, then by `id` descending as a tiebreaker "so two actions in the same millisecond still sort as 'most recent last written', not arbitrarily."
- **Notable behavior**: the free-text `query` matches against a joined string of `action`, `objectType`, `objectId`, `actorId`, and `reason ?? ''` — lowercased, so matching is case-insensitive; an empty/whitespace-only query behaves like no query.
- **Depends on**: `LocalAuditEvent` (`core/database/app_database.dart` — Drift-generated row class, defined outside this module). **Depended on by**: `audit_log_screen.dart` (this module), and — notably — `test/features/audit/audit_traceability_test.dart`, which reuses this exact function to verify cross-module audit traceability, not just within this module.
- **State/I/O**: none — pure function, no async, no provider.

### `lib/features/audit/application/audit_providers.dart`
- **Purpose**: The single Riverpod provider this module defines — fetches every audit event from the shared local database.
- **Status**: IMPLEMENTED.
- **Key providers**: `auditEventsProvider` (`FutureProvider.autoDispose<List<LocalAuditEvent>>`) — calls `auditLogDaoProvider.getAll()` and unwraps the `Result`, falling back to an empty list on failure (no error surfaced to the caller at this layer — errors would only be visible if the underlying `FutureProvider` itself throws, which `getAll()`'s `Result`-wrapping is designed to avoid).
- **Depends on**: `auditLogDaoProvider` (`core/providers/core_providers.dart`, wiring `AuditLogDao` to the shared `AppDatabase`). **Depended on by**: `AuditLogScreen`.
- **State it reads**: the local Drift database's `local_audit_events` table (read-only, via `AuditLogDao.getAll()`).

### `lib/features/audit/presentation/audit_log_screen.dart`
- **Purpose**: The one screen in this module — search box, object-type filter chips, and the scrollable list of audit event cards.
- **Status**: IMPLEMENTED.
- **Key classes**: `AuditLogScreen` (`ConsumerStatefulWidget`), `_AuditLogScreenState` (holds `_objectTypeFilter`, `_query` as local widget state — not persisted, resets each time the screen is opened), `_AuditEventCard` (`StatelessWidget`, renders one `LocalAuditEvent`).
- **Key logic**: derives the list of distinct object-type filter chips dynamically from whatever's actually in `events` (`events.map((e) => e.objectType).toSet().toList()..sort()`) rather than a hardcoded list — so it automatically reflects whatever object types any module has ever audited.
- **Notable gap found**: `filterAuditEvents` supports filtering by `actorId`, but this screen **never passes an `actorId` argument** to it — there is no UI control (dropdown, chip, or field) anywhere in this screen for filtering by actor. The capability exists in the filter function and is unit-tested, but it is not wired to any UI here.
- **State it reads**: `auditEventsProvider` (this module). **State it writes**: `ref.invalidate(auditEventsProvider)` on the refresh icon.
- **External communication**: none directly — delegates entirely to `auditEventsProvider` → `AuditLogDao` → local SQLite (via Drift), never touches the network or Firestore.
- **Depends on**: `filterAuditEvents`, `auditEventsProvider` (this module), `LocalAuditEvent` (core). **Depended on by**: `lib/app/router.dart` (registers it at `/audit`).

## Data Models

This module defines **no domain models of its own**. The one model it displays, `LocalAuditEvent`, is owned by `core/database/` (Drift-generated from the `LocalAuditEvents` table defined in `lib/core/database/tables/local_audit_events_table.dart`):

| Field | Type | Notes |
|---|---|---|
| `id` | `int` (auto-increment) | used as a tiebreaker for same-timestamp sort order |
| `actorId` | `String` | who performed the action |
| `action` | `String` | free-text action identifier, e.g. `"incident.acknowledged"`, `"shelter.created"`, `"alert.cancelled"` |
| `objectType` | `String` | e.g. `"incident"`, `"shelter"`, `"alert"` — drives the filter chips |
| `objectId` | `String` | the specific object affected |
| `oldValue` | `String?` | nullable — shown as "Before: ..." if present |
| `newValue` | `String?` | nullable — shown as "After: ..." if present |
| `reason` | `String?` | nullable — free-text, shown if present, also searchable |
| `occurredAt` | `DateTime` | primary sort key, descending |

The table's own doc comment states this transcribes the blueprint's "Actor, action, object, time, old/new value and reason" spec verbatim, and explicitly has **no update/delete access anywhere in the app** — enforced structurally, since `AuditLogDao` (core, not this module) exposes only `record()`, `listForObject()`, and `getAll()` — no `update`/`delete` method exists at all.

## Services / Repositories / Data Sources

This module has **no service, repository, or data source of its own**. It is a pure consumer of one shared component that lives outside this module's directory:

| Component | Location | Real or Mock | Storage |
|---|---|---|---|
| `AuditLogDao` | `lib/core/database/audit_log_dao.dart` | Real | Local Drift/SQLite table `local_audit_events` |

**Important architectural finding**: audit data is stored **entirely locally on-device** (Drift/SQLite), not in Firestore and not synced to any backend. A grep across `lib/features/sync/` for any reference to `localAuditEvents`/`LocalAuditEvent` found none — this table is never included in the app's offline-sync pipeline (M17). This means the audit log a System Admin sees on their own device only contains events that were written by that same physical device (or app instance) — it is **not** a centralized, cross-device audit trail. Every module that writes audit entries (verification, shelters, hazards, alerts, command/resources, habitations) does so via the same shared `AuditLogDao.record()` call, but all writes land in the local database of whichever device performed the action.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/audit` | `AuditLogScreen` | `Permission.reviewAudit` | Home quick action "Audit Log" (visible only to roles with `reviewAudit`, by default only `UserRole.systemAdmin`) |

Confirmed both from `defaultRoutePermissions` in `lib/app/route_guard.dart` (`'/audit': Permission.reviewAudit`) and from `route_guard_test.dart`, which explicitly asserts a system admin is admitted to `/audit` and a district/command user is turned away.

## Module Data Flow

The module's main (and only) action — loading and filtering the log:

```
AuditLogScreen.build()
  → ref.watch(auditEventsProvider)
    → AuditLogDao.getAll()   [core/database/audit_log_dao.dart — NOT owned by this module]
      → Drift query: SELECT * FROM local_audit_events  (no ordering applied here)
    ← Result<List<LocalAuditEvent>>
  ← List<LocalAuditEvent>  (empty list if the Result was a failure)

  → filterAuditEvents(events, objectType: _objectTypeFilter, query: _query)
    [pure, in-memory: filter by objectType/query, then sort by occurredAt desc, id desc]
  ← filtered, ordered List<LocalAuditEvent>

  → renders one _AuditEventCard per filtered event

User taps refresh icon:
  → ref.invalidate(auditEventsProvider)  → re-runs AuditLogDao.getAll()

Meanwhile, elsewhere in the app (NOT this module's code, shown for context on where the
data this screen displays actually comes from):
  IncidentVerificationService.acknowledgeReport() / ShelterManagementService.upsertShelter() /
  AlertBroadcastService.broadcastToZone() / HazardIngestionService.remove() / ...
    → AuditLogDao.record(actorId, action, objectType, objectId, oldValue, newValue, reason)
      → INSERT INTO local_audit_events (...)
```

## Current Status

- **Working**: the filter/sort logic and the screen are both fully implemented and correctly wired to the shared `AuditLogDao`, verified by reading the code and by two passing test files (one of which proves cross-module correctness, not just this module's own logic).
- **No demo/mock content** anywhere in this module — `AuditLogDao` is a real Drift/SQLite integration, not a fake.
- **Partial UI surface**: actor-based filtering exists in the underlying filter function but has no corresponding UI control in the screen — see Known Limitations.

## Known Limitations

- **Audit data is local-only, not synced or centralized** — this is the module's single most important limitation and is not stated anywhere in the module's own code comments; it was determined by tracing `AuditLogDao`/`LocalAuditEvents` usage and confirming no sync-pipeline reference exists. A System Admin reviewing the audit log on their own device sees only actions performed on (or synced to, if any sync mechanism existed for this table, which none does) that device — there is no server-side aggregation of audit events across all users' devices. For a genuinely centralized "who did what across the whole deployment" audit trail, this architecture would need to change.
- No actor-filtering UI, despite the underlying `filterAuditEvents` function supporting an `actorId` parameter — a System Admin cannot currently filter the visible list down to "just what one specific person did" through this screen; they'd have to use the free-text search against the actor's ID string instead, which only works if they know the exact ID.
- No pagination or date-range filtering — `getAll()` fetches every row in the table unconditionally; for a long-running deployment this could become a large single fetch with no visible limit in the code.
- No export/print/download of audit data from this screen — it's view-only.
- The event card's timestamp formatting (`'${event.occurredAt.toLocal()}'.split('.').first`) is a manual string manipulation of `DateTime.toString()`'s output rather than a proper date-formatting library call — functionally fine, but not a robust approach if locale-aware formatting were ever needed.

## Test Coverage

`test/features/audit/` contains 2 files, both read in full:

- **`audit_log_filter_test.dart`** — thorough unit coverage of `filterAuditEvents` in isolation: default most-recent-first ordering, same-timestamp tiebreak by `id`, filtering by `objectType`, filtering by `actorId`, the free-text query matching action/object/actor/reason (explicitly labeled in the test as covering the blueprint's "CRITICAL CHANGES ARE TRACEABLE" acceptance criterion), case-insensitivity, empty/blank query behaving as no-op, and combined `objectType` + `query` filtering.
- **`audit_traceability_test.dart`** — an integration-style test (not a pure unit test) that uses a real in-memory Drift database (`NativeDatabase.memory()`) and exercises three *other* modules' real services end-to-end — `IncidentVerificationService` (verification module), `ShelterManagementService` (shelters module), `AlertBroadcastService` (alerts module) — each writing to the same shared `AuditLogDao`, then asserts `AuditLogDao.getAll()` returns all three events with every required field populated, and that `filterAuditEvents` correctly orders/filters across all three (by object type, by actor, by a reason-text query). This is explicitly the strongest test of the module's actual real-world purpose: proving audit traceability holds *across* independently-written modules, not just within this one.

**Not covered**:
- `audit_providers.dart` (`auditEventsProvider`) has no dedicated test — its `Result`-unwrapping-with-fallback-to-empty-list behavior on a DAO failure is untested.
- `AuditLogScreen` itself has **no widget test** — nothing pumps the screen and asserts the search field, filter chips, refresh button, or empty state actually render/behave correctly. The two existing tests both test the *filter function* and the *underlying data layer*, never the screen widget.
- No test exercises the "no matching audit events" empty state, the object-type chip generation from live data, or the refresh-icon's `ref.invalidate` behavior at the widget level.
