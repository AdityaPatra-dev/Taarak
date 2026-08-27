# MODULE: Admin

## Purpose

This module is the System Admin's control panel for the rest of the app. Concretely, it solves four separate problems that only a System Admin (`Permission`-gated: `manageAccounts`, `moderateContent`, `managePermissions`, `manageTechnicalConfiguration`) should be able to touch:

1. **Who has what role** — before this module's "Manage Accounts" screen existed, promoting someone from Citizen to Field Responder (or any other role) meant hand-editing a document in the Firebase console. Now a System Admin can browse every registered account and change its role from within the app.
2. **Removing bad data** — a System Admin can pull a hazard zone, an incident/SOS report, or an alert off every user's map/dashboard through "Content Moderation." Every removal is a soft delete (the record gets a `removedAt`/`cancelledAt` timestamp, never a hard delete) and is written to the audit log.
3. **Who can do what, live** — "Manage Permissions" lets a System Admin override, per role, which of the app's 29 permissions that role actually has, without shipping a new build. Every place in the app that checks "can this user do X" (the router's redirect guard, the Home screen's quick-action list) consults this override before falling back to the hardcoded default.
4. **How the app behaves mechanically** — "Technical Configuration" currently exposes exactly one operational knob: how often (in seconds) every signed-in device polls for new hazard zones/incidents/alerts/shelters in the background.

## User-facing functionality

