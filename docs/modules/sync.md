# MODULE: Sync (`lib/features/sync/`)

## Purpose

Sync (blueprint milestone "M17") is TAARAK's offline-first synchronization engine. It drains a single local outbox (`SyncQueueEntries` in the Drift database) that every feature enqueues to whenever it writes offline-created/edited data, pushes those entries to a backend transport with deduplication, priority ordering, exponential-backoff retry, and version-based conflict resolution, and pulls back every other device's changes for eight shared-state entity tables so a second device (a different login, a different role) actually sees data the first one created. It is pure orchestration/coordination — it owns no UI and is invisible to every screen except for the numbers it feeds into a "pending sync" banner elsewhere in the app.

## User-facing functionality

None directly — this module has no `presentation/` layer and no routed screen. Its effect is felt everywhere indirectly: any screen that watches a data provider derived from a `core/database` repository sees fresher data after a sync run completes, because `sync_providers.dart`'s `_syncAndRefresh` helper invalidates ten cross-feature providers after every run (see Module Data Flow below). The two providers other features actually surface to a human (`pendingSyncCountProvider`, `syncQueueSummaryProvider`) live in this module but are consumed by presentation code outside it.

## Entry points

Not route-based — this module is triggered entirely by app-lifecycle events, watched once at the app root:

| Trigger | Provider | Watched from |
|---|---|---|
| Offline→online transition | `syncOnReconnectTriggerProvider` | `lib/app/app.dart`, `TaarakApp.build` |
| Periodic timer (admin-configurable interval, default 45s) | `syncPollingTriggerProvider` | `lib/app/app.dart`, `TaarakApp.build` |

Both are `Provider.autoDispose<void>` — side-effect-only providers whose entire purpose is the subscription/timer they set up, kept alive for the app's session because `TaarakApp` (a `ConsumerWidget` that never unmounts) holds a permanent `ref.watch` on each. No screen, and no other part of the app, triggers a sync directly (there is no "Sync now" button call site inside this module — that would live in whichever screen renders `syncQueueSummaryProvider`, outside this module's scope).

## Architecture

