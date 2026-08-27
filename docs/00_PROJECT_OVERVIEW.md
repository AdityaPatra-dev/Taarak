# Project Overview

## What this application is

TAARAK is a Flutter-based, offline-first disaster-management and disaster-decision-support application. It was built as a submission for Smart India Hackathon 2026, problem statement 26191 (Ministry of Home Affairs / NDRF Disaster Management Division, Software category): a system to dynamically identify and update multi-hazard "Red Zones" and provide actionable relocation/response guidance to disaster-management authorities, combining hazard intensity, population vulnerability, and disaster history.

Concretely, as verified against the running code (not the pitch), the application today lets an authenticated user, depending on their role:

- View a live map of mapped hazard zones (landslide/flood), shelters, and evacuation routes.
- Report a citizen-facing incident, send an SOS, or mark themselves safe.
- (As an official) mark a hazard zone's location and severity on the map, register a vulnerable "habitation" (a population center) with its population/access/infrastructure indicators, and manage shelter capacity.
- Have the app compute, from that real data, a **risk score** per habitation (combining hazard exposure and vulnerability), a **shelter capacity gap**, and a ranked **relocation priority queue** — a deterministic, weighted, explainable scoring pipeline, not a black box.
- Broadcast/receive emergency alerts, and (for a District/Command or State/Admin account) see an aggregated operational dashboard.
- Continue working with locally cached data and queued actions while offline, syncing automatically once connectivity returns.

## What it is not (verified, not assumed)

- It does not run any AI/ML model today. A `HazardSusceptibilityModel` extension point exists in the code, but its only implementation always returns `null` by design — there is no trained model. See `12_DEMO_MOCK_AUDIT.md`.
- It does not ingest real government hazard data (e.g. from the Geological Survey of India) automatically — hazard zones are entered by an official through the app's own report screen, or via a demo seeder for local development.
- It has no automated CI/CD pipeline — builds and deployments observed this session were manual, developer-run commands.

## Target users (from the app's own role model, `lib/features/auth/domain/user_role.dart`)

Six roles, each with an independently-scoped `Set<Permission>` (no implicit hierarchy — a District/Command account does not automatically inherit Local Official permissions):

| Role | Real-world analogue |
|---|---|
| Citizen | General public in a hazard-prone area |
| Field Responder | On-ground responder (e.g. NDRF/SDRF personnel, trained volunteers) |
| Local Official | Village/block-level disaster-management officer |
| District/Command | District Disaster Management Authority staff |
| State/Admin | State Disaster Management Authority staff |
| System Admin | The platform's own technical administrator (not a disaster-response role) |

## Current architecture, in one paragraph

A single Flutter codebase (Android/iOS/Web/desktop-scaffolded) using Riverpod for state and dependency wiring, go_router for centrally-permission-gated navigation, a local Drift (typed SQLite) database as the offline-first source of truth for most screens, and a real, live Firebase project (Authentication + Cloud Firestore) as the shared backend that local data syncs against through a purpose-built sync-queue engine. Business logic that produces a number an official will act on (risk score, capacity gap, relocation priority) is implemented as pure, deterministic, unit-tested Dart — not as a call to any external or AI service. Full detail in `01_ARCHITECTURE.md`.

## Where to go next in this documentation package

- `01_ARCHITECTURE.md` — full startup trace, layering rationale, honest inconsistencies.
- `02_TECH_STACK.md` — every real dependency, what it's actually for.
- `03_FILE_INDEX.md` — the complete repository file tree.
- `docs/modules/*.md` — one detailed document per feature module (29 feature modules + 6 infrastructure documents).
- `12_DEMO_MOCK_AUDIT.md` — a dedicated, consolidated list of every demo/mock/placeholder finding across the whole app.
- `16_IMPLEMENTATION_GAPS.md` — what's missing, prioritized.
- `18_AI_HANDOVER.md` — the fastest-path summary for another AI picking this project up cold.
