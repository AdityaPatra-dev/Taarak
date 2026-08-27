# Testing

Ground-truth test-directory inventory generated directly from the filesystem this pass (`find test/features -maxdepth 1 -type d`, cross-referenced against every `lib/features/*` directory) — not inferred from module-doc prose alone, specifically to avoid misattributing a finding from one module's document to the wrong feature.

## Test framework

`flutter_test` (bundled with Flutter) for unit and widget tests. No separate integration-test package (`integration_test`) is used; `test/integration/` contains cross-service tests that exercise real collaborating classes together (including, per its own file name, a `backend_stub_integration_test.dart` that runs against the local `backend/` stub — the one context where that dormant backend is still actually exercised, by tests, not by the app itself).

Dev-only test-support packages (`sqlite3`, `fake_cloud_firestore`, `firebase_auth_mocks`, `mock_exceptions`) let Drift-backed tests run against a genuine in-memory SQLite database (not a fake — real Drift queries execute) and Firebase-backed tests run against in-memory fakes rather than a live project.

## Current totals

**440 tests, all passing** — re-verified by directly running `flutter test` during this documentation pass (see `14_BUILD_RUN_GUIDE.md`). 73 test files across `test/core/`, `test/features/`, `test/integration/`, `test/support/`.

## Per-feature test coverage (ground truth, not estimated)

| Feature | Test files | Feature | Test files |
|---|---|---|---|
| admin | 2 | map | 4 |
| alerts | 2 | notifications | **0** |
| audit | 2 | profile | 1 |
| auth | 5 | relocation | 4 |
| capacity | 2 | reporting | 2 |
| command | **0** | risk | 2 |
| dashboard | 1 | routing | 2 |
| device_relay | 2 | shelters | 2 |
| disaster_events | 2 | sms_prototype | 3 |
| environmental | 6 | state_admin | **0** |
| field_response | **0** | susceptibility | **0** |
| fusion | 1 | sync | 4 |
| habitations | 1 | verification | 3 |
| hazards | 3 | vulnerability | 4 |
| home | **0** | | |

## Features with ZERO test coverage — confirmed by directory absence, not by reading test output

**`command`, `field_response`, `home`, `notifications`, `state_admin`, `susceptibility`** — no `test/features/<name>/` directory exists at all for any of these six.

For `susceptibility` this is a minor gap in practice: its only implementation (`UnavailableHazardSusceptibilityModel`) is a one-line, always-`null` stub with essentially nothing to test. For the other five, this is a genuine, non-trivial coverage gap:
- **`command`** — District/Command's manage-responders/resources/relocation screens and `ResourceManagementService` have no test coverage at all.
- **`field_response`** — `DamageReportService` and the Field Responder incident-status transition logic are untested; this is also the module where the earlier "Navigate to incident" permission bug was found and fixed this session, and the module still has no regression test of its own for that flow (the regression tests that do exist for it live in `test/features/auth/route_guard_test.dart` and `test/features/auth/role_permissions_test.dart`, testing the permission grant and route redirect, not this module's own screen behavior).
- **`home`** — the ~20-branch quick-action visibility logic on `HomeScreen` (one `if (can(Permission.x))` block per permission) has no widget test verifying any role sees the correct subset.
- **`notifications`** — the local-notification diffing/dedup logic (`notificationWatcherProvider`) is untested.
- **`state_admin`** — `StateReportAggregator` (the aggregation logic behind the State Reports screen) and the policy-configuration write path are untested.

## Core infrastructure test coverage (also ground-truth checked)

| Core module | Test files |
|---|---|
| `core/database` | **1** (against 39 source files — the entire Drift schema + every repository) |
| `core/gis` | 3 |
| `core/location` | 2 |
| `core/media` | 1 |
| `core/routing` | 1 |
| `core/config`, `core/error`, `core/logging`, `core/network`, `core/providers`, `core/repository`, `core/storage` | **0 each** |

`core/database` having only 1 test file against the largest, most structurally important directory in the app (18 tables, every repository the rest of the app depends on) is the single most notable test-coverage gap found in this entire audit — most of that layer's real exercise comes indirectly, through the many feature-level tests that construct an in-memory `AppDatabase` and then call a feature service against it (verified as the dominant test pattern across `test/features/*` — e.g. `test/features/relocation/relocation_priority_service_test.dart` exercises `LocalHabitationRepository`/`LocalHazardZoneRepository` this way), not through dedicated repository-level unit tests.

## What is tested, structurally

The dominant, consistently-applied pattern (verified across dozens of files touched or read this session): pure engine/domain classes get direct unit tests with hand-constructed input objects and no I/O at all (e.g. `relocation_priority_engine_test.dart`); services with real I/O get tests against an in-memory Drift database (`NativeDatabase.memory()`) via `test/support/sqlite3_test_setup.dart`'s shared setup helper; Firebase-touching code gets tests against `fake_cloud_firestore`/`firebase_auth_mocks` rather than a live project. `computeRedirect()` (the route guard) is unit-tested directly as a pure function with 20+ cases, requiring no widget pump at all.

## What is not tested

Beyond the six zero-coverage features above: no widget/golden-image tests were observed for visual regression of any screen; no end-to-end test drives the actual compiled app (the `integration/` tests exercise service-layer collaboration, not a real running UI); UI-level permission-gating (whether a button that *shouldn't* be visible for a role is actually absent from the rendered widget tree) is untested beyond the pure-function route-guard tests.

## Known missing tests, prioritized

See `16_IMPLEMENTATION_GAPS.md` for the full prioritized gap list; the testing-specific entries are the six zero-coverage features above, plus dedicated `core/database` repository-level tests.
