# MODULE: Home

## Purpose

This module is the very first screen a signed-in user sees, and it's the app's central "here's what you can do" hub. Concretely: after logging in, every user of every role lands on the same `HomeScreen`. It greets them by name and shows their role, then builds a personalized grid of "Quick action" tiles — Report Incident, I Am Safe, Manage Accounts, Command Dashboard, and so on — but only the tiles that person's role (or an admin's live permission override) actually grants access to. A Citizen never sees "Manage Accounts"; a System Admin never sees "Send SOS." It also shows a background-sync status banner (pending/stalled/retrying uploads) and, for roles with SOS access, a prominent red emergency card. The second file in this module, `UnauthorizedScreen`, is the "you don't have access to that" page every gated route bounces to — it's the module's other half: Home shows you what you *can* reach, Unauthorized is what you see if you try to reach something you can't.

The code's own doc comment is explicit that this is a **temporary, shared landing screen** whose real job right now is to prove the RBAC (role-based access control) system works end-to-end — it is meant to be replaced by real per-role home screens (e.g. "My Safety" for citizens, "Operations Dashboard" for command roles) as those are built.

## User-facing functionality

- **Home screen** (`/`): 
  - Greeting card with the user's initial, name, and role label.
  - A sync-status banner reflecting the local offline sync queue (empty/pending/retrying/stalled), with a "Sync now" button that triggers an immediate sync attempt.
  - A red "Emergency SOS" card (only shown to roles with `sendSos`), tapping it opens `/sos`.
  - A responsive grid of "Quick actions" (2/3/4 columns depending on screen size) — one tile per permission the user's *effective* role grants, each navigating to that feature's route.
  - A "SMS Fallback" and "Device Relay" tile, shown only in dev builds (`kReleaseMode == false`) to roles with `sendSos`.
  - An app bar with: a map icon (if `viewRiskMap` is granted, opens `/map`), a profile icon (always, opens `/profile`), and a logout icon (always — logs out and navigates to `/login`).
  - A "Available to your role" section listing every permission chip the role currently has, for transparency/debugging.
- **Unauthorized screen** (`/unauthorized`): a lock icon, "Not authorized" heading, explanatory text ("Your role does not have access to this page"), and a "Back to Home" button.

## Entry points

- `/` (Home) is the app's post-login default landing route — `computeRedirect` in `lib/app/route_guard.dart` sends any authenticated user away from the auth screens (`/login`, `/register`, `/forgot-password`) to `/`, and it's also where a fresh `GoRouter` with no other location naturally lands.
- `/unauthorized` is reached only via redirect — any authenticated user who navigates (directly, via a pushed link, or via a Quick Action tap) to a route whose required `Permission` they don't have is redirected here by `computeRedirect`. It is not linked to directly from anywhere in the UI.
- From Home, every other module in the app is one tap away via the Quick Actions grid, plus the app bar's map/profile/logout icons.

## Architecture

This is the simplest module in the app — **no `domain/`, `data/`, or `application/` subfolders at all**. Both files live directly under `presentation/`, and neither defines its own Riverpod providers, repositories, or domain models. `HomeScreen` is a pure aggregator: it reads providers owned by other modules (`authControllerProvider`/`currentUserProvider` from auth, `rolePermissionOverridesProvider` from admin, `syncQueueSummaryProvider`/`syncCoordinatorServiceProvider`/`pendingSyncCountProvider` from sync, `appConfigProvider` from core) and composes them into one screen. `UnauthorizedScreen` is fully self-contained and stateless.

## Files in this module

