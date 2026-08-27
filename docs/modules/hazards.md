# MODULE: Hazards

## Purpose

This module is the front door for getting hazard information (landslide and flood zones) into the app's local cache in a trustworthy, machine-usable shape. It answers: "where are the currently known danger zones, how severe are they, and how much should we trust that data given its age?" Everything downstream that needs to know "is this habitation/shelter inside a mapped danger zone" (risk scoring, capacity-gap assessment, relocation candidate ranking) reads the output this module produces — it never reads raw, unvalidated hazard reports directly.

## User-facing functionality

- **Local Official** (permission `manageLocalIncidents`): can open "Report Hazard Zone" (`ReportHazardZoneScreen`), tap a point on the map to mark a hazard's epicenter, pick a hazard type (landslide/flood), a severity band (low/medium/high/critical), and an affected radius (from a policy-configured list of options), then submit. The screen converts the tap+radius into a circular polygon and submits it through the real ingestion pipeline.
- **System Admin** (implied by `HazardIngestionService.remove`, which takes an `adminId`): can remove a hazard zone as a content-moderation action; this is a service-level capability with an audit trail, though this module's file set contains no dedicated "moderate hazard zones" screen — the admin content-moderation screen (`lib/features/admin/presentation/content_moderation_screen.dart`, outside this module's scope) is presumably the caller.
- There is no screen in this module for *browsing/querying* hazard zones directly — `HazardQueryService` is a read API consumed by other modules (e.g. the map layer), not a screen of its own.

## Entry points

- Route `/hazards/report` in `lib/app/router.dart` → `ReportHazardZoneScreen`.
- `hazardIngestionServiceProvider` and `hazardQueryServiceProvider` (in `hazard_providers.dart`) are watched from outside this module by: `lib/features/map/application/map_data_providers.dart`, `lib/features/dashboard/application/dashboard_providers.dart`, `lib/features/dashboard/presentation/command_dashboard_screen.dart`, `lib/features/alerts/presentation/broadcast_alert_screen.dart`, `lib/features/map/presentation/risk_map_screen.dart`, `lib/features/sync/application/sync_providers.dart` (M17 sync), `lib/features/admin/presentation/content_moderation_screen.dart`, `lib/features/state_admin/application/state_admin_providers.dart`, `lib/features/disaster_events/application/disaster_event_providers.dart`, `lib/features/disaster_events/presentation/simulate_alert_screen.dart`.
- Internally to the scoring pipeline: `RiskEngine.assess()` (risk module), `CapacityGapEngine.assess()` / `isPointHazardExposed()` (capacity module), `RelocationEngine.plan()` (relocation module) all read `LocalHazardZone` rows that this module wrote.

## Architecture

Domain/application/presentation layering, no separate `data/` folder (persistence is delegated to `lib/core/database/repositories/local_hazard_zone_repository.dart`, outside this module):

