# Authentication

Verified directly against `lib/features/auth/` in full (all 15 files read this session, several written/modified this session) and `lib/app/route_guard.dart`.

## Layering

```
AuthController (Riverpod AsyncNotifier<AuthSession?>)
        ↓
AuthRepository (interface) → AuthRepositoryImpl
        ↓                              ↓
AuthLocalDataSource          AuthRemoteDataSource (interface)
(secure-storage session          ↓                    ↓
 persistence)          FirebaseAuthRemoteDataSource   DevMockAuthRemoteDataSource
                        (REAL — selected when          (in-memory demo directory —
                         AppConfig.useFirebaseAuth)      selected when
                                                          AppConfig.useMockAuth)
                        ApiAuthRemoteDataSource (talks to backend/ stub —
                                                 not selected by the app's only
                                                 AppConfig constructor)
```

## Which path is real (verified, not assumed)

`AppConfig.development()` — the only `AppConfig` constructed anywhere in the app — sets `useFirebaseAuth: true`, `useMockAuth: false` (default). `authRepositoryProvider`'s wiring selects the remote data source based on these flags with `useMockAuth` checked first (see its own doc comment: *"Checked before useFirebaseAuth"*), but since it is false in the app's actual config, **`FirebaseAuthRemoteDataSource` is the live, real path for every login/register/logout/forgot-password call in the running app.** `DevMockAuthRemoteDataSource`'s seeded demo accounts (`citizen@taarak.dev`, `responder@taarak.dev`, `official@taarak.dev`, `command@taarak.dev`, `stateadmin@taarak.dev`, `sysadmin@taarak.dev` — with a `_showDemoAccounts` picker UI in `LoginScreen` that only renders when `useMockAuth` is true) **do not exist as real Firebase accounts** and cannot be used to log into the deployed app — this was confirmed directly this session when investigating a "forgot password not working" report: these demo emails have no corresponding Firebase Authentication user.

## Login