### `lib/features/home/presentation/home_screen.dart`
- **Purpose**: The post-login landing screen — greeting, sync status, SOS shortcut, permission-gated quick-actions grid, and the app-bar navigation hub (map/profile/logout).
- **Status**: IMPLEMENTED, but explicitly self-documented as **temporary** — the doc comment says it exists to "prove RBAC works" and will be "replaced by the real per-role home screens... as those modules land."
- **Key classes**: `HomeScreen` (`ConsumerWidget`); private `_GreetingCard`, `_SosCard`, `_SyncBanner` (`ConsumerWidget`), `_QuickAction` widgets.
- **Key logic**: builds a `List<_QuickAction>` by checking `can(permission)` (a local closure over `effectivePermissions`) for every gated feature in the app — this list is effectively a manually-maintained index of every route in `lib/app/router.dart` that has a `Permission` requirement. Two `isDevMode && hasSos` entries (SMS Fallback, Device Relay) are gated on `AppConfig.isDevMode` in addition to permission, restricting them from real release builds.
- **Notable imports**: pulls from four *other* modules directly — `admin/application/admin_providers.dart` (`rolePermissionOverridesProvider`), `auth/application/auth_controller.dart` (`authControllerProvider`), `auth/domain/permission.dart` + `user_role.dart`, `sync/application/sync_providers.dart` + `sync/domain/sync_queue_summary.dart`, `core/providers/core_providers.dart` (`appConfigProvider`).
- **State it reads**: `authControllerProvider` (session/user), `rolePermissionOverridesProvider` (effective permissions — falls back to `user.role.permissions` if the override provider hasn't resolved yet), `syncQueueSummaryProvider` (falls back to an empty `SyncQueueSummary()` if unresolved), `appConfigProvider.isDevMode`.
- **State it writes**: none directly to its own state, but triggers `authControllerProvider.notifier.logout()` on the logout icon, and `syncCoordinatorServiceProvider.syncPendingEntries()` on "Sync now" (then invalidates `pendingSyncCountProvider` and `syncQueueSummaryProvider`).
- **External communication**: none directly — all network/database access happens inside the providers it reads, owned by other modules.
- **Depends on**: (see imports above). **Depended on by**: `lib/app/router.dart` (registers it at `/`), reached from every other module indirectly via its Quick Actions grid.

### `lib/features/home/presentation/unauthorized_screen.dart`
- **Purpose**: The landing page for any authenticated-but-not-permitted navigation attempt.
- **Status**: IMPLEMENTED — small, complete, no known issues.
- **Key classes**: `UnauthorizedScreen` (`StatelessWidget`, no state, no providers).
- **Key logic**: single "Back to Home" button calling `context.go('/')`.
- **State it reads/writes**: none — this is a pure, static UI component with a single navigation action.
- **External communication**: none.
- **Depends on**: `go_router` only (plus shared `TaarakAppBar`, `Spacing`). **Depended on by**: `lib/app/router.dart` (registers it at `/unauthorized`); reached exclusively via `computeRedirect`'s `/unauthorized` return value in `lib/app/route_guard.dart`.

## Data Models

This module defines **no domain models of its own**. It consumes models owned elsewhere: `AppUser`/`UserRole`/`Permission` (auth module), `SyncQueueSummary` (sync module).

## Services / Repositories / Data Sources

None. This module has no `data/` layer, no repository, and no direct external communication — it is purely a presentation-layer consumer of other modules' state.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/` | `HomeScreen` | None — reachable by any authenticated user regardless of role | Default post-login landing; redirect target for authenticated users hitting an auth screen |
| `/unauthorized` | `UnauthorizedScreen` | None — reachable by any authenticated user | Redirect target when `computeRedirect` finds the current role lacks a route's required `Permission` |

Both routes are registered directly in `lib/app/router.dart` and are absent from `defaultRoutePermissions` in `lib/app/route_guard.dart`, confirming neither is permission-gated — they are the "floor" every authenticated user, regardless of role, can always reach.

## Module Data Flow

The Home screen's main action — building the permission-gated quick-actions grid on every rebuild:

```
HomeScreen.build()
  → ref.watch(authControllerProvider).valueOrNull   [auth module]
      → AuthSession? (null ⇒ render nothing, router redirect is already in flight)
  → session.user  (AppUser: name, email, role)
  → ref.watch(rolePermissionOverridesProvider).valueOrNull   [admin module]
      → RolePermissionOverrides.effectivePermissionsFor(user.role)
      → (falls back to user.role.permissions if the override provider hasn't loaded)
  → can(permission) closure checks membership in effectivePermissions
  → for each of ~20 permission-gated features: if can(permission), add a _QuickAction tile
  → ref.watch(syncQueueSummaryProvider).valueOrNull   [sync module] → _SyncBanner
  → ref.watch(appConfigProvider).isDevMode            [core]        → dev-only tiles

User taps a Quick Action tile:
  → context.push('/<route>')
    → lib/app/router.dart's redirect closure re-runs computeRedirect
      → re-checks permission against (possibly stale, but re-read) rolePermissionOverridesProvider
      → if still permitted: navigates to the target screen
      → if NOT (e.g. an admin revoked it moments ago): redirected to /unauthorized (this module's other screen)

User taps logout icon:
  → authControllerProvider.notifier.logout()  [auth module]
  → context.go('/login')
```

## Current Status

- **Working**: both screens are fully implemented and functional, confirmed by reading the code and by `test/features/auth/rbac_flow_test.dart`, which — despite living in the auth test directory — is actually the primary automated proof that `HomeScreen`'s permission-gated rendering works correctly (it pumps the real `TaarakApp`, logs in as different roles, and asserts which quick-action labels are/aren't present).
- **Explicitly temporary by design**: `HomeScreen`'s own doc comment states it is a stand-in for future per-role home screens. This is not a bug or an incomplete feature — it's a known, intentional placeholder whose replacement is out of scope for this module as it exists today.
- **No demo/mock content** in either file.

