# MODULE: Map

## Purpose

This module renders the single interactive "Risk Map" that every other module hangs its geography on: hazard zones, shelters, incidents, habitations (with their risk/capacity/relocation scores), and recommended evacuation routes, all as layers on one Google Map. It answers "what's dangerous, what's safe, and where do I go" for a citizen, and doubles as the shared base-map component (`TaarakMapView` + the layer-builder functions in `map_overlay_layers.dart`) that the shelter-registration, habitation-registration, and hazard-reporting screens in other modules reuse for their own tap-to-place forms. It owns no write path of its own for hazards/shelters/incidents/habitations — those are owned by their respective modules (hazards, shelters, reporting, habitations) — this module is a read/render layer plus routing-trigger UI.

## User-facing functionality

- **Citizen** (permission `viewRiskMap`) — and, after the fix this session, **Field Responder** and **Local Official** too (see Known Limitations / the fix noted below): opens the "Risk Map" screen and sees:
  - Hazard zone polygons, colored by severity (critical/high/medium/low), tappable to show a bottom sheet with source/observed-time/confidence.
  - Shelter markers (blue = has room, azure = full), tappable to trigger routing from the user's current GPS position to that shelter.
  - Incident markers (colored by severity), with a tooltip that says "Confirmed by N independent sources" once more than one report has corroborated it.
  - Habitation markers, colored by risk class (violet if not yet assessed), with a tooltip spelling out the risk score, hazard/vulnerability breakdown, capacity gap, and best relocation candidate if those assessments exist.
  - Route polylines (green = safe, orange = detours around a hazard/blockage; solid = real road geometry, dashed = straight-line/offline estimate).
  - A collapsible legend (starts as a small "Legend" chip, expands to a scrollable card — this collapse-by-default behavior was a deliberate fix for a real UI bug where the fully-open legend covered nearly half a phone screen).
  - A local text search box that filters hazard zones/shelters/incidents already loaded on the map by name/description and pans to the tapped result.
  - A "center on my location" floating action button, and automatic camera framing: centers on the user's GPS fix once available, or fits the camera to the bounding box of loaded data if no fix is available yet, or falls back to a whole-of-India default view.
- No screen in this module lets a user *create* hazards/shelters/incidents/habitations — that happens in `hazards`, `shelters`, `reporting`, and `habitations` respectively; this module only renders what those modules (or the demo seeder) have written to the local cache.

## Entry points

