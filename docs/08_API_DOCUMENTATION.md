# API Documentation

Every external network call found across this documentation pass (cross-referenced from all module documents plus direct inspection of `lib/core/network/`, `lib/features/environmental/`, `lib/core/routing/`).

## Firebase Authentication

- **SDK**: `firebase_auth` (^6.6.0), not a raw REST/HTTP call — the app talks to Firebase Auth exclusively through the official Dart SDK.
- **Calls made**: `signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, `sendPasswordResetEmail`, `updateDisplayName`, `getIdToken`.
- **Calling file**: `lib/features/auth/data/firebase_auth_remote_data_source.dart`.
- **Auth**: N/A (this *is* the auth mechanism).
- **Status**: **PRODUCTION** — live project `taakrak-d9ed0`, verified directly this session via the Identity Toolkit Admin API.
- **Offline**: fails outright — no local fallback. See `10_AUTHENTICATION.md`.

## Cloud Firestore

- **SDK**: `cloud_firestore` (^6.9.0), official Dart SDK, not raw REST.
- **Collections/documents touched**: `users/{uid}`, `local_incident_reports`, `local_incidents`, `local_hazard_zones`, `local_shelters`, `local_alerts`, `local_damage_reports`, `local_resources`, `local_habitations`, `config/policy`, `config/role_permissions`, `config/technical` — full read/write rule per collection in `15_SECURITY_AUDIT.md`.
- **Calling files**: `FirestoreSyncTransport` (entity sync), plus small dedicated data sources for the three `config/*` documents and `users/{uid}` (`UserAdminDataSource`, `AppPolicyDataSource`, `RolePermissionOverridesDataSource`, `TechnicalConfigDataSource`).
- **Auth**: implicit via the signed-in Firebase Auth session; server-side authorization enforced by `firestore.rules`, independently re-deriving the caller's role (see `15_SECURITY_AUDIT.md`).
- **Status**: **PRODUCTION**.
- **Offline**: entity collections are cached locally via the sync engine (see `11_OFFLINE_FIRST.md`); the `config/*` documents and `users/{uid}` are read directly each time and have documented `.defaults`-style fallbacks for a failed/offline read (verify exact fallback per document in the relevant module doc).

## Google Maps

- **SDK**: `google_maps_flutter` (^2.18.0) for the map widget itself; a plain `<script src="https://maps.googleapis.com/maps/api/js?key=...">` tag in `web/index.html` for the web target's JS SDK.
- **Auth**: a real Google Cloud API key (see `15_SECURITY_AUDIT.md` — key value not reproduced here).
- **Status**: **PRODUCTION** (real key, real tile/map rendering) but **not restricted to this app's identity** — see `15_SECURITY_AUDIT.md`.
- **Offline**: map tiles require connectivity; no offline tile cache observed.

## Open-Meteo (weather / environmental data)

- **Base URL**: `https://api.open-meteo.com/v1/forecast` — confirmed by direct code inspection this session (the disaster-science-engine research pass read `lib/features/environmental/application/open_meteo_data_source.dart` directly).
- **Method**: HTTP GET, via `dio`.
- **Auth**: none — Open-Meteo's free tier requires no API key.
- **Calling file**: `lib/features/environmental/application/open_meteo_data_source.dart`.
- **Status**: **REAL, production-wired implementation** — confirmed to be the actual default data source, not a demo stub (a separate `DemoEnvironmentalDataSource` also exists in the same directory — verify in `docs/modules/environmental.md` which one is actually selected by the app's providers). **Important caveat, flagged directly by this session's research**: nothing observed in the codebase calls `EnvironmentalDataService.refreshForHabitation()` from any real screen/button — the real API integration exists and compiles, but may not currently be *invoked* anywhere outside its own tests. This should be treated as **PARTIALLY IMPLEMENTED — wired but not observably triggered by any user action**, not as "fully working end-to-end," until that call site is confirmed. See `docs/modules/environmental.md` for the authoritative detail and `16_IMPLEMENTATION_GAPS.md`.
- **Offline**: fails; no offline weather fallback beyond whatever was last cached locally (verify exact caching behavior in `docs/modules/environmental.md`).

## OSRM (road-network routing)

- `lib/core/routing/osrm_road_network_provider.dart` — confirmed by the infrastructure research pass to point at **OSRM's public demo server**, which is itself self-described (by OSRM's own project) as non-production infrastructure, not something this app operates. Status: **EXTERNAL DEPENDENCY on a third party's demo service** — functional for development/demo purposes, not something to depend on for real production load or uptime guarantees. See `docs/modules/routing.md` and `docs/modules/core_infrastructure.md` for the exact endpoint/request shape.

## The `backend/` stub API — not currently reachable by the running app

`ApiAuthRemoteDataSource` and `ApiSyncTransport` (in `lib/features/auth/data/` and `lib/features/sync/application/` respectively) implement calls against `AppConfig.apiBaseUrl` (`http://localhost:8080/api`) — a local Dart `shelf`/`shelf_router` server in `backend/`. Because `AppConfig.development().useFirebaseAuth` is always `true`, **neither of these classes is ever actually selected/invoked in the running app** — they exist as complete, compiling, historically-real code, confirmed **UNUSED / DEAD CODE in practice** (not deleted, per this documentation task's own "do not modify application code" constraint and the pubspec.yaml comment explicitly keeping `backend/` "for reference"). If reactivated (by changing `AppConfig`), the endpoints these classes call would need to be cross-referenced against `backend/lib/src/taarak_backend.dart`'s actual route definitions — not documented here since it is not a live path.

## No AI/LLM API of any kind

Confirmed by the absence of any AI/LLM package in `pubspec.yaml` and by direct inspection of the one module that could plausibly have one (`susceptibility/`) — its only implementation always returns `null`. There is no OpenAI/Gemini/Anthropic/any-LLM HTTP call anywhere in this codebase as of this documentation pass.
