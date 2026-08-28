# Security Audit

Lightweight, code-level documentation pass — findings only, nothing exploited, no secret values reproduced. Verified directly against `firestore.rules`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`, `web/index.html`, and a repo-wide grep for common hardcoded-secret patterns.

## Hardcoded credentials / API keys

**Google Maps API key**: a real, live key is embedded directly in both `android/app/src/main/AndroidManifest.xml` (as the `com.google.android.geo.API_KEY` meta-data value) and `web/index.html` (in the Maps JS SDK `<script src="https://maps.googleapis.com/maps/api/js?key=...">` tag) — the same key value in both places. `SECRET PRESENT IN SOURCE — DO NOT COPY INTO DOCUMENTATION.`

- Per the project's own README (verified this pass): this key currently has **no application-identity restriction** — no Android package-name+SHA-1 restriction, no web HTTP-referrer restriction — deliberately, because a single Google Cloud API key can only carry one restriction *type*, and this key is shared between the Android and Web builds (which need different restriction types). It belongs to a Maps Platform trial project with no billing account attached.
- Risk: anyone who extracts this key from the APK or the web bundle's HTML source (trivial — it's plaintext in a static file) can use it against the same Google Cloud quota, from any app or website, until it's split into two properly-restricted keys.
- This is a known, already-documented gap (see `16_IMPLEMENTATION_GAPS.md`), not a new finding.

**Firebase client configuration** (`lib/firebase_options.dart`): contains real project identifiers and a Firebase Web API key. **This is not a security defect** — a Firebase *client* config, unlike a server API key, only identifies which project to talk to; it grants no access by itself. Real access control is enforced entirely by `firestore.rules` (audited below) and Firebase Authentication. This is standard, documented Firebase practice, and the project's own README correctly explains this distinction.

**Demo account passwords** (`DevMockAuthRemoteDataSource`, e.g. `'citizen123'`, `'sysadmin123'`): plaintext, hardcoded, but not a real secret exposure — these gate an in-memory mock auth path that is never selected in the app's actual running configuration (`AppConfig.useMockAuth` is always `false`; see `10_AUTHENTICATION.md`), and are already publicly documented in the project's own README as demo credentials. No real account or real data is protected by these values.

## Firestore security rules — full audit

`firestore.rules` gates 11 top-level collections/docs. Every rule was read in full this pass. General pattern, consistently applied: **reads are open to any signed-in user** (`isSignedIn()`) for every shared-state collection — a deliberate choice, documented inline, because the local-first sync engine pulls each collection into every device's cache unconditionally, so a narrower read rule would silently break sync for roles the UI doesn't screen-gate the read for. **Writes are role-scoped** via a `hasAnyRole([...])` helper that reads the caller's own `users/{uid}` document to determine their role — i.e., authorization is enforced server-side by re-deriving the caller's role from Firestore itself on every write, not merely trusted from client-supplied data.

| Collection | Read | Write | Notes |
|---|---|---|---|
| `users/{uid}` | Own doc, or `systemAdmin`/`districtCommand` | Create: self, role forced to `citizen`. Update: self (role unchanged) or `systemAdmin`. Delete: never. | A user cannot self-promote their own role — enforced server-side, not just client-side. |
| `local_incident_reports/{id}` | Any signed-in user | Create: any signed-in user. Update: `localOfficial`/`districtCommand`. Delete: never. | |
| `local_incidents/{id}` | Any signed-in user | Create/update: `localOfficial`/`districtCommand`. Delete: `systemAdmin` only (moderation). | |
| `local_hazard_zones/{id}` | Any signed-in user | Create/update: `localOfficial`/`districtCommand`/`stateAdmin`. Delete: `systemAdmin` only. | |
| `local_shelters/{id}` | Any signed-in user | Create/update/delete: `localOfficial` only. | Delete added alongside `ShelterManagementService.removeShelter` — a Local Official's own manage capability, not `systemAdmin` moderation like incidents/hazard_zones/alerts. |
| `local_alerts/{id}` | Any signed-in user | Create/update: `localOfficial` only. Delete: `systemAdmin` only. | |
| `local_damage_reports/{id}` | Any signed-in user | Create: `fieldResponder` only. Update/delete: never. | Field reports are treated as immutable once filed. |
| `local_resources/{id}` | Any signed-in user | Create/update: `districtCommand` only. Delete: never. | |
| `local_habitations/{id}` | Any signed-in user | Create/update: `localOfficial`/`districtCommand`/`stateAdmin`. Delete: never. | |
| `config/policy` | Any signed-in user | `stateAdmin` only. | |
| `config/role_permissions` | Any signed-in user | `systemAdmin` only. | Runtime RBAC-override document — see `docs/modules/admin.md`. |
| `config/technical` | Any signed-in user | `systemAdmin` only. | |

**No collection allows unrestricted delete except by `systemAdmin`**, and several collections (`local_habitations`, `local_damage_reports`, `local_resources`) don't allow *any* role to delete — a deliberate immutability choice for those record types, worth knowing before assuming a "remove" feature exists anywhere in the app for them. `local_shelters` used to be in this list too, but now allows `localOfficial` delete (see its row above).

**Missing authorization observed**: none found in the 11 rule blocks — every collection has an explicit, role-scoped write rule. The rules file's own header comment states it's meant to mirror `lib/app/route_guard.dart`'s permission table exactly, and spot-checking several entries against `06_ROUTING.md`'s route table confirms they do.

## Android release signing

`android/app/build.gradle.kts`'s `release` build type is explicitly signed with `signingConfigs.getByName("debug")` — confirmed directly this pass. This means **any `flutter build apk --release` produces an APK signed with the shared, machine-generated Android debug keystore**, not a real release key. This is documented in the project's own README as an intentional development-stage choice (reproducibility across contributor machines), not an oversight — but it is a real, unresolved blocker for any actual Play Store submission (a debug-signed APK cannot be uploaded to Google Play), and means anyone with the debug keystore could sign an update that Android would treat as coming from the same "developer" for a device that installed a debug-signed build.

## Application identity

`applicationId` / `namespace` in `android/app/build.gradle.kts` is still `com.example.taarak` — the Flutter-default placeholder, confirmed directly this pass. Also blocks Play Store submission, and means the Android app has no distinct, real identity to restrict the Maps API key against even after signing is fixed.

## Insecure HTTP

No `http://` (non-TLS) endpoint was found wired into any live code path. `AppConfig.apiBaseUrl` is `http://localhost:8080/api` — plaintext HTTP — but this only ever addresses the local, never-deployed `backend/` stub for local development, and is never reached in the app's actual configuration (`useFirebaseAuth: true` always wins — see `10_AUTHENTICATION.md`). Real traffic (Firebase Auth, Firestore, Google Maps) all uses Google-managed TLS by default via their respective SDKs.

