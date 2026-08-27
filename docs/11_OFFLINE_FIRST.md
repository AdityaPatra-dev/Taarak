# Offline-First Behavior

Verified against `lib/features/sync/` (11 files, fully read this pass by a dedicated research pass) and `lib/app/app.dart`.

## What works offline

Every screen that reads from the local Drift database works fully offline: the risk map, the command dashboard, shelters, alerts (viewing), habitation registration, hazard zone reporting, incident reporting, damage reports, relocation priority queue computation (it reads only local Drift data — risk/capacity/relocation engines never make a network call themselves). A citizen or official can use the app's core recording/viewing functionality with zero connectivity.

## What requires internet

- **All authentication** (login, register, forgot-password, logout) — direct Firebase Auth SDK calls, no offline fallback.
- **Config document reads/writes** (`config/policy`, `config/role_permissions`, `config/technical`) — direct Firestore reads, not routed through the sync queue.
- **The actual sync push/pull** — obviously requires connectivity; queued writes wait until it returns.
- **The map tiles themselves** (Google Maps SDK) and **live weather data** (Open-Meteo API, confirmed real by this pass's research — see `docs/modules/environmental.md`).

## Local write queue

Every create/update to an entity that participates in sync (hazard zones, habitations, incidents, incident reports, shelters, alerts, damage reports, resources) writes to its local Drift table **and** enqueues a row in `SyncQueueEntries` (the sync outbox table) — this happens synchronously with the local write, so the write succeeds from the user's perspective immediately, regardless of connectivity.

## What triggers a sync pass

Exactly two providers, both watched once at the app root in `TaarakApp.build()` (`lib/app/app.dart`) — confirmed by direct inspection this pass:

1. **`syncOnReconnectTriggerProvider`** — subscribes to `NetworkInfo.onConnectivityChanged` and fires a sync pass only on a genuine **false→true edge** (an offline→online transition), not on every connectivity event.
2. **`syncPollingTriggerProvider`** — a `Timer.periodic` sync pass. The interval is read reactively from `technicalConfigProvider` (a System Admin can change it live via `/admin/technical`; changing it cancels and recreates the timer for every already-running session), falling back to `TechnicalConfig.defaults.syncIntervalSeconds = 45` seconds if unset. It also fires **once immediately** on creation (app launch), not just after the first interval elapses.

Both funnel into the same method: `SyncCoordinatorService.syncPendingEntries()`.

## Sync pass: what actually happens

1. **Drain the outbox**: list pending `SyncQueueEntries`, deduplicate (a later queued write for the same entity supersedes an earlier one), prioritize, then push each to Firestore via `FirestoreSyncTransport` with a version number attached.
2. **Conflict resolution — purely version-number based, no timestamps involved**: `SyncEngine.resolveConflict({localVersion, serverVersion})` returns `localWins` if `localVersion > serverVersion`, otherwise `serverWins` (a tie is treated as a redundant push, not a conflict). `FirestoreSyncTransport` independently enforces the identical rule **server-side, inside a Firestore transaction**, before accepting any write — so a client cannot force a stale write through by racing the check.
3. **Pull fresh data**: after pushing, the coordinator pulls the current state of 8 wired entity tables from Firestore into the local Drift cache.
4. **Invalidate consumers**: on completion, 10 cross-feature Riverpod providers are explicitly `ref.invalidate()`d, so every already-mounted screen watching that data rebuilds with the fresh result — this is what makes "another device's change eventually shows up here" actually visible without a manual refresh.

## Connectivity detection

`NetworkInfo` (`lib/core/network/network_info.dart`), backed by `connectivity_plus`. Used both by the reconnect trigger above and, independently, by `SyncCoordinatorService` itself to skip a sync attempt entirely (rather than fail loudly) when there's no connectivity at the moment a pass would run.

## Cached data / staleness

Because sync is trigger-based (reconnect + ~45s poll) rather than a live subscription/websocket, there is a real, bounded window — up to the polling interval — during which one device's write is not yet visible on another device. This is a deliberate, documented trade-off (see `05_STATE_MANAGEMENT.md`'s note on "explicit, not continuous" refresh) rather than a bug, but it means the app is **not** "real-time" in the sense of an open Firestore snapshot listener — verify this framing doesn't overclaim by checking whether any screen *does* use a live Firestore stream directly (not observed in the files read for this pass; if found elsewhere, it would be an exception to this general pattern).

## Retry / backoff

Confirmed present (deduplication + prioritization logic exists in `SyncEngine`) but the exact backoff schedule/retry-limit numbers were not independently re-verified for this specific document — see `docs/modules/sync.md` for the authoritative per-file detail, including exact class/method names, written from a direct, complete read of every file in `lib/features/sync/`.

## Offline UI signaling

`HomeScreen`'s `_SyncBanner` widget (verified present in `home.md`'s module documentation) shows the current `SyncQueueSummary` (pending/stalled/retrying counts) with an explicit manual "Sync now" button — so a user is never left guessing whether their offline actions have actually reached the server; the pending count is visible and a manual trigger exists alongside the two automatic ones.

## Is "offline-first" a fair characterization?

Yes, for the entity-data screens (the majority of the app's functionality) — verified, not assumed: local Drift is the primary read path for every entity-data screen, writes succeed locally before any network involvement, and a purpose-built sync engine (not an afterthought — it has its own conflict-resolution algorithm, its own dedicated test suite, and its own admin-configurable polling interval) reconciles local and remote state. It is **not** offline-first for authentication or the three `config/*` documents, which is an honest, worth-stating exception rather than undermining the overall characterization.

## OFFLINE FLOW

```
User action (e.g. register habitation) — no connectivity
        ↓
HabitationRegistrationService writes to LocalHabitationRepository (Drift)
        ↓
SyncQueueDao.enqueue(...) — a pending row, version incremented
        ↓
AuditLogDao.record(...) — local audit trail entry
        ↓
UI shows success immediately — the user never waited on the network
        ↓
[time passes, still offline — the entry sits in SyncQueueEntries]
        ↓
Connectivity returns → syncOnReconnectTriggerProvider fires
        ↓
SyncCoordinatorService.syncPendingEntries() pushes the queued entry to
Firestore (FirestoreSyncTransport, version-checked transaction)
        ↓
Providers invalidated — the habitation now also appears wherever the
app reads habitations across all devices, once each has itself synced
```

## ONLINE FLOW

```
User action (e.g. register habitation) — connectivity present
        ↓
Same local-first write path as OFFLINE FLOW above (there is no
"different" online code path for the write itself — the app always
writes locally first)
        ↓
Within ~45s (or immediately on the next reconnect-style trigger, since
connectivity never dropped) syncPollingTriggerProvider's periodic tick
picks up the queued entry and pushes it — the user does not wait for
this synchronously; it's a background pass
```