- Route `/map` in `lib/app/router.dart` → `RiskMapScreen`. Guarded in `lib/app/route_guard.dart`'s `defaultRoutePermissions` map by `Permission.viewRiskMap` (`'/map': Permission.viewRiskMap`).
- Reachable from the home screen's quick-action grid (`context.push('/map')` in `lib/features/home/presentation/home_screen.dart`) for any role whose `rolePermissions` set includes `viewRiskMap`.
- Reachable from `RiskMapScreen` itself after tapping a shelter marker (routes to it, stays on the same screen).
- Reachable from `lib/features/field_response/presentation/field_incident_detail_screen.dart`'s "Navigate to incident" button, which plans a route then calls `context.push('/map')` to show it — this is the exact action that was broken before the permission fix described below.
- `TaarakMapView`/`TaarakMapController` (this module's shared map widget) are also imported directly by `lib/features/shelters/presentation/shelter_management_screen.dart`, `lib/features/habitations/presentation/register_habitation_screen.dart`, `lib/features/hazards/presentation/report_hazard_zone_screen.dart`, and `lib/features/disaster_events/presentation/simulate_alert_screen.dart` — all outside this module — for their own tap-to-place map forms, reusing this module's base map but not its overlay layers.

### The `viewRiskMap` permission fix (confirmed present)

`lib/features/auth/domain/user_role.dart` grants `Permission.viewRiskMap` to `UserRole.citizen` (its original, blueprint-defined permission), and now also explicitly to `UserRole.fieldResponder` and `UserRole.localOfficial`, each with its own inline comment explaining why:

- `fieldResponder`: *"navigateToIncident's only implementation is planning a route and pushing to /map to show it — without this, that push itself got bounced to /unauthorized. Same fix, same reason, as localOfficial below."*
- `localOfficial`: *"Without this, an official reporting hazard zones/broadcasting to them, verifying reports, or managing shelters had no way to see the very map those actions place things on."*

This confirms the bug described in the handover brief — Field Responder's "Navigate to incident" button pushed to `/map`, a route gated by `Permission.viewRiskMap`, which `fieldResponder`'s permission set did not originally include, so `computeRedirect` in `lib/app/route_guard.dart` bounced the navigation to `/unauthorized` — and confirms the fix (adding `viewRiskMap` to both roles) is in place in the current codebase, with explanatory comments at the point of the fix rather than a silent addition.

## Architecture

Domain / application / presentation layering, no `data/` folder (persistence is delegated to repositories in `lib/core/database/repositories/`, outside this module):

- **domain/** — pure value types: `HabitationOverview` (a habitation joined with its latest risk/capacity/relocation assessments), `MapSearchResult` (label + point), `road_blockage.dart` (a single shared string constant).
- **application/** — `DemoMapDataSeeder` (dev-only seed data — see below), `map_data_providers.dart` (Riverpod `FutureProvider`s that read straight from local Drift repositories), `map_search.dart` (pure functions building/filtering an in-memory search index).
- **presentation/** — `RiskMapScreen` (the citizen Risk Map, and the reference composition every other tap-to-place map screen in the app follows) plus its widgets: `TaarakMapView` (the shared Google Map wrapper), `TaarakMapController` (async-safe camera-control wrapper), `map_overlay_layers.dart` (pure functions building `gmaps.Marker`/`Polygon`/`Polyline` sets from domain rows), `MapLegend`, `MapSearchBar`.

## Files in this module

### `lib/features/map/application/demo_map_data_seeder.dart`
- **Purpose:** Dev-only convenience that seeds a fixed, hand-authored set of sample data — two hazard zones (via the *real* `HazardIngestionService` ingestion pipeline, so they're properly normalized/bucketed), two shelters, two incidents (one a landslide, one a road blockage), and two habitations (one deliberately inside the seeded landslide zone, one deliberately outside it) — so the map has something to render before real data exists. Its own doc comment states it is "Gated behind `AppConfig.isDevMode` at the call site — never runs in a real build."
- **Status: DEMO/MOCK data generation — and currently UNUSED/DEAD CODE in the running app.** `DemoMapDataSeeder` is defined and constructed only inside its own test file (`test/features/map/demo_map_data_seeder_test.dart`); a repo-wide grep for `DemoMapDataSeeder`, `demoMapDataSeeder`, and `seedIfEmpty` found **no call site anywhere in `lib/`** — not in `main.dart`, `app/app.dart`, any Riverpod provider file, or any screen's `initState`. The class's own comment claims it is gated at "the call site," but no such call site currently exists in the codebase. It is fully exercised by its test but never invoked by the running application.
- **Key classes/functions:** `DemoMapDataSeeder(AppDatabase, HazardIngestionService)` — constructor; `seedIfEmpty()` — no-ops if any `LocalHazardZone` row already exists, otherwise inserts the fixed demo dataset in one Drift `batch()` plus two `HazardIngestionService.ingest()` calls.
- **Notable imports:** `HazardIngestionService`/`RawHazardObservation` from the `hazards` module (routes the seeded hazard data through real normalization rather than inserting pre-normalized rows directly), `roadBlockageIncidentType` from this module's own `road_blockage.dart`.
- **Depends on:** `AppDatabase`, `HazardIngestionService`. **Depended on by:** nothing in `lib/` (see Status above); `test/features/map/demo_map_data_seeder_test.dart` only.
- **State:** writes `local_hazard_zones`, `local_shelters`, `local_incidents`, `local_habitations` tables directly via Drift, bypassing the `shelters`/`reporting`/`habitations` modules' own write-path services (no audit-log entries, no sync-queue entries — this data would never sync to Firestore even if the seeder were wired up).
- **External communication:** none.
- **Demo/mock content:** the entire file. Every id is prefixed `demo-` (`demo-hazard-landslide`, `demo-shelter-1`, `demo-incident-road-blockage`, `demo-habitation-ridge-colony`, etc.), coordinates are all offsets from a hardcoded `demoCenter = LatLng(12.9716, 77.5946)` (Bengaluru).

### `lib/features/map/application/map_data_providers.dart`
- **Purpose:** The Riverpod read layer for every map overlay — five `FutureProvider`s, each reading one repository's `getAll()` (or, for habitations, joining three repositories client-side) and degrading to an empty list on any repository failure rather than surfacing an error to the map.
- **Status:** IMPLEMENTED.
- **Key providers:** `hazardZonesProvider` (via `hazardQueryServiceProvider`, not the repository directly — the only one of the five that goes through the `hazards` module's query service rather than its repository), `sheltersProvider`, `incidentsProvider`, `routesProvider`, `habitationsOverviewProvider` (joins `LocalHabitation` with `LocalRiskAssessment`, `LocalCapacityAssessment`, `LocalRelocationPlan` by `habitationId`, all optional — a habitation with no assessment yet still renders, just unscored).
- **Notable imports:** `hazard_providers.dart` (hazards module), `core_providers.dart` (shelter/incident/route/habitation/risk-assessment/capacity-assessment/relocation-plan repository providers).
- **Depends on:** `HazardQueryService`, `LocalShelterRepository`, `LocalIncidentRepository`, `LocalRouteRepository`, `LocalHabitationRepository`, `LocalRiskAssessmentRepository`, `LocalCapacityAssessmentRepository`, `LocalRelocationPlanRepository`. **Depended on by:** `RiskMapScreen`, `ShelterManagementScreen` (reads `sheltersProvider`), `VerificationScreen` (reads `incidentsProvider`), `FieldIncidentDetailScreen`/`AssignedIncidentsScreen` (read `incidentsProvider`), `RoutingService` callers that invalidate `routesProvider` after planning a route.
- **State:** reads `local_hazard_zones`, `local_shelters`, `local_incidents`, `local_routes`, `local_habitations`, `local_risk_assessments`, `local_capacity_assessments`, `local_relocation_plans` — writes nothing.
- **External communication:** none directly (local Drift cache only).

### `lib/features/map/application/map_search.dart`
- **Purpose:** Pure, offline, in-memory search over whatever's currently loaded on the map. Explicitly not a geocoding service — its own doc comment notes "there's no geocoding service wired in (that would need its own API key/account, which nothing here has been given)" — so it matches on hazard-zone type, shelter name, and incident description/type substrings, not arbitrary place names.
- **Status:** IMPLEMENTED.
- **Key functions:** `buildSearchIndex({hazardZones, shelters, incidents})` → `List<MapSearchResult>`; `filterSearchIndex(index, query)` — case-insensitive substring match, empty/whitespace-only query returns no results (deliberately, not "everything").
- **Depends on:** `LocalHazardZone`/`LocalShelter`/`LocalIncident` (Drift rows), `decodePolygonPoints` (`core/gis/geometry_codec.dart`), `MapSearchResult`. **Depended on by:** `RiskMapScreen` (builds the index each rebuild from the three loaded lists), `MapSearchBar` (filters it on each keystroke).
- **State:** none (pure functions over passed-in lists).

### `lib/features/map/domain/habitation_overview.dart`
- **Purpose:** Value object pairing a `LocalHabitation` with its latest `LocalRiskAssessment`, `LocalCapacityAssessment`, and `LocalRelocationPlan`, all nullable — "the shape the map's habitation layer actually needs." Vulnerability is deliberately not a separate field since it's already folded into the risk assessment's `vulnerabilityIndex`.
- **Status:** IMPLEMENTED (plain data class, no logic).
- **Depends on:** `AppDatabase` (for the four row types). **Depended on by:** `habitationsOverviewProvider`, `buildHabitationLayer` in `map_overlay_layers.dart`.

### `lib/features/map/domain/map_search_result.dart`
- **Purpose:** Trivial value object — `label: String`, `point: LatLng` — one entry in the search index.
- **Status:** IMPLEMENTED.

### `lib/features/map/domain/road_blockage.dart`
- **Purpose:** Defines the single string constant `roadBlockageIncidentType = 'road_blockage'`, the `LocalIncident.type` value the map (and routing) treat as a blocked road, matching the blueprint's demo scenario of modeling "blocked road" as an incident rather than a separate road-network entity.
- **Status:** IMPLEMENTED. Its own comment notes the `reporting` module (M12) owns the full incident-type vocabulary; this is the one value the map/routing modules needed before that existed.
- **Depended on by:** `map_overlay_layers.dart` (renders a "Blocked road" title), `map_search.dart` indirectly via incident data, `routing/application/routing_service.dart` and `risk_aware_routing_engine.dart` (filters incidents to just this type for blockage-proximity checks), `demo_map_data_seeder.dart`.

### `lib/features/map/presentation/risk_map_screen.dart`
- **Purpose:** The citizen "Risk Map" screen — composes `TaarakMapView` with all four overlay-layer builders, the search bar, the legend, a routing-in-progress progress indicator, and a recenter FAB. Also documented in its own header comment as "the reference composition ... that the official Incident Map / Risk & Red-Zone Map screens will follow once those modules land" — i.e., this screen's structure is the template for future map screens, not a one-off.
- **Status:** IMPLEMENTED.
- **Key classes:** `RiskMapScreen` (stateful) / `_RiskMapScreenState`. Key behavior: `_routeToShelter(shelter, userPoint)` — calls `routingServiceProvider.planRoute()` and shows a snackbar reporting whether the route is clear of hazards or passes near one; camera auto-centers on the user's GPS fix once available (via `ref.listen(locationStatusProvider, ...)`), or auto-fits to the bounding box of loaded shelters/incidents/hazard-zone points if no fix is available yet, falling back to `defaultMapCenter`/`defaultMapZoom` (whole-of-India view) only if neither is available; `_showHazardZoneProvenance(zone)` — bottom sheet on hazard-polygon tap showing source/observed-time/confidence.
- **Notable imports:** `routing/application/routing_providers.dart` and `routing/domain/route_candidate.dart` (this module triggers routing, doesn't implement it), `profile/application/location_status_controller.dart` (GPS fix), `core/gis/default_map_center.dart`, `core/gis/geometry_codec.dart`.
- **Depends on:** `hazardZonesProvider`, `sheltersProvider`, `incidentsProvider`, `habitationsOverviewProvider`, `routesProvider` (all from `map_data_providers.dart`), `locationStatusProvider` (profile module), `routingServiceProvider` (routing module), every widget in this module's `presentation/widgets/`. **Depended on by:** router (`/map` route), and it's the destination `context.push('/map')` calls from other modules land on (field_response's "Navigate to incident").
- **State:** reads all five map-data providers; writes nothing itself (routing writes happen inside `RoutingService`, invoked here).
- **External communication:** Google Maps SDK rendering (via `TaarakMapView`), device GPS via `locationStatusProvider` (profile module, outside this module's scope but consumed here).
- **Demo/mock content:** none in this file itself — it renders whatever `map_data_providers.dart` returns, which may be the demo seeder's data *if* something else in the app were to call the seeder (currently nothing does — see the seeder's own entry above).

### `lib/features/map/presentation/widgets/map_legend.dart`
- **Purpose:** A collapsible legend (13 rows across four sections: hazard severities, feature icons, risk classes, route types). Its own doc comment records a real device-QA bug fix: the legend previously rendered fully open by default and covered nearly half a phone screen; it now starts collapsed to a small tappable chip.
- **Status:** IMPLEMENTED.
- **Key classes:** `MapLegend` (stateful) / `_MapLegendState` with `_expanded` toggle.
- **Depends on:** `severityColor` (`core/gis/severity_palette.dart`), `RiskClass`/`riskClassLabel`/`riskClassColor` (`risk` module — read-only reference, not a write dependency). **Depended on by:** `RiskMapScreen`.
- **State:** local widget state only (`_expanded`).

### `lib/features/map/presentation/widgets/map_overlay_layers.dart`
- **Purpose:** Pure functions turning domain/Drift rows into Google Maps overlay objects: `buildHazardZoneLayer`, `buildShelterLayer`, `buildHabitationLayer`, `buildRouteLayer`, `buildIncidentLayer`. Each also builds a human-readable tooltip/InfoWindow string (shelter occupancy, habitation risk breakdown with environmental-adjustment provenance, incident corroboration count).
- **Status:** IMPLEMENTED.
- **Key functions/notable detail:** `_markerHue(Color)` converts an arbitrary app color to the nearest Google Maps marker hue (0–360), since `gmaps.Marker` only supports hue-tinted standard pins, not arbitrary bitmap colors, without shipping custom marker bitmaps (not done here). `buildRouteLayer` renders a route dashed if `!route.isRoadSnapped` (straight-line/offline estimate) and solid if it came from a real road-network provider — "a route is never shown in a way that could be mistaken for the other kind," per its own comment.
- **Notable imports:** `google_maps_flutter` directly (`as gmaps`), `core/gis/severity_palette.dart`, `risk/domain/risk_class.dart` + `risk/presentation/risk_class_color.dart` (read-only cross-module reference for the habitation layer's coloring).
- **Depends on:** `LocalHazardZone`/`LocalShelter`/`LocalIncident`/`LocalRoute` (Drift rows), `HabitationOverview`, `decodePolygonPoints`. **Depended on by:** `RiskMapScreen` exclusively within this module (not reused by the other modules' tap-to-place forms, which use `TaarakMapView` directly with their own single marker, not these layer builders).
- **External communication:** Google Maps SDK (marker/polygon/polyline construction — rendering happens in `TaarakMapView`).

### `lib/features/map/presentation/widgets/map_search_bar.dart`
- **Purpose:** Stateful search box UI — a `TextField` plus a dropdown result list, wired to `map_search.dart`'s pure filter function.
- **Status:** IMPLEMENTED.
- **Key classes:** `MapSearchBar` (stateful) / `_MapSearchBarState` — `_onChanged` re-filters on every keystroke, `_select` fires the `onSelect` callback, clears the field, and unfocuses.
- **Depends on:** `map_search.dart` (`filterSearchIndex`), `MapSearchResult`. **Depended on by:** `RiskMapScreen`.
- **State:** local widget state only (`_controller`, `_results`).

### `lib/features/map/presentation/widgets/taarak_map_controller.dart`
- **Purpose:** Thin async-safe wrapper around `gmaps.GoogleMapController`. Its own comment explains why it exists: it matches the synchronous-feeling API shape callers previously used with `flutter_map`'s `MapController`, but Google Maps only hands back its controller asynchronously via `onMapCreated`, so this class queues `move()`/`fitBounds()` calls made before the map finishes initializing (via a `Completer`) instead of every caller needing to handle that timing itself.
- **Status:** IMPLEMENTED. This class's own doc comment is itself evidence the codebase previously used `flutter_map` and was migrated to `google_maps_flutter` — worth noting as migration history, not a currently-live alternative implementation.
- **Key classes/functions:** `TaarakMapController` — `attach(controller)`, `move(point, zoom)` (animated camera), `fitBounds(points, {paddingPixels})` (computes a bounding box across all points, single-point case falls back to `move`).
- **Depends on:** `google_maps_flutter`. **Depended on by:** `RiskMapScreen`, `ShelterManagementScreen`'s form, `RegisterHabitationScreen`, `ReportHazardZoneScreen`, `SimulateAlertScreen` — every tap-to-place map screen in the app.
- **External communication:** Google Maps SDK (`GoogleMapController.animateCamera`).

### `lib/features/map/presentation/widgets/taarak_map_view.dart`
- **Purpose:** The shared base map widget — owns only the `gmaps.GoogleMap` view itself (initial camera, tap handler, markers/polygons/polylines sets, "my location" blue dot enabled but the built-in location button disabled in favor of this module's own recenter FAB), with all overlay content supplied by the caller so it stays reusable across the citizen Risk Map and every other module's tap-to-place forms.
- **Status:** IMPLEMENTED. Confirms real `google_maps_flutter` usage (`import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;`), not a placeholder or a different mapping library.
- **Key classes:** `TaarakMapView` (stateless) — `initialCenter`, `initialZoom` (default 13), `markers`/`polygons`/`polylines` (default empty sets), optional `mapController`, optional `onTap`.
- **Depends on:** `google_maps_flutter`. **Depended on by:** same list as `TaarakMapController` above.
- **External communication:** Google Maps SDK rendering; `myLocationEnabled: true` requests the device's live location dot from the SDK (separate from this app's own `LocationService`/GPS-fix flow used for report geotagging).

## Data Models

- **`HabitationOverview`** — `habitation: LocalHabitation`, `riskAssessment: LocalRiskAssessment?`, `capacityAssessment: LocalCapacityAssessment?`, `relocationPlan: LocalRelocationPlan?`.
- **`MapSearchResult`** — `label: String`, `point: LatLng`.
- **`LocalHazardZone`** (Drift row, `core/database/tables/local_hazard_zones_table.dart`) — `id`, `hazardType`, `severity`, `geometryJson`, `source`, `observedAt`, `confidence` (default 1.0), `updatedAt`, `version`.
- **`LocalShelter`** (`local_shelters_table.dart`) — `id`, `name`, `latitude`, `longitude`, `capacityTotal` (default 0), `occupancy` (default 0), `facilitiesJson` (default `'[]'`), `accessQuality: double?`, `updatedAt`, `version`.
- **`LocalIncident`** (`local_incidents_table.dart`) — `id`, `type`, `status`, `latitude`, `longitude`, `description` (default `''`), `severity` (default `'unknown'`), `independentSourceCount` (default 1), `confidence` (default 0.5), `createdAt`, `updatedAt`, `version`, `isSynced` (default false), `assignedResponderId: String?`.
- **`LocalHabitation`** (`local_habitations_table.dart`) — `id`, `name`, `latitude`, `longitude`, `population` (default 0), `administrativeRegionName: String?`, `infrastructureQuality: double?`, `accessQuality: double?`, `updatedAt`, `version`.
- **`LocalRoute`** (`local_routes_table.dart`) — `id`, `originLat/Lng`, `destLat/Lng`, `polylineJson`, `distanceMeters`, `etaSeconds`, `isSafe` (default true), `isRoadSnapped` (default false), `cachedAt`, `version`.

## Services / Repositories

This module owns no repository or write-side service of its own — it is a pure read/render layer over repositories owned by `core/database/repositories/` and the `hazards` module's `HazardQueryService`. Its one "service"-shaped class is `DemoMapDataSeeder`, which is dev-only seed data generation (see Files above), not a production service.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/map` | `RiskMapScreen` | `Permission.viewRiskMap` | Home screen quick actions (citizen, and now field responder / local official); `FieldIncidentDetailScreen`'s "Navigate to incident" button (field_response module); a shelter marker tap on the map itself stays on `/map` but triggers routing. |

## Module Data Flow

Citizen opens the Risk Map and taps a shelter to get directions:

```
RiskMapScreen (route: /map, guarded by Permission.viewRiskMap)
  build()
    ref.watch(hazardZonesProvider)       → HazardQueryService.query() → LocalHazardZoneRepository
    ref.watch(sheltersProvider)          → LocalShelterRepository.getAll()
    ref.watch(incidentsProvider)         → LocalIncidentRepository.getAll()
    ref.watch(habitationsOverviewProvider) → joins LocalHabitationRepository +
                                              LocalRiskAssessmentRepository +
                                              LocalCapacityAssessmentRepository +
                                              LocalRelocationPlanRepository
    ref.watch(routesProvider)            → LocalRouteRepository.getAll()
    buildSearchIndex(hazardZones, shelters, incidents)   [map_search.dart]
    buildHazardZoneLayer / buildShelterLayer / buildIncidentLayer /
      buildHabitationLayer / buildRouteLayer             [map_overlay_layers.dart]
    → TaarakMapView renders markers/polygons/polylines via google_maps_flutter

User taps a shelter marker
  → RiskMapScreen._routeToShelter(shelter, userPoint)
      → ref.read(routingServiceProvider).planRoute(origin: userPoint, destination: shelter location)
          [routing module — RoutingService, out of this module's scope]
      → on Success: ref.invalidate(routesProvider)  → routesProvider re-reads LocalRouteRepository
                                                       → buildRouteLayer picks up the new cached route
      → snackbar: "Route ready — clear of known hazards" or "passes near a hazard zone"
```

## Current Status

**Working**, for the real (non-demo) data path: every provider in `map_data_providers.dart` reads live from Drift repositories populated by the `hazards`, `shelters`, `reporting`→`verification`, and `habitations` modules' real write paths — none of it depends on the demo seeder to function. `RiskMapScreen` itself has no dedicated widget test in `test/features/map/` (see Test Coverage) but its dependencies (`map_search.dart`, `MapLegend`, `MapSearchBar`) are each unit/widget-tested directly.

**Demo/Mock — and currently dead**: `DemoMapDataSeeder` is real, working code (its own test exercises it fully and passes), but it has no call site anywhere in the running app (`lib/`). It cannot currently run in either a dev build or a release build, because nothing invokes `seedIfEmpty()`. If a reader of this documentation sees an empty map on a fresh install, this seeder is *not* the reason — either the map is legitimately empty (no data has been ingested yet) or the seeder needs to be wired up somewhere (e.g. `app.dart`'s startup path) for its documented dev-mode behavior to actually occur.

**Real ingestion pathways** (distinct from the demo seeder, and fully wired): hazard zones via `ReportHazardZoneScreen` → `HazardIngestionService` (hazards module); shelters via `ShelterManagementScreen` → `ShelterManagementService` (shelters module); incidents via citizen reports (`ReportIncidentScreen`/`SosScreen`) → `CitizenReportSubmissionService` (reporting module) → `IncidentVerificationService.acknowledgeReport` (verification module) turning a report into a `LocalIncident`; habitations via `RegisterHabitationScreen` → `HabitationRegistrationService` (habitations module). All four are real, tested, audited write paths distinct from — and now the actual source of — the data this map renders.

## Known Limitations

- No real geocoding — `MapSearchBar`/`map_search.dart` only searches labels of data already loaded on the map (hazard type, shelter name, incident description/type), not arbitrary place names, by explicit design (no geocoding API key configured).
- `DemoMapDataSeeder` is unreferenced dead code as shipped — see Current Status above. Its own doc comment ("gated behind `AppConfig.isDevMode` at the call site") describes a call site that does not exist in this codebase.
- Marker coloring is constrained to Google Maps' hue-tint model (`BitmapDescriptor.defaultMarkerWithHue`) rather than arbitrary RGB, so the app's severity/risk-class palette is only approximated on markers (exact colors are used for polygons/polylines, which don't have this constraint).
- `RiskMapScreen` has no `key`-addressable way to distinguish "no GPS fix yet" from "GPS permission permanently denied" in its camera-centering logic — both cases fall through to the same bounding-box-or-default behavior.
- A **Google Maps API key is present in `android/app/src/main/AndroidManifest.xml`** (the `com.google.android.geo.API_KEY` meta-data value). SECRET PRESENT IN SOURCE — DO NOT COPY INTO DOCUMENTATION. This means the map is backed by a real, working Google Maps configuration on Android, not a placeholder — but a hardcoded API key committed to source control is itself worth flagging to whoever owns key rotation/restriction policy.

## Test Coverage

`test/features/map/` contains four files:

- **`demo_map_data_seeder_test.dart`** — thorough for what it covers: seeds hazard zones/shelters/incidents (including one road-blockage type) and confirms hazard data went through real normalization (bucketed severity, computed confidence) rather than a raw insert; confirms one seeded habitation falls inside the seeded landslide polygon and one falls outside it (using `isPointInPolygon`); confirms calling `seedIfEmpty()` twice does not duplicate data. **Does not** (and cannot, from this file alone) prove the seeder ever runs in the actual app — that requires checking call sites in `lib/`, which this scan did (see above): there are none.
- **`map_legend_test.dart`** — confirms the legend starts collapsed (a small chip, not the full 13-row card), expands on tap to show every layer type, and can be collapsed again.
- **`map_search_bar_test.dart`** — one widget test: typing filters the visible result list, tapping a result fires `onSelect` and clears the field.
- **`map_search_test.dart`** — confirms the search index includes hazard zones/shelters/incidents, filtering is case-insensitive and substring-based, and an empty/whitespace query returns no results.

**Not covered by any test in `test/features/map/`:** `RiskMapScreen` itself (no widget test — the camera-centering/fit-to-data logic, the shelter-tap-to-route flow, and the hazard-zone-tap bottom sheet are all untested at this layer); `map_data_providers.dart` (no provider-level test — the five providers' repository-read/degrade-to-empty-on-failure behavior is unverified by a dedicated test, though it's exercised indirectly by other modules' integration tests that seed the same tables); `map_overlay_layers.dart` (no test verifying marker/polygon/polyline construction, hue conversion, or tooltip string formatting); `TaarakMapController`/`TaarakMapView` (no test — these wrap the `google_maps_flutter` SDK directly and would need widget/integration testing with a fake platform channel to cover meaningfully).