Three-layer split:
- **`application/`** — `sync_engine.dart` is a pure, IO-free deterministic core (dedup, priority ordering, backoff timing, conflict-winner decision, queue summarization — no database or network calls). `sync_coordinator_service.dart` is the orchestration layer: it's the only class in this module that actually talks to `SyncQueueDao`, `NetworkInfo`, a `SyncTransport`, and up to eight `LocalRepository` implementations. `sync_transport.dart` (interface + `ApiSyncTransport`) and `firestore_sync_transport.dart` (`FirestoreSyncTransport`) are the two interchangeable backend implementations. `sync_providers.dart` wires everything into Riverpod and defines the two lifecycle triggers.
- **`domain/`** — six small, dependency-free value types (`DedupeResult`, `RemoteSyncRecord`, `SyncConflictResolution`, `SyncPushOutcome`, `SyncQueueSummary`, `SyncRunSummary`) that carry data between the layers above without any of them depending on Drift-generated types directly (except where `SyncQueueEntry` itself, a `core/database` generated class, is unavoidably the queue's row type).
- No `data/` or `presentation/` subfolder — persistence is entirely the shared `core/database/` layer (`SyncQueueDao` plus the eight entity repositories), and there is no UI in this module.

## Files in this module

### `lib/features/sync/application/sync_engine.dart`
- **Purpose**: The deterministic core of M17 — everything sync needs to decide *which* entries to push, in *what order*, whether an entry is *ready to retry*, and *who wins* a version conflict. Contains no I/O; `SyncCoordinatorService` is the only caller.
- **Status**: IMPLEMENTED.
- **Key classes/functions**:
  - `SyncEngine.dedupe(entries) -> DedupeResult` — collapses multiple queued entries for the same `entityTable:entityId` down to the highest-`id` (most recent) one; everything else becomes `superseded` and gets marked synced immediately without a network call.
  - `SyncEngine.prioritize(entries) -> List<SyncQueueEntry>` — sorts by a 4-tier priority (0 = `reportType == 'sos'`, 1 = `severity == 'critical'`, 2 = everything else, 3 = `entityTable == SyncEngine.mediaAttachmentsTable` i.e. `'media_attachments'`), oldest-first within a tier. This is the concrete mechanism behind the "critical text/GPS syncs even if media fails" acceptance criterion: a report's own queue entry is always pushed before its own photo attachment, and a stuck/failing media push never blocks a report.
  - `SyncEngine.isReadyToRetry(entry, now) -> bool` — `true` for any non-`'failed'` entry; a `'failed'` entry must have passed its backoff window since `lastAttemptAt`.
  - `SyncEngine.backoffDelay(attemptCount) -> Duration` — `baseBackoff (2s) * 2^attemptCount`, clamped to `maxBackoff` (5 minutes) with the exponent itself clamped to 8 to avoid overflow.
  - `SyncEngine.shouldGiveUp(entry, {maxAttempts = defaultMaxAttempts (5)}) -> bool`.
  - `SyncEngine.resolveConflict({localVersion, serverVersion}) -> SyncConflictResolution` — **the entire conflict-resolution algorithm, in full**: `localVersion > serverVersion ? localWins : serverWins`. This is a strict version-number comparison, not last-write-wins-by-timestamp and not always-client-wins/always-server-wins — whichever side holds the numerically higher `version` field wins; a tie goes to the server (local push treated as redundant, not retried).
  - `SyncEngine.localVersionOf(entry) -> int` — reads `payloadJson['version']`, defaulting to `1` if absent or the payload isn't valid JSON.
  - `SyncEngine.summarize(entries) -> SyncQueueSummary` — partitions into pending/retrying/stalled (stalled = would `shouldGiveUp`).
  - Constants: `defaultMaxAttempts = 5`, `baseBackoff = 2s`, `maxBackoff = 5min`, `mediaAttachmentsTable = 'media_attachments'` (a queue-only table name — no `LocalMediaAttachments` Drift table exists; it's purely a priority-sorting convention).
  - `syncModelVersion = '1.0.0'` — a top-level constant, declared but not referenced anywhere else read in this module; likely a placeholder for future payload-schema versioning.
- **Notable imports**: `dart:convert` (payload decoding), `core/database/app_database.dart` (`SyncQueueEntry`), three `domain/` types.
- **Depends on**: nothing stateful — pure logic over its inputs.
- **Depended on by**: `sync_coordinator_service.dart` (default engine when none injected), `sync_providers.dart` (`syncEngineProvider`, `syncQueueSummaryProvider`), both `sync_engine_test.dart` and `sync_coordinator_service_test.dart`.
- **Mock/demo content**: none.

### `lib/features/sync/application/sync_coordinator_service.dart`
- **Purpose**: Orchestrates a full sync run: drains the outbox through `SyncEngine`'s rules against a `SyncTransport`, then pulls fresh data for every wired entity repository. This class's `syncPendingEntries` is the acceptance-criterion method for "offline data must synchronize safely once connectivity is back" — safely meaning no duplicate pushes (dedup), no silent data loss on conflict (version comparison, never blind overwrite), and no hammering a backend that just rejected a request (backoff).
- **Status**: IMPLEMENTED.
- **Key classes/functions**:
  - Constructor — takes `SyncQueueDao`, `NetworkInfo`, `SyncTransport` (all required), an optional `SyncEngine` (defaults to `SyncEngine()`), and eight **optional** `LocalRepository` fields (`incidentReportRepository`, `incidentRepository`, `hazardZoneRepository`, `shelterRepository`, `alertRepository`, `damageReportRepository`, `resourceRepository`, `habitationRepository`) — each pull step is skipped as a no-op when its repository isn't supplied, which is how tests exercise a subset without wiring everything.
  - `syncPendingEntries({now?}) -> Future<SyncRunSummary>` — the entry point. If offline, returns immediately with `skippedOffline: true` (no push attempted). If the queue is empty, still runs the pull half (`_pullAll`) so a device that never creates its own data still receives others' updates. Otherwise: `dedupe` → mark superseded entries synced → `prioritize` → for each entry, skip if `shouldGiveUp` (counts as `abandoned`) or not yet `isReadyToRetry` (silently skipped this run), else `transport.push(entry)`:
    - `accepted` → `markSynced`, count as `synced`.
    - `conflict` → `resolveConflict(localVersion, serverVersion ?? localVersion)`; `serverWins` → `markSynced` (redundant push, not an error); `localWins` → `markFailed` (kept queued, retried next run — **not** an automatic re-push in the same run).
    - transport failure (`Failed<SyncPushOutcome>`) → `markFailed`, count as `failed`.
    - Always finishes with `_pullAll()`, whose count feeds `SyncRunSummary.pulledCount`.
  - `_pullAll() -> Future<int>` — computes the set of entity ids that still have pending/failed queue entries per table (so a fresh, not-yet-pushed local creation is never mistaken for "deleted upstream" and wiped), then calls each of eight `_pull<Entity>()` methods in sequence, summing applied counts.
  - `_deleteLocallyMissing<T>({getAllLocal, deleteLocal, idOf, remoteIds, pendingIds})` — the generic delete-diff: any locally-cached row whose id is absent from the just-pulled remote set *and* not in the still-pending set is deleted locally. This is how a System Admin's remote content-moderation delete (no per-record delete event exists in the transport contract) eventually propagates to other devices — purely inferred from absence, not from an explicit delete signal.
  - Per-entity pull pairs (`_pull<Entity>()` + `_<entity>FromPayload(RemoteSyncRecord)`), one per wired repository: `_pullIncidentReports`/`_reportFromPayload` (no delete-diff; `mediaPath` always nulled — a remote report's photo lives only on the device that took it), `_pullIncidents`/`_incidentFromPayload` (with delete-diff), `_pullHazardZones`/`_hazardZoneFromPayload` (with delete-diff), `_pullShelters`/`_shelterFromPayload` (no delete-diff), `_pullAlerts`/`_alertFromPayload` (with delete-diff), `_pullDamageReports`/`_damageReportFromPayload` (no delete-diff; `mediaPath` nulled same as reports), `_pullResources`/`_resourceFromPayload` (no delete-diff), `_pullHabitations`/`_habitationFromPayload` (deliberately no delete-diff — comment states nothing in the app deletes a habitation).
  - Every pull applies the same version guard inline: `if (local != null && local.version >= record.version) continue;` — a remote record no newer than the local copy is simply skipped, so a pull can never regress a locally-ahead entity.
  - Every `_<entity>FromPayload` wraps its JSON decode in try/catch, returning `null` (silently skipped) on any malformed payload rather than throwing.
- **Notable imports**: `dart:convert`, eight `core/database/repositories/*`, `core/database/sync_queue_dao.dart`, `core/network/network_info.dart`, `core/repository/result.dart`, `sync_engine.dart`, `sync_transport.dart`, three `domain/` types.
- **Depends on**: `SyncQueueDao`, `NetworkInfo`, `SyncTransport`, `SyncEngine`, up to eight `LocalRepository` implementations.
- **Depended on by**: `sync_providers.dart` (`syncCoordinatorServiceProvider`, fully wired with all eight repositories), `sync_coordinator_service_test.dart`.
- **Mock/demo content**: none — real Drift persistence when tested against an in-memory database; the eight-repository wiring in production goes through the real `core_providers.dart` repositories.

### `lib/features/sync/application/sync_transport.dart`
- **Purpose**: The abstraction `SyncCoordinatorService` needs to exchange data with "somewhere" — kept separate from the coordinator so the dedup/retry/conflict/priority logic is testable without a real backend, and so the backend can be swapped (see `AppConfig.useFirebaseAuth`).
- **Status**: `SyncTransport` interface — IMPLEMENTED. `ApiSyncTransport` — IMPLEMENTED but genuinely non-functional in the running app: it talks to a generic `/sync/<entityTable>` REST endpoint via `ApiClient`, whose `apiBaseUrl` (`http://localhost:8080/api`, from `AppConfig.development()`) is a never-deployed placeholder — the doc comment states outright "this genuinely fails with a `NetworkFailure`/`ServerFailure` against the placeholder `apiBaseUrl`." It is selected only when `AppConfig.useFirebaseAuth == false`, which is never the case in the shipped `AppConfig.development()` factory (`useFirebaseAuth: true` is hardcoded), so `ApiSyncTransport` is effectively dead code on the path actually exercised by the running app today, though it remains fully wired and would activate if that flag flipped.
- **Key classes/functions**: abstract `SyncTransport` — `push(SyncQueueEntry) -> Result<SyncPushOutcome>`, `pullAll(String table) -> Result<List<RemoteSyncRecord>>`; `ApiSyncTransport` (constructor takes `ApiClient`) — `push` POSTs `{entityId, operation, payload}`, parses a `{conflict: bool, serverVersion?}` response shape; `pullAll` GETs and parses a list of `{entityId, payload, version}`.
- **Notable imports**: `core/database/app_database.dart`, `core/network/api_client.dart`, `core/repository/result.dart`, two `domain/` types.
- **Depends on**: `ApiClient`.
- **Depended on by**: `sync_providers.dart` (`syncTransportProvider`, conditionally), `firestore_sync_transport.dart` (implements the same interface, not a dependency of this file).

### `lib/features/sync/application/firestore_sync_transport.dart`
- **Purpose**: The real, hosted sync transport actually used by the running app — replaces `ApiSyncTransport`'s call to the never-deployed backend stub with direct Cloud Firestore reads/writes. One Firestore collection per `entityTable` string, one document per `entityId`, implementing the exact same version-based conflict contract `SyncEngine.resolveConflict` expects.
- **Status**: IMPLEMENTED. This is the transport actually selected in production (`AppConfig.development().useFirebaseAuth == true`).
- **Key classes/functions**: `FirestoreSyncTransport` (constructor takes optional `FirebaseFirestore`, defaults to `FirebaseFirestore.instance`); `push(entry)` — a hard `delete` operation is a plain Firestore doc delete (no version check — deleting an already-gone doc is a no-op success, not an error); a create/update runs inside `_firestore.runTransaction`: reads the existing doc's `version` field (defaults to 1 if the field is missing), and if the incoming version is `<=` the existing one, returns `SyncPushOutcome.conflict(existingVersion)` **without writing**; otherwise `transaction.set(docRef, {payload, version})` and returns `accepted`. Any thrown exception (network, permission-denied, etc.) is caught and mapped to `Result.failure(NetworkFailure())`, regardless of the real cause. `pullAll(table)` — reads every document in the collection and maps it to a `RemoteSyncRecord`; also blanket-catches to `NetworkFailure()`. `_versionOf(payloadJson)` — decodes the version out of the payload for the version stamped alongside it in Firestore (defaults to 1 on any decode failure).
- **Notable imports**: `dart:convert`, `cloud_firestore`.
- **Depends on**: `core/database/app_database.dart` (`SyncQueueEntry`), `core/error/failure.dart`, `core/repository/result.dart`, `sync_transport.dart` (implements it), two `domain/` types.
- **Depended on by**: `sync_providers.dart` (`syncTransportProvider`, the actual selected branch).
- **Mock/demo content**: none in the transport itself, but tested exclusively against `fake_cloud_firestore`'s in-memory fake, never a live Firestore instance — see Test Coverage.

### `lib/features/sync/application/sync_providers.dart`
- **Purpose**: Riverpod wiring for the whole module, and the two app-lifetime side-effect providers that make sync actually run without any screen knowing it exists.
- **Status**: IMPLEMENTED.
- **Key classes/functions**:
  - `syncEngineProvider` — plain `SyncEngine()`.
  - `syncTransportProvider` — branches on `appConfigProvider`'s `useFirebaseAuth`: `FirestoreSyncTransport()` if true (the live path), `ApiSyncTransport(apiClient)` if false (the dead-in-practice path).
  - `syncCoordinatorServiceProvider` — the fully-wired `SyncCoordinatorService` with all eight repositories attached.
  - `pendingSyncCountProvider` (`FutureProvider.autoDispose<int>`) — raw count of `SyncQueueDao.listSyncable()` (pending + failed).
  - `syncQueueSummaryProvider` (`FutureProvider.autoDispose<SyncQueueSummary>`) — the breakdown version, via `SyncEngine.summarize`.
  - `syncOnReconnectTriggerProvider` (`Provider.autoDispose<void>`) — subscribes to `NetworkInfo.onConnectivityChanged`, tracks a local `wasConnected` flag (starts `true`), and calls `_syncAndRefresh` exactly on a `false→true` edge (not on every "connected" event, and not on the initial subscription). Cancels the subscription in `ref.onDispose`.
  - `syncPollingTriggerProvider` (`Provider.autoDispose<void>`) — `ref.watch`es `technicalConfigProvider` for `syncIntervalSeconds` (falls back to `TechnicalConfig.defaults.syncIntervalSeconds` = **45** if the admin config hasn't loaded), calls `_syncAndRefresh` once immediately (so app launch doesn't wait for the first `Timer.periodic` tick), then sets up `Timer.periodic(Duration(seconds: intervalSeconds), ...)`. Because this watches (not reads) the config provider, an admin changing the interval on the "Manage Technical Configuration" screen rebuilds this provider — cancelling and recreating the timer with the new interval — live, for every running session, not just after a restart. Cancels the timer in `ref.onDispose`.
  - `_syncAndRefresh(Ref)` (private) — calls `syncCoordinatorServiceProvider.read().syncPendingEntries()` inside a try/catch that silently swallows any exception (comment: "a transient failure ... shouldn't surface anywhere; the next periodic tick or reconnect event just tries again" — there is no user-visible error path for a sync failure at this layer). On success, invalidates ten providers from six other features: `hazardZonesProvider`, `sheltersProvider`, `incidentsProvider`, `habitationsOverviewProvider`, `routesProvider`, `alertHistoryProvider`, `activeAlertsForCurrentLocationProvider`, `pendingReportsProvider`, `auditEventsProvider`, `dashboardSnapshotProvider`.
- **Notable imports**: `dart:async` (`Timer`), `core/providers/core_providers.dart`, and cross-feature imports into `features/admin/` (`admin_providers.dart`, `technical_config.dart`), `features/alerts/`, `features/audit/`, `features/dashboard/`, `features/map/`, `features/verification/` — this file is the single most cross-feature-coupled file in the sync module, by design (it's the app's central "refresh everything after sync" hook).
- **Depends on**: `SyncEngine`, `SyncCoordinatorService`, `FirestoreSyncTransport`, `ApiSyncTransport`, `TechnicalConfig`/`technicalConfigProvider` (from `features/admin/`), and the ten invalidated providers listed above.
- **Depended on by**: `lib/app/app.dart` (`TaarakApp.build` watches `syncOnReconnectTriggerProvider` and `syncPollingTriggerProvider`), whichever screen(s) render `pendingSyncCountProvider`/`syncQueueSummaryProvider` (outside this module's scope).
- **Mock/demo content**: none.

### `lib/features/sync/domain/dedupe_result.dart`
- **Purpose**: Output shape of `SyncEngine.dedupe` — which entries are still worth pushing (`toPush`) vs. stale duplicates that can be marked synced without a network call (`superseded`).
- **Status**: IMPLEMENTED. Trivial data class, no logic.

### `lib/features/sync/domain/remote_sync_record.dart`
- **Purpose**: One entity as the backend has it — the pull-side counterpart to `SyncQueueEntry`'s push side. Same payload shape as a push for that table would have sent, so both sides can share a decoder.
- **Status**: IMPLEMENTED. Fields: `entityId`, `payloadJson`, `version`.

### `lib/features/sync/domain/sync_conflict_resolution.dart`
- **Purpose**: The two-value outcome of `SyncEngine.resolveConflict`.
- **Status**: IMPLEMENTED. `enum SyncConflictResolution { localWins, serverWins }` — `localWins` means the queued local change is strictly newer and should be retried/pushed again to overwrite; `serverWins` means the server is already at an equal-or-newer version, so the local push is redundant and dropped without error.

### `lib/features/sync/domain/sync_push_outcome.dart`
- **Purpose**: What a transport's `push` call reports back for one entry.
- **Status**: IMPLEMENTED. `SyncPushStatus` enum (`accepted`, `conflict`); `SyncPushOutcome` — `.accepted()` const constructor (`serverVersion` null), `.conflict(serverVersion)` const constructor.

### `lib/features/sync/domain/sync_queue_summary.dart`
- **Purpose**: A more honest breakdown of "N items waiting to sync" than a raw count — distinguishing "never attempted" from "actively retrying" from "gave up." Also owns the human-readable message-selection logic for whatever UI surfaces this (outside this module).
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `SyncQueueSummary` (`pendingCount`, `retryingCount`, `stalledCount`, `totalCount`, `isEmpty`); `syncQueueSummaryMessage(SyncQueueSummary) -> String` — priority order stalled > retrying > pending > "Up to date", each with correct singular/plural grammar.

### `lib/features/sync/domain/sync_run_summary.dart`
- **Purpose**: Outcome of one `syncPendingEntries` call — what actually happened, not just "it ran."
- **Status**: IMPLEMENTED. Fields: `syncedCount`, `conflictCount`, `failedCount`, `abandonedCount` (hit `shouldGiveUp` this run — still queued, not deleted), `skippedOffline`, `pulledCount`.

## Data Models

- **`SyncQueueEntry`** (Drift-generated, table `sync_queue_entries` — full column table in `docs/modules/core_database.md`): the queue row this entire module operates on.
- **`DedupeResult`, `RemoteSyncRecord`, `SyncConflictResolution`, `SyncPushOutcome`, `SyncQueueSummary`, `SyncRunSummary`** — the six `domain/` value types documented above.
- Eight `core/database` generated entity models the pull half writes into: `LocalIncidentReport`, `LocalIncident`, `LocalHazardZone`, `LocalShelter`, `LocalAlert`, `LocalDamageReport`, `LocalResource`, `LocalHabitation` — see `docs/modules/core_database.md` for their full schemas.

## Services / Repositories

- **`SyncEngine`** — pure domain logic (see above); the sole authority on dedup/priority/backoff/conflict-winner decisions.
- **`SyncCoordinatorService`** — the module's only orchestration service; sole write path for marking queue entries synced/failed and applying pulled remote records to local repositories.
- **`SyncTransport` (`ApiSyncTransport`) / `FirestoreSyncTransport`** — the two interchangeable backend transports; `FirestoreSyncTransport` is the one actually active in the running app.
- Shared (outside this module, load-bearing for it): `SyncQueueDao`, eight `LocalRepository` implementations, `NetworkInfo`, `ApiClient` — all in `lib/core/`.

## Routes owned by this module

None — this module has no `presentation/` layer and registers no route in `lib/app/router.dart`.

## Module Data Flow

**Push half (offline-created data reaching the backend):**

```
Any feature's write path (e.g. citizen_report_submission_service.dart)
  -> LocalIncidentReportRepository.save(...)         [writes local_incident_reports]
  -> SyncQueueDao.enqueue(entityTable: 'local_incident_reports', operation: 'create', payloadJson)
                                                       [writes sync_queue_entries, status='pending']

--- later, triggered by reconnect or the polling timer ---

syncOnReconnectTriggerProvider (offline->online edge)          syncPollingTriggerProvider (every syncIntervalSeconds, default 45s)
        \                                                              /
         \____________________________  ____________________________/
                                       \/
                          _syncAndRefresh(ref)
                            -> SyncCoordinatorService.syncPendingEntries()
                               -> NetworkInfo.isConnected? no -> return (skippedOffline: true)
                               -> SyncQueueDao.listSyncable()        [reads sync_queue_entries, status in (pending,failed)]
                               -> SyncEngine.dedupe(...)             [pure: latest-per-entity wins]
                                  -> superseded entries -> SyncQueueDao.markSynced (no network call)
                               -> SyncEngine.prioritize(...)         [pure: sos > critical > routine > media]
                               -> for each entry (skip if shouldGiveUp / not isReadyToRetry):
                                    -> SyncTransport.push(entry)      [FirestoreSyncTransport: Firestore transaction,
                                                                        version compare against stored doc]
                                       accepted       -> SyncQueueDao.markSynced
                                       conflict        -> SyncEngine.resolveConflict(localVersion, serverVersion)
                                                            serverWins -> markSynced (redundant, not an error)
                                                            localWins  -> SyncQueueDao.markFailed (retried next run)
                                       transport failed -> SyncQueueDao.markFailed
                               -> _pullAll() (see below)
                            <- SyncRunSummary
                          ref.invalidate(10 cross-feature providers)  [hazardZones, shelters, incidents, habitationsOverview,
                                                                        routes, alertHistory, activeAlertsForCurrentLocation,
                                                                        pendingReports, auditEvents, dashboardSnapshot]
```

**Pull half (another device's changes reaching this device):**

```
_pullAll()
  -> SyncQueueDao.listSyncable()  [to exclude this device's own not-yet-pushed creations from the delete-diff below]
  -> for each of 8 wired repositories (incident reports, incidents, hazard zones, shelters, alerts, damage reports,
     resources, habitations):
       -> SyncTransport.pullAll('<table>')            [FirestoreSyncTransport: reads every doc in that collection]
       -> for each RemoteSyncRecord:
            local = repository.getById(record.entityId)
            if local != null && local.version >= record.version: skip   [never regress a locally-ahead entity]
            else: decode payload -> repository.save(...)                 [writes the local table]
       -> (incidents, hazard zones, alerts only) _deleteLocallyMissing(...)
            [any locally-cached row absent from the remote set AND not in this device's own pending set is deleted]
  <- total applied count -> SyncRunSummary.pulledCount
```

## Current Status

**Working**, with strong deterministic-logic test coverage and real (if fake-backed) integration coverage of the Firestore transport and the coordinator's push/pull orchestration. `FirestoreSyncTransport` is the transport actually active in the shipped app (`AppConfig.useFirebaseAuth` is hardcoded `true`); `ApiSyncTransport` remains fully implemented but points at a backend that was never deployed, so it is dead in practice on the currently-exercised code path, not dead code in the codebase. Both lifecycle triggers (`syncOnReconnectTriggerProvider`, `syncPollingTriggerProvider`) are watched once at the app root in `lib/app/app.dart` and confirmed live for the whole app session.

## Known Limitations

- **Sync failures are entirely invisible.** `_syncAndRefresh`'s catch-all swallows every exception from `syncPendingEntries()` with no logging call and no surfaced state — a persistent, non-connectivity failure (e.g. a Firestore permission error) produces no diagnostic signal anywhere; the only visible symptom is that `SyncQueueSummary` keeps showing retrying/stalled counts.
- **A `localWins` conflict is not retried within the same run** — it's marked `failed` and picked up on the *next* sync trigger (reconnect or next poll tick), not immediately re-pushed. For a fast succession of edits this could mean a real, deterministically-winning local change waits up to `syncIntervalSeconds` (default 45s) to actually land.
- **`ApiSyncTransport` is unreachable in the shipped app** since `useFirebaseAuth` is hardcoded true in the only `AppConfig` factory ever constructed — its own tests would need to be checked separately (none were found under `test/features/sync/` exercising it directly; only `FirestoreSyncTransport` has a dedicated transport test).
- **Delete propagation is inference-only, not event-based.** `_deleteLocallyMissing` treats "absent from the current full pull" as "deleted upstream" for incidents, hazard zones, and alerts only (shelters, damage reports, resources, incident reports, and habitations never get this treatment — by explicit design for habitations, undocumented for the other four). A transient partial/failed pull for one of the delete-diffed tables could in theory delete rows locally that still exist remotely, though `pullAll`'s own try/catch means a failed pull returns an empty list from `dataOrNull ?? const []` — worth flagging as a theoretical correctness risk even though no test currently exercises it.
- **`syncModelVersion` constant in `sync_engine.dart` is unused** — declared, never referenced elsewhere in the module as read.
- **No widget/UI test exists in this module** (expected, since it has no `presentation/` layer) — but this also means the "invalidate 10 providers" refresh behavior in `_syncAndRefresh` has no test coverage at all; it's verified only by reading the source.

## Test Coverage

- `test/features/sync/sync_engine_test.dart` — exhaustive pure-logic coverage: `dedupe` (multi-entry collapse, single-entry no-op), `prioritize` (SOS-over-routine, critical-over-routine-not-over-SOS, media-always-last including against an older-but-lower-priority report, same-priority oldest-first), `backoffDelay`/`isReadyToRetry` (exponential growth, cap, pending-always-ready, failed-inside/past-window), `shouldGiveUp` (under/at max attempts), `resolveConflict` (strictly-newer-local wins, equal-or-newer-server wins), `localVersionOf` (present/absent payload version), `summarize` (all three categories individually and mixed, empty queue).
- `test/features/sync/sync_coordinator_service_test.dart` — integration-style against a real in-memory Drift `AppDatabase` and a scripted fake `SyncTransport`: offline skip (nothing pushed, stays pending), reconnected push-and-sync, transport failure keeps entry queued for retry, backoff window respected (not retried too early), five-attempt exhaustion produces `abandonedCount` without further pushes, both conflict-resolution branches (server-wins marks synced, local-wins keeps failed for retry), dedup (only latest of two edits to the same entity is pushed), priority (SOS jumps a routine entry queued earlier), the literal "critical text/GPS syncs even if media fails" scenario end-to-end, and three multi-device pull scenarios (a report nobody has locally is pulled and saved; a remote record no newer than local is skipped and local data is preserved; pulling with no repository wired is a safe no-op).
- `test/features/sync/firestore_sync_transport_test.dart` — against `fake_cloud_firestore`'s in-memory fake: new-entity push accepted; strictly-newer push accepted and overwrites; equal-or-lower push is a conflict and does not overwrite; different tables with the same `entityId` are tracked independently (separate Firestore collections); pull sees what another device's push wrote (the literal multi-device acceptance criterion); an empty table pulls back an empty list, not an error.
- `test/features/sync/sync_queue_summary_test.dart` — `SyncQueueSummary.totalCount`/`isEmpty`, and every branch of `syncQueueSummaryMessage`'s priority-ordered message selection including singular/plural grammar.
- **Not covered by any test**: `sync_providers.dart` itself (no test file targets it directly — the two lifecycle-trigger providers, the ten-provider invalidation list, and the swallowed-exception behavior in `_syncAndRefresh` are unverified by automated tests); `ApiSyncTransport` has no dedicated test file under `test/features/sync/`.
