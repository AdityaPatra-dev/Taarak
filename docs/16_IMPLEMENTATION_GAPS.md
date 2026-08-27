# Implementation Gaps

Prioritized per the source task's own scheme: **P0** (required for the core application to function), **P1** (important for a usable/demo-ready application), **P2** (useful enhancement, not required). Every item below is drawn from a directly-verified finding in this documentation pass — nothing here is speculative.

## P0 — Critical

None found that block the *core* application from functioning. The app runs, builds, and its primary user flows (report, sync, score, prioritize) work end-to-end today. The items below are real but do not prevent the app from being usable.

## P1 — Important for a usable/demo-ready application

1. **Risk/capacity/vulnerability assessment has exactly one production trigger** (opening the Relocation Priority screen) — see `12_DEMO_MOCK_AUDIT.md`'s "wired but unconfirmed as triggered" section. A District/Command dashboard could display stale or absent risk-derived figures for any habitation whose assessment was never computed because no one has yet opened `/relocation/priority` this session. **Fix**: either trigger `assessAllHabitations()` from an additional entry point (e.g. right after habitation registration, or on the dashboard's own load), or make this dependency explicit in the dashboard's own UI ("assessment last computed: —").
2. **`DemoMapDataSeeder` has no call site** — real, tested code that cannot currently run. If this was meant to seed a fresh dev/demo environment, it silently does nothing today. **Fix**: either wire a call site (e.g. gated behind `AppConfig.isDevMode` as its own doc comment already claims should exist) or remove it if it's no longer wanted, now that real ingestion pathways exist for every entity type it used to seed.
3. **Six features have zero automated test coverage**: `command`, `field_response`, `home`, `notifications`, `state_admin` (all non-trivial, real gaps) and `susceptibility` (trivial — a one-line stub). See `13_TESTING.md` for specifics per module.
4. **`core/database` (the entire 18-table Drift schema, 39 source files) has exactly 1 dedicated test file.** Most of its real exercise is indirect, through feature-level tests that happen to construct an in-memory database. A schema-level regression (e.g. a migration mistake, since migrations are destructive per `09_DATABASE_STORAGE.md`) has thin direct test coverage.
5. **Sync failures are entirely invisible** — `_syncAndRefresh`'s catch-all swallows every exception with no logging and no surfaced state. A persistent, non-connectivity sync failure (e.g. a Firestore rules/permission problem) produces no diagnostic signal anywhere in the running app.
6. **Android release builds are signed with the debug keystore**, and **`applicationId`/`namespace` is still `com.example.taarak`** — both block real Play Store submission (see `15_SECURITY_AUDIT.md`, `14_BUILD_RUN_GUIDE.md`).
7. **The Google Maps API key has no application-identity restriction** (see `15_SECURITY_AUDIT.md`) — functional today, but a real risk before any public release.
8. **`route_guard.dart` doesn't check `isDevMode` for `/sms-prototype`/`/device-relay`** — in a release web build, a Citizen (who holds `sendSos`) could reach these dev-only prototype screens by typing the URL directly, even though no UI links to them. Low actual impact (both are confirmed simulations with no real device I/O), but a real gap between intended and actual gating.

## P2 — Enhancement, not required

1. **Two parallel backend implementations coexist in source** (`backend/` stub + `Api*` classes vs. the real Firebase path) — not harmful, but a maintenance/clarity cost; a future cleanup pass could remove the dormant path once it's confirmed nothing will ever need to fall back to it.
2. **`RemoteRepository` interface is defined but has no implementation anywhere.**
3. **Demo account credentials are duplicated** between `DevMockAuthRemoteDataSource._seedAccounts` and `LoginScreen._demoAccounts` with no shared constant — low risk (mock path is dormant), but a future edit to one without the other would desync the demo picker.
4. **`DamageReportService` writes no audit-log entry**, unlike every sibling write-service in the app (hazard ingestion, habitation registration, etc. all record an audit event) — an inconsistency worth fixing for a complete audit trail.
5. **Audit records never sync to Firestore** — confirmed by direct grep: `local_audit_events` is purely local per-device. Each device's audit log only reflects actions performed on that device; there is no centralized, cross-device audit trail today, which is a meaningful limitation for a System Admin trying to review "everything that happened," not just "everything that happened on this device."
6. **`HomeScreen`'s quick-action list is a manually maintained ~20-branch list** that must be kept in sync by hand with `route_guard.dart`'s route table — no single source of truth generates both.
7. **No in-app notification history/inbox** — once shown, a local notification leaves no record inside the app.
8. **OSRM routing depends on OSRM's public demo server**, not a production-owned instance — fine for development, not something to depend on for real load or uptime.
9. **Infrastructure/access vulnerability indicators still default to a neutral `0.5`** for any habitation an official didn't explicitly set them for at registration (a real data-entry path exists — see the correction in `docs/modules/vulnerability.md` — this is about historical/incomplete data, not a missing feature).
10. **No centralized permission-check helper reused across `route_guard.dart` and `HomeScreen`** beyond both independently consulting the same `rolePermissionOverridesProvider` — functionally correct today (verified), but a future refactor consolidating "compute this user's effective permissions" into one shared function would reduce the risk of the two call sites drifting apart.
11. **A localWins sync conflict isn't retried within the same sync run** — it waits for the next trigger (up to the polling interval, default 45s) rather than being immediately re-attempted.
12. **CI/CD**: no automated pipeline exists; every build/test/deploy verified this session was a manually-run developer command.

## Explicitly NOT a gap (verified, to prevent mischaracterization)

- The app is genuinely offline-first for its core entity data (see `11_OFFLINE_FIRST.md`) — this is not merely claimed, it was independently verified this pass.
- There is no fake AI anywhere — the one AI-shaped extension point (`susceptibility`) is honestly non-functional, not dressed up to look real.
- Firestore security rules were found to be consistently role-scoped with no missing-authorization gaps across all 11 audited collections (`15_SECURITY_AUDIT.md`).
