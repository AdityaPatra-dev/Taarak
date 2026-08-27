# Architecture

## Application entry point and startup flow

Traced directly from `lib/main.dart`, `lib/app/app.dart`, and `lib/app/router.dart`.

```
Application Start
        ↓
main() [lib/main.dart]
        ↓
WidgetsFlutterBinding.ensureInitialized()
        ↓
Firebase.initializeApp() — guarded by Firebase.apps.isEmpty (web double-init
guard) and wrapped in _initializeFirebaseWithRetry(), a 5-attempt retry with
backoff working around a known FlutterFire web race condition
(firebase/flutterfire#9995) where minified release builds can lose a race
against JS-side plugin registration
        ↓
runApp(ProviderScope(child: TaarakApp()))    ← Riverpod's root provider
                                                 container is created here
        ↓
TaarakApp.build() [lib/app/app.dart]
        ↓
Root-lifetime providers are watched ONCE here (kept alive for the whole
app session regardless of which screen is on top):
  • syncOnReconnectTriggerProvider  — fires a sync pass when connectivity
    transitions offline→online
  • syncPollingTriggerProvider      — Timer.periodic sync pass; the
    interval is read from technicalConfigProvider (admin-configurable,
    falls back to TechnicalConfig.defaults.syncIntervalSeconds = 45)
  • notificationWatcherProvider     — diffs alert/incident lists and
    fires a local notification for genuinely new entries
  • rolePermissionOverridesProvider — kept warm so the router's redirect
    closure (which can only ref.read, not ref.watch) sees a resolved
    value rather than a perpetually-reloading autoDispose provider
        ↓
authControllerProvider.select(isLoading) checked — while the initial
session-restore read is in flight, a minimal _SplashScreen is shown
INSTEAD of the real router, so no route-guard logic ever has to reason
about an in-flight auth state
        ↓
Once session restore resolves: appRouterProvider is read, producing a
GoRouter configured with:
  • refreshListenable: a ChangeNotifier bridged to authControllerProvider
    changes (login/logout triggers a redirect re-evaluation)
  • redirect: computeRedirect() [lib/app/route_guard.dart] — pure,
    side-effect-free function: unauthenticated → /login; authenticated
    visiting an auth screen → /; authenticated but missing the route's
    required Permission (checked against role defaults merged with any
    admin-configured RolePermissionOverrides) → /unauthorized
        ↓
MaterialApp.router renders the resolved initial route — for a fresh,
never-logged-in session this is HomeScreen after passing through /login
```

**Theme initialization**: `AppTheme.light` / `AppTheme.dark` (from `lib/app/theme.dart`) are set directly on `MaterialApp`/`MaterialApp.router`; no dynamic/remote theme loading.

**Database initialization**: Drift's `AppDatabase` is constructed lazily, the first time any repository provider that depends on it is first read — there is no explicit "open database" step in the startup sequence above. Verify the exact provider in `docs/modules/core_database.md`.

## Overall architecture

TAARAK follows a **feature-first, layered architecture**: `lib/features/<feature_name>/` is the primary organizational unit (29 of them), and within each, a consistent set of sub-layers recurs:

```
lib/features/<feature>/
  domain/          — pure Dart: entities, value objects, enums, no Flutter/Firebase/IO imports
  application/      — Riverpod providers + services/engines: orchestration and business logic
  data/             — repositories/data sources that actually talk to Drift or Firestore
  presentation/     — Flutter widgets: screens and screen-local widgets
```

Not every feature has all four sub-folders — a pure-computation feature (a scoring engine with no UI or storage of its own) may have only `domain/` + `application/`; a feature with no independent screen may have no `presentation/`. This is a real, load-bearing pattern, not a coincidence: it separates *what a thing is* (domain) from *how it's computed/orchestrated* (application) from *where it's stored* (data) from *how it's shown* (presentation), and every module-level document in `docs/modules/` records which of these sub-layers a given feature actually has.

## Why this layering exists (evidence from the code itself)

The pattern is not just conventional Flutter boilerplate — it is used deliberately in this codebase to enforce a specific, explicitly-stated architectural rule found in doc comments across the scoring-engine modules (`risk/`, `capacity/`, `relocation/`, `vulnerability/`): **engines must be pure and deterministic** (no I/O inside the `application/` engine class itself), taking already-fetched data as parameters and returning a `*Result` domain object with an explicit factor breakdown and a versioned `modelVersion` constant. The `data/`-layer repository or a coordinating `*Service` class is what performs the actual Drift/Firestore I/O, then hands plain data into the pure engine. This lets every scoring engine be unit-tested with hand-constructed inputs and no database at all — verified directly in this session's own engine test files (e.g. `test/features/relocation/relocation_priority_engine_test.dart` constructs `RiskAssessmentResult`/`CapacityGapResult`/`RelocationPlan` objects by hand, with no database setup).

## Cross-cutting core layer (`lib/core/`)

Not feature-specific — shared infrastructure every feature depends on:

- `lib/core/database/` — the entire Drift schema (tables + generated code) and every `LocalXRepository` built on it. See `docs/modules/core_database.md`.
- `lib/core/repository/` — the `Result<T>`/`LocalRepository<T, Id>` abstractions every repository implements.
- `lib/core/error/` — `Failure` (returned inside `Result.failure`) and `AppException` (thrown internally, caught and mapped to a `Failure` at the data-source boundary) — two distinct types for two distinct layers, not redundant.
- `lib/core/network/`, `lib/core/gis/`, `lib/core/location/`, `lib/core/media/`, `lib/core/logging/`, `lib/core/routing/`, `lib/core/storage/`, `lib/core/config/`, `lib/core/providers/` — see `docs/modules/core_infrastructure.md` for the full per-file breakdown.

## App shell (`lib/app/`)

Not a feature — the composition root: `main.dart`'s `TaarakApp`, `router.dart`'s route table, `route_guard.dart`'s permission-gating logic, `theme.dart`, `spacing.dart`. See `docs/modules/app_shell.md`.

## Shared presentation (`lib/shared/`)

Reusable widgets with no feature-specific business logic (loading/error/empty states, app bar, section headers, status pills, responsive layout helpers). See `docs/modules/shared_widgets.md`.

## Is the architecture consistent?

Largely yes, with two honest exceptions found during this pass:

1. **Two competing backend/auth pathways coexist in source.** `ApiAuthRemoteDataSource`/`ApiSyncTransport` (talking to the `backend/` Dart stub) and `FirebaseAuthRemoteDataSource`/`FirestoreSyncTransport` (talking to the real, live Firebase project) both implement the same interfaces and both exist as complete, compiling code — but `AppConfig`'s only constructor (`AppConfig.development()`) hardcodes `useFirebaseAuth: true`, so the API-based path is never actually selected at runtime. This is not a bug — it's an intentional migration artifact, per the pubspec.yaml comment quoted in `02_TECH_STACK.md` — but it means roughly two full parallel implementations of "talk to a backend" exist in the tree simultaneously, one live, one dormant.
2. **State-management providers are not distributed 100% uniformly.** Most screens are `ConsumerWidget`/`ConsumerStatefulWidget` reading feature-scoped providers; a few cross-cutting concerns (permission-override resolution, sync triggers) are watched once at the `TaarakApp` root rather than per-screen — a deliberate choice (documented inline in `app.dart`'s own comments) for anything that must stay alive independent of navigation, not an inconsistency in practice, but worth knowing before assuming "every provider is scoped to the screen that uses it."

No other structural inconsistency was found in the portions of the codebase directly inspected for this document; the per-module documents in `docs/modules/` may surface narrower, module-local exceptions.
