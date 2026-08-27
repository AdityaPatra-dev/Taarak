# Dependency Graph

Only relationships directly verified in code (this session's own construction of several of these providers, plus the module-level research passes) are shown — this is not a generic template graph.

## High-level dependency graph

```
Presentation (screens, ConsumerWidget/ConsumerStatefulWidget)
        ↓ ref.watch / ref.read
Application (Riverpod Provider graph: services, engines, controllers)
        ↓ constructor injection via ref.watch(...)
Data (repositories wrapping Drift; data sources wrapping Firestore/HTTP/SDKs)
        ↓
Local Drift database  ⇄  Cloud Firestore  ⇄  External APIs (Google Maps,
                                               Open-Meteo, OSRM)
```

Domain-layer classes (pure value objects/enums/result types) sit outside this vertical flow — they're the data *shape* passed between every layer above, not a layer that itself depends on anything.

## Module dependency graph (the scoring pipeline — the app's core value chain)

This is the single most important cross-module dependency chain in the app, verified directly this session (`RelocationPriorityService` was read in full):

```
habitations (registration) ──┐
                              │
hazards (zone ingestion) ────┼──→ risk (RiskEngine: 0.6×hazardExposure
                              │           + 0.4×vulnerabilityIndex)
vulnerability ────────────────┘         │
                                         ↓
shelters (capacity) ──────────→ capacity (CapacityGapEngine)
                                         │
                                         ↓
routing (distance-to-shelter) ─→ relocation (RelocationEngine →
                                   RelocationPriorityEngine: 0.4×risk +
                                   0.3×capacityGap + 0.2×distance +
                                   0.1×accessibility)
                                         │
                                         ↓
                              relocation/presentation
                              (RelocationPriorityScreen)
```

`environmental` (real Open-Meteo data) additively adjusts `risk`'s score via a documented merge function (`risk_environmental_merge.dart`) rather than replacing the deterministic hazard/vulnerability computation — see `docs/modules/risk.md` and `docs/modules/environmental.md` for the exact mechanism. `susceptibility` is a defined extension point in this same chain (intended to feed a future ML-derived signal into `risk`) but is currently a stub that always returns `null` — see `docs/modules/susceptibility.md`.

`disaster_events` sits *upstream* of `hazards`: `DisasterEventProcessor` routes a hazard-shaped `DisasterEvent` (sourced from `GovernmentAlertParser` or the `SimulateAlertScreen` UI) into the same `HazardIngestionService.ingest()` call an official's manual report screen already uses — no separate hazard-creation code path exists.

## Module dependency graph (sync)

```
Every feature's data/ layer repository (LocalXRepository)
        ↓ enqueues on write
SyncQueueDao (local Drift outbox table)
        ↓ drained by
SyncCoordinatorService.syncPendingEntries()
        ↓ push
SyncEngine (dedup + prioritize + version-based conflict resolution)
        ↓
FirestoreSyncTransport ⇄ Cloud Firestore
        ↓ pull (after push)
Back into each LocalXRepository — 8 entity tables refreshed, 10
cross-feature providers invalidated
```

Triggered by exactly two root-watched providers (`syncOnReconnectTriggerProvider`, `syncPollingTriggerProvider`) — see `11_OFFLINE_FIRST.md`.

## Module dependency graph (auth + RBAC)

```
LoginScreen / RegisterScreen / ForgotPasswordScreen
        ↓
AuthController (AsyncNotifier) → AuthRepositoryImpl
        ↓
FirebaseAuthRemoteDataSource ⇄ Firebase Auth + Firestore users/{uid}
        ↓
authControllerProvider (AuthSession?) ─────┬─────────────────────┐
        ↓                                  ↓                     ↓
route_guard.dart's computeRedirect()   HomeScreen's quick-action  Every
(reads rolePermissionOverridesProvider  visibility (same          route's
 via ref.read)                          override provider,        Permission
                                         ref.watch)                requirement
        ↑
admin's ManagePermissionsScreen writes RolePermissionOverrides
→ config/role_permissions (Firestore) → rolePermissionOverridesProvider
  (kept warm at TaarakApp root)
```

## Important file-level dependency relationships (spot-verified this session)

- `lib/app/router.dart` depends on every feature's top-level `presentation/` screen (29 imports) and on `lib/app/route_guard.dart` + `lib/features/admin/application/admin_providers.dart` (for `rolePermissionOverridesProvider`).
- `lib/app/route_guard.dart` depends on `lib/features/auth/domain/{auth_session,permission,user_role}.dart` and `lib/features/admin/domain/role_permission_overrides.dart` — a cross-feature import from `app/` into `features/admin/`, confirmed intentional (not circular — `admin/` does not import anything from `app/`).
- `lib/app/app.dart` depends on `lib/features/sync/application/sync_providers.dart`, `lib/features/notifications/application/notification_providers.dart`, `lib/features/admin/application/admin_providers.dart`, and `lib/features/auth/application/auth_controller.dart` — the only four feature-level imports the app shell needs to keep root-lifetime triggers alive.
- `lib/features/relocation/application/relocation_priority_service.dart` depends on `LocalHabitationRepository`, `LocalHazardZoneRepository` (both `core/database/repositories/`), plus `RiskAssessmentService`, `CapacityAssessmentService`, `RelocationPlanningService` (three sibling-feature services) — the most cross-feature-dependent single file found this pass.

## Circular dependencies

None found. The layering described in `01_ARCHITECTURE.md` (domain → application → data/presentation, features depending on `core/` but not vice versa, `app/` depending on `features/` but not vice versa) held consistently across every file inspected across all five parallel research passes plus this session's own direct edits. If a circular dependency exists somewhere in the ~110 files not individually re-verified for this specific document, it was not surfaced by any of the module-level passes either.

## Tightly coupled components

The scoring pipeline above (`habitations`/`hazards`/`vulnerability` → `risk` → `capacity` → `relocation`) is deliberately, tightly coupled by data dependency (each stage's `Result` is a required input to the next) — this is intentional domain coupling, not an architecture smell, and is exactly why `RelocationPriorityService` exists as an explicit orchestrator rather than each screen independently calling three services in the right order.

## Suspicious or unused dependencies

- `ApiAuthRemoteDataSource` / `ApiSyncTransport` — implemented, compiling, never selected at runtime (see `08_API_DOCUMENTATION.md`).
- `RemoteRepository` interface (`lib/core/repository/remote_repository.dart`) — confirmed by the infrastructure research pass to be fully defined but unused by any concrete class.
- `backend/` — a complete, separate Dart package no longer reachable from the running app.

See `16_IMPLEMENTATION_GAPS.md` for the full, prioritized list.