`LoginScreen` (`AutofillGroup`-wrapped, `autofillHints: [AutofillHints.email]` / `[AutofillHints.password]`) → `AuthController.login(email, password)` → `AuthRepositoryImpl.login()` → `FirebaseAuthRemoteDataSource.login()`:
1. `FirebaseAuth.signInWithEmailAndPassword(email, password)`.
2. On success, reads the matching `users/{uid}` Firestore document for `name`/`email`/`role`. **If that document is missing (even though the Firebase Auth account exists), login fails with `NotFoundFailure('No profile found for this account — contact a system admin')`** — this is a real, reachable failure mode (verified this session: it's exactly what happens if a `users/{uid}` doc is deleted without also deleting the underlying Auth account).
3. On success, `AuthSession(user: AppUser(id, name, email, role), token)` is returned; `AuthRepositoryImpl` persists it via `AuthLocalDataSource` (backed by `flutter_secure_storage`) before returning.
4. `AuthController.login()` sets `state = AsyncData(session)` on success only — a failed login leaves the controller's state untouched (still signed-out), and the screen surfaces `failure.message` inline.

## Registration

`RegisterScreen` → `AuthController.register(name, email, password)` → `FirebaseAuthRemoteDataSource.register()`: `createUserWithEmailAndPassword`, then `user.updateDisplayName(name)`, then writes `users/{uid}` = `{name, email, role: 'citizen'}` directly. **Public self-registration can only ever create a Citizen account** — there is no UI path to self-select a different role; the `role` field is hardcoded to `UserRole.citizen.name` in this code path, by explicit design (comment: *"Public self-registration is always Citizen; Field Responder, Official and Admin accounts are provisioned separately"*).

## Forgot password (built this session)

`ForgotPasswordScreen` → `AuthController.sendPasswordResetEmail(email)` → `AuthRepositoryImpl.sendPasswordResetEmail()` → `FirebaseAuthRemoteDataSource.sendPasswordResetEmail()` → `FirebaseAuth.sendPasswordResetEmail(email: email)`. **Verified directly against the live Firebase project this session**: this project has "Improved Email Privacy" enabled in Firebase Auth settings (`emailPrivacyConfig.enableImprovedEmailPrivacy: true`), so this call returns success identically whether or not the email is registered — confirmed by a direct REST call comparison against a real vs. a fabricated email, both returning the same response shape. The UI's success copy (*"If an account exists for X, a password reset link is on its way"*) is written to be honest about this, not to imply the email definitely exists.

## Logout

`AuthController.logout()` → `AuthRepositoryImpl.logout()` → `AuthLocalDataSource.clearSession()`; state set to `AsyncData(null)`. The home screen's logout button calls `context.go('/login')` explicitly afterward (not just relying on the reactive redirect) specifically because `go()` replaces the entire navigation stack, so no authenticated screen remains reachable via the back button — a deliberate choice per its own inline comment.

## Session persistence

`AuthLocalDataSource` wraps `flutter_secure_storage` (`SecureKeyValueStore` abstraction in `lib/core/storage/`). `AuthController.build()` calls `AuthRepository.restoreSession()` once at app startup — this is the read that `TaarakApp` waits on (showing `_SplashScreen`) before ever constructing the real router, so no route-guard logic has to reason about an in-flight session-restore state (see `01_ARCHITECTURE.md`).

## Token handling

`AuthSession.token` is populated from `user.getIdToken()` (a Firebase ID token) on both login and register. **Verify in `docs/modules/core_infrastructure.md` / `docs/modules/sync.md` whether this token is actually attached to any outgoing request** — Firestore/Firebase Auth SDK calls authenticate via the SDK's own internal session, not by manually attaching this token to headers, so this field's only confirmed live consumer, absent further evidence, is `ApiClient` (for the dormant `backend/`-stub path). Mark as **UNKNOWN — requires verification** whether anything in the live Firebase path actually reads `AuthSession.token`.

## Roles and permissions (see also `docs/modules/admin.md` for the runtime-override mechanism)

Six `UserRole` values, each mapped to a `const Set<Permission>` in `lib/features/auth/domain/user_role.dart` (`rolePermissions`), no role hierarchy/inheritance. As of this session, a System Admin can additionally *override* any role's effective permission set at runtime via `/admin/permissions` (`RolePermissionOverrides`, persisted to Firestore `config/role_permissions`, consulted by both the route guard and `HomeScreen`'s quick-action visibility) — so a role's *actual* granted permissions at any moment are `RolePermissionOverrides.effectivePermissionsFor(role)`, which falls back to the hardcoded `rolePermissions[role]` when no override exists for that role. Two permissions (`manageAccounts`, `managePermissions`) can never be removed from `systemAdmin` through this screen, specifically to prevent every admin being permanently locked out.

## Authorization / protected routes

Enforced centrally by `computeRedirect()` — see `06_ROUTING.md` for the full mechanism and route table. There is no per-widget/per-button authorization check duplicated elsewhere in the app beyond `HomeScreen`'s quick-action visibility (which mirrors, but does not replace, the route guard — a user without a permission simply never sees the button, and would additionally be redirected to `/unauthorized` if they somehow navigated to the route directly).

## Credential storage

Passwords are never stored by the app itself — Firebase Auth owns credential storage and hashing (SCRYPT, per the live project's Identity Toolkit config verified this session) entirely outside this codebase. The only locally-persisted auth artifact is the post-login `AuthSession` (id/name/email/role/token) in secure storage.

## Error handling

Every `AuthRemoteDataSource` method returns `Result<T>` (never throws across the data-source boundary); `FirebaseAuthRemoteDataSource._mapAuthException()` translates specific `FirebaseAuthException.code` values (`user-not-found`/`wrong-password`/`invalid-credential` → `UnauthorizedFailure`; `email-already-in-use` → `ValidationFailure`; `weak-password` → `ValidationFailure`; `invalid-email` → `ValidationFailure`; `network-request-failed` → `NetworkFailure`; anything else → `UnknownFailure(error.message)`) into the app's own `Failure` hierarchy, so every auth screen displays a real, specific, user-facing message rather than a raw exception string.

## Demo/mock vs. real — explicit summary

| Path | Status |
|---|---|
| `FirebaseAuthRemoteDataSource` | **REAL** — live Firebase project, verified this session |
| `DevMockAuthRemoteDataSource` | **DEMO/MOCK** — in-memory, only reachable when `AppConfig.useMockAuth == true`, which never happens in the app's actual constructed config |
| `ApiAuthRemoteDataSource` | **UNUSED** in the running app — implemented against `backend/`'s stub API, never selected |