- **Manage Accounts** (`/admin/users`): lists every account (name, email, current role) pulled from Firestore, sorted alphabetically by name. Each row (except the signed-in admin's own) has a role dropdown; picking a new role writes it immediately and shows a confirmation snackbar. The admin's own row is shown as a read-only chip — you cannot change your own role from this screen (to avoid locking yourself out).
- **Content Moderation** (`/admin/moderation`): three sections — Hazard Zones, Incidents & SOS reports, Alerts — each listing currently-active items with a delete icon. Tapping delete opens a confirmation dialog with an optional free-text "Reason" field; confirming removes the item (soft delete) and shows a success/error snackbar. Explicitly tells the admin the action is audited.
- **Manage Permissions** (`/admin/permissions`): one expandable card per role, each listing all 29 permissions as checkboxes reflecting that role's *effective* permissions (override if one exists, otherwise the hardcoded default). Toggling a checkbox writes an override immediately ("Changes apply immediately across the app for every signed-in user of that role"). A "Customized" chip marks roles with an active override, and a "Reset to default" link removes it. Two permissions on System Admin (`manageAccounts`, `managePermissions`) are permanently un-toggleable, to prevent a self-lockout.
- **Technical Configuration** (`/admin/technical`): a single numeric field for the background sync interval (15–600 seconds), with a Save button; explains what the value controls in plain language.

## Entry points

- Reachable only from the Home screen's "Quick actions" grid, each tile gated by its permission: "Manage Accounts" (`manageAccounts`), "Content Moderation" (`moderateContent`), "Manage Permissions" (`managePermissions`), "Technical Configuration" (`manageTechnicalConfiguration`) — see `lib/features/home/presentation/home_screen.dart`.
- Direct URL/deep-link to any of the four routes also works, but is still gated by `computeRedirect` — a role without the matching permission is bounced to `/unauthorized`.

## Architecture

Real `domain` / `data` / `application` / `presentation` split, same pattern as Auth:

- **`domain/`** — `AdminUserSummary` (account list row), `RolePermissionOverrides` (the override map + its Firestore codec), `TechnicalConfig` (the sync-interval value + its Firestore codec and bounds).
- **`data/`** — three thin Firestore-only data sources, one per concern: `UserAdminDataSource`, `RolePermissionOverridesDataSource`, `TechnicalConfigDataSource`. No local/offline caching layer — these are all "always online, source of truth" data by deliberate design (see code comments), unlike the Drift-cached entities other modules use.
- **`application/`** — two provider files: `admin_providers.dart` (accounts, overrides, technical config) and `content_moderation_providers.dart` (moderation queues — these actually re-read *other modules'* repositories/services: hazard zones, incidents, alerts).
- **`presentation/`** — four screens, one per admin capability.

## Files in this module

### `lib/features/admin/domain/admin_user_summary.dart`
- **Purpose**: A trimmed-down user record for the account list — just `uid`, `name`, `email`, `role` (not the full `AppUser` shape auth uses).
- **Status**: IMPLEMENTED.
- **Key classes**: `AdminUserSummary`, factory `fromFirestore(uid, data)`.
- **Notable behavior**: if the stored `role` string doesn't match any `UserRole` value, it silently falls back to `UserRole.citizen` rather than throwing — "shouldn't happen via the app's own write paths" per the code comment, but this is a real silent-failure path if Firestore data is ever malformed.
- **Depends on**: `UserRole` (auth module). **Depended on by**: `UserAdminDataSource.listUsers()`, `UserAdminScreen`.

### `lib/features/admin/domain/role_permission_overrides.dart`
- **Purpose**: The data model for "Manage Permissions" — a `Map<UserRole, Set<Permission>>` of admin-edited overrides. A role with no entry falls back unchanged to its hardcoded `UserRoleX.permissions`. Overrides are a **full replacement** per role, not an additive/subtractive diff.
- **Status**: IMPLEMENTED.
- **Key classes**: `RolePermissionOverrides` — `overridesByRole`, `effectivePermissionsFor(role)` (the single call site every permission check should use instead of `UserRoleX.permissions` directly), `withRole(role, permissions)`, `fromFirestore`/`toFirestore`.
- **Notable behavior**: `fromFirestore` silently drops unknown role names and unknown permission names rather than failing — verified by test (`role_permission_overrides_test.dart`).
- **Depends on**: `Permission`, `UserRole` (auth module). **Depended on by**: `route_guard.dart`'s `computeRedirect` (`permissionOverrides` param), `HomeScreen` (effective-permission quick-action gating), `RolePermissionOverridesDataSource`, `ManagePermissionsScreen`.

### `lib/features/admin/domain/technical_config.dart`
- **Purpose**: The one operational knob currently modeled: `syncIntervalSeconds`, with bounds (15–600s) and a default (45s). Deliberately kept separate from `AppPolicy`'s disaster-response policy values — this is "app mechanics," not domain policy.
- **Status**: IMPLEMENTED.
- **Key classes**: `TechnicalConfig` — `defaults`, `minSyncIntervalSeconds`, `maxSyncIntervalSeconds`, `fromFirestore` (falls back to `defaults` if the stored value is missing or out of bounds), `toFirestore`.
- **Depended on by**: `TechnicalConfigDataSource`, `ManageTechnicalConfigurationScreen`, and (outside this module) `syncPollingTriggerProvider` in `features/sync`, which is what actually consumes `syncIntervalSeconds` to drive background polling.

### `lib/features/admin/data/role_permission_overrides_data_source.dart`
- **Purpose**: Reads/writes the single override document at Firestore path `config/role_permissions`.
- **Status**: IMPLEMENTED — real Firestore integration, no mock.
- **Key classes**: `RolePermissionOverridesDataSource` — `read()`, `write(overrides)`.
- **Failure handling**: `read()` never surfaces a failure — a missing document or any exception both resolve to `Result.success(RolePermissionOverrides.empty)`, "so a missing/unreachable override doc shouldn't ever block routing." `write()` returns `NetworkFailure` on any exception.
- **External communication**: Firestore document `config/role_permissions`.

### `lib/features/admin/data/technical_config_data_source.dart`
- **Purpose**: Reads/writes the technical config document at Firestore path `config/technical`.
- **Status**: IMPLEMENTED — real Firestore integration.
- **Key classes**: `TechnicalConfigDataSource` — `read()`, `write(config)` (uses `SetOptions(merge: true)`).
- **Failure handling**: same pattern as above — `read()` failures/missing doc silently resolve to `Result.success(TechnicalConfig.defaults)`; `write()` failures return `NetworkFailure`.
- **External communication**: Firestore document `config/technical`.

### `lib/features/admin/data/user_admin_data_source.dart`
- **Purpose**: Lists every user in Firestore's `users` collection and reassigns a user's role. Deliberately bypasses the app's offline sync pipeline (M17) — account/role data is "always online, source of truth," and security rules already reject a user writing anyone else's role (server-side enforcement, not verified in this codebase since Firestore rules live outside `lib/`).
- **Status**: IMPLEMENTED — real Firestore integration.
- **Key classes**: `UserAdminDataSource` — `listUsers()` (sorted case-insensitively by name), `updateRole({uid, role})`.
- **External communication**: Firestore collection `users` (read all docs; `update({'role': ...})` on one doc).
- **Depended on by**: `admin_providers.dart` (`userAdminDataSourceProvider`, `adminUsersProvider`), `UserAdminScreen`.

### `lib/features/admin/presentation/user_admin_screen.dart`
- **Purpose**: The "Manage Accounts" screen — lists accounts, lets an admin change any other account's role via a dropdown.
- **Status**: IMPLEMENTED.
- **Key classes**: `UserAdminScreen`, `_UserRow` (`_changeRole`).
- **Notable behavior**: self-role-change is deliberately disabled ("Changing your own role would risk locking yourself out of this very screen").
- **State it reads**: `adminUsersProvider`, `currentUserProvider` (auth module, to detect "is this row me"). **State it writes**: calls `userAdminDataSourceProvider.updateRole()` then invalidates `adminUsersProvider` to refresh the list.
- **Imports of note**: `auth_controller.dart` (for `currentUserProvider`), `user_role.dart` (role dropdown options).

### `lib/features/admin/presentation/content_moderation_screen.dart`
- **Purpose**: The "Content Moderation" console — three sections that let an admin soft-delete a hazard zone, incident, or alert, each going through a confirm-with-reason dialog.
- **Status**: IMPLEMENTED, but its correctness depends heavily on services owned by *other* modules (hazards, verification/incidents, alerts) — this screen is essentially a thin UI wrapper calling into them.
- **Key classes**: `ContentModerationScreen`, `_HazardZonesSection`/`_IncidentsSection`/`_AlertsSection` (each with its own `_removeX` method), `_ModerationCard` (shared card + confirm dialog, generic over an `onRemove` callback).
- **Cross-module calls (out of this module's own code, but load-bearing here)**: `hazardIngestionServiceProvider.remove(id, adminId, reason)` (hazards module), `incidentVerificationServiceProvider.removeIncident(incidentId, adminId, reason)` (verification module), `alertBroadcastServiceProvider.deleteAlert(alertId, adminId, reason)` (alerts module). All three are asserted by the code comment to perform a **soft delete**, never a hard delete, and to write an audit entry.
- **State it reads**: `moderatableHazardZonesProvider`, `moderatableIncidentsProvider`, `moderatableAlertsProvider` (this module's `content_moderation_providers.dart`), `currentUserProvider` (auth module, to supply `adminId`). **State it invalidates on success**: the moderation-specific provider plus the "real" provider other screens use (`hazardZonesProvider`, `incidentsProvider`, `alertHistoryProvider`), so removals are reflected everywhere immediately.

### `lib/features/admin/presentation/manage_permissions_screen.dart`
- **Purpose**: The runtime permission-override editor — per-role checkboxes for all 29 permissions, backed by `RolePermissionOverrides`.
- **Status**: IMPLEMENTED. This is explicitly framed in the code comment as filling a real historical gap: `Permission.managePermissions` existed and was granted to System Admin from day one, but "had nothing to actually manage" until this screen was built.
- **Key classes/functions**: `ManagePermissionsScreen`, `_RolePermissionsCard` (`_toggle`, `_resetToDefault`, `_save`), module-level `_isProtected(role, permission)` helper.
- **Hardcoded protection rule (flagged)**: `_isProtected` hardcodes that System Admin can never have `manageAccounts` or `managePermissions` toggled off through this UI — "could lock every admin out of both account recovery and this screen itself, with no other way back in." This is a genuine, intentional guard-rail, not a bug.
- **State it reads/writes**: `rolePermissionOverridesProvider` (read), `rolePermissionOverridesDataSourceProvider.write()` (write, then invalidates the read provider).

### `lib/features/admin/presentation/manage_technical_configuration_screen.dart`
- **Purpose**: The sync-interval editor.
- **Status**: IMPLEMENTED.
- **Key classes**: `ManageTechnicalConfigurationScreen`, `_ManageTechnicalConfigurationScreenState` (`_save`).
- **Notable cross-module effect**: the code comment states `technicalConfigProvider` is watched directly by `syncPollingTriggerProvider` (features/sync), so a saved change here "reaches a running session without anyone needing to restart the app" — this module does not implement that polling itself, only supplies the value.
- **State it reads/writes**: `technicalConfigProvider` (read), `technicalConfigDataSourceProvider.write()` (write, then invalidates the read provider). Client-side validates the entered value is within `TechnicalConfig.min/maxSyncIntervalSeconds` before saving.

### `lib/features/admin/application/admin_providers.dart`
- **Purpose**: Riverpod wiring for accounts, permission overrides, and technical config.
- **Status**: IMPLEMENTED.
- **Key providers**: `userAdminDataSourceProvider`, `adminUsersProvider` (`FutureProvider.autoDispose<List<AdminUserSummary>>`), `rolePermissionOverridesDataSourceProvider`, `rolePermissionOverridesProvider` (`FutureProvider.autoDispose<RolePermissionOverrides>` — explicitly documented as watched from both `computeRedirect`'s call site and the Home screen, "the single source of truth every permission check in the app defers to"), `technicalConfigDataSourceProvider`, `technicalConfigProvider`.
- **Depended on by**: `lib/app/router.dart` (redirect closure), `lib/app/app.dart` (kept alive at app root — see below), `HomeScreen`, all four admin presentation screens.
- **Notable**: `rolePermissionOverridesProvider` is `autoDispose`, but `lib/app/app.dart` explicitly `ref.watch`es it at the app root "so the router's `ref.read` ... always sees a resolved value rather than a perpetually-reloading autoDispose provider with no watcher" — a subtle but load-bearing detail for correct redirect behavior.

### `lib/features/admin/application/content_moderation_providers.dart`
- **Purpose**: Re-exposes other modules' data (hazard zones, incidents, alert history) sorted for moderation display, "deliberately the same repositories every other screen reads, so a removal here always matches exactly what's currently visible elsewhere."
- **Status**: IMPLEMENTED.
- **Key providers**: `moderatableHazardZonesProvider` (sorted by `observedAt` desc), `moderatableIncidentsProvider` (sorted by `createdAt` desc), `moderatableAlertsProvider` (via `alertBroadcastServiceProvider.history()` — includes cancelled alerts too, unlike other screens that only show active ones).
- **Imports of note**: `core/database/app_database.dart` (Drift entity types `LocalHazardZone`/`LocalIncident`/`LocalAlert`), `features/alerts/application/alert_providers.dart` — this file has no domain logic of its own, it is purely a re-projection of other modules' repositories.

## Data Models

| Class | Fields | Notes |
|---|---|---|
| `AdminUserSummary` | `uid`, `name`, `email`, `role` (`UserRole`) | unknown Firestore role string → falls back to `citizen` |
| `RolePermissionOverrides` | `overridesByRole` (`Map<UserRole, Set<Permission>>`) | full-replacement semantics per role; `effectivePermissionsFor()` is the canonical read path |
| `TechnicalConfig` | `syncIntervalSeconds` (`int`) | bounded 15–600s, default 45s |

## Services / Repositories / Data Sources

All three admin data sources are **real Firestore integrations — no mock/demo layer exists in this module**, unlike Auth's contrast between `FirebaseAuthRemoteDataSource` and `DevMockAuthRemoteDataSource`.

| Component | Real or Mock | Firestore location |
|---|---|---|
| `UserAdminDataSource` | Real | `users` collection (all docs) |
| `RolePermissionOverridesDataSource` | Real | `config/role_permissions` doc |
| `TechnicalConfigDataSource` | Real | `config/technical` doc |

Content moderation additionally reaches into three other modules' real services (`HazardIngestionService`, `IncidentVerificationService`, `AlertBroadcastService`) — none of those are re-implemented here, only invoked.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/admin/users` | `UserAdminScreen` | `Permission.manageAccounts` | Home quick action "Manage Accounts" |
| `/admin/moderation` | `ContentModerationScreen` | `Permission.moderateContent` | Home quick action "Content Moderation" |
| `/admin/permissions` | `ManagePermissionsScreen` | `Permission.managePermissions` | Home quick action "Manage Permissions" |
| `/admin/technical` | `ManageTechnicalConfigurationScreen` | `Permission.manageTechnicalConfiguration` | Home quick action "Technical Configuration" |

All four map values come directly from `defaultRoutePermissions` in `lib/app/route_guard.dart`. Per the default `rolePermissions` map (auth module), only `UserRole.systemAdmin` is granted all four permissions out of the box — though a System Admin could, via "Manage Permissions," grant any of them to another role (subject to the two protected permissions that can never be revoked from System Admin itself).

## Module Data Flow

Role reassignment, the module's clearest end-to-end action:

```
UserAdminScreen (_UserRow._changeRole)
  → ref.read(userAdminDataSourceProvider).updateRole(uid, role)
    → UserAdminDataSource.updateRole()
      → FirebaseFirestore.collection('users').doc(uid).update({'role': role.name})
    ← Result<void>
  → ref.invalidate(adminUsersProvider)
    → adminUsersProvider re-runs
      → UserAdminDataSource.listUsers()
        → FirebaseFirestore.collection('users').get()
        → AdminUserSummary.fromFirestore(...) per doc
      ← List<AdminUserSummary>
  → screen shows SnackBar("{name} is now {role.label}") or the failure message
```

Permission-override edit, the module's other central action (with wider blast radius):

```
ManagePermissionsScreen (_RolePermissionsCard._toggle)
  → RolePermissionOverrides.withRole(role, updatedPermissionSet)
  → ref.read(rolePermissionOverridesDataSourceProvider).write(updated)
    → RolePermissionOverridesDataSource.write()
      → FirebaseFirestore.doc('config/role_permissions').set(overrides.toFirestore())
  → ref.invalidate(rolePermissionOverridesProvider)

Elsewhere, on the affected role's NEXT navigation attempt (not live-pushed):
  lib/app/router.dart's redirect closure
    → ref.read(rolePermissionOverridesProvider).valueOrNull
    → computeRedirect(..., permissionOverrides: overrides)
      → overrides.effectivePermissionsFor(role) instead of role.permissions
  HomeScreen's quick-action list
    → ref.watch(rolePermissionOverridesProvider) → effectivePermissionsFor(user.role)
```

## Current Status

- **Working**: all four screens are fully implemented against real Firestore data, verified by reading every file; the domain-model round-trip logic (`RolePermissionOverrides`, `TechnicalConfig`) is unit tested.
- **No demo/mock content found anywhere in this module** — every data source talks to real Firestore.
- **Partial**: `ContentModerationScreen` and `content_moderation_providers.dart` correctness is only as good as three other modules' services (hazards, verification, alerts) — those were not the target of this documentation pass and were not independently re-verified here, only their call signatures as used from this module.

## Known Limitations

- Changing a role does not update in real time for the affected *other* device — `lib/app/router.dart`'s own comment states permission-override edits (and, by the same mechanism, presumably role changes generally) "take effect on the affected user's next navigation... not via a live mid-page kick-out." A user mid-session on a now-revoked screen is not forcibly removed from it.
- `RolePermissionOverridesDataSource.read()` and `TechnicalConfigDataSource.read()` both swallow *all* exceptions (not just "document not found") and silently fall back to defaults/empty — a genuine Firestore permission error or outage looks identical to "no admin has ever touched this screen," with no user-visible distinction.
- Two System Admin permissions (`manageAccounts`, `managePermissions`) can never be revoked through "Manage Permissions" — a deliberate anti-lockout guard, but it does mean the screen's own claim of being able to "grant or remove any capability from any role" has an explicit, hardcoded exception.
- `AdminUserSummary.fromFirestore`'s fallback-to-citizen behavior on an unrecognized role string means a malformed Firestore write elsewhere in the system would silently demote that user's *displayed* role in this screen rather than surfacing an error to the admin.
- No self-service role change (admin cannot change their own role) — intentional, but means a solo System Admin who wants to relinquish the role needs a second admin account to do it.

## Test Coverage

`test/features/admin/` contains only 2 files — both read and verified:

- **`role_permission_overrides_test.dart`** — thorough unit coverage of `RolePermissionOverrides`: no-override fallback, `withRole` scoping (only touches the targeted role), empty-set-as-valid-override (revokes everything), Firestore round-trip, and graceful handling of unknown role/permission names in stored data.
- **`technical_config_test.dart`** — thorough unit coverage of `TechnicalConfig`: valid decode, missing-value fallback, out-of-bounds (both directions) fallback, Firestore round-trip.

**Not covered at all** (no test file touches these):
- `AdminUserSummary` (no direct unit test — only implicitly exercised if some other test constructs one, which none in this directory do).
- `UserAdminDataSource` — no test exercises `listUsers()`/`updateRole()` against a fake/real Firestore.
- `RolePermissionOverridesDataSource` / `TechnicalConfigDataSource` — the Firestore I/O layer itself is untested; only the pure domain objects they wrap are tested.
- All four presentation screens (`UserAdminScreen`, `ContentModerationScreen`, `ManagePermissionsScreen`, `ManageTechnicalConfigurationScreen`) — no widget tests exist for any of them in this module. (`route_guard_test.dart`, which lives under `test/features/auth/`, does exercise `RolePermissionOverrides` in combination with `computeRedirect`, but that is routing-focused, not admin-screen-focused.)
- `content_moderation_providers.dart` and the cross-module remove/delete calls it wires into — untested from this module's side.

This means the module's Firestore-facing behavior (the actual account list, actual role writes, actual override persistence, actual moderation removals) is **verified only by manual/production use and by reading the code**, not by any automated test in this repository.
