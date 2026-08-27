# MODULE: Verification

## Purpose

This module is the official's front door for turning raw, unlinked citizen ground observations (`LocalIncidentReport` rows, produced by the `reporting` module) into tracked, lifecycle-managed `LocalIncident` rows — and for moving those incidents through an audited verification lifecycle: new → acknowledged → verified/rejected → active → resolved. It answers "has an official looked at this yet, is it confirmed real, and what's its current operational status." Every state change writes a real audit-log entry — described in this module's own code as "the acceptance criterion itself, not an afterthought" — and a new report that matches an already-tracked incident is merged into it (via the `fusion` module's ground-truth fusion engine) rather than spawning a duplicate.

## User-facing functionality

- **Local Official** (permission `verifyReports`): opens "Official Verification" (`VerificationScreen`) and sees two sections:
  - **Pending reports** — every `LocalIncidentReport` not yet linked to an incident (a count chip shows how many), each as a card with description/type, severity chip, coordinates, and an "Acknowledge" button that turns it into a tracked incident (or merges it into a matching existing one).
  - **Tracked incidents** — every `LocalIncident`, each as a card showing its current status pill, description, a "Confirmed by N independent sources (X% confidence)" line once corroborated by more than one report, and buttons for every status transition currently allowed from its state (e.g. an "acknowledged" incident shows "Verified" and "Rejected" buttons; a "verified" incident shows only "Active"). Tapping a transition button opens a dialog collecting an optional reason and evidence string before confirming.
- There is no dedicated screen name for this in the blueprint's own screen list — its own doc comment notes this is "the natural home for the workflow [this module's] acceptance criterion describes," i.e. this screen was purpose-built to host the lifecycle, not lifted from a named blueprint mockup.
- A Field Responder also drives this same lifecycle from a different screen (`FieldIncidentDetailScreen`, in the `field_response` module, calling the same `IncidentVerificationService.transitionIncident`) — see field_response.md for that flow; this module's own screen is the Local Official's view of it.

## Entry points

