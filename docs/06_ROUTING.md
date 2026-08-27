# Routing / Navigation

Verified directly against `lib/app/router.dart` and `lib/app/route_guard.dart` (both fully read this documentation pass — this file reflects their exact current content, not a paraphrase).

## Routing library

**go_router** (`^14.6.2`). One `GoRoute` list, no nested/shell routes, no named routes (paths are used directly via `context.push('/path')`/`context.go('/path')`). The router instance is itself a Riverpod provider: `appRouterProvider` (`Provider<GoRouter>`), built once and re-evaluated only when its own dependency (`_routerRefreshProvider`) changes.

## Authentication gating mechanism

`GoRouter`'s `redirect:` callback is wired to a **pure, side-effect-free function**: `computeRedirect()` in `route_guard.dart`. It takes an `AuthSession?`, the target `location` string, and two optional maps (`routePermissions`, defaulting to the real route table; `permissionOverrides`, an admin-configurable `RolePermissionOverrides?`) — deliberately kept free of `BuildContext`/`GoRouterState` so it is unit-testable without pumping a widget tree (see `test/features/auth/route_guard_test.dart`, 20+ passing cases).

Redirect logic, in order:
1. `session == null` (not signed in) → allowed only on `_authRoutes = {'/login', '/register', '/forgot-password'}`; everything else redirects to `/login`.
2. Signed in, but visiting one of `_authRoutes` → redirected to `/` (an already-authenticated user can't sit on the login/register/forgot-password screens).
3. Otherwise, the target location's required `Permission` is looked up (exact match in `routePermissions`, or — for the two path-parameterized routes — a prefix check: `/dashboard/incidents/*` requires `Permission.monitorZones`, `/field/incidents/*` requires `Permission.viewAssignedIncidents`). If a permission is required and the signed-in user's **effective** permission set (role defaults merged with any admin `RolePermissionOverrides` for that role — see `docs/modules/admin.md`) does not contain it, redirect to `/unauthorized`.
4. Otherwise, no redirect — the route renders normally.

`appRouterProvider`'s `redirect:` closure calls `ref.read(...)`, not `ref.watch(...)`, for both the session and the permission-overrides lookup — deliberate, because this closure runs on every navigation attempt (not during the provider's own build), where `ref.watch` would be invalid. Consequently: a permission-override edit made by a System Admin takes effect on the affected user's **next navigation** (including the very quick-action tap that just became visible to them), not as a live mid-page kick-out of someone already on a now-forbidden screen.

`refreshListenable` is a small `ChangeNotifier` (`_RouterRefreshNotifier`) bridged to `authControllerProvider` via `ref.listen`, so a login/logout event re-runs the redirect check without rebuilding the whole router.

## Complete route table

Every `GoRoute` in `router.dart`, cross-referenced against its `defaultRoutePermissions` entry in `route_guard.dart` (`—` means no permission required — reachable by any authenticated user, or, for the three auth routes, by anyone):

