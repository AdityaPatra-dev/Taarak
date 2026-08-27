# MODULE: Auth

## Purpose

This module is how TAARAK decides "who are you, and what are you allowed to touch." Concretely: when someone opens the app, this module checks whether a session was saved from last time and, if so, silently signs them back in; if not, it shows a login form. When someone types an email/password and taps "Sign in," this module sends those credentials to Firebase Auth, looks up that person's role (citizen, field responder, local official, district/command, state admin, or system admin) in a Firestore document, and hands the rest of the app an `AuthSession` object that every other screen and route can check. When someone taps "Register," this module creates a brand-new account — but only ever as a Citizen; there is no self-service way to become a Field Responder, Official, or Admin, because those roles are meant to be handed out deliberately, not claimed. When someone forgets their password, this module asks Firebase to email them a reset link and shows whether that request actually succeeded or failed (it does not fake a generic "check your email" for every outcome). This module also *defines* the six-role/permission system (`UserRole`, `Permission`) that every other feature in the app gates its screens and buttons on.

## User-facing functionality

- **Login screen** (`/login`): email + password form, "Forgot password?" link, "Don't have an account? Register" link, and — only when the app is running with the mock/demo backend switched on — a "Use a demo account" expandable list of one-tap-fill demo credentials per role.
- **Register screen** (`/register`): name + email + password form that always creates a Citizen account; explicitly tells the user that other roles are provisioned by a system admin, not self-registered.
- **Forgot-password screen** (`/forgot-password`): single email field; on success shows a "Check your email" confirmation state (worded to not confirm/deny whether the account exists, but the underlying call *does* distinguish success/failure — see Known Limitations); on failure shows the real error (e.g., invalid email).
- **Session persistence**: closing and reopening the app keeps the user signed in (session is restored from encrypted local storage) until they explicitly log out (the logout action lives in the Home module's app bar, not in this module).
- **Role/permission definitions**: not a screen, but this module is the single source of truth for what each of the six roles can do by default (`rolePermissions` map in `user_role.dart`), which the Admin module's "Manage Permissions" screen can then override per role at runtime.

## Entry points

- App cold start → `TaarakApp` (`lib/app/app.dart`) watches `authControllerProvider`; while its `build()` is restoring a session it shows a splash screen, then GoRouter's `redirect` (via `computeRedirect` in `lib/app/route_guard.dart`) sends an unauthenticated user to `/login` for any route, or an authenticated user away from `/login`/`/register`/`/forgot-password` back to `/`.
- Login screen → "Forgot password?" pushes `/forgot-password`; "Don't have an account? Register" pushes `/register`.
- Register/Forgot-password screens → back arrow or "Already have an account?" pops back to (or `go()`es to) `/login`.
- Home screen's logout icon (`lib/features/home/presentation/home_screen.dart`) calls `authControllerProvider.notifier.logout()` then `context.go('/login')` — this is the only sign-out entry point and it lives outside this module.
- Admin module's "Manage Accounts" screen reads `currentUserProvider` (defined in this module) to identify "you" in the account list.

## Architecture

Real, verified layering — a textbook `domain` / `data` / `application` / `presentation` split:

- **`domain/`** — pure data classes and enums, no I/O: `AppUser`, `AuthSession`, `UserRole` (+ `rolePermissions` map), `Permission` (+ labels).
- **`data/`** — the repository interface (`AuthRepository`), its implementation (`AuthRepositoryImpl`), the local session cache (`AuthLocalDataSource`), and three interchangeable *remote* data sources implementing one `AuthRemoteDataSource` interface: `FirebaseAuthRemoteDataSource` (real, production), `DevMockAuthRemoteDataSource` (in-memory demo), and `ApiAuthRemoteDataSource` (a REST stub for a backend that was never built).
- **`application/`** — Riverpod wiring: `auth_providers.dart` assembles the dependency graph (which remote data source to use, based on `AppConfig`), and `auth_controller.dart` holds the `AsyncNotifier<AuthSession?>` that the rest of the app watches/reads.
- **`presentation/`** — three `ConsumerStatefulWidget` screens (`LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen`), each owning its own form state and calling the controller.

## Files in this module

### `lib/features/auth/domain/app_user.dart`
- **Purpose**: The authenticated user's identity — id, name, email, role. JSON (de)serializable for local session persistence.
- **Status**: IMPLEMENTED.
- **Key classes**: `AppUser` — immutable data class; `fromJson`/`toJson`.
- **Depends on**: `UserRole` (same module). **Depended on by**: `AuthSession`, `AuthController.currentUserProvider`, `AdminUserSummary` (admin module, structurally similar), every screen that shows "Welcome, {name}" or checks `user.role`.
- **State/external I/O**: none — pure data class.

### `lib/features/auth/domain/auth_session.dart`
- **Purpose**: Wraps an `AppUser` with an auth token; this is the object persisted to local storage and held in `authControllerProvider`'s state.
- **Status**: IMPLEMENTED.
- **Key classes**: `AuthSession` — `user`, `token`; `fromJson`/`toJson`.
- **Depends on**: `AppUser`. **Depended on by**: `AuthLocalDataSource`, `AuthRepository` and all its implementations, `AuthController`, `lib/app/route_guard.dart` (`computeRedirect` takes an `AuthSession?`).

### `lib/features/auth/domain/permission.dart`
- **Purpose**: Enumerates every granular capability in the app (29 values, e.g. `sendSos`, `manageAccounts`, `reviewAudit`) and gives each a human-readable label. Routes and UI gate on these, never on role directly.
- **Status**: IMPLEMENTED.
- **Key classes**: `Permission` enum; `PermissionLabel` extension (`.label`).
- **Depended on by**: `UserRole`/`rolePermissions` (this module), `lib/app/route_guard.dart` (`defaultRoutePermissions` maps routes to a `Permission`), `RolePermissionOverrides` (admin module), `HomeScreen`'s quick-action list, `ManagePermissionsScreen`.

### `lib/features/auth/domain/user_role.dart`
- **Purpose**: Defines the six roles and the hardcoded default `Map<UserRole, Set<Permission>>` (`rolePermissions`) that each role grants. No role hierarchy/inheritance — each role's set is independent, by design (see code comment).
- **Status**: IMPLEMENTED.
- **Key classes**: `UserRole` enum (6 values); `UserRoleX` extension — `.label`, `.permissions`, `.can(Permission)`.
- **Notable content**: comments in the map explicitly flag two deliberate additions beyond the literal blueprint spec — `fieldResponder` and `localOfficial` both also grant `viewRiskMap`, added because features that push to `/map` would otherwise be unreachable (self-documented as a bug-driven fix, not scope creep).
- **Depended on by**: virtually everything — `route_guard.dart`, `RolePermissionOverrides`, every screen that gates a quick action, `AdminUserSummary`, `UserAdminScreen`'s role dropdown.

### `lib/features/auth/data/auth_local_data_source.dart`
- **Purpose**: Persists/reads/clears the current session to/from encrypted device storage, so login survives an app restart. Deliberately uses `SecureKeyValueStore` (`flutter_secure_storage`-backed) rather than the general Drift database, because a session token is a credential.
- **Status**: IMPLEMENTED.
- **Key classes**: `AuthLocalDataSource` — `saveSession`, `readSession`, `readToken`, `clearSession`.
- **Imports**: `taarak/core/storage/secure_key_value_store.dart` (`SecureKeyValueStore` interface, `FlutterSecureKeyValueStore` real impl).
- **Depends on**: `SecureKeyValueStore`, `AuthSession`. **Depended on by**: `AuthRepositoryImpl`; also, `auth_providers.dart` wires this data source's `readToken` into `ApiClient.attachTokenProvider` so any REST call carries the session token as a Bearer header.
- **State**: writes/reads key `taarak.auth.session` in secure storage. No network I/O.

### `lib/features/auth/data/auth_remote_data_source.dart`
- **Purpose**: Defines the `AuthRemoteDataSource` abstract interface (`login`, `register`, `sendPasswordResetEmail`) implemented by all three backends, and contains `ApiAuthRemoteDataSource`, a REST-based implementation targeting a "Identity backend module" via `ApiClient` (`POST /auth/login`, `/auth/register`, `/auth/forgot-password`).
- **Status**: `AuthRemoteDataSource` interface — IMPLEMENTED (as a contract). `ApiAuthRemoteDataSource` — DEMO/MOCK-adjacent DEAD CODE in practice: the doc comment states outright "Not usable until that service exists" — there is no backend at `apiBaseUrl` (`http://localhost:8080/api` per `AppConfig.development()`). It is only selected by `authRemoteDataSourceProvider` when both `useFirebaseAuth` and `useMockAuth` are false, which is not the app's current default.
- **Key classes**: `AuthRemoteDataSource` (interface), `ApiAuthRemoteDataSource`.
- **Depends on**: `ApiClient` (`core/network/api_client.dart`), `Result`. **Depended on by**: `auth_providers.dart` as the fallback data source.
- **External communication**: intends `POST /auth/login`, `POST /auth/register`, `POST /auth/forgot-password` against a never-deployed backend.

### `lib/features/auth/data/auth_repository.dart`
- **Purpose**: Abstract `AuthRepository` contract used by the application layer — decouples `AuthController` from which concrete backend/local combo is wired up.
- **Status**: IMPLEMENTED (interface).
- **Key methods**: `login`, `register`, `sendPasswordResetEmail`, `logout`, `restoreSession`.
- **Depended on by**: `AuthController`, `authRepositoryProvider`.

### `lib/features/auth/data/auth_repository_impl.dart`
- **Purpose**: The real `AuthRepository` implementation — delegates each call to whichever `AuthRemoteDataSource` was injected, and on a successful login/register additionally persists the session via `AuthLocalDataSource`.
- **Status**: IMPLEMENTED.
- **Key classes**: `AuthRepositoryImpl` (constructor takes `remote` + `local`).
- **Depends on**: `AuthRemoteDataSource`, `AuthLocalDataSource`, `Result`, `AuthSession`. **Depended on by**: `authRepositoryProvider`, and directly instantiated in `test/features/auth/auth_repository_test.dart`.
- **State**: writes the local session cache as a side effect of a successful `login`/`register`; `logout()` clears it; `restoreSession()` reads it.

### `lib/features/auth/data/dev_mock_auth_remote_data_source.dart`
- **Purpose**: An in-memory, hardcoded "backend" used purely so the RBAC flow is demoable before any real backend existed. Seeds exactly one account per role.
- **Status**: DEMO/MOCK — explicitly and unambiguously so (doc comment: "In-memory demo directory used only while `AppConfig.useMockAuth` is true").
- **Hardcoded content (flagged)**: six seeded accounts, one per role, all with the plaintext password pattern `<role>123`:
  - `citizen@taarak.dev` / `citizen123` → Citizen
  - `responder@taarak.dev` / `responder123` → Field Responder
  - `official@taarak.dev` / `official123` → Local Official
  - `command@taarak.dev` / `command123` → District/Command
  - `stateadmin@taarak.dev` / `stateadmin123` → State Admin
  - `sysadmin@taarak.dev` / `sysadmin123` → System Admin
  - Login/register/reset all operate against this in-memory `Map<String, _DevAccount>` only — nothing is persisted beyond the process lifetime, and `sendPasswordResetEmail` never sends a real email (it just checks the account exists).
  - The same six credential pairs are also hardcoded a second time, independently, in `LoginScreen._demoAccounts` (presentation layer) purely for the "Use a demo account" auto-fill chips.
- **Key classes**: `DevMockAuthRemoteDataSource`, private `_DevAccount`.
- **Depends on**: `AuthRemoteDataSource` interface, domain classes. **Depended on by**: `authRemoteDataSourceProvider` when `AppConfig.useMockAuth == true`; also directly instantiated in `auth_repository_test.dart` and `rbac_flow_test.dart` (tests pin this data source deliberately, regardless of `AppConfig`'s real defaults, to stay deterministic).

### `lib/features/auth/data/firebase_auth_remote_data_source.dart`
- **Purpose**: The real, production authentication backend. Firebase Auth owns credentials (email/password sign-in, account creation, password-reset emails); a `users/{uid}` Firestore document owns everything Firebase Auth doesn't model — name and role.
- **Status**: IMPLEMENTED — this is real production code, in clear contrast to the mock/demo data source above.
- **Key classes**: `FirebaseAuthRemoteDataSource` — `login`, `register`, `sendPasswordResetEmail`, private `_sessionForExistingUser`, `_mapAuthException`.
- **Behavior of note**: `register()` always writes `role: UserRole.citizen.name` to Firestore regardless of any role a caller might try to pass — there is no `role` parameter on `register()` at all, so this restriction is structural, not just a runtime check. `login()` fails with `NotFoundFailure` if the Firebase-Auth-authenticated user has no matching `users/{uid}` Firestore document ("contact a system admin").
- **Imports**: `cloud_firestore`, `firebase_auth`.
- **External communication**: Firebase Auth (`signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, `sendPasswordResetEmail`, `updateDisplayName`, `getIdToken`); Firestore reads/writes at `users/{uid}` (fields: `name`, `email`, `role`).
- **Depends on**: `AuthRemoteDataSource`, `Failure`/`Result`, domain classes. **Depended on by**: `authRemoteDataSourceProvider` when `AppConfig.useFirebaseAuth == true` — which is the actual default (see `AppConfig.development()`).
- **Error mapping**: `FirebaseAuthException` codes are mapped to the app's own `Failure` hierarchy (`user-not-found`/`wrong-password`/`invalid-credential` → `UnauthorizedFailure`; `email-already-in-use`/`weak-password`/`invalid-email` → `ValidationFailure`; `network-request-failed` → `NetworkFailure`; anything else → `UnknownFailure`).

### `lib/features/auth/application/auth_controller.dart`
- **Purpose**: The `AsyncNotifier<AuthSession?>` that is the single reactive source of truth for "is anyone signed in, and as whom." `null` (once the initial `AsyncData` resolves) means signed out.
- **Status**: IMPLEMENTED.
- **Key classes/providers**: `authControllerProvider` (`AsyncNotifierProvider<AuthController, AuthSession?>`), `currentUserProvider` (`Provider<AppUser?>`, derived), `AuthController` — `build()` (calls `restoreSession()`), `login`, `register`, `sendPasswordResetEmail`, `logout`.
- **State it reads/writes**: reads `authRepositoryProvider`; writes its own `state` (`AsyncData<AuthSession?>`) on login/register/logout success.
- **Depended on by**: all three auth screens, `lib/app/app.dart` (splash-vs-router gate), `lib/app/router.dart` (`_routerRefreshProvider` listens to it to re-run redirects), `HomeScreen`, `ProfileScreen`, `UserAdminScreen` (via `currentUserProvider`).

### `lib/features/auth/application/auth_providers.dart`
- **Purpose**: Assembles the dependency-injection graph for auth — decides which concrete `AuthRemoteDataSource` to use based on `AppConfig`, builds `AuthLocalDataSource`, and composes `AuthRepositoryImpl`.
- **Status**: IMPLEMENTED.
- **Key providers**: `authRemoteDataSourceProvider` (the three-way `if/else` selecting Firebase → Mock → API), `authLocalDataSourceProvider` (also wires the API client's Bearer-token provider as a side effect), `authRepositoryProvider`.
- **Selection logic (verified in code)**: `if (config.useFirebaseAuth) return FirebaseAuthRemoteDataSource(); if (config.useMockAuth) return DevMockAuthRemoteDataSource(); return ApiAuthRemoteDataSource(...)`. Firebase takes priority; with `AppConfig.development()`'s real values (`useFirebaseAuth: true, useMockAuth: false`), **Firebase is what actually runs today**, not the mock.
- **Depends on**: `core/providers/core_providers.dart` (`appConfigProvider`, `apiClientProvider`, `secureKeyValueStoreProvider`).

### `lib/features/auth/presentation/login_screen.dart`
- **Purpose**: The sign-in form: email/password fields, inline validation, submit → `AuthController.login`, error banner on failure, links to register/forgot-password, and (mock-mode only) a demo-account picker.
- **Status**: IMPLEMENTED.
- **Key classes**: `LoginScreen`, `_LoginScreenState` (`_submit`, `_fillDemoAccount`), `_ErrorBanner`.
- **Hardcoded content (flagged)**: `_demoAccounts` — a second, independent hardcoded copy of the six demo email/password pairs from `DevMockAuthRemoteDataSource`, shown only `if (useMockAuth)`.
- **State it reads**: `appConfigProvider.useMockAuth` (controls demo-picker visibility); calls `authControllerProvider.notifier`.
- **Depends on**: `shared/widgets/auth_brand_header.dart` (`AuthBrandHeader`, `AuthCard` — shared UI, out of this module's scope). **Reachable from**: unauthenticated redirect to `/login`; `RegisterScreen`/`ForgotPasswordScreen` back-navigation.

### `lib/features/auth/presentation/register_screen.dart`
- **Purpose**: The self-registration form — name/email/password, always producing a Citizen account. Explicitly tells the user other roles are admin-provisioned.
- **Status**: IMPLEMENTED.
- **Key classes**: `RegisterScreen`, `_RegisterScreenState` (`_submit`, `_goBackToLogin`).
- **Depends on**: `AuthController.register`. **Reachable from**: `/login`'s "Register" link, or directly via URL/deep link (handles the no-back-stack case by falling back to `context.go('/login')`).

### `lib/features/auth/presentation/forgot_password_screen.dart`
- **Purpose**: Password-reset request form. Shows the real success/failure outcome of `sendPasswordResetEmail` rather than a blanket message.
- **Status**: IMPLEMENTED.
- **Key classes**: `ForgotPasswordScreen`, `_ForgotPasswordScreenState` (`_submit`, `_buildSentState`, `_buildFormFields`).
- **Note**: the code comment claims this "shows the real result rather than a blanket... message," and technically it does differentiate failure vs. success at the `Result` level — but the success copy itself is deliberately non-committal ("If an account exists for {email}, a password reset link is on its way"), which is standard practice to avoid confirming which emails have accounts.
- **Depends on**: `AuthController.sendPasswordResetEmail`. **Reachable from**: `/login`'s "Forgot password?" link.

## Data Models

| Class | Fields | Notes |
|---|---|---|
| `AppUser` | `id`, `name`, `email`, `role` (`UserRole`) | JSON round-trippable |
| `AuthSession` | `user` (`AppUser`), `token` (`String`) | persisted whole to secure storage |
| `UserRole` (enum) | `citizen`, `fieldResponder`, `localOfficial`, `districtCommand`, `stateAdmin`, `systemAdmin` | + `.label`, `.permissions`, `.can()` |
| `Permission` (enum) | 29 values across 6 role groupings | + `.label` |

## Services / Repositories / Data Sources

| Component | Real or Mock | Backend |
|---|---|---|
| `FirebaseAuthRemoteDataSource` | **Real, production** | Firebase Auth + Firestore `users/{uid}` |
| `DevMockAuthRemoteDataSource` | **Demo/mock, explicitly flagged** | In-memory `Map`, 6 seeded accounts, no persistence |
| `ApiAuthRemoteDataSource` | Written as real, but its own doc comment says the backend it targets ("never-deployed") doesn't exist | REST via `ApiClient` to `apiBaseUrl` |
| `AuthLocalDataSource` | Real | `SecureKeyValueStore` (encrypted local storage) |
| `AuthRepositoryImpl` | Real (orchestration layer) | Delegates to whichever remote data source is injected |

Backend selection is config-driven (`authRemoteDataSourceProvider`), and the *current default* (`AppConfig.development()`) selects **Firebase**, not the mock.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/login` | `LoginScreen` | None — gated purely by auth state (`computeRedirect` sends unauthenticated visitors here for any other route, and authenticated visitors away from it) | App start when signed out; logout action |
| `/register` | `RegisterScreen` | None (same auth-state-only gating) | `/login`'s "Register" link |
| `/forgot-password` | `ForgotPasswordScreen` | None — same auth-state-only gating (`_authRoutes` in `route_guard.dart` lists all three of `/login`, `/register`, `/forgot-password`) | `/login`'s "Forgot password?" link |

All three auth routes share identical gating: reachable while signed out; an authenticated user hitting any of them is redirected straight to `/`.

## Module Data Flow

Login, the module's main action:

```
LoginScreen (_submit)
  → ref.read(authControllerProvider.notifier).login(email, password)
    → AuthController.login()
      → ref.read(authRepositoryProvider).login(...)
        → AuthRepositoryImpl.login()
          → AuthRemoteDataSource.login()   [concrete impl chosen by authRemoteDataSourceProvider]
             ├─ FirebaseAuthRemoteDataSource (production)
             │    → FirebaseAuth.signInWithEmailAndPassword()
             │    → FirebaseFirestore.collection('users').doc(uid).get()
             │    → returns Result<AuthSession>
             ├─ DevMockAuthRemoteDataSource (demo)
             │    → in-memory Map lookup
             └─ ApiAuthRemoteDataSource (unused/never-deployed)
                  → ApiClient.post('/auth/login')
          ← Result<AuthSession>
          [on Success] → AuthLocalDataSource.saveSession()  (writes encrypted local storage)
        ← Result<AuthSession>
      [on Success] → AuthController.state = AsyncData(session)
    ← Result<AuthSession>
  → LoginScreen shows error banner on Failed, or clears form/lets router redirect on Success

Meanwhile, reactively:
authControllerProvider state change
  → _routerRefreshProvider (lib/app/router.dart) notifies GoRouter
  → GoRouter re-evaluates computeRedirect(session, location, permissionOverrides)
  → user is redirected from /login to / (Home)
```

## Current Status

- **Working**: Login, register, forgot-password, session persistence/restore, logout (triggered from Home), role/permission definitions, route guarding. All confirmed by both reading the code and passing tests.
- **Demo/Mock**: `DevMockAuthRemoteDataSource` plus its UI surface in `LoginScreen` — clearly gated behind `AppConfig.useMockAuth`, which is `false` by default, so this is dormant in the app's current configuration but present and testable.
- **Dead/unreachable in current config**: `ApiAuthRemoteDataSource` — reachable only if both `useFirebaseAuth` and `useMockAuth` are false, which no `AppConfig` factory currently produces; its own doc comment calls its backend "never-deployed."
- **Broken**: none found.

## Known Limitations

- Public self-registration can only ever create a Citizen account — enforced structurally (no `role` parameter exists on `register()` in either real data source), not just by a UI restriction. Field Responder / Local Official / District Command / State Admin / System Admin accounts must be provisioned by an existing System Admin via the Admin module's "Manage Accounts" screen (or, before that screen existed, by hand in the Firestore console — see comment in `firebase_auth_remote_data_source.dart`).
- `AdminUserSummary.fromFirestore` (admin module, cross-referenced here because it reads the same `users` collection) silently falls back to `UserRole.citizen` if a stored role string doesn't match any known `UserRole` — meaning a corrupted/unexpected Firestore `role` value fails silently rather than surfacing an error.
- `UserRole` permissions have **no hierarchy/inheritance** by design — e.g. District/Command does not automatically get Local Official capabilities. This is stated explicitly in the code comment and is a real, intentional restriction someone unfamiliar with the blueprint might expect to work differently.
- Session restore has no explicit token-expiry/refresh handling visible in this module — `readToken()` simply returns whatever was last saved; if a Firebase ID token expires, nothing in this module proactively refreshes it (Firebase's SDK does handle refresh internally for its own calls, but the locally-cached `token` string used for e.g. `ApiClient`'s Bearer header is a point-in-time snapshot from the last login).
- `ApiAuthRemoteDataSource` exists as a fully-written REST client for a backend that was never built — dead weight unless/until that Identity backend module is implemented.
- The demo account credentials are duplicated in two places (`DevMockAuthRemoteDataSource._seedAccounts` and `LoginScreen._demoAccounts`) with no shared constant — a change to one without the other would desync the demo picker from what actually logs in.

## Test Coverage

`test/features/auth/` contains 5 files, all read and verified:

- **`auth_repository_test.dart`** — exercises `AuthRepositoryImpl` against `DevMockAuthRemoteDataSource` + a fake secure store: login success/failure + session persistence, register (always-Citizen, duplicate-email rejection), password reset (known/unknown email), and full session lifecycle (login → restore → logout → restore is null). Good coverage of the repository/local-persistence orchestration, but **does not exercise `FirebaseAuthRemoteDataSource` through the repository** (that's covered separately, one layer down).
- **`firebase_auth_remote_data_source_test.dart`** — exercises `FirebaseAuthRemoteDataSource` directly against `fake_cloud_firestore` + `firebase_auth_mocks`: register-then-citizen-role acceptance test, duplicate-email → `ValidationFailure`, wrong-password → `UnauthorizedFailure`, signed-in-but-no-Firestore-profile → `NotFoundFailure`, multi-role login (district command) reads real role from Firestore, and password-reset success/failure mapping. Solid, realistic coverage of the production auth path.
- **`rbac_flow_test.dart`** — full widget-level test pumping `TaarakApp` itself: unauthenticated → `/login` redirect, citizen login shows only citizen-permitted quick actions (`Send SOS`, not `Manage accounts`/`Monitor zones`), logout returns to login, sysadmin login shows admin-only actions and hides citizen-only ones, and a wrong password keeps the user on login with a visible error. This is effectively an integration test spanning Auth + Home + routing, deliberately pinned to `DevMockAuthRemoteDataSource` for determinism regardless of `AppConfig`'s real default.
- **`role_permissions_test.dart`** — pure unit tests on `UserRole`/`Permission`: every role has ≥1 permission, spot-checks per role (citizen can't manage accounts, field responder can't verify reports, etc.), confirms only System Admin can `manageAccounts`/`managePermissions`, and confirms no role inherits another's capabilities.
- **`route_guard_test.dart`** — pure unit tests on `computeRedirect` (lives in `lib/app/router.dart`'s guard, not strictly this module, but heavily exercises `AuthSession`/`UserRole`/`Permission` from this module plus `RolePermissionOverrides` from the admin module): unauthenticated→login, authenticated-away-from-auth-screens, permission-gated routes admitted/denied per role for essentially every real route in the app, path-parameterized routes (`/dashboard/incidents/:id`), and role-permission-override grant/revoke scenarios.

**Not covered**: `AuthLocalDataSource` has no dedicated unit test file of its own (it's only exercised indirectly through `auth_repository_test.dart`); `ApiAuthRemoteDataSource` has no test at all (consistent with it being unused/unreachable code); the presentation-layer widgets (`LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen`) have no widget tests of their own beyond what `rbac_flow_test.dart` incidentally exercises on `LoginScreen`.