## Sensitive data logging

Not exhaustively audited across all 269 `lib/` files in this pass — the per-module documents in `docs/modules/` note logging calls where directly observed during their own inspection. **UNKNOWN — requires verification**: whether any password, token, or full user PII is ever passed to `logger`'s output in a debug build. No such instance was directly observed in the files read for this cross-cutting audit, but this claim should not be read as an exhaustive guarantee.

## Client-side trust assumptions

The one genuine trust boundary worth naming precisely: **`route_guard.dart`'s permission gating is a UI/UX convenience, not the actual security boundary** — the real enforcement is `firestore.rules`, verified above to independently re-derive the caller's role server-side rather than trusting anything the client asserts. This is the correct architecture (a client-side-only check would be trivially bypassable), and this pass found no case where a Firestore write rule was *looser* than what the UI implies is possible — i.e., no case where a role could write something through a raw Firestore call that the app's own screens wouldn't have let them do anyway.

## Debug-only security bypasses

`AppConfig.isDevMode` (tied to Flutter's real `kReleaseMode`, not to `Environment`) gates the visibility of the SMS-prototype and Device-Relay quick-action buttons on `HomeScreen` — but, as noted in `06_ROUTING.md`, `route_guard.dart`'s redirect logic does **not** itself check `isDevMode` for `/sms-prototype`/`/device-relay`, only the underlying `sendSos` permission. In a **release** web build, a signed-in user holding `sendSos` (i.e. any Citizen) could still reach `/sms-prototype` or `/device-relay` by typing the URL directly, even though no button links to it. Since both of those modules are confirmed simulations with no real device I/O (per the command/comms module cluster's findings — no real SMS, no real Bluetooth/WiFi), the actual impact of this gap is low (nothing genuinely dangerous is reachable), but it is a real, minor inconsistency between the intended dev-only gating and what the route guard actually enforces — recorded in `16_IMPLEMENTATION_GAPS.md`.
