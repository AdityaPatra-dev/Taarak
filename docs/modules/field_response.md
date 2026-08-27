# MODULE: Field Response

## Purpose

This module is the Field Responder role's entire working surface: a worklist of incidents assigned to them, and — per assigned incident — the ability to navigate to it, move it through the verification lifecycle on-site (confirm/verify, mark active, mark resolved), and submit a structured damage-assessment report once they've actually looked. It answers "what has command sent me to deal with, and what do I do once I'm there." It reuses the `verification` module's existing lifecycle wholesale (its own doc comment: "M13's existing acknowledged→verified→active→resolved lifecycle already models exactly what a responder does in the field") rather than inventing a parallel status model, and reuses the `routing` module for the "navigate" action rather than implementing its own routing.

## User-facing functionality

- **Field Responder** (permissions `viewAssignedIncidents`, `navigateToIncident`, `submitDamageReport`, `updateFieldStatus`, `verifyFieldObservation`):
  - **My Assigned Incidents** (`AssignedIncidentsScreen`) — the front door for the whole role, per its own doc comment: "the front door for the whole role, since every other Field Responder action ... starts from a specific assigned incident." A pull-to-refresh list of every `LocalIncident` whose `assignedResponderId` matches the current user, each card showing description/type, status, and a severity chip. Empty state explicitly tells the responder: "District/Command assigns incidents from Manage Responders" — i.e. this list is populated by another role's action, not something a responder can add to themselves. Tapping a card pushes to the incident's detail screen.
  - **Assigned Incident detail** (`FieldIncidentDetailScreen`) — one incident's working view:
    - **Navigate to incident** button — plans a route from the responder's current GPS position to the incident, then pushes to `/map` to show it.
    - A **status action button** whose label/icon/target state depend on the incident's current status: "Confirm on-site (verify)" when acknowledged, "Mark active" when verified, "Mark resolved" when active — each a direct call into the `verification` module's `IncidentVerificationService.transitionIncident`, using the exact same status enum and transition rules a Local Official uses.
    - **Submit damage report** form — free-text description, a severity picker (low/medium/high/critical), and a submit button, listing every damage report submitted so far for this incident below the form.

## Entry points

