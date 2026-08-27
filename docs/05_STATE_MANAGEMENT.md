# State Management

**Riverpod** (`flutter_riverpod: ^2.6.1`) is the only state-management system in the app — verified by the absence of any Bloc/Provider-package/GetX import anywhere touched this session, and confirmed present in every feature's `application/<feature>_providers.dart` file. This document explains the concrete patterns used, with real provider names as evidence, not generic Riverpod terminology.

## The four provider shapes actually used

**1. Plain `Provider<T>` — dependency wiring, not reactive state.** The overwhelming majority of providers in the codebase are this shape: a repository, service, or engine that is itself constructed by composing other providers via `ref.watch(...)` inside its own definition. Example, verified directly in `lib/features/relocation/application/relocation_priority_providers.dart`:
```dart
final relocationPriorityServiceProvider = Provider<RelocationPriorityService>(
  (ref) => RelocationPriorityService(
    habitationRepository: ref.watch(localHabitationRepositoryProvider),
    hazardZoneRepository: ref.watch(localHazardZoneRepositoryProvider),
    riskAssessmentService: ref.watch(riskAssessmentServiceProvider),
    capacityAssessmentService: ref.watch(capacityAssessmentServiceProvider),
    relocationPlanningService: ref.watch(relocationPlanningServiceProvider),
  ),
);
```
This *is* the app's dependency-injection mechanism — there is no separate DI container. Swapping an implementation (e.g. for a test) means overriding one provider in a `ProviderScope`, not editing a service-locator registration.

**2. `FutureProvider.autoDispose<T>` — one-shot or recompute-on-open async data.** Used for screen data that's genuinely worth recomputing each time a screen opens, rather than kept live-streaming. Example, `relocationPriorityQueueProvider`:
```dart
final relocationPriorityQueueProvider =
    FutureProvider.autoDispose<List<RelocationPriorityResult>>((ref) async {
      return ref.watch(relocationPriorityServiceProvider).buildQueue();
    });
```
`.autoDispose` means the provider's state (and any pending Firestore/Drift work) is discarded once no widget is watching it — verified as the dominant pattern for screen-scoped data across `admin/`, `relocation/`, `state_admin/` providers inspected this session. The Relocation Priority screen exposes an explicit "Recompute" button and pull-to-refresh that call `ref.invalidate(relocationPriorityQueueProvider)` — data does **not** silently go stale in the background; refresh is a deliberate user action or an app-root trigger (see pattern 4 below), matching the codebase's own stated convention ("assessment refreshes as explicit, not continuous").

**3. `AsyncNotifierProvider` — the one genuinely mutable, long-lived piece of app state.** `authControllerProvider` (`AsyncNotifierProvider<AuthController, AuthSession?>`) is the canonical example: its `build()` performs the initial session restore, and `login()`/`register()`/`logout()` explicitly set `state = AsyncData(...)` in response to user actions. This is the one provider whose value genuinely represents "the current state of the world" rather than "the current answer to a query" — every route-guard decision and every role-gated UI element ultimately reads from it (directly, or via the derived `currentUserProvider = Provider<AppUser?>((ref) => ref.watch(authControllerProvider).valueOrNull?.user)`).

**4. Root-lifetime `Provider.autoDispose<void>` — background triggers with no meaningful return value.** Three of these are watched exactly once, in `TaarakApp.build()`, specifically to outlive whatever screen happens to be on top:
- `syncOnReconnectTriggerProvider` — subscribes to `NetworkInfo.onConnectivityChanged`, fires a sync pass on an offline→online transition.
- `syncPollingTriggerProvider` — a `Timer.periodic` sync pass; the interval is itself read reactively from `technicalConfigProvider`, so an admin's change to the sync interval (via `/admin/technical`) actually cancels and recreates the timer with the new value for every already-running session, not just after a restart.
- `notificationWatcherProvider` — diffs the alert/incident lists against a remembered "already seen" id set and fires a local notification for genuinely new entries only (the first emission after app start establishes the baseline rather than notifying for everything that already existed).

`rolePermissionOverridesProvider` (a `FutureProvider.autoDispose`) is also watched once at the `TaarakApp` root, for a narrower reason: it needs to stay warm because `route_guard.dart`'s redirect closure can only `ref.read` it (not `ref.watch` — see `06_ROUTING.md`), and an `.autoDispose` provider with no watcher would otherwise reset between reads.

## What state persists across app restarts, and how

Only two things survive an app restart, by design:
1. **The auth session** — `flutter_secure_storage`, read once by `AuthController.build()`.
2. **Everything in the local Drift database** — habitations, hazard zones, incidents, shelters, alerts, relocation plans, risk/capacity/vulnerability assessments, the sync queue itself. See `09_DATABASE_STORAGE.md`.

Every other piece of Riverpod state — including the entire in-memory session for `DevMockAuthRemoteDataSource`'s demo accounts, if that path were ever active — is rebuilt from scratch on cold start. There is no `hydrated_riverpod`-style automatic state persistence.

## What happens on app restart, concretely

1. `ProviderScope` creates a fresh provider container — every provider is unbuilt.
2. `TaarakApp.build()` runs, watching the four root-lifetime triggers above (all rebuild from nothing — the notification watcher's "already seen" id set restarts empty, meaning a genuinely-new-since-last-session alert could, in principle, be treated as new on the very first diff after restart; **UNKNOWN — requires verification** whether this produces a duplicate/spurious notification on cold start for a citizen who already saw an alert in a previous session, since no persisted "seen" set exists).
3. `AuthController.build()` reads the persisted session from secure storage. If present, the user lands past `/login`; if absent or the read fails, they land on `/login`.
4. Every screen-scoped provider (all the `FutureProvider.autoDispose`s) starts genuinely empty and refetches from Drift/Firestore the first time its screen is opened — this is not a cache warm-up, it's a fresh query each time.

## Local (screen-only) state

Form fields, "is this button currently submitting" flags, and similar screen-local UI state use plain Flutter `StatefulWidget`/`setState` (e.g. `_isSubmitting`, `_obscurePassword` in `LoginScreen`) — deliberately NOT promoted to a Riverpod provider, since nothing outside that one screen instance needs to read or react to it.

## State-flow diagram (a representative screen-triggered write)

```
User taps "Register habitation" [RegisterHabitationScreen, a ConsumerStatefulWidget]
        ↓
ref.read(habitationRegistrationServiceProvider).register(...)   ← ref.read, not
                                                                     watch: a one-off
                                                                     action, not a
                                                                     rebuild trigger
        ↓
HabitationRegistrationService: writes to LocalHabitationRepository
(Drift), enqueues a SyncQueueDao entry, records an AuditLogDao entry
        ↓
On success: ref.invalidate(habitationsProvider)   ← explicitly tells
                                                       Riverpod "this
                                                       cached query is
                                                       now stale"
        ↓
habitationsProvider (FutureProvider.autoDispose, watched by
RegisterHabitationScreen's own "Registered habitations" list AND by
RelocationPriorityService's buildQueue() indirectly via
LocalHabitationRepository.getAll()) recomputes
        ↓
Any currently-mounted widget watching habitationsProvider rebuilds
with the new list — the newly-registered habitation appears immediately
in the same screen; the Relocation Priority screen picks it up the next
time it's opened or its own "Recompute" is tapped (not live-pushed,
per pattern 2/3 above)
```
