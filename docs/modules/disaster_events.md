# MODULE: Disaster Events

## Purpose

Disaster Events is a normalization layer: a thin `DisasterEvent` envelope that any external signal (today: a manually-pasted government bulletin; documented as "later SMS or a store-and-forward relay") gets converted into, plus a router (`DisasterEventProcessor`) that sends the subset of event types that already map onto an existing pipeline (landslide, river-rise) into the real hazard-ingestion service used elsewhere in the app. It deliberately creates no new source of truth, no new synced table, and no AI/LLM in the data path — text parsing is regex-based pattern matching only, and the module is explicit and repeated in its own doc comments that it will never invent a location from free text.

**Verified finding on the required check**: `GovernmentAlertParser` (`lib/features/disaster_events/application/government_alert_parser.dart`) uses exactly three `RegExp` patterns (`_rainfallPattern`, `_riverPattern`, `_roadPattern`) plus a plain `if/contains` keyword classifier (`_classifyHazard`) — there is no LLM call, no HTTP call to any AI service, and no ML model of any kind anywhere in this file or the module. The file's own doc comment states this explicitly: *"Deterministic, regex-based extraction of the fields a government bulletin typically states plainly — not an LLM, not a guess. This is exactly the kind of 'AI' this project's architecture notes explicitly warn against needing."* Location is never geocoded from text: `ParsedGovernmentAlert` has no lat/lng field at all, and both the parser's doc comment and `SimulateAlertScreen`'s UI copy ("The text alone is not trusted to guess a location — tap the map where this alert applies") confirm a human must always tap a map point; `DisasterEvent.latitude`/`longitude` come only from that tap, never from parsed text.

## User-facing functionality

- **Local Official** (`Permission.manageLocalIncidents`, screen `SimulateAlertScreen` at `/hazards/simulate-alert`): pastes government bulletin text into a text field; as they type, the screen live-parses the text (`GovernmentAlertParser.parse`) and shows a "Detected" card listing only the fields actually found (hazard type, 24h rainfall in mm, river names mentioned, road names mentioned) or "Nothing recognizable in this text" if none matched. The official must then tap a point on an embedded map to confirm where the alert applies — the submit button is disabled until both a recognized landslide/riverRise hazard type AND a tapped map point exist. On submit, a `DisasterEvent` is built and run through `DisasterEventProcessor`, and the screen shows the processor's real outcome in a `SnackBar` ("Hazard zone created from this alert." / a not-actionable detail message / a rejection message) — never an assumed success.
- The screen's own header text and doc comment both explicitly disclose to the user that this "does not read real SMS" and is "a safe intake path for testing."

## Entry points

Grepped from `lib/app/router.dart` and `lib/app/route_guard.dart`:

| Route | Screen | Permission required |
|---|---|---|
| `/hazards/simulate-alert` | `SimulateAlertScreen` | `Permission.manageLocalIncidents` |

Single flat route, no path params.

## Architecture

