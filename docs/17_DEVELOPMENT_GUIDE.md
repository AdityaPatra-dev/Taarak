# Development Guide — How to Safely Continue This Project

Written for whoever picks this codebase up next, human or AI, with zero prior context beyond this documentation package.

## General rules that hold across the whole codebase (verified, not aspirational)

1. **Follow the existing layering.** Every feature separates `domain/` (pure value objects/enums), `application/` (Riverpod providers + services/engines), `data/` (repositories/data sources), `presentation/` (screens). New code should slot into the matching layer, not bypass it — e.g. a new screen should never call Firestore directly; it should go through a `Provider` that composes a repository.
2. **Scoring engines stay pure.** If you touch `risk/`, `capacity/`, `vulnerability/`, `relocation/`, or `fusion/`, keep the engine class itself free of I/O — it should take already-fetched data as parameters and return a `*Result` object with an explicit factor breakdown and a `modelVersion` constant. Put any Drift/Firestore access in the orchestrating `*Service` class instead. This is the single most consistently-enforced pattern in the entire codebase — breaking it would be the most visible architectural regression you could introduce.
3. **Never fabricate a score, prediction, or "AI" output.** This is an explicit, repeatedly-enforced rule already in the code (see `susceptibility/`'s deliberate `null`-returning stub, and `relocation/`'s "never invent a priority for data it doesn't actually have" comment). If you're adding real ML/AI, wire a real model and be honest about partial results — do not hardcode a plausible-looking number.
4. **Reuse `Result<T>`/`Failure`, don't introduce a new error-handling convention.** Every repository/service/data source in the app returns `Result<T>` rather than throwing across a layer boundary; `AppException` is the internal, layer-local exception type that gets caught and mapped to a `Failure` at the data-source boundary. A new feature that throws raw exceptions across its own service boundary would be inconsistent with everything else.
5. **Reuse the existing `LocalRepository<T, Id>` shape** for any new Drift-backed entity, and add its sync handling to `SyncCoordinatorService`/`SyncQueueDao` rather than inventing a parallel sync mechanism.
6. **Route additions**: add the `GoRoute` in `lib/app/router.dart`, add the exact-match entry (or a new prefix rule) in `lib/app/route_guard.dart`'s `defaultRoutePermissions`, and add the mirroring Firestore rule in `firestore.rules` if the route's data is Firestore-synced — these three files must move together (verified this session: this is exactly the three-file change pattern used to add every route this session).
7. **New Firestore collections need a matching `firestore.rules` block.** The file's own header comment states it's meant to mirror `route_guard.dart`'s permission table exactly — keep that true.

## Where to start, by what you're trying to do

