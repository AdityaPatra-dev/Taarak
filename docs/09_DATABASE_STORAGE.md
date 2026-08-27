# Database / Storage

Two real storage systems exist. No PostgreSQL, MongoDB, Hive, or Supabase is used anywhere in this codebase — verified by their absence from `pubspec.yaml` and confirmed by direct inspection of `lib/core/database/` and every feature's `data/` layer.

## 1. Drift (typed SQLite) — the offline-first local database

Full schema detail lives in `docs/modules/core_database.md` (written this pass from a direct read of every file in `lib/core/database/`, 39 files). Summary, verified via that pass:

- **18 tables total**: 17 entity tables + 1 sync-outbox table (`SyncQueueEntries`).
- **Schema version 11** (`AppDatabase.schemaVersion`).
- **Migration strategy is destructive**: on any schema version bump, all tables are dropped and recreated — there is no per-version, data-preserving migration path. This is an explicit, self-documented pre-release shortcut in `app_database.dart` itself, not an oversight, but it means **upgrading the app on a device with existing local data wipes that device's local cache** (the remote Firestore data is unaffected and re-syncs on next pull).
- Every table has a corresponding `LocalXRepository` implementing a shared `LocalRepository<T, Id>` interface (`lib/core/repository/local_repository.dart`), returning `Result<T>` rather than throwing.
- Initialization is lazy — the database is constructed the first time any provider that depends on it is first read, not at an explicit app-startup step (see `01_ARCHITECTURE.md`).

## 2. Cloud Firestore — the shared backend

Real, live Firestore project `taakrak-d9ed0`. Collections and their exact security rules are fully enumerated in `15_SECURITY_AUDIT.md`. Every Firestore collection that mirrors a local Drift table is written to via the sync engine (below), not read/written directly by feature screens — the one documented exception class is small "always-online" configuration documents (`config/policy`, `config/role_permissions`, `config/technical`) and account data (`users/{uid}`), which are read/written directly against Firestore by their own dedicated data sources rather than routed through the offline sync queue, since they're small, need-to-be-current, low-write-frequency documents rather than offline-cacheable entity data.

## 3. flutter_secure_storage — auth session only

Wrapped by `lib/core/storage/secure_key_value_store.dart` and consumed by `AuthLocalDataSource`. The only thing stored here is the persisted `AuthSession` (id/name/email/role/token). See `10_AUTHENTICATION.md`.

## Offline vs. online behavior, per operation type

| Operation | Offline | Online |
|---|---|---|
| Read any entity screen (map, dashboard, shelters, etc.) | Reads local Drift cache — works fully | Same read path; a background sync pass (see `11_OFFLINE_FIRST.md`) may have refreshed the cache moments earlier |
| Create/update an entity (report a hazard zone, register a habitation, submit a report) | Writes to local Drift immediately, enqueues a `SyncQueueEntries` row — succeeds from the user's perspective instantly | Same local write; the sync engine picks up the queued entry on its next trigger (reconnect or periodic poll) and pushes it |
| Config reads (`config/policy` etc.) | Falls back to hardcoded `.defaults` if the last-fetched value isn't cached — verify exact fallback behavior per config type in `docs/modules/admin.md`/`docs/modules/state_admin.md` | Fetched fresh via a `FutureProvider.autoDispose` each time the consuming screen is opened |
| Account operations (login/register/forgot-password) | **Do not work offline** — these are direct Firebase Auth SDK calls with no local fallback | Real Firebase Auth calls |

## Relationships between tables

Documented per-table in `docs/modules/core_database.md`, including foreign-key-shaped references (e.g. a damage report referencing an incident id, a risk assessment referencing a habitation id) — Drift/SQLite here is used without declared foreign-key constraints enforced at the schema level (verify this specific claim against `docs/modules/core_database.md`'s table-by-table listing); relationships are maintained by application-level id references, not database-enforced referential integrity.

## Persistence guarantee

Everything written to Drift survives an app restart (it's real SQLite on disk/IndexedDB-via-sqlite3.wasm on web). Nothing in Riverpod's in-memory provider state survives a restart on its own — see `05_STATE_MANAGEMENT.md`.
