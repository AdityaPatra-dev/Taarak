# AI Handover Summary

Read this first if you're picking up this project cold. Everything here is cross-referenced to a longer document in this same `docs/` folder — treat this as the map, not the territory.

## Project purpose

TAARAK is a Flutter-based, offline-first disaster-management application built for Smart India Hackathon 2026, problem statement 26191: dynamically identify hazard "Red Zones" and give disaster-management authorities actionable relocation/response guidance, combining hazard intensity, population vulnerability, and disaster history. Full detail: `00_PROJECT_OVERVIEW.md`.

## Target users

Six independently-permissioned roles: Citizen, Field Responder, Local Official, District/Command, State/Admin, System Admin. No role hierarchy — a higher-level role does not automatically inherit a lower one's permissions. Full detail: `00_PROJECT_OVERVIEW.md`, `10_AUTHENTICATION.md`.

## Current architecture (short)

Feature-first Flutter app (`lib/features/<name>/{domain,application,data,presentation}/`), Riverpod for state and dependency wiring, go_router for centrally permission-gated navigation, Drift (typed SQLite) as the local offline-first database, real live Firebase (Auth + Firestore) as the shared backend synced via a purpose-built version-conflict-resolving sync queue. Scoring logic (risk/capacity/vulnerability/relocation-priority) is pure, deterministic Dart with explicit weighted factors — never an LLM or fabricated number. Full detail: `01_ARCHITECTURE.md`.

## Exact technology stack

Flutter/Dart 3, `flutter_riverpod` 2.6.1, `go_router` 14.6.2, `drift` 2.31.0, `firebase_auth`/`cloud_firestore`/`firebase_core` (6.x/6.x/4.x), `google_maps_flutter` 2.18.0, `dio` 5.7.0, `flutter_local_notifications` 22.3.0. No AI/ML package of any kind. Full detail: `02_TECH_STACK.md`.

## Main modules (29 feature modules + core infrastructure)

Identity/access: `auth`, `admin`, `home`, `profile`, `audit`.
Disaster-science pipeline: `hazards`, `risk`, `vulnerability`, `capacity`, `relocation`, `susceptibility` (stub), `environmental`, `fusion` (incident dedup, unrelated to hazard fusion despite the name).
Field operations: `map`, `routing`, `shelters`, `reporting`, `verification`, `field_response`, `habitations`.
Command/comms: `alerts`, `dashboard`, `command`, `state_admin`, `disaster_events`, `sms_prototype` (simulation), `device_relay` (simulation), `notifications`.
Infrastructure: `sync`, `lib/core/` (database, network, gis, location, media, error, providers, repository, routing, storage, config, logging), `lib/app/` (router, route_guard, app shell), `lib/shared/`.
Full detail per module: `docs/modules/<name>.md`.

## Important files (the ones worth reading first, in order)

1. `lib/app/app.dart` — startup, root-lifetime providers.
2. `lib/app/router.dart` + `lib/app/route_guard.dart` — the entire navigation/permission surface.
3. `lib/features/auth/domain/{user_role,permission}.dart` — the RBAC model.
4. `lib/core/database/app_database.dart` — the entire local schema (18 tables, schema v11).
5. `lib/features/relocation/application/relocation_priority_service.dart` — the app's most important cross-module orchestration, and its scoring pipeline's only production trigger (see gaps).
6. `firestore.rules` — the real security boundary (route/UI gating is convenience, not enforcement).

## State management

Riverpod, exclusively. `Provider<T>` for dependency wiring (the DI mechanism — no separate DI framework), `FutureProvider.autoDispose<T>` for recompute-on-open screen data, one `AsyncNotifierProvider` (`authControllerProvider`) for genuinely mutable session state, and four `Provider.autoDispose<void>` triggers watched once at the app root for background behavior (sync-on-reconnect, sync-polling, notification-watching, permission-override warming). Full detail: `05_STATE_MANAGEMENT.md`.

## Routing

go_router, one flat route list (33 routes), centrally gated by a pure `computeRedirect()` function consulting each user's effective (role-default + admin-override) permission set. Full route table: `06_ROUTING.md`.

## Backend

Real, live Firebase project `taakrak-d9ed0` (Auth + Firestore) — confirmed by direct API inspection this session, not assumed from config files. A second, dormant backend candidate (`backend/`, a `shelf` Dart stub + matching `Api*` client classes) exists in source but is never selected at runtime. Full detail: `08_API_DOCUMENTATION.md`.

## Database

Drift (typed SQLite), 18 tables, schema version 11, destructive migration strategy (no data-preserving upgrades). Full detail: `09_DATABASE_STORAGE.md`, `docs/modules/core_database.md`.

## APIs

Firebase Auth SDK, Cloud Firestore SDK, Google Maps SDK (real key, unrestricted), Open-Meteo weather REST API (real, confirmed, but its fetch trigger's production call site is unconfirmed), OSRM public demo server (routing). No AI/LLM API anywhere. Full detail: `08_API_DOCUMENTATION.md`.

## Authentication

Firebase Auth, email/password. Public self-registration is Citizen-only by hard structural design (no `role` parameter exists on the registration call path). A dormant in-memory mock-auth path exists but is never selected. Full detail: `10_AUTHENTICATION.md`.

## Offline behavior

Genuinely offline-first for entity data (verified, not just claimed): local-first writes, a version-based conflict-resolving sync queue, two automatic triggers (reconnect + ~45s admin-configurable poll) plus a manual "Sync now." Auth and the three `config/*` documents are the honest exception — they require connectivity. Full detail: `11_OFFLINE_FIRST.md`.

## Demo functionality — everything still mocked/simulated, in one place

`DevMockAuthRemoteDataSource` (dormant), `HazardSusceptibilityModel`'s only implementation (deliberate `null` stub, disconnected), `DemoMapDataSeeder` (dead code, no call site), `sms_prototype`'s transport (loopback simulation), `device_relay`'s transport (loopback simulation), `backend/` + its `Api*` client classes (dormant). **Full, authoritative list with evidence**: `12_DEMO_MOCK_AUDIT.md` — read this before claiming any capability is "real."

## Known problems (the ones that matter most)

1. Risk/capacity/vulnerability assessment has exactly one production trigger (the Relocation Priority screen) — see `16_IMPLEMENTATION_GAPS.md` P1 #1.
2. Sync failures are silently swallowed with no logging or surfaced state — P1 #5.
3. Six features (`command`, `field_response`, `home`, `notifications`, `state_admin`, `susceptibility`) have zero test coverage; `core/database` has one test file against 39 source files.
4. Android release signing uses the debug keystore; `applicationId` is still the Flutter default — both block a real Play Store release.
5. The Google Maps API key has no application-identity restriction.

Full, prioritized list: `16_IMPLEMENTATION_GAPS.md`.

## Development priorities (what to work on next, in order)

Follow `17_DEVELOPMENT_GUIDE.md`'s "Where to start, by what you're trying to do" section — it maps each gap above directly to the file(s) to touch and the existing pattern to follow. Do not skip reading the "What NOT to touch without a deliberate decision" section first; several apparent gaps (debug signing, unrestricted Maps key, no role hierarchy, `backend/` left in place) are documented as deliberate, coupled, in-progress states rather than oversights.