- Route `/verification` in `lib/app/router.dart` → `VerificationScreen`. Guarded in `lib/app/route_guard.dart`'s `defaultRoutePermissions` map by `Permission.verifyReports` (`'/verification': Permission.verifyReports`).
- Reachable from the home screen's quick-action grid for `UserRole.localOfficial` (the only role granted `verifyReports` in `user_role.dart`).
- `incidentVerificationServiceProvider` is also called directly (without navigating to `/verification`) from `lib/features/field_response/presentation/field_incident_detail_screen.dart` (`_transition`, for a Field Responder's own on-site status updates) — outside this module.

## Architecture

Domain / application / presentation layering, no `data/` folder (persistence delegated to `LocalIncidentReportRepository`/`LocalIncidentRepository` in `lib/core/database/repositories/`, outside this module):

- **domain/** — `IncidentVerificationStatus` (the six-state lifecycle enum plus the allowed-transitions map).
- **application/** — `IncidentVerificationEngine` (pure: is this transition allowed), `IncidentVerificationService` (orchestration: acknowledge, transition, assign responder, remove, list pending, audit trail — all audited and sync-queued), `verification_providers.dart` (Riverpod wiring).
- **presentation/** — `VerificationScreen`.

## Files in this module

### `lib/features/verification/application/incident_verification_engine.dart`
- **Purpose:** The deterministic core: is a requested `from → to` status transition even allowed. Pure, no I/O, so `IncidentVerificationService` can check a transition before touching the database.
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `IncidentVerificationEngine.validateTransition({from, to})` → `Result<IncidentVerificationStatus>` — looks up `allowedIncidentStatusTransitions[from]`, returns `ValidationFailure` if `to` isn't in that set.
- **Depends on:** `IncidentVerificationStatus`, `allowedIncidentStatusTransitions` (this module's own domain file), `Result`/`Failure`. **Depended on by:** `IncidentVerificationService.transitionIncident`, `verification_providers.dart`.
- **State:** none (pure).
- **External communication:** none.

### `lib/features/verification/application/incident_verification_service.dart`
- **Purpose:** Orchestrates the full lifecycle: turns an unlinked citizen report into a tracked incident via the fusion module's `GroundTruthFusionEngine` (so a report matching an already-tracked incident joins it rather than spawning a duplicate), and moves incidents through the rest of the lifecycle — writing a real audit entry to `AuditLogDao` for every state change.
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `IncidentVerificationService` — `acknowledgeReport({reportId, officialId, reason?, now?})` → `Result<LocalIncident>` (runs `GroundTruthFusionEngine.evaluate`; if it matches an existing incident, updates that incident's severity/independentSourceCount/confidence and links the report to it via `incidentId`, audit action `incident.report_merged`; if not, creates a new incident in `acknowledged` status, audit action `incident.acknowledged`); `transitionIncident({incidentId, to, officialId, reason?, evidence?, now?})` → `Result<LocalIncident>` (validates via `IncidentVerificationEngine` first — an invalid transition fails cleanly with **no** audit entry written, confirmed by test; a valid one writes audit action `incident.status_changed` with old/new status and optional evidence in `newValue`); `assignResponder({incidentId, responderId, officialId, now?})` → District/Command's responder-assignment action (`responderId: null` unassigns), audit action `incident.responder_assigned`/`incident.responder_unassigned`; `removeIncident({incidentId, adminId, reason?, now?})` → a System Admin's content-moderation hard-delete (both locally and, once synced, in Firestore — relies on the sync module's pull diffing each device's cache against the current remote id set to propagate the delete), audit action `incident.removed`; `pendingReports()` → reports with `incidentId == null`; `auditTrailFor(incidentId)` → full audit history for one incident.
- **Notable imports:** `fusion/application/ground_truth_fusion_engine.dart` (the M14 matching logic this service delegates to but does not itself implement — out of this module's scope), `AuditLogDao`, `SyncQueueDao`.
- **Depends on:** `LocalIncidentReportRepository`, `LocalIncidentRepository`, `AuditLogDao`, `IncidentVerificationEngine`, `GroundTruthFusionEngine`, `SyncQueueDao?`. **Depended on by:** `verification_providers.dart`, `VerificationScreen` directly, and `FieldIncidentDetailScreen`/`AssignedIncidentsScreen` (`field_response` module) for the Field Responder's own status-transition and damage-report-adjacent workflow.
- **State:** writes `local_incidents` (create/update/delete via repository), updates `local_incident_reports.incidentId` on acknowledgement, writes `sync_queue` and `audit_log`.
- **External communication:** none directly (local Drift only); `removeIncident`'s doc comment explicitly notes the delete "propagates to every other device the same way a delete elsewhere is noticed here" via the sync module's pull-diff mechanism, not a direct Firestore call from this service.
- **Demo/mock content:** none — this is the real orchestration layer.

### `lib/features/verification/application/verification_providers.dart`
- **Purpose:** Riverpod wiring for the engine and service, plus the `pendingReportsProvider` the screen reads.
- **Status:** IMPLEMENTED.
- **Key providers:** `incidentVerificationEngineProvider`, `incidentVerificationServiceProvider`, `pendingReportsProvider` (`FutureProvider.autoDispose`, reads `pendingReports()` and degrades to empty list on failure).
- **Depends on:** `core/providers/core_providers.dart`, `fusion/application/fusion_providers.dart` (`groundTruthFusionEngineProvider`). **Depended on by:** `VerificationScreen`, `FieldIncidentDetailScreen`.

### `lib/features/verification/domain/incident_verification_status.dart`
- **Purpose:** The six-state lifecycle enum and its allowed-transitions map. Its own doc comment: the blueprint's lifecycle is "New→acknowledged→verified/rejected→active→resolved," transcribed exactly except the first state is named `reported` here since `new` is a reserved word in Dart — its storage value is still the literal string `'new'`.
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `IncidentVerificationStatus` (`reported`, `acknowledged`, `verified`, `rejected`, `active`, `resolved`) — `storageValue`, `label`, `fromStorageValue(String)`. `allowedIncidentStatusTransitions` — `Map<IncidentVerificationStatus, Set<IncidentVerificationStatus>>`: `reported → {acknowledged}`; `acknowledged → {verified, rejected}`; `verified → {active}`; `rejected → {}` (terminal); `active → {resolved}`; `resolved → {}` (terminal). Its own comment notes "rejected and resolved are terminal ... there's no path back out of either. Reopening a wrongly-rejected report is a manual re-acknowledgement (a fresh entry into the lifecycle), not a transition this map allows."
- **Depended on by:** `IncidentVerificationEngine`, `IncidentVerificationService`, `VerificationScreen`, `FieldIncidentDetailScreen` (field_response module).

### `lib/features/verification/presentation/verification_screen.dart`
- **Purpose:** The only UI in this module — described in User-facing functionality above.
- **Status:** IMPLEMENTED and wired to the real service (`_acknowledge`/`_IncidentCard._showTransitionDialog` both call `incidentVerificationServiceProvider` for real).
- **Key classes:** `VerificationScreen` (`ConsumerWidget`), `_IncidentCard` (`ConsumerWidget`) — computes `nextOptions` from `allowedIncidentStatusTransitions[status]` to render exactly the valid transition buttons for the incident's current state, and `_showTransitionDialog` collects reason/evidence before confirming.
- **Notable imports:** `map/application/map_data_providers.dart` (`incidentsProvider` — reads the same incidents the map module renders, invalidated after every acknowledge/transition so the map's incident layer updates immediately).
- **Depends on:** `pendingReportsProvider`, `incidentsProvider` (map module), `incidentVerificationServiceProvider`, `currentUserProvider` (auth module, for `officialId`). **Depended on by:** router (`/verification` route).
- **State:** reads `pendingReportsProvider`, `incidentsProvider`; writes via `incidentVerificationServiceProvider.acknowledgeReport`/`transitionIncident`, invalidating both providers after every write.
- **Demo/mock content:** none.

## Data Models

- **`IncidentVerificationStatus`** — enum `reported`/`acknowledged`/`verified`/`rejected`/`active`/`resolved`, with `storageValue`/`label`; `allowedIncidentStatusTransitions` map.
- **`LocalIncident`** (Drift row, `core/database/tables/local_incidents_table.dart`) — `id`, `type`, `status` (an `IncidentVerificationStatus.storageValue`), `latitude`, `longitude`, `description` (default `''`), `severity` (default `'unknown'`), `independentSourceCount` (default 1 — the fusion module's ground-truth output: how many independent reporters, deduplicated by reporter id, have corroborated this incident), `confidence` (default 0.5), `createdAt`, `updatedAt`, `version`, `isSynced` (default false), `assignedResponderId: String?` (set by District/Command, read by the field_response module's assigned-incidents list).
- **`LocalIncidentReport`** (see `reporting` module for full field list) — this module reads `incidentId` (null = pending, non-null = already linked) and writes it back on acknowledgement.

## Services / Repositories

- **`IncidentVerificationEngine`** (pure engine) — transition validity.
- **`IncidentVerificationService`** (orchestrator) — acknowledge (with fusion), transition, assign, remove, list pending, audit trail. See Files above for full detail.
- **`GroundTruthFusionEngine`** (`fusion` module, outside this documented scope but load-bearing here) — evaluates whether a new report matches an existing incident. Confirmed from its own source (`lib/features/fusion/application/ground_truth_fusion_engine.dart`, read only to verify this claim, not otherwise documented here): matching is proximity- and type-based, with a `clusterRadiusMeters = 500` constant — a same-type report within 500m of an existing incident's reports merges into it; farther than that starts a new incident (consistent with this module's own tests: a report ~150m away merges, one at `(40, 40)` — thousands of km away — does not). Also computes the merged severity (escalates to the worse of the two), `independentSourceCount`, and `confidence`.
- **`LocalIncidentRepository`/`LocalIncidentReportRepository`** (outside this module, in `core/database/repositories/`) — the actual Drift persistence layer.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/verification` | `VerificationScreen` | `Permission.verifyReports` | Home screen quick actions (Local Official). |

## Module Data Flow

A Local Official acknowledges a pending report, then moves the resulting incident through the lifecycle:

```
VerificationScreen  (route: /verification, guarded by Permission.verifyReports)
  ref.watch(pendingReportsProvider)  → IncidentVerificationService.pendingReports()
                                        → LocalIncidentReportRepository.getAll() → filter incidentId == null
  ref.watch(incidentsProvider)  [map module]  → LocalIncidentRepository.getAll()

Official taps "Acknowledge" on a pending report
  → ref.read(incidentVerificationServiceProvider).acknowledgeReport(reportId, officialId)
      IncidentVerificationService.acknowledgeReport()
        → LocalIncidentReportRepository.getById(reportId)
        → LocalIncidentRepository.getAll()  +  LocalIncidentReportRepository.getAll()  (build fusion context)
        → GroundTruthFusionEngine.evaluate(newReport, existingIncidents, reportsByIncidentId)   [fusion module]
            → match found  → merge: update existing LocalIncident's severity/sourceCount/confidence
            → no match     → create: new LocalIncident(status: 'acknowledged')
        → LocalIncidentRepository.save(incident)
        → SyncQueueDao.enqueue('local_incidents', ...)
        → LocalIncidentReportRepository.save(report.copyWith(incidentId: incident.id))
        → AuditLogDao.record(action: 'incident.acknowledged' | 'incident.report_merged', ...)
  → ref.invalidate(pendingReportsProvider); ref.invalidate(incidentsProvider)   [map module refreshes]

Official taps "Verified" on the now-tracked incident
  → _showTransitionDialog collects optional reason/evidence
  → ref.read(incidentVerificationServiceProvider).transitionIncident(incidentId, to: verified, officialId, reason, evidence)
      IncidentVerificationService.transitionIncident()
        → LocalIncidentRepository.getById(incidentId)
        → IncidentVerificationEngine.validateTransition(from: acknowledged, to: verified)  → allowed
        → LocalIncidentRepository.save(incident.copyWith(status: 'verified'))
        → SyncQueueDao.enqueue(...)
        → AuditLogDao.record(action: 'incident.status_changed', oldValue: {status: acknowledged},
                              newValue: {status: verified, evidence: ?evidence})
  → ref.invalidate(incidentsProvider)
```

## Current Status

**Working.** Both `acknowledgeReport` (including the fusion-based merge path) and `transitionIncident` (including rejection of invalid transitions with zero audit-entry side effect) are real, tested end-to-end against an in-memory Drift database — not mocked business logic. This is the actual pipeline that turns `reporting` module output into the tracked incidents every other module (map, field_response, dashboard) reads.

## Known Limitations

- `rejected` and `resolved` are hard terminal states with no transition path back out in `allowedIncidentStatusTransitions` — a wrongly-rejected report must be re-acknowledged as a fresh entry into the lifecycle (a new `acknowledgeReport` call, not a state-map transition), which starts it over rather than resuming from where it was rejected.
- `acknowledgeReport`'s fusion match is evaluated only against reports already merged into *existing* incidents (`reportsByIncidentId`) plus the new report — there is no explicit re-evaluation of already-acknowledged incidents against each other if their own geometry/type overlaps after the fact.
- `removeIncident` is a hard delete relying entirely on the sync-queue "delete" entry and the sync module's pull-diff to propagate to other devices — there is no tombstone/soft-delete record kept locally, so a device that never receives that particular sync pass (e.g. was offline through several sync cycles) could have stale data indefinitely until its own next full pull.
- `transitionIncident`'s `evidence` field is a free-text string, not a structured/validated reference (e.g. no check that it points to an actual attached photo or damage report).
- `VerificationScreen` has no filtering/sorting for a large pending-reports or tracked-incidents list — both render as flat lists with no pagination.

## Test Coverage

`test/features/verification/` contains three files:

- **`incident_verification_engine_test.dart`** — allows a valid forward transition; allows the acknowledged fork to either verified or rejected; rejects skipping a state (new straight to active); rejects moving backward; rejects any transition out of a terminal state (both rejected and resolved).
- **`incident_verification_service_test.dart`** — thorough: `acknowledgeReport` creates an acknowledged incident and links the report back to it, fails cleanly for an unknown report, and removes the report from `pendingReports` once acknowledged. `transitionIncident`: a valid transition with reason/evidence is explicitly labeled "the acceptance criterion" for "authorized official changes incident state with audit entry," and verifies the audit entry's actor/action/objectType/objectId/reason/oldValue/newValue in full; an invalid transition is rejected and confirmed to write **no** audit entry; a full acknowledge→verified→active→resolved path accumulates exactly one audit entry per step (four total); fails cleanly for an unknown incident. A `group('ground-truth fusion (M14) via acknowledgeReport')` covers: a second nearby report of the same type merges into the first incident, escalates severity to the worse of the two, and is recorded as `incident.report_merged` in the audit trail; a report far away starts its own incident instead of merging.
- **`incident_verification_status_test.dart`** — the initial state stores as the literal string `'new'`; every status round-trips through its storage value; an unrecognized storage value maps to null; the transition map matches the spec's literal lifecycle exactly; rejected and resolved are confirmed terminal (empty transition sets).

**Not covered by any test in this module:** `VerificationScreen` has no widget test in `test/features/verification/` — the pending-reports/tracked-incidents rendering, the acknowledge button, and the transition dialog (reason/evidence collection) are all untested at this layer. `assignResponder` and `removeIncident` have no dedicated test in this module's own test directory (their logic is straightforward CRUD-plus-audit, but the responder-assignment and admin-removal paths specifically are unverified by a test file under `test/features/verification/`). `verification_providers.dart` has no dedicated provider-wiring test.