## Known Limitations

- `HomeScreen` is a single monolithic screen serving all six roles with one shared layout — there's no role-specific visual design (e.g. a citizen and a state admin see the identical greeting card and grid layout, just with different tiles). This is the intentional "temporary" tradeoff called out in the code comment.
- The Quick Actions list is a **manually maintained, hardcoded sequence of ~20 `if (can(permission))` blocks** in `HomeScreen.build()` — every time a new permission-gated route is added to the router, a matching entry must be added here by hand, or that feature becomes unreachable via the UI (still reachable by direct URL/deep link if the user knows it, since `computeRedirect` gates by permission independent of whether a Home tile exists for it). There's no dynamic/config-driven mapping between routes and quick-action tiles.
- Dev-only tiles (SMS Fallback, Device Relay) are gated on `kReleaseMode`, not on `AppConfig.environment` — the code comment explains this is deliberate today because `environment` never resolves to anything but `.development()`, but it means the gating logic is coupled to Flutter's build mode rather than to a proper environment concept, which could surprise someone expecting `environment`-based gating to work.
- `UnauthorizedScreen` gives no indication of *what* permission was missing or *which* role would have access — a generic "Your role does not have access to this page" for every case, which is fine for end users but offers no debugging affordance.
- Permission changes (via the admin module's "Manage Permissions") are not pushed live to an already-rendered Home screen mid-session in real time beyond Riverpod's normal provider-rebuild propagation — see the Admin module's documented limitation that overrides apply "on the affected user's next navigation," not as an instant kick-out.

## Test Coverage

**`test/features/home/` does not exist** — there is no dedicated test directory for this module, confirmed by directory listing.

The module is *not* left completely unverified, however: `test/features/auth/rbac_flow_test.dart` (which lives under the auth test directory, not a home-specific one) pumps the full `TaarakApp` widget tree and, after logging in as a Citizen and separately as a System Admin, asserts on `HomeScreen`'s rendered output — specifically that role-appropriate quick-action labels (`'Send SOS / need help'`, `'Manage accounts'`, `'Monitor zones'`, `'Review audit log'`) appear or don't appear per role, and that the greeting text (`'Welcome, Citizen Demo'` / `'Welcome, System Admin Demo'`) is correct. It also exercises the logout icon (`Icons.logout`) navigating back to `/login`.

What this leaves **not covered**:
- `UnauthorizedScreen` has no test coverage at all — nothing asserts its content renders, nor that its "Back to Home" button navigates correctly.
- The sync banner (`_SyncBanner`) and its "Sync now" button are not exercised by any test.
- The SOS card, dev-mode-only tiles, and the map/profile app-bar icons are not directly asserted on by any test.
- No test covers the responsive column-count logic (`ScreenSize.mobile/tablet/desktop` → 2/3/4 columns).