| Path | Screen | Required Permission |
|---|---|---|
| `/` | `HomeScreen` | — (any authenticated user) |
| `/profile` | `ProfileScreen` | — |
| `/map` | `RiskMapScreen` | `viewRiskMap` |
| `/hazards/report` | `ReportHazardZoneScreen` | `manageLocalIncidents` |
| `/hazards/simulate-alert` | `SimulateAlertScreen` | `manageLocalIncidents` |
| `/report` | `ReportIncidentScreen` | `submitIncidentReport` |
| `/sos` | `SosScreen` | `sendSos` |
| `/safe-status` | `IAmSafeScreen` | `updateSafeStatus` |
| `/verification` | `VerificationScreen` | `verifyReports` |
| `/shelters/manage` | `ShelterManagementScreen` | `manageSheltersResources` |
| `/alerts` | `AlertsScreen` | `viewAlerts` |
| `/alerts/broadcast` | `BroadcastAlertScreen` | `sendBroadcast` |
| `/dashboard` | `CommandDashboardScreen` | `monitorZones` |
| `/dashboard/incidents/:incidentId` | `IncidentDetailScreen` | `monitorZones` (prefix rule) |
| `/audit` | `AuditLogScreen` | `reviewAudit` |
| `/admin/users` | `UserAdminScreen` | `manageAccounts` |
| `/admin/moderation` | `ContentModerationScreen` | `moderateContent` |
| `/admin/permissions` | `ManagePermissionsScreen` | `managePermissions` |
| `/admin/technical` | `ManageTechnicalConfigurationScreen` | `manageTechnicalConfiguration` |
| `/field/incidents` | `AssignedIncidentsScreen` | `viewAssignedIncidents` |
| `/field/incidents/:incidentId` | `FieldIncidentDetailScreen` | `viewAssignedIncidents` (prefix rule) |
| `/command/responders` | `ManageRespondersScreen` | `manageResponders` |
| `/command/resources` | `ManageResourcesScreen` | `manageResources` |
| `/command/relocation` | `ManageRelocationScreen` | `manageRelocation` |
| `/relocation/priority` | `RelocationPriorityScreen` | `manageRelocation` |
| `/habitations/register` | `RegisterHabitationScreen` | `manageHabitations` |
| `/state/oversight` | `CommandDashboardScreen` (reused, `title: 'Cross-District Oversight'`) | `crossDistrictOversight` |
| `/state/reports` | `StateReportsScreen` | `viewReports` |
| `/state/policy` | `PolicyConfigurationScreen` | `managePolicyConfiguration` |
| `/sms-prototype` | `SmsPrototypeScreen` | `sendSos` (also gated behind `AppConfig.isDevMode` in the UI that links to it — see below) |
| `/device-relay` | `DeviceRelayScreen` | `sendSos` (same dev-mode UI gating) |
| `/login` | `LoginScreen` | — (auth route) |
| `/register` | `RegisterScreen` | — (auth route) |
| `/forgot-password` | `ForgotPasswordScreen` | — (auth route) |
| `/unauthorized` | `UnauthorizedScreen` | — (the redirect target itself) |

31 top-level routes + 2 path-parameterized routes = 33 total `GoRoute` entries.

## Dev-only visibility gating (distinct from permission gating)

Two quick actions on `HomeScreen` (`SMS Fallback`, `Device Relay`) are shown only when `AppConfig.isDevMode` is true **and** the user has `sendSos` — `isDevMode` is tied to Flutter's real compile-time `kReleaseMode` flag (false in a release build), not to `Environment`, specifically so these prototype screens can never be reached in a real release build regardless of role. The routes themselves are still permission-gated by `sendSos` at the router level (defense in depth: even a direct URL visit on web would still be blocked for a role without `sendSos`), but the *route guard alone* does not enforce dev-mode-only — that enforcement is UI-level (no quick-action button is rendered) on `HomeScreen`. **Verify in `docs/modules/sms_prototype.md` / `docs/modules/device_relay.md` whether a signed-in user with `sendSos` could still reach `/sms-prototype` directly by typing the URL in a release web build** — based on `route_guard.dart` alone, the answer is yes (nothing in `computeRedirect` checks `isDevMode`), so this is a real, minor gap worth flagging in `16_IMPLEMENTATION_GAPS.md`.

## Route → module ownership

Every route above belongs to exactly one feature module — see the per-module "Routes owned by this module" sections in `docs/modules/*.md` for entry-point cross-referencing in the other direction.

## Navigation tree (real, not illustrative)

```
App (redirect-gated by computeRedirect)
├── /login, /register, /forgot-password   (reachable only signed-out)
├── /                                      HomeScreen (role-adaptive quick actions)
│   ├── /profile
│   ├── /map                               (+ /hazards/report, /hazards/simulate-alert)
│   ├── /report, /sos, /safe-status        (citizen actions)
│   ├── /verification                      (Local Official)
│   ├── /shelters/manage
│   ├── /alerts, /alerts/broadcast
│   ├── /field/incidents → /field/incidents/:id   (Field Responder)
│   ├── /dashboard → /dashboard/incidents/:id     (District/Command, reused for State/Admin oversight)
│   ├── /command/responders, /command/resources, /command/relocation
│   ├── /relocation/priority
│   ├── /habitations/register
│   ├── /state/oversight, /state/reports, /state/policy   (State/Admin)
│   ├── /audit, /admin/users, /admin/moderation, /admin/permissions, /admin/technical  (System Admin)
│   └── /sms-prototype, /device-relay      (dev-mode only, sendSos)
└── /unauthorized                          (redirect target on permission failure)
```