- **domain/** — pure value types and enums with no I/O: `HazardType`, `HazardSeverity`, `HazardFreshness`, `RawHazardObservation` (input), `NormalizedHazardZone` (output of normalization).
- **application/** — orchestration and the one deterministic engine: `HazardNormalizer` (pure engine), `HazardIngestionService` (write orchestration: normalize → persist → enqueue sync → nothing else), `HazardQueryService` (read orchestration: fetch-all → in-memory filter), `hazard_providers.dart` (Riverpod wiring).
- **presentation/** — one screen, `ReportHazardZoneScreen`.

## Files in this module

### `lib/features/hazards/application/hazard_ingestion_service.dart`
- **Purpose:** Orchestrates writing a hazard observation into the local cache: runs it through `HazardNormalizer`, computes a monotonically increasing `version` per zone id (so re-ingesting the same id is traceable as an update, and doubles as M17's sync-conflict resolution signal), persists via `LocalHazardZoneRepository`, and enqueues a sync-queue entry. Also implements hard-delete for admin moderation with an audit-log entry.
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `HazardIngestionService` — `ingest({id, observation, now})` returns `Result<LocalHazardZone>`; `remove({id, adminId, reason, now})` returns `Result<void>` and always writes an audit-log row (`hazard_zone.removed`) plus a sync-queue delete entry.
- **Weights/formula:** N/A (not a scoring engine). Version logic: `nextVersion = (existing?.version ?? 0) + 1`.
- **Notable imports:** `core/database/audit_log_dao.dart`, `core/database/sync_queue_dao.dart` (both optional/nullable constructor params — the service degrades gracefully if either is omitted), `core/gis/geometry_codec.dart` (`encodePolygonPoints`).
- **Depends on:** `HazardNormalizer`, `LocalHazardZoneRepository`, `SyncQueueDao?`, `AuditLogDao?`. **Depended on by:** `hazard_providers.dart` (`hazardIngestionServiceProvider`), `ReportHazardZoneScreen`, and directly by several test files across other modules (`capacity`, `relocation`) which use it to seed hazard zones for their own tests.
- **State:** writes `local_hazard_zones` table (via repository), writes `sync_queue` and `audit_log` tables (both optional collaborators).
- **External communication:** none directly — sync propagation to Firestore is M17's concern, out of this module's scope; this module only enqueues the local sync-queue row.
- **Demo/mock content:** none.

### `lib/features/hazards/application/hazard_normalizer.dart`
- **Purpose:** The pure, deterministic core of hazard ingestion. Validates a `RawHazardObservation` (hazard type known, ≥3 boundary points, severity score in `[0,1]`, `observedAt` not in the future), buckets the raw severity score into a canonical `HazardSeverity`, classifies freshness, and computes a discounted confidence figure.
- **Status:** IMPLEMENTED. Explicitly documented as pure — "no I/O, no clock reads unless a caller wants 'now' to be something other than `DateTime.now`, which is why `now` is a parameter."
- **Key classes/functions:** `HazardNormalizer.normalize(observation, {now})` → `Result<NormalizedHazardZone>`; private `_bucketSeverity(score)`.
- **Exact formula:**
  - Severity bucketing: `score >= 0.85 → critical`, `>= 0.65 → high`, `>= 0.35 → medium`, else `low`.
  - Confidence: `baseConfidence = (sourceConfidence ?? 0.5).clamp(0,1)`; `confidence = baseConfidence * freshnessConfidenceFactor(age)`.
  - Rejects hazard types other than `landslide`/`flood` (case-insensitive).
- **Depends on:** `HazardType`, `HazardSeverity`, `HazardFreshness`/`freshnessConfidenceFactor`, `Failure`/`Result`. **Depended on by:** `HazardIngestionService`.
- **State:** none (pure).
- **External communication:** none.
- **Demo/mock content:** none.

### `lib/features/hazards/application/hazard_providers.dart`
- **Purpose:** Riverpod wiring for the module's two services and the normalizer.
- **Status:** IMPLEMENTED.
- **Key providers:** `hazardNormalizerProvider`, `hazardIngestionServiceProvider`, `hazardQueryServiceProvider`.
- **Depends on:** `core/providers/core_providers.dart` (`localHazardZoneRepositoryProvider`, `syncQueueDaoProvider`, `auditLogDaoProvider`). **Depended on by:** every screen/provider listed under Entry points.

### `lib/features/hazards/application/hazard_query_service.dart`
- **Purpose:** The read side — "hazard layer is queryable" by type and/or minimum freshness. Fetches the whole cached set and filters in memory (explicitly noted as acceptable "since the local hazard set is small").
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `HazardQueryService.query({hazardTypes, minFreshness, now})` → `Result<List<LocalHazardZone>>`.
- **Depends on:** `LocalHazardZoneRepository`, `HazardType`, `HazardFreshness`/`classifyFreshness`. **Depended on by:** `hazard_providers.dart`; not directly imported by the map/dashboard providers seen in this scan (those appear to query the repository directly instead — worth noting as a place `HazardQueryService` is under-used relative to its design intent).
- **State:** read-only.

### `lib/features/hazards/domain/hazard_freshness.dart`
- **Purpose:** Defines how stale an observation is, and how much that staleness should discount confidence.
- **Status:** IMPLEMENTED.
- **Exact thresholds:** `classifyFreshness(age)`: `age <= 6h → fresh`, `age <= 48h → aging`, else `stale`. `freshnessConfidenceFactor`: `fresh → 1.0`, `aging → 0.7`, `stale → 0.4`.

### `lib/features/hazards/domain/hazard_severity.dart`
- **Purpose:** Canonical severity band enum plus the numeric intensity weight risk scoring uses.
- **Status:** IMPLEMENTED.
- **Exact values:** `HazardSeverity.low/medium/high/critical`; `intensity`: `low → 0.25`, `medium → 0.5`, `high → 0.75`, `critical → 1.0` (midpoints of the normalizer's own bucket thresholds).

### `lib/features/hazards/domain/hazard_type.dart`
- **Purpose:** The closed set of hazard types the normalizer currently accepts.
- **Status:** IMPLEMENTED but deliberately narrow — only `landslide` and `flood`. Documented in-code as the extension point for a third hazard type.

### `lib/features/hazards/domain/normalized_hazard_zone.dart`
- **Purpose:** Output value object of normalization — validated, bucketed, confidence-scored, ready to persist.
- **Status:** IMPLEMENTED (plain data class, no logic).

### `lib/features/hazards/domain/raw_hazard_observation.dart`
- **Purpose:** Input value object — an unnormalized, untrusted hazard signal from whatever produced it (official entry, external feed, sensor).
- **Status:** IMPLEMENTED (plain data class).

### `lib/features/hazards/presentation/report_hazard_zone_screen.dart`
- **Purpose:** The only UI in this module. Lets a Local Official mark a hazard epicenter + radius on a map, pick type/severity, and submit through the real `HazardIngestionService`.
- **Status:** IMPLEMENTED and wired to the real pipeline (not a mock form — `_submit` calls `ref.read(hazardIngestionServiceProvider).ingest(...)` for real).
- **Key classes:** `ReportHazardZoneScreen` (stateful), private `_ReportHazardZoneScreenState`.
- **Notable behavior:** captures the zone as "epicenter + radius" (via `circlePolygonPoints`) rather than a freehand polygon — a deliberate simplification for speed of entry under pressure, still geometrically a real polygon. Radius options come from `AppPolicy` (state-admin configurable), defaulting to 500m if available. `source` is set to `'official:$officialId'` — traceable to the reporting user.
- **Depends on:** `hazardIngestionServiceProvider`, `hazardZonesProvider` (invalidated on success — this lives in `map_data_providers.dart`, outside this module), `AppPolicy`, `TaarakMapView`/`TaarakMapController` (map widgets), `locationStatusProvider` (for a fallback center), `currentUserProvider` (auth).
- **State:** local widget state only (`_center`, `_hazardType`, `_severity`, `_selectedRadiusMeters`, `_isSubmitting`).

### `test/features/hazards/hazard_ingestion_service_test.dart`
- **Purpose:** Verifies persistence of normalized fields, rejection of invalid observations (nothing written), and version incrementing on re-ingestion of the same id.
- **Status:** IMPLEMENTED, uses an in-memory Drift `NativeDatabase.memory()`.
- **Coverage:** valid ingest persists correctly-bucketed severity and version 1; invalid hazard type is rejected and the table stays empty; re-ingesting the same id bumps version to 2 and re-buckets severity.

### `test/features/hazards/hazard_normalizer_test.dart`
- **Purpose:** Exhaustive pure-function tests of `HazardNormalizer` — type validation (case-insensitivity, rejection), geometry validation (<3 points rejected), severity score range validation, `observedAt` future-timestamp rejection, the full severity-bucketing boundary table (0.0/0.34/0.35/0.64/0.65/0.84/0.85/1.0), and confidence computation (fresh keeps source confidence as-is, stale discounts it, missing confidence defaults to 0.5).
- **Status:** IMPLEMENTED, thorough — this is the most exhaustively tested file in the module.

### `test/features/hazards/hazard_query_service_test.dart`
- **Purpose:** Verifies unfiltered query returns everything, type filtering narrows correctly, and `minFreshness` filtering excludes stale entries.
- **Status:** IMPLEMENTED.

## Data Models

- **`RawHazardObservation`** — `hazardType: String`, `severityScore: double`, `boundaryPoints: List<LatLng>`, `source: String`, `observedAt: DateTime`, `sourceConfidence: double?`.
- **`NormalizedHazardZone`** — `hazardType: HazardType`, `severity: HazardSeverity`, `freshness: HazardFreshness`, `confidence: double`, `boundaryPoints: List<LatLng>`, `source: String`, `observedAt: DateTime`.
- **`LocalHazardZone`** (persisted row, defined in `core/database/app_database.dart`, referenced here since this module writes/reads it) — `id`, `hazardType`, `severity`, `geometryJson`, `source`, `observedAt`, `confidence`, `updatedAt`, `version`.

## Services / Engines / Repositories

- **`HazardNormalizer`** (pure engine) — validation + severity bucketing + confidence computation, formulas given above. No model-version constant of its own (hazard normalization isn't versioned the way risk/vulnerability/capacity/relocation are — worth noting as an inconsistency with the rest of the pipeline's "model version" convention).
- **`HazardIngestionService`** (orchestrator) — write path, version tracking, sync-queue + audit-log side effects.
- **`HazardQueryService`** (orchestrator) — read path with in-memory filtering.

## Module Data Flow

```
ReportHazardZoneScreen._submit()
  → HazardIngestionService.ingest(id, observation, now)
      → HazardNormalizer.normalize(observation, now) → Result<NormalizedHazardZone>
      → LocalHazardZoneRepository.getById(id)            (to compute nextVersion)
      → LocalHazardZoneRepository.save(LocalHazardZone)  (persist)
      → SyncQueueDao.enqueue(...)                         (M17 outbound sync)
  → ref.invalidate(hazardZonesProvider)                    (map/dashboard refresh, outside this module)

Downstream (other modules read the persisted LocalHazardZone rows directly via
LocalHazardZoneRepository.getAll(), not through HazardQueryService):
  RiskEngine.assess() / CapacityGapEngine.assess() / RelocationEngine.plan()
      → core/gis/hazard_exposure.isPointHazardExposed(point, hazardZones)
      → core/gis/point_in_polygon.isPointInPolygon(...)
```

## Current Status

**Working.** The full write path (screen → ingestion → normalization → persistence → sync-queue) is real and exercised end-to-end by tests using an in-memory SQLite database, not mocks. The read path (`HazardQueryService`) is implemented and tested but appears to be bypassed by at least the map/dashboard providers seen in this scan, which query `LocalHazardZoneRepository` directly rather than through this service — the service isn't dead code (tests exercise it directly), but its adoption outside its own module is unconfirmed from this module's files alone.

## Known Limitations

- Only two hazard types are normalized (`landslide`, `flood`); anything else is rejected outright, by design ("What Not to Build First").
- Hazard zones are recorded as a circle (epicenter + radius) from the screen, not a freehand polygon, even though the underlying data model supports arbitrary polygons.
- No model-version constant on `HazardNormalizer`/`NormalizedHazardZone`, unlike every downstream engine (risk/vulnerability/capacity/relocation all carry a `modelVersion` string) — an inconsistency, not necessarily a bug.
- `HazardIngestionService.remove` is a hard delete (not a soft-delete/tombstone), relying entirely on the sync-queue "delete" entry to propagate the removal to other devices.

## Test Coverage

Three test files, all using an in-memory Drift database rather than mocks — a real, if narrow, integration test:
- `hazard_normalizer_test.dart`: full coverage of the pure validation/bucketing logic, including exact boundary values for severity bucketing and freshness-based confidence discounting.
- `hazard_ingestion_service_test.dart`: persistence + rejection + version-increment behavior.
- `hazard_query_service_test.dart`: filter-by-type and filter-by-freshness behavior.

**Not covered by any test in this module:** `HazardIngestionService.remove()` (delete + audit-log path) has no dedicated test file in `test/features/hazards/`; `ReportHazardZoneScreen` has no widget test in this directory (UI is untested here — a widget/integration test may exist elsewhere in the repo but is outside `test/features/hazards/`).