- **`domain/`** — `disaster_event.dart`: the `DisasterEvent` envelope (plain immutable class) and `DisasterEventType` enum. No Drift table backs this — it is a pure in-memory/transient handoff object, never persisted as-is.
- **`application/`** — three files: `government_alert_parser.dart` (pure regex parsing, no IO), `disaster_event_processor.dart` (routing/orchestration — the only file that talks to another module's service, `HazardIngestionService`), `disaster_event_providers.dart` (two-line Riverpod wiring for the parser and processor).
- **`presentation/`** — one screen, `simulate_alert_screen.dart`, which is both the only producer of a `DisasterEvent` in this module and the only caller of `DisasterEventProcessor.process`.
- Deliberately no `data/` folder and no repository — this module owns no persistence of its own; `DisasterEventProcessor` is explicitly documented as owning "no storage and no business rules of its own," forwarding everything actionable to `HazardIngestionService` (Hazards module).

## Files in this module

### `lib/features/disaster_events/domain/disaster_event.dart`
- **Purpose**: Defines the transport-agnostic envelope (`DisasterEvent`) that any external signal is normalized into, and the closed set of event categories (`DisasterEventType`) it can carry.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `DisasterEventType` enum — `heavyRainfall`, `riverRise`, `landslide`, `roadBlocked`, `evacuationOrder`, `shelterUpdate`, `governmentAlert`; `DisasterEvent` class — `id`, `type`, `source` (free text, e.g. `'simulated-alert:<officialId>'`), `timestamp`, optional `latitude`/`longitude`, `severity` (low/medium/high/critical, default `'medium'`), `payload` (loose `Map<String, dynamic>`, default `{}`), `confidence` (`double`, default `0.7`), optional `provenanceNote`.
- **Notable imports**: none beyond core Dart.
- **Depends on**: nothing.
- **Depended on by**: `government_alert_parser.dart` (for `DisasterEventType`), `disaster_event_processor.dart`, `simulate_alert_screen.dart`, both test files.
- **State read/written**: none — this class is never itself persisted to Drift or Firestore; it exists only in-memory as a handoff between the parser/UI and the processor.
- **External communication**: none.
- **Mock/demo content**: none.

### `lib/features/disaster_events/application/government_alert_parser.dart`
- **Purpose**: Deterministic, regex-only extraction of structured fields (rainfall amount, river names, road names, a coarse hazard-type classification) from free-text government bulletin content. Explicitly and repeatedly documented as NOT an LLM and as never guessing a location.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `ParsedGovernmentAlert` (result holder: `hazardType` nullable `DisasterEventType`, `rainfall24hMm` nullable `double`, `riverMentions`/`roadMentions` `List<String>`, `rawText`, plus a derived `hasAnyStructuredData` getter); `GovernmentAlertParser.parse(String text)` — runs three static `RegExp`s (`_rainfallPattern = r'(\d+(?:\.\d+)?)\s*mm'`, `_riverPattern = r'([A-Z][a-zA-Z]+)\s+river\b'`, `_roadPattern = r'\b([NS]H\s?-?\s?\d+)\b'`) and a keyword-based `_classifyHazard(lowerText)` helper (checks, in order: `'landslide'` → landslide; `'river'` AND `'ris'` → riverRise; `'rainfall'`/`'rain'` → heavyRainfall; `'road'`/`'blocked'`/`'vulnerable'` → roadBlocked; `'evacuat'` → evacuationOrder; else `null`).
- **Notable imports**: only `disaster_event.dart` (for `DisasterEventType`) — no `dart:` networking, no HTTP client, no AI/LLM package of any kind.
- **Depends on**: nothing external — pure string processing.
- **Depended on by**: `disaster_event_providers.dart` (`governmentAlertParserProvider`), `simulate_alert_screen.dart` (live-parses on every keystroke), `government_alert_parser_test.dart`.
- **State read/written**: none — pure function, no IO, no side effects.
- **External communication**: none. **This is the file the task specifically asked to verify — confirmed regex-based, not an LLM, and confirmed it never invents a location (no lat/lng field exists anywhere in `ParsedGovernmentAlert`).**
- **Mock/demo content**: none — real, working pattern-matching logic, not a stub.

### `lib/features/disaster_events/application/disaster_event_processor.dart`
- **Purpose**: Routes a `DisasterEvent` into the existing hazard-ingestion pipeline when (and only when) its type maps cleanly onto a hazard zone and it carries real coordinates; otherwise returns an explicit "not actionable" outcome rather than forcing the data through a pipeline that doesn't fit or fabricating missing information.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `DisasterEventProcessor` (constructor DI: `HazardIngestionService`); `process(DisasterEvent, {now})` — maps `DisasterEventType.landslide` → `'landslide'`, `DisasterEventType.riverRise` → `'flood'`, everything else → `null` (returns `notActionable` immediately with an explicit message naming the event type); if `latitude`/`longitude` are null, also returns `notActionable` with a message stating a human must confirm a location on the map; otherwise converts `severity` to a numeric score (`critical=1.0, high=0.75, medium=0.5, low=0.25`, default `0.5`), builds a circular polygon of `_defaultEventRadiusMeters = 500` around the point (`circlePolygonPoints` from `core/gis/circle_geometry.dart`), and calls `HazardIngestionService.ingest(...)`, translating its `Result` into `ingestedAsHazardZone` or `rejected(failure.message)`; `DisasterEventProcessingStatus` enum (`ingestedAsHazardZone`, `notActionable`, `rejected`); `DisasterEventProcessingOutcome` (private constructor + three named factories) — carries the status plus an optional human-readable `detail`, so a caller always has something concrete to show, never a silent no-op.
- **Notable imports**: `latlong2`, `core/gis/circle_geometry.dart` (`circlePolygonPoints`), `core/repository/result.dart`, `features/hazards/application/hazard_ingestion_service.dart` (cross-module — the real hazard pipeline), `features/hazards/domain/raw_hazard_observation.dart`.
- **Depends on**: `HazardIngestionService` (Hazards module) — this is the one and only external pipeline this module writes through; the doc comment explicitly notes `heavyRainfall` is deliberately NOT auto-converted into a hazard zone ("rainfall alone describes weather, not a bounded affected area, and inventing a polygon from it would be exactly the kind of fabricated-looking data Rule 7 rules out"), and that rainfall instead belongs to the (separate, out-of-scope) `EnvironmentalRiskEngine`/`OpenMeteoDataSource` signal path.
- **Depended on by**: `disaster_event_providers.dart` (`disasterEventProcessorProvider`), `simulate_alert_screen.dart`, `disaster_event_processor_test.dart`.
- **State read/written**: writes `local_hazard_zones` indirectly via `HazardIngestionService.ingest` (only for landslide/riverRise types with coordinates); writes nothing for any other event type.
- **External communication**: none directly — all persistence flows through `HazardIngestionService`, itself local-Drift-backed (verified by the test using an in-memory `AppDatabase`).
- **Mock/demo content**: none — real routing logic with a genuinely restrictive allow-list (only 2 of 7 `DisasterEventType` values are actually wired to a pipeline; the other 5 — `heavyRainfall`, `roadBlocked`, `evacuationOrder`, `shelterUpdate`, `governmentAlert` — always return `notActionable`, by design, "recorded but not acted on").

### `lib/features/disaster_events/application/disaster_event_providers.dart`
- **Purpose**: Minimal Riverpod wiring — two providers, no logic of its own.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `governmentAlertParserProvider` (`Provider<GovernmentAlertParser>`); `disasterEventProcessorProvider` (`Provider<DisasterEventProcessor>`, wires `hazardIngestionServiceProvider` from `features/hazards/application/hazard_providers.dart`).
- **Notable imports**: `hazard_providers.dart` (cross-module — Hazards).
- **Depends on**: `GovernmentAlertParser`, `DisasterEventProcessor`, `hazardIngestionServiceProvider` (hazards module).
- **Depended on by**: `simulate_alert_screen.dart`.
- **State read/written**: none.
- **External communication**: none.
- **Mock/demo content**: none.

### `lib/features/disaster_events/presentation/simulate_alert_screen.dart`
- **Purpose**: The module's only UI — a manual-paste intake form standing in for a real SMS/network alert feed, explicitly labeled as such in both its doc comment and its on-screen copy. Live-parses text via `GovernmentAlertParser`, requires a human-confirmed map tap for location, and submits through `DisasterEventProcessor`.
- **Status**: IMPLEMENTED (as a manual-entry simulation/prototype intake screen — this is its documented purpose, not an incomplete real-feed integration).
- **Key classes/functions**: `SimulateAlertScreen`/`_SimulateAlertScreenState` — `_onTextChanged` (re-parses on every keystroke via `governmentAlertParserProvider`), `_canSubmit()` (requires a tapped `_center` point AND a parsed hazard type of exactly `landslide` or `riverRise` — matching `DisasterEventProcessor`'s allow-list, so the UI never lets an official submit an event type the processor would just reject as not-actionable), `_submit()` (builds a `DisasterEvent` with `source: 'simulated-alert:$officialId'`, `confidence: 0.6` (hardcoded, lower than the domain default of 0.7 — reflecting that manually-pasted/simulated data is explicitly less trusted), `payload: {'rawText': parsed.rawText}`, `provenanceNote: 'Entered via the alert-simulation screen, not a live feed.'` — this provenance note is itself explicit, permanent evidence embedded in the data that this event did not come from a real feed).
- **Notable imports**: `google_maps_flutter` (map marker rendering), `uuid`, `core/gis/default_map_center.dart`, `features/auth/application/auth_controller.dart` (`currentUserProvider`), `disaster_event_providers.dart`, `disaster_event_processor.dart`, `government_alert_parser.dart`, `disaster_event.dart`, `features/map/application/map_data_providers.dart` (`hazardZonesProvider`, invalidated on success), `features/map/presentation/widgets/taarak_map_controller.dart` + `taarak_map_view.dart` (cross-module reuse of the Map feature's embeddable map widget), `features/profile/application/location_status_controller.dart` (`locationStatusProvider`, used only to center the map on the official's own GPS fix).
- **Depends on**: `governmentAlertParserProvider`, `disasterEventProcessorProvider` (this module), `hazardZonesProvider` (map), `TaarakMapView`/`TaarakMapController` (map), `locationStatusProvider` (profile), `currentUserProvider` (auth).
- **Depended on by**: routed at `/hazards/simulate-alert`.
- **State read/written**: no direct Drift access — all writes flow through `DisasterEventProcessor.process` → `HazardIngestionService`.
- **External communication**: none directly.
- **Mock/demo content**: **This entire screen is an explicitly-labeled simulation/manual-testing intake path, not a live feed** — both its class doc comment ("A safe stand-in for a real SMS/network alert intake... without asking for SMS permissions or standing up any receiving infrastructure this round") and its in-app UI text ("This is a safe intake path for testing — it does not read real SMS") say so directly. This is the intended, honest design, not a hidden shortcut: every `DisasterEvent` it produces is permanently tagged with `source: 'simulated-alert:...'` and `provenanceNote: 'Entered via the alert-simulation screen, not a live feed.'` so downstream consumers of `local_hazard_zones` can always tell a real ingestion from a simulated one.

### `test/features/disaster_events/government_alert_parser_test.dart`
- **Purpose**: Pure unit tests of `GovernmentAlertParser.parse` — no IO.
- **Status**: IMPLEMENTED.
- **Key tests**: extracts rainfall/river/road from a combined bulletin (also confirms river-rise is classified ahead of generic rainfall when both signals are present — "the more specific, more actionable signal"); classifies a landslide bulletin; classifies plain rainfall (no river) as `heavyRainfall`; classifies a river-rise bulletin distinctly; returns no structured data for unrelated text ("Office will remain closed tomorrow"); explicitly asserts the parser "does not invent a river or road mention that is not present" for text that only mentions rain with no river/road named.
- **Notable imports**: `flutter_test`, `government_alert_parser.dart`, `disaster_event.dart`.
- **External communication**: none.

### `test/features/disaster_events/disaster_event_processor_test.dart`
- **Purpose**: Integration-style test against a real in-memory Drift `AppDatabase`, exercising `DisasterEventProcessor.process` end to end through the real `HazardIngestionService`/`HazardNormalizer`.
- **Status**: IMPLEMENTED.
- **Key tests**: a landslide event is ingested as a hazard zone (verifies the saved `local_hazard_zones` row has `hazardType: 'landslide'`, `severity: 'high'`); a riverRise event is ingested with `hazardType: 'flood'`; a heavyRainfall event is left not-actionable and confirms via a real DB query that no row was written ("rather than faked into a zone" — test name is explicit about this being the point); an event with no coordinates is left not-actionable, again confirming no row was written.
- **Notable imports**: `drift/native`, `flutter_test`, `core/database/app_database.dart`, `core/database/repositories/local_hazard_zone_repository.dart`, `disaster_event_processor.dart`, `disaster_event.dart`, `features/hazards/application/hazard_ingestion_service.dart` + `hazard_normalizer.dart`, `test/support/sqlite3_test_setup.dart`.
- **External communication**: none — fully in-memory Drift.

## Data Models

`DisasterEvent` (`lib/features/disaster_events/domain/disaster_event.dart`) — plain Dart class, never persisted as its own table:
- `id` (String), `type` (`DisasterEventType`), `source` (String), `timestamp` (DateTime)
- `latitude`/`longitude` (double, nullable — null means "no confirmed location yet")
- `severity` (String, default `'medium'`)
- `payload` (`Map<String, dynamic>`, default `{}`)
- `confidence` (double, default `0.7`)
- `provenanceNote` (String, nullable)

`DisasterEventType` enum: `heavyRainfall`, `riverRise`, `landslide`, `roadBlocked`, `evacuationOrder`, `shelterUpdate`, `governmentAlert`. Only `landslide` and `riverRise` are currently wired to any pipeline.

`ParsedGovernmentAlert` (`government_alert_parser.dart`) — plain Dart class, transient parse result, never persisted:
- `hazardType` (`DisasterEventType?`), `rainfall24hMm` (`double?`), `riverMentions`/`roadMentions` (`List<String>`), `rawText` (String), derived `hasAnyStructuredData` (bool).

`DisasterEventProcessingOutcome` (`disaster_event_processor.dart`) — transient result object: `status` (`DisasterEventProcessingStatus`: `ingestedAsHazardZone` | `notActionable` | `rejected`), `detail` (String?, human-readable explanation).

## Services / Repositories

- **`GovernmentAlertParser`** — stateless regex parser, no repository, no persistence.
- **`DisasterEventProcessor`** — the module's only orchestration service; owns no storage itself, delegates all persistence to `HazardIngestionService` (Hazards module).
- No repository is defined in this module — by design, per the processor's own doc comment ("this class deliberately owns no storage and no business rules of its own").

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/hazards/simulate-alert` | `SimulateAlertScreen` | `Permission.manageLocalIncidents` | Local Official menu/navigation (outside this module) |

## Module Data Flow

**Simulate a government alert → hazard zone (the module's only real flow):**

```
SimulateAlertScreen: official pastes bulletin text
  -> _onTextChanged -> GovernmentAlertParser.parse(text)   [pure regex: rainfall/river/road patterns + keyword classifier]
    <- ParsedGovernmentAlert (hazardType, rainfall24hMm, riverMentions, roadMentions)
  UI shows only fields actually found — no invented values

official taps a point on the embedded map
  -> _center = tapped LatLng
  -> _canSubmit(): requires _center != null AND parsed.hazardType in {landslide, riverRise}

official taps "Process alert"
  -> builds DisasterEvent(type: parsed.hazardType, source: 'simulated-alert:<officialId>',
                           latitude/longitude: from the tap (never from text), confidence: 0.6,
                           payload: {rawText}, provenanceNote: 'Entered via the alert-simulation screen, not a live feed.')
  -> DisasterEventProcessor.process(event)
     -> maps type: landslide -> 'landslide' | riverRise -> 'flood'
     -> builds a 500m-radius circular polygon around (latitude, longitude)  [core/gis/circle_geometry.dart]
     -> HazardIngestionService.ingest(id: event.id, RawHazardObservation(...))   [Hazards module -> writes local_hazard_zones]
  <- DisasterEventProcessingOutcome(status: ingestedAsHazardZone | notActionable | rejected, detail)

SnackBar shows the real outcome; on success: ref.invalidate(hazardZonesProvider), form resets
```

## Current Status

**Working** as a manual-entry simulation/prototype intake path — explicitly documented as such, not a bug or an unfinished feature masquerading as complete. Evidence: both application-layer files have real test coverage including an integration test against a real Drift database confirming that non-actionable event types (rainfall, no-coordinates) genuinely write nothing rather than silently succeeding; the parser correctly distinguishes river-rise from generic rainfall and never invents fields; the processor's allow-list (only landslide/riverRise) is enforced consistently in both the UI (`_canSubmit`) and the service itself (`process`'s hazardType mapping).

## Known Limitations

- Only 2 of 7 `DisasterEventType` values (`landslide`, `riverRise`) are wired to any actual pipeline. `roadBlocked`, `evacuationOrder`, `shelterUpdate`, and `governmentAlert` events would always return `notActionable` — the enum anticipates future event categories that have no consumer yet.
- The alert-intake path is a manual paste-and-confirm UI only — there is no automated SMS, webhook, or government-feed ingestion anywhere in this module (or, per the SMS Prototype module's separate findings, elsewhere in the app as of this codebase). Any real integration with a live government alert feed would require new code, not just enabling something already built.
- `DisasterEventProcessor._defaultEventRadiusMeters = 500` is a fixed, non-configurable fallback footprint for any point-only event — coarser than an official's own manually-drawn hazard boundary via the regular hazard-report screen.
- `GovernmentAlertParser`'s river/road regexes are shape-based only (`<Capitalized word> + "river"`, `[N|S]H-<digits>`) — they will miss rivers/roads named in a different format (e.g. lowercase, or a road code not matching the `NH`/`SH` prefix pattern) and will not error, simply return an empty list; there is no confidence scoring or fuzzy matching.

## Test Coverage

- `test/features/disaster_events/government_alert_parser_test.dart` — covers rainfall/river/road extraction, hazard-type classification priority (river-rise over generic rainfall), landslide classification, no-match behavior, and an explicit "does not invent" negative test.
- `test/features/disaster_events/disaster_event_processor_test.dart` — covers both actionable paths (landslide→'landslide', riverRise→'flood') against a real in-memory Drift database, and both not-actionable paths (heavyRainfall type, missing coordinates), each confirming via direct DB query that no `local_hazard_zones` row was written.
- **Not covered by any test**: `disaster_event_providers.dart` (trivial, low-risk, but untested), `simulate_alert_screen.dart` (no widget test — the live-parse-on-keystroke behavior, the `_canSubmit` gating logic, the map-tap-to-center flow, and the `hazardZonesProvider` invalidation-and-form-reset on success are all unverified by automated tests). The `rejected` outcome branch of `DisasterEventProcessingOutcome` (a failure from `HazardIngestionService.ingest` itself) is not exercised by any test — only `ingestedAsHazardZone` and `notActionable` are tested.