- Route `/field/incidents` in `lib/app/router.dart` → `AssignedIncidentsScreen`. Guarded in `lib/app/route_guard.dart`'s `defaultRoutePermissions` map by `Permission.viewAssignedIncidents` (`'/field/incidents': Permission.viewAssignedIncidents`).
- Route `/field/incidents/:incidentId` → `FieldIncidentDetailScreen(incidentId: ...)`. Not matched by `defaultRoutePermissions`' exact-path lookup — `route_guard.dart` handles it via a dedicated prefix check: any location starting with `fieldIncidentDetailPrefix = '/field/incidents/'` requires `Permission.viewAssignedIncidents` (the same permission as the list screen, since the detail screen is reached only by drilling into that list).
- Reachable from the home screen's quick-action grid (`context.push('/field/incidents')`) for `UserRole.fieldResponder`.
- `AssignedIncidentsScreen`'s cards push to `/field/incidents/${incident.id}` via `context.push`.
- **The "Navigate to incident" button pushes `context.push('/map')`** — a route gated by `Permission.viewRiskMap`, documented and confirmed fixed in `map.md` (this module's dependency on `/map` is exactly why `fieldResponder` needed `viewRiskMap` added to its permission set — see below).

### The viewRiskMap fix, from this module's side

`FieldIncidentDetailScreen._navigate()` (this file) is the concrete code that made the bug real: it calls `RoutingService.planRoute()` and then, on success, `context.push('/map')`. Before the fix documented in `lib/features/auth/domain/user_role.dart` (see map.md for full detail), `UserRole.fieldResponder`'s permission set did not include `Permission.viewRiskMap`, so this exact `context.push('/map')` call would have been immediately bounced to `/unauthorized` by `computeRedirect` in `lib/app/route_guard.dart` — the responder would tap "Navigate to incident," the route would plan successfully, and then the screen they were sent to would refuse to load. This is now fixed: `fieldResponder`'s permission set includes `viewRiskMap`, with an inline comment in `user_role.dart` naming this exact button as the reason.

## Architecture

Application / presentation layering only — **no `domain/` folder** in this module (it defines no domain value types of its own; it reuses `IncidentVerificationStatus` from the `verification` module and `LocalIncident`/`LocalDamageReport` Drift rows directly), and no `data/` folder (persistence delegated to `LocalDamageReportRepository` in `lib/core/database/repositories/`, outside this module):

- **application/** — `DamageReportService` (the one write-side service this module owns: submit a damage report, list reports for an incident), `field_response_providers.dart` (Riverpod wiring, including the client-side-filtered `assignedIncidentsProvider`).
- **presentation/** — `AssignedIncidentsScreen` (worklist), `FieldIncidentDetailScreen` (per-incident working view — navigate, transition status, submit damage report).

## Files in this module

### `lib/features/field_response/application/damage_report_service.dart`
- **Purpose:** A Field Responder's on-site structured assessment for an incident they're assigned to — described by the `LocalDamageReports` table's own comment as "kept as its own table rather than folded into [LocalIncidentReports] ... this is an official's structured follow-up once someone has actually been sent to look, with different semantics (always tied to a specific responder and incident, never itself fused into anything)" — i.e. deliberately distinct from a citizen's initial ground observation and never run through the fusion engine.
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `DamageReportService` — `submit({incidentId, responderId, description, severity, now?})` → `Result<LocalDamageReport>` (writes the row, best-effort enqueues a sync-queue entry — `SyncQueueDao` is an optional constructor param); `forIncident(incidentId)` → `Result<List<LocalDamageReport>>`.
- **Depends on:** `LocalDamageReportRepository`, `SyncQueueDao?`. **Depended on by:** `field_response_providers.dart`, `FieldIncidentDetailScreen`.
- **State:** writes `local_damage_reports` (via repository), writes `sync_queue`.
- **External communication:** none directly — sync propagation to Firestore's `local_damage_reports` collection is the sync module's concern, reached only via the enqueued sync-queue row.
- **Demo/mock content:** none — this is a real, if simple, write path. **Notably: no audit-log entry is written for a damage-report submission** — unlike every other write-side service in the modules documented alongside this one (`shelters`, `habitations`, `verification` all call `AuditLogDao.record`), `DamageReportService` has no `AuditLogDao` dependency at all. This is a genuine gap worth flagging, not a demo/mock finding, but adjacent to one: an official reviewing the audit trail for an incident (`IncidentVerificationService.auditTrailFor`) will see status transitions but not that a damage report was ever filed.

### `lib/features/field_response/application/field_response_providers.dart`
- **Purpose:** Riverpod wiring for `DamageReportService`, plus the two read providers the screens use.
- **Status:** IMPLEMENTED.
- **Key providers:** `damageReportServiceProvider`; `assignedIncidentsProvider` (`FutureProvider.autoDispose<List<LocalIncident>>` — described by its own comment as "the Field Responder's own worklist ... sourced from the same `incidentsProvider` read everyone else's screens already use, just filtered client-side" by `assignedResponderId == currentUserId`); `damageReportsForIncidentProvider` (`FutureProvider.autoDispose.family<List<LocalDamageReport>, String>`, keyed by incident id).
- **Notable imports:** `map/application/map_data_providers.dart` (`incidentsProvider` — this module has no incident repository provider of its own; it reuses the map module's, then filters).
- **Depends on:** `core/providers/core_providers.dart` (`localDamageReportRepositoryProvider`, `syncQueueDaoProvider`), `auth/application/auth_controller.dart` (`currentUserProvider`), `map/application/map_data_providers.dart` (`incidentsProvider`). **Depended on by:** `AssignedIncidentsScreen`, `FieldIncidentDetailScreen`.
- **State:** reads `local_incidents` (via the map module's `incidentsProvider`) and `local_damage_reports`.

### `lib/features/field_response/presentation/assigned_incidents_screen.dart`
- **Purpose:** The Field Responder's worklist — described in User-facing functionality above.
- **Status:** IMPLEMENTED.
- **Key classes:** `AssignedIncidentsScreen` (`ConsumerWidget`), `_IncidentCard` (stateless) — `onTap: () => context.push('/field/incidents/${incident.id}')`.
- **Depends on:** `assignedIncidentsProvider`. **Depended on by:** router (`/field/incidents` route), home screen quick actions.
- **State:** reads `assignedIncidentsProvider` only; writes nothing.

### `lib/features/field_response/presentation/field_incident_detail_screen.dart`
- **Purpose:** The one incident-detail working screen for this whole role — navigate, transition status, submit damage report. Described in User-facing functionality above.
- **Status:** IMPLEMENTED and wired to real services throughout (`_navigate` → real `RoutingService`; `_transition` → real `IncidentVerificationService`; `_submitDamageReport` → real `DamageReportService`).
- **Key classes:** `FieldIncidentDetailScreen` (stateful, takes `incidentId` as a constructor param from the route's path parameter) / `_FieldIncidentDetailScreenState`. `_navigate(incident)` — reads `locationStatusProvider` for the responder's GPS fix (shows a snackbar and aborts if unavailable), calls `routingServiceProvider.planRoute()`, on success invalidates `routesProvider` (map module) and pushes to `/map`. `_transition(to)` — calls `incidentVerificationServiceProvider.transitionIncident(incidentId, to, officialId: responderId)` — note the parameter name `officialId` even though the caller is a Field Responder, not an official; the service's audit trail records whichever user id is passed, regardless of role. `_submitDamageReport(incident)` — calls `damageReportServiceProvider.submit(...)`. Private `_StatusActionButton` — a stateless widget computing the single next-status label/icon from the incident's *current* status via a `switch` (not from `allowedIncidentStatusTransitions` directly, unlike `VerificationScreen`'s `_IncidentCard`, which renders a button per allowed next state — this screen only ever offers the *one* forward-most transition a responder would take, not every technically-allowed one).
- **Notable imports:** `routing/application/routing_providers.dart`/`routing/domain/route_candidate.dart` (routing module), `verification/application/verification_providers.dart`/`verification/domain/incident_verification_status.dart` (verification module — this module has no incident-status logic of its own, it calls straight into verification's), `map/application/map_data_providers.dart` (`incidentsProvider`, `routesProvider`), `profile/application/location_status_controller.dart` (GPS fix for navigation).
- **Depends on:** `incidentsProvider` (map module), `damageReportsForIncidentProvider`, `routingServiceProvider` (routing module), `incidentVerificationServiceProvider` (verification module), `locationStatusProvider` (profile module), `currentUserProvider` (auth module). **Depended on by:** router (`/field/incidents/:incidentId` route).
- **State:** reads `incidentsProvider`, `damageReportsForIncidentProvider`; writes via `routingServiceProvider.planRoute` (→ `local_routes`), `incidentVerificationServiceProvider.transitionIncident` (→ `local_incidents`, `audit_log`), `damageReportServiceProvider.submit` (→ `local_damage_reports`); invalidates `routesProvider`/`incidentsProvider`/`assignedIncidentsProvider`/`damageReportsForIncidentProvider` after their respective writes.
- **External communication:** device GPS indirectly via `locationStatusProvider` (required for navigation, not for status transitions or damage reports).
- **Demo/mock content:** none.

## Data Models

This module defines no domain value types of its own. It reads/writes:

- **`LocalIncident`** (see `verification.md`/`map.md` for full field list) — this module reads `assignedResponderId` to build the worklist and `status` to drive the status-action button, and writes `status` via `IncidentVerificationService.transitionIncident` (verification module).
- **`LocalDamageReport`** (Drift row, `core/database/tables/local_damage_reports_table.dart`) — `id`, `incidentId`, `responderId`, `description` (default `''`), `severity` (default `'unknown'`), `mediaPath: String?` (defined in the schema — same pattern as `LocalIncidentReports.mediaPath` — but **not actually collected anywhere in this module's UI**: `FieldIncidentDetailScreen`'s damage-report form has no photo-attach control, and `DamageReportService.submit()` has no `mediaPath` parameter, so this column is always null in practice from this module's current code), `submittedAt`, `version`.

## Services / Repositories

- **`DamageReportService`** — the sole service this module owns; submit + list. See Files above for full detail, including the missing-audit-log gap.
- **`IncidentVerificationService`** (verification module, not owned by this module but called directly by it) — status transitions.
- **`RoutingService`** (routing module, not owned by this module but called directly by it) — route planning for the "Navigate to incident" action.
- **`LocalDamageReportRepository`** (outside this module, in `core/database/repositories/`) — the actual Drift persistence layer.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/field/incidents` | `AssignedIncidentsScreen` | `Permission.viewAssignedIncidents` | Home screen quick actions (Field Responder). |
| `/field/incidents/:incidentId` | `FieldIncidentDetailScreen` | `Permission.viewAssignedIncidents` (via `route_guard.dart`'s `fieldIncidentDetailPrefix` prefix check, not the exact-path map) | `AssignedIncidentsScreen` card taps. |

## Module Data Flow

A Field Responder navigates to an assigned incident, then files a damage report:

```
AssignedIncidentsScreen  (route: /field/incidents, guarded by Permission.viewAssignedIncidents)
  ref.watch(assignedIncidentsProvider)
    → ref.watch(incidentsProvider.future)          [map module → LocalIncidentRepository.getAll()]
    → filter: incident.assignedResponderId == currentUserProvider.id
  → tap a card → context.push('/field/incidents/${incident.id}')

FieldIncidentDetailScreen  (route: /field/incidents/:incidentId, guarded via fieldIncidentDetailPrefix)
  ref.watch(incidentsProvider) → find incident by widget.incidentId

Responder taps "Navigate to incident"
  → _navigate(incident)
      → locationStatusProvider.valueOrNull?.geoTag   [responder's current GPS fix]
      → ref.read(routingServiceProvider).planRoute(origin: responderFix, destination: incident location)
          [routing module — RiskAwareRoutingEngine / OSRM, see routing.md]
      → on Success: ref.invalidate(routesProvider) [map module]; context.push('/map')
                    [guarded by Permission.viewRiskMap — now present for fieldResponder, see above]

Responder taps "Confirm on-site (verify)"
  → _transition(IncidentVerificationStatus.verified)
      → ref.read(incidentVerificationServiceProvider).transitionIncident(
            incidentId, to: verified, officialId: responderId)
          [verification module — same engine/audit path a Local Official uses]
  → ref.invalidate(incidentsProvider); ref.invalidate(assignedIncidentsProvider)

Responder submits a damage report
  → _submitDamageReport(incident)
      → ref.read(damageReportServiceProvider).submit(
            incidentId, responderId, description, severity)
          DamageReportService.submit()
            → LocalDamageReportRepository.save(LocalDamageReport(...))
            → SyncQueueDao.enqueue('local_damage_reports', ...)
            [NO AuditLogDao call — see the gap noted in Files above]
  → ref.invalidate(damageReportsForIncidentProvider(incidentId))
```

## Current Status

**Working**, with one notable gap. The worklist, navigation trigger, and status-transition actions are all real and wired to the same production services other roles use (`RoutingService`, `IncidentVerificationService`) — there is no parallel/duplicate/mock implementation of routing or lifecycle logic in this module. `DamageReportService` is also real and functional (writes persist, sync-queue entries are created), but — confirmed by reading the full file — it never calls `AuditLogDao`, unlike every sibling write-service in the modules documented alongside it. This is a real functionality gap, not a mock: submitting a damage report works, but it leaves no audit trail.

**The `viewRiskMap` permission fix described in map.md is directly load-bearing for this module's "Navigate to incident" button** — confirmed present in `lib/features/auth/domain/user_role.dart`, with an inline comment specifically citing this button as the reason for the fix.

## Known Limitations

- **No audit-log entry for damage-report submission** (see above) — an official auditing an incident's history via `IncidentVerificationService.auditTrailFor()` will not see that a damage report was ever filed, only status transitions and acknowledgements.
- **`LocalDamageReport.mediaPath` exists in the schema but is never populated by this module's UI** — the damage-report form has no photo-attach control (unlike `ReportIncidentScreen` in the `reporting` module, which does), and `DamageReportService.submit()` takes no `mediaPath` parameter at all.
- `_StatusActionButton` only ever offers the single, linear next step (acknowledged→verify, verified→active, active→resolved) — it never offers `rejected` as an option, meaning a Field Responder cannot reject an incident from the field even though the underlying `IncidentVerificationStatus` lifecycle technically allows `acknowledged → rejected`; that path is only reachable through `VerificationScreen` (the Local Official's UI, in the `verification` module).
- `_navigate` silently no-ops (just a snackbar) if the responder's GPS fix isn't available yet — there is no retry/poll loop, the responder has to back out and try again once `locationStatusProvider` resolves.
- The worklist (`AssignedIncidentsScreen`) has no sorting or prioritization by severity/status — assigned incidents render in whatever order `LocalIncidentRepository.getAll()` returns them.
- This module has **no `domain/` folder** — it is thinner architecturally than the other six documented modules, borrowing its one meaningful domain type (`IncidentVerificationStatus`) entirely from the `verification` module rather than defining its own.

## Test Coverage

**`test/features/field_response/` does not exist.** This was explicitly checked as part of this documentation pass (`find test/features/field_response -name "*.dart"` and `test -d test/features/field_response` both confirm no such directory exists in the repository), and it is itself a finding: **this is the only one of the seven modules documented in this handover package with zero automated test coverage.** Neither `DamageReportService` (the one service this module owns) nor `field_response_providers.dart` nor either presentation screen has any test file anywhere in the repository under a field-response-specific path. Everything this module calls into (`RoutingService`, `IncidentVerificationService`) is tested from *their own* modules' perspectives (`test/features/routing/`, `test/features/verification/`), but the field_response-specific glue code — the `assignedResponderId` client-side filter in `assignedIncidentsProvider`, the `_navigate`/`_transition`/`_submitDamageReport` handlers, and `DamageReportService.submit`/`forIncident` themselves — has no test coverage anywhere in this repository as of this documentation pass.
