# MODULE: Routing

## Purpose

This module answers "how do I get from A to B without crossing a known hazard zone or a reported road blockage, and how do I get there safely if the direct path does cross one." It is the evacuation/navigation planning engine: given an origin and destination, it either returns the direct path (if safe) or computes a detour, tries a real road-network provider first and falls back to a straight-line/detour estimate if that's unavailable, caches the result for offline re-display, and can plan a whole habitation's evacuation route to its top-ranked relocation shelter (feeding off the `relocation` module's output, which is out of this module's documented scope). It does not decide *where* people should evacuate *to* — that's the relocation module's job — it only plans *how* to get there safely.

## User-facing functionality

- **Citizen** (implicitly, via `viewSheltersRoutes`/`viewRiskMap`): tapping a shelter marker on the Risk Map (`map` module, `RiskMapScreen._routeToShelter`) triggers `RoutingService.planRoute()` from the citizen's current GPS position to that shelter; the resulting route renders as a polyline on the map, and a snackbar reports whether it's "clear of known hazards" or "passes near a hazard zone, proceed with caution."
- **Field Responder** (`navigateToIncident`): tapping "Navigate to incident" on `FieldIncidentDetailScreen` (field_response module) triggers the same `RoutingService.planRoute()` from the responder's GPS position to the incident's location, then pushes to `/map` to show the result.
- This module has **no screen of its own** — it is a pure service layer triggered from map and field_response screens; there is no `presentation/` folder in `lib/features/routing/`.

## Entry points

This module owns no route in `lib/app/router.dart`'s route table and has no entry in `defaultRoutePermissions` — it is invoked programmatically from other modules' screens, not navigated to directly:

- `RiskMapScreen._routeToShelter()` (map module) → `ref.read(routingServiceProvider).planRoute(...)`.
- `FieldIncidentDetailScreen._navigate()` (field_response module) → same provider, same method.
- `RelocationPlanningService`/command screens (outside documented scope) call `RoutingService.planEvacuationRoute()`/`planEvacuationRoutesForAllHabitations()` to route habitations to their top relocation candidates in bulk.

## Architecture

Domain / application layering only — no `presentation/` folder, no `data/` folder (persistence delegated to `LocalRouteRepository` in `lib/core/database/repositories/`, outside this module):