**Fix the "assessment only triggers from one screen" gap (P1 #1)**: start in `lib/features/relocation/application/relocation_priority_service.dart` to see the exact orchestration shape, then either add a second call site (e.g. from `HabitationRegistrationService.register()` itself, or a dashboard-load hook) or surface a "last computed" state so the gap is visible rather than silent. Do not change the engines themselves — they're correct; only the triggering is thin.

**Wire the demo seeder back up, or remove it** (P1 #2): `lib/features/map/application/demo_map_data_seeder.dart` is real and tested — decide whether it's still wanted now that real ingestion pathways exist for everything it used to seed, then either add the `AppConfig.isDevMode`-gated call site its own doc comment already describes, or delete it along with its test.

**Add test coverage for the six zero-coverage features**: `command`, `field_response`, `home`, `notifications`, `state_admin` are the real gaps (see `13_TESTING.md`). For each, follow the existing pattern in a sibling module of the same shape — e.g. `field_response`'s `DamageReportService` should be tested the same way `habitations`' `HabitationRegistrationService` is (in-memory Drift database, real repository, assert on the persisted row) — that exact test already exists as a template at `test/features/habitations/habitation_registration_service_test.dart`.

**Add `core/database` repository-level tests**: follow the existing pattern at `test/features/hazards/hazard_ingestion_service_test.dart` or similar — `NativeDatabase.memory()` via `test/support/sqlite3_test_setup.dart`'s shared helper, real Drift queries, no mocking of the database layer itself.

**Make sync failures visible** (P1 #5): the swallow point is `_syncAndRefresh`'s catch block in `lib/features/sync/application/sync_providers.dart` — add a logged failure (via `lib/core/logging/app_logger.dart`) and/or a surfaced state (e.g. extend `SyncQueueSummary` with a "last error" field) rather than silently returning.

**Fix Play Store blockers** (P1 #6/#7): change `android/app/build.gradle.kts`'s `applicationId`/`namespace` off `com.example.taarak`, generate a real release keystore and wire it into `signingConfigs.release`, and split the Google Maps key into two properly-restricted keys (Android package+SHA-1, web HTTP-referrer) — all three changes are coupled (a new `applicationId` needs a matching Firebase Android app registration and a matching Maps key restriction), do them together, not incrementally.

**Add real AI/ML susceptibility prediction**: the extension point already exists and is correctly designed — implement `HazardSusceptibilityModel` for real (a trained model, ported to pure Dart inference per the module's own doc comments — no new runtime dependency needed if the model stays simple enough), replace `hazardSusceptibilityModelProvider`'s implementation, and *then* find a real caller for it (currently nothing in the app consumes this provider — that's a second, separate piece of work). Do not skip finding a real caller; a technically-correct model with no consumer doesn't change user-visible behavior.

**Add real SMS/device-relay capability**: both modules' transport-layer abstractions (`SmsTransport`, `RelayTransport`) already exist specifically to make this swap possible — implement a real platform-channel-backed transport, request the real permissions, and swap the provider. The packet protocol/codec/engine layers above the transport are already real and tested; only the transport itself is a simulation.

## What NOT to touch without a deliberate decision

- **Don't restrict the Google Maps API key or change the Android debug-signed release build** without first reading the `// TODO` comments in `android/app/build.gradle.kts` and `15_SECURITY_AUDIT.md`'s full reasoning — both are intentional, coupled, in-progress states, not oversights, and changing one without the others will break builds for other contributors.
- **Don't delete `backend/`, `ApiAuthRemoteDataSource`, or `ApiSyncTransport`** without confirming with whoever owns the project that the Firebase migration is permanent — they're kept "for reference" per the pubspec.yaml's own comment, which reads as a deliberate choice, not neglect.
- **Don't add a role hierarchy/inheritance to the permission system** — the "no implicit hierarchy" design is stated explicitly in `user_role.dart`'s own comment as intentional, not an oversight to "fix."
- **Don't bypass `RolePermissionOverrides` when adding a new permission-gated screen** — both `route_guard.dart` and `HomeScreen` must consult the effective (override-merged) permission set, not the raw role default, or a System Admin's runtime permission edits would silently stop applying to the new screen.

## Existing abstractions worth knowing about before building something similar

- **`Result<T>` / `Failure`** (`lib/core/repository/result.dart`, `lib/core/error/failure.dart`) — every operation's return type.
- **`LocalRepository<T, Id>`** (`lib/core/repository/local_repository.dart`) — the interface every Drift repository implements.
- **`SyncQueueDao`/`SyncCoordinatorService`** — the one sync mechanism; don't build a second one.
- **`AuditLogDao`** — the one audit-trail mechanism; new write-services should call it (note the one sibling inconsistency already found: `DamageReportService` currently doesn't — see `16_IMPLEMENTATION_GAPS.md`).
- **`AppPolicyDataSource`/`RolePermissionOverridesDataSource`/`TechnicalConfigDataSource`** — the established pattern for a small, always-online, admin-configurable Firestore document with a `.defaults` fallback; a new admin-configurable setting should follow this exact shape rather than inventing a new one.