- **domain/** — `RouteCandidate`/`RoutePlan` (one candidate path plus the overall plan with alternatives), `RouteSegmentAssessment` (per-leg hazard/blockage verdict).
- **application/** — `RiskAwareRoutingEngine` (pure deterministic core: given points + hazard/blockage data, decide if a path is safe and build detours), `RoutingService` (orchestration: fetch current hazard/incident data, try a real road-network provider, fall back to the engine's straight-line/detour geometry, cache the result, and the habitation-evacuation convenience methods), `routing_providers.dart` (Riverpod wiring, including the `RoadNetworkProvider` that reaches out to an external OSRM server — see below).

## Files in this module

### `lib/features/routing/application/risk_aware_routing_engine.dart`
- **Purpose:** The deterministic core. There is no real road-network graph baked into this engine itself — its own doc comment is explicit: *"There's no real road-network graph available (that would mean an external routing service/API key ... and which cuts against the offline-first goal) — so a 'route' here is a straight-line path through a small number of waypoints."* Strategy: try the direct origin→destination line; if any segment is hazard-exposed or blocked, try a perpendicular-offset detour waypoint on each side of the line and recommend whichever is safe (preferring the shorter one if both are safe, or if neither fully clears the obstruction).
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `RiskAwareRoutingEngine` — `planRoute({origin, destination, hazardZones, blockedRoadIncidents, now})` → `RoutePlan` (straight-line/detour logic); `assessRoadRoute({roadPoints, hazardZones, blockedRoadIncidents, etaSecondsOverride})` → `RouteCandidate` (assesses a *real* road polyline, typically from a `RoadNetworkProvider`, against the same hazard/blockage rules — same engine, different geometry source; throws `ArgumentError` if given fewer than two points, "a programming error, not a silent no-op" per its own test). Constants: `defaultSpeedMetersPerSecond = 8.33` (~30 km/h flat-speed ETA estimate), `blockedRoadProximityMeters = 300` (a path is "blocked" if it comes within 300m of a reported blockage incident), `detourOffsetFraction = 0.35`, `segmentSampleCount = 20` (straight-line samples per segment), `roadRouteSamplesPerSegment = 2` (fewer samples for real road geometry, since consecutive road points are already close together, unlike a straight-line segment that can span kilometers).
- **Notable imports:** `core/gis/point_in_polygon.dart` (hazard-zone crossing check), `core/gis/geometry_codec.dart` (`decodePolygonPoints`).
- **Depends on:** `RouteCandidate`/`RoutePlan`/`RouteSegmentAssessment` (this module's own domain types), `LocalHazardZone`/`LocalIncident` (Drift rows, read-only). **Depended on by:** `RoutingService`, `routing_providers.dart` (`riskAwareRoutingEngineProvider`).
- **State:** none (pure, no I/O — takes hazard/incident lists as parameters rather than reading a repository itself).
- **External communication:** none.
- **Demo/mock content:** none — this is real routing logic, not a placeholder, though its geometry model (straight lines + one detour waypoint) is a deliberate simplification given no road-network graph was available when it was written.

### `lib/features/routing/application/routing_providers.dart`
- **Purpose:** Riverpod wiring for the engine, the real road-network provider, and the orchestrating service.
- **Status:** IMPLEMENTED.
- **Key providers:** `riskAwareRoutingEngineProvider`, `roadNetworkProviderProvider` (constructs `OsrmRoadNetworkProvider`, see below), `routingServiceProvider` (wires `RoutingService` with every repository it needs plus the engine and road-network provider).
- **Depends on:** `core/providers/core_providers.dart` (six repository providers), `core/routing/osrm_road_network_provider.dart`, `core/routing/road_network_provider.dart` (both outside this module, in `core/`). **Depended on by:** `RiskMapScreen`, `FieldIncidentDetailScreen`.

### `lib/features/routing/application/routing_service.dart`
- **Purpose:** Orchestrates M11: fetches current hazard zones and blocked-road incidents from the local cache, tries a real road-network provider first (`_tryRoadSnappedPlan`), falls back to the engine's straight-line/detour geometry if no provider is configured, offline, or the request fails, then caches the recommended route — "the 'cached last-known routes' the acceptance criterion calls out."
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `RoutingService` — `planRoute({origin, destination, now})` → `Result<RoutePlan>` (the main entry point; always writes/updates a `LocalRoute` cache row regardless of which geometry source won); `getCachedRoute({origin, destination})` → `Result<LocalRoute>` (offline/no-recompute read); `planEvacuationRoute(habitationId, {now})` → `Result<RoutePlan>` (routes a habitation to the top candidate from its current relocation plan — fails with `ValidationFailure` if no relocation plan or no candidates exist yet, "run M10 first"); `planEvacuationRoutesForAllHabitations({now})` → `List<RoutePlan>` (bulk version, skips habitations whose relocation plan says zero population needs to move). `routeCacheKey(origin, destination)` — free function, derives a cache key from endpoints rounded to ~5 decimal places (~1m) so repeated queries for the same pair hit the same cached row.
- **Notable imports:** `core/routing/road_network_provider.dart`/`road_route.dart` (the external-provider abstraction), `map/domain/road_blockage.dart` (`roadBlockageIncidentType`, filters incidents to just this type).
- **Depends on:** `LocalHazardZoneRepository`, `LocalIncidentRepository`, `LocalRouteRepository`, `LocalHabitationRepository`, `LocalRelocationPlanRepository`, `LocalShelterRepository`, `RiskAwareRoutingEngine`, `RoadNetworkProvider?` (optional — constructor accepts `null`, in which case it always falls back to the engine directly). **Depended on by:** `routingServiceProvider`, both callers listed under Entry points, and the relocation module (out of scope) for bulk evacuation routing.
- **State:** reads `local_hazard_zones`, `local_incidents`, `local_habitations`, `local_relocation_plans`, `local_shelters`; writes/upserts `local_routes` (with an incrementing `version` per cache key).
- **External communication:** indirectly, via the injected `RoadNetworkProvider` — see `OsrmRoadNetworkProvider` below (in `core/routing/`, outside this module but wired in by `routing_providers.dart`). No direct Firestore access; a cached `LocalRoute` is **not** currently enqueued to the sync queue anywhere in this service (confirmed by reading the full file — no `SyncQueueDao` reference), so routes are local-cache-only and do not sync to other devices.

### `lib/features/routing/domain/route_candidate.dart`
- **Purpose:** `RouteCandidate` — one candidate path (points, per-segment assessments, distance, ETA), with `isSafe` computed as "every segment is safe." `RoutePlan` — the engine's full output for one origin/destination pair: the recommended primary route plus whichever other candidates were considered ("alternatives"), a `modelVersion` string, and `plannedAt`.
- **Status:** IMPLEMENTED. Also defines `const String routingModelVersion = '1.0.0'` — a versioning convention shared with the risk/vulnerability/capacity/relocation engines elsewhere in the app, "bump when the routing/detour formula changes."
- **Depends on:** `RouteSegmentAssessment`. **Depended on by:** `RiskAwareRoutingEngine`, `RoutingService`, `RiskMapScreen`/`FieldIncidentDetailScreen` (pattern-match on `Result<RoutePlan>`).

### `lib/features/routing/domain/route_segment_assessment.dart`
- **Purpose:** One leg of a candidate route — `start`, `end`, `isHazardExposed`, `isBlocked`, `reasons: List<String>` (human-readable strings like "Crosses a landslide hazard zone" or "Passes within 210m of a reported road blockage"). `isSafe` computed as `!isHazardExposed && !isBlocked`.
- **Status:** IMPLEMENTED.
- **Depended on by:** `RouteCandidate`, `RiskAwareRoutingEngine._assessSegment`.

## Data Models

- **`RouteCandidate`** — `points: List<LatLng>`, `segments: List<RouteSegmentAssessment>`, `distanceMeters: double`, `etaSeconds: int`; computed `isSafe`.
- **`RoutePlan`** — `origin: LatLng`, `destination: LatLng`, `primaryRoute: RouteCandidate`, `alternativeRoutes: List<RouteCandidate>`, `modelVersion: String`, `plannedAt: DateTime`.
- **`RouteSegmentAssessment`** — `start: LatLng`, `end: LatLng`, `isHazardExposed: bool`, `isBlocked: bool`, `reasons: List<String>`; computed `isSafe`.
- **`LocalRoute`** (Drift row, `core/database/tables/local_routes_table.dart`) — `id` (the `routeCacheKey`), `originLat/Lng`, `destLat/Lng`, `polylineJson`, `distanceMeters` (default 0), `etaSeconds` (default 0), `isSafe` (default true), `isRoadSnapped` (default false — distinguishes real road geometry from the straight-line/detour fallback for map rendering), `cachedAt`, `version`.
- **`RoadRoute`** (external-provider result type, `core/routing/road_route.dart`, outside this module) — `points`, `distanceMeters`, `etaSeconds`.

## Services / Repositories

- **`RiskAwareRoutingEngine`** (pure engine) — the deterministic detour/safety logic, described above.
- **`RoutingService`** (orchestrator) — read hazards/incidents, try road provider, fall back to engine, cache result; also the habitation-evacuation convenience methods.
- **`OsrmRoadNetworkProvider`** (`lib/core/routing/osrm_road_network_provider.dart`, outside this module's file list but load-bearing for it — read for accuracy since `routing_providers.dart` wires it in directly): the real `RoadNetworkProvider` implementation, backed by **OSRM's public demo routing server** (`https://router.project-osrm.org/route/v1/driving`) via `dio`. Its own doc comment is explicit that this public server "is explicitly documented (by its own operators) as being for evaluation/demo traffic only, not production load — fine for this app's current stage, but a real deployment should point `baseUrl` at a self-hosted OSRM/Valhalla instance or a commercial Directions API instead." Checks `NetworkInfo.isConnected` before attempting a request and returns `NetworkFailure` immediately if offline; on a `DioException` or an unparseable response, logs via `AppLogger` and returns `Result.failure` (`NetworkFailure`/`UnknownFailure`/`ServerFailure`) rather than throwing, so `RoutingService._tryRoadSnappedPlan` can cleanly fall back to the straight-line engine. **This is a real external network dependency** — every routing request that reaches a connected device first tries an unauthenticated HTTPS call to a third-party public demo server before falling back to the offline engine.

## Routes owned by this module

None. This module has no `presentation/` folder and no entry in `lib/app/router.dart` or `defaultRoutePermissions`. It is invoked as a service from the `map` and `field_response` modules' screens (see Entry points above).

## Module Data Flow

Field Responder taps "Navigate to incident":

```
FieldIncidentDetailScreen._navigate(incident)          [field_response module]
  → ref.read(routingServiceProvider).planRoute(
        origin: <responder's GPS fix, from locationStatusProvider>,
        destination: LatLng(incident.latitude, incident.longitude))
      RoutingService.planRoute()
        → LocalHazardZoneRepository.getAll()
        → LocalIncidentRepository.getAll() → filter to roadBlockageIncidentType
        → _tryRoadSnappedPlan()
            → OsrmRoadNetworkProvider.fetchRoute(origin, destination)   [external HTTPS call]
                success → RiskAwareRoutingEngine.assessRoadRoute(roadPoints, hazardZones, blockedRoadIncidents)
                         → RouteCandidate (real road geometry, engine-assessed for hazard/blockage)
                         → if unsafe, also compute the straight-line engine's detour as an alternative
                failure/offline/no-provider → null
        → if road-snapped plan is null:
            RiskAwareRoutingEngine.planRoute(origin, destination, hazardZones, blockedRoadIncidents)
              → straight-line direct candidate; if unsafe, two perpendicular-offset detour candidates,
                pick the safer/shorter as primaryRoute
        → routeCacheKey(origin, destination) → LocalRouteRepository.getById() (for version) → .save(LocalRoute)
        → Result.success(RoutePlan)
  → on Success: ref.invalidate(routesProvider)   [map module — re-renders the new route]
  → context.push('/map')   [guarded by Permission.viewRiskMap — see map.md for the fix that makes this reachable
                             for a Field Responder]
```

## Current Status

**Working.** Both the deterministic straight-line/detour engine and the real-road-network integration path are implemented, exercised by real service-layer logic (not stubs), and covered by tests using an in-memory Drift database and a scripted `RoadNetworkProvider` fake. The OSRM integration is a genuine external dependency (a live HTTPS call to a public third-party server), not a mock — but it is explicitly a demo/evaluation-tier public server, not production infrastructure, per the provider's own doc comment.

## Known Limitations

- **No real road-network graph of its own** — the offline fallback engine (`RiskAwareRoutingEngine`) always produces a straight line or a single-detour-waypoint path, never actual turn-by-turn road geometry, when no road-network provider is reachable (offline, or the OSRM call fails).
- **The only real road-network provider wired in is a public OSRM demo server** (`router.project-osrm.org`), explicitly not rated for production traffic by its own operators. There is no API key, quota management, or self-hosted fallback configured — a production deployment would need to swap `OsrmRoadNetworkProvider.baseUrl` (or the whole `RoadNetworkProvider` implementation) for a self-hosted instance or a commercial Directions API, which the code's own comments call out as the expected future path.
- **ETA is a flat-speed estimate** (`8.33 m/s`, ~30 km/h) for any straight-line/detour route; only a real road-network provider's own duration is used when available (`etaSecondsOverride`).
- **Cached routes (`LocalRoute`) are not enqueued to the sync queue** by `RoutingService` — confirmed by reading the full file, no `SyncQueueDao` is referenced or injected. Routes are local-cache-only per device; they do not propagate to Firestore or other devices, unlike hazard zones, shelters, incidents, and habitations, which all explicitly enqueue sync entries in their own modules' services.
- **Detour logic tries exactly one perpendicular offset on each side** of the direct line — it does not iterate to find a wider detour if both single-offset candidates remain unsafe; in that case it just picks whichever detour is safer or shorter, which may still be marked unsafe.

## Test Coverage

`test/features/routing/` contains two files:

- **`risk_aware_routing_engine_test.dart`** — thorough coverage of the pure engine: clear path used directly; a blocked road forces a detour (explicitly labeled as covering "the acceptance criterion"); a hazard zone crossing the direct path also forces a detour, and the detour is verified actually safe (not just different); segments carry human-readable reasons when unsafe; distance/ETA are positive for a real route; `modelVersion` is present; a far-away incident does not force a detour; a full `assessRoadRoute` group covering: a real road polyline correctly assessed against a hazard zone it passes through (explicitly labeled "the acceptance criterion" for real-road-geometry assessment), a route avoiding all hazards is safe, an ETA override is honored, ETA falls back to the flat-speed estimate without an override, a blockage on a real road route is detected, and fewer than two points throws `ArgumentError`.
- **`routing_service_test.dart`** — covers: a planned route is cached and re-readable; re-planning the same endpoints increments the cached version; an uncached pair returns failure; a `_ScriptedRoadNetworkProvider` fake used to test the road-provider integration: a successful road route is cached as road-snapped with the real geometry and ETA; a failing provider falls back to the straight-line engine; an unsafe road route still surfaces the straight-line detour as an alternative; a road route of fewer than two points falls back to the straight-line engine; `planEvacuationRoute` routes a habitation to its top relocation candidate, fails cleanly with no plan or no candidates; `planEvacuationRoutesForAllHabitations` skips habitations with zero population to relocate.

**Not covered by any test in `test/features/routing/`:** `RoutingService`'s own tests exercise the road-provider integration only through `_ScriptedRoadNetworkProvider`, a hand-written fake that bypasses the real HTTP/JSON-parsing code in `OsrmRoadNetworkProvider` entirely. `OsrmRoadNetworkProvider` itself does have a dedicated test — `test/core/routing/osrm_road_network_provider_test.dart` — but that file lives under `lib/core/routing/`'s own test path, outside `test/features/routing/`, so it was not part of this module's directory but is worth knowing about for anyone auditing the live-network-call code path. `routing_providers.dart` has no dedicated provider-wiring test.
