# MODULE: Risk

## Purpose

This module answers, per habitation: "given the hazard zones currently mapped and how vulnerable this place is, how dangerous is it right now, on a single comparable scale?" It is the second stage of the scoring pipeline (after hazard ingestion), and its output — a 0.0–1.0 risk score plus a four-band classification — is the input every later stage (capacity gap, relocation planning, relocation priority) treats as "how bad is this place" without re-deriving it.

## User-facing functionality

This module has **no screens of its own**. `RiskAssessmentResult` is never rendered directly by any presentation code found in this scan — the only user-visible trace of this module's work is the **persisted** `LocalRiskAssessment` row's `riskClass` string, which is read (via `LocalRiskAssessmentRepository`, outside this module) and colored/labeled using `risk_class_color.dart`'s `riskClassColor`/`riskClassLabel` by: the Command Dashboard (`command_dashboard_screen.dart`) and the Risk/Red-Zone map overlay (`map_overlay_layers.dart`, `map_legend.dart`). So risk *does* surface to a District/Command role and on the citizen-facing Risk Map, but only as a color/label on already-computed, already-persisted data — nothing in this module drives that UI directly.

## Entry points

- `riskAssessmentServiceProvider` (in `risk_providers.dart`) is watched by exactly one external consumer found in this scan: `lib/features/relocation/application/relocation_priority_providers.dart` (via `RelocationPriorityService`). **No other production code calls `RiskAssessmentService.assessHabitation` or `.assessAllHabitations`** — the only way a risk assessment actually gets (re)computed and written to the database is by the Relocation Priority screen's queue build, or in tests. The map/dashboard read whatever is already sitting in the `local_risk_assessments` table; they do not trigger recomputation themselves.
- `riskClassColor`/`riskClassLabel` (presentation layer) are consumed by `map_overlay_layers.dart`, `map_legend.dart`, `command_dashboard_screen.dart`.

## Architecture

Domain/application/presentation layering, no `data/` folder (persistence via `LocalRiskAssessmentRepository`, outside this module):

- **domain/** — `RiskAssessmentResult` (output, with `riskModelVersion` constant), `RiskClass` enum + `classifyRiskScore`, `VulnerabilityProvider` abstract contract + its original `DefaultVulnerabilityProvider` neutral stand-in.
- **application/** — `RiskEngine` (pure engine), `RiskAssessmentService` (orchestrator), `risk_providers.dart` (Riverpod wiring).
- **presentation/** — `risk_class_color.dart` only (no screens; a pure color/label mapping helper).

## Files in this module

### `lib/features/risk/application/risk_assessment_service.dart`
- **Purpose:** Orchestrates a single habitation's risk assessment: loads the habitation, loads all hazard zones, asks the injected `VulnerabilityProvider` for a vulnerability index, runs `RiskEngine.assess()`, optionally layers in an environmental adjustment (M24, see the environmental module), and persists the result with version tracking.
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `RiskAssessmentService.assessHabitation(habitationId, {now})` → `Result<RiskAssessmentResult>`; `assessAllHabitations({now})` → `List<RiskAssessmentResult>` (best-effort batch — per-habitation failures are silently skipped, not aggregated as errors).
- **Notable imports:** `features/environmental/application/environmental_data_service.dart` and `risk_environmental_merge.dart` — the M24 integration point; `_environmentalDataService` is nullable and optional, so behavior is byte-identical to pre-M24 when omitted.
- **Depends on:** `LocalHabitationRepository`, `LocalHazardZoneRepository`, `LocalRiskAssessmentRepository`, `VulnerabilityProvider`, `RiskEngine`, `EnvironmentalDataService?`. **Depended on by:** `risk_providers.dart`, `RelocationPriorityService` (relocation module).
- **State:** reads `local_habitations`, `local_hazard_zones`; reads+writes `local_risk_assessments` (one current row per habitation, version incremented on re-assessment).
- **External communication:** none directly (delegates to `EnvironmentalDataService`, which may call Open-Meteo — see environmental module).

### `lib/features/risk/application/risk_engine.dart`
- **Purpose:** The deterministic scoring core. Combines hazard exposure (worst-hazard-wins across overlapping zones the habitation falls inside) with a supplied vulnerability index into one weighted risk score.
- **Status:** IMPLEMENTED. Explicitly documented and tested as pure and reproducible ("no I/O, no clock reads unless a caller supplies `now`... the same inputs always produce the same `RiskAssessmentResult`").
- **Key classes/functions:** `RiskEngine.assess({habitation, hazardZones, vulnerabilityIndex, now})` → `RiskAssessmentResult`.
- **EXACT FORMULA:**
  ```
  hazardWeight = 0.6
  vulnerabilityWeight = 0.4

  For each hazard zone the habitation point falls inside (point-in-polygon test):
      zoneIntensity = HazardSeverity.intensity * zone.confidence.clamp(0,1)
      hazardExposure = max(hazardExposure, zoneIntensity)   // worst zone wins, not summed

  riskScore = (hazardWeight * hazardExposure + vulnerabilityWeight * vulnerabilityIndex.clamp(0,1))
              .clamp(0.0, 1.0)
  ```
  Model version constant: `riskModelVersion = '1.0.0'`.
- **Notable imports:** `core/gis/point_in_polygon.dart`, `core/gis/geometry_codec.dart` (decode zone geometry), `features/hazards/domain/hazard_severity.dart` (for `.intensity`).
- **Depends on:** `HazardSeverity`, `RiskClass`/`classifyRiskScore`. **Depended on by:** `RiskAssessmentService`; instantiated directly (no `engine` override) in production wiring but overridable via constructor injection (used by tests).
- **State:** none (pure).
- **Demo/mock content:** none — every number here is a real, tested computation.

### `lib/features/risk/application/risk_providers.dart`
- **Purpose:** Riverpod wiring. Notably documents the historical swap: `vulnerabilityProviderProvider` now resolves to `RealVulnerabilityProvider` (M08's real implementation), replacing the M07-era `DefaultVulnerabilityProvider` neutral stand-in.
- **Status:** IMPLEMENTED.
- **Key providers:** `vulnerabilityProviderProvider`, `riskAssessmentServiceProvider`.
- **Depends on:** `core_providers.dart`, `environmental_providers.dart`, `real_vulnerability_provider.dart`, `vulnerability_providers.dart`.

### `lib/features/risk/domain/risk_assessment_result.dart`
- **Purpose:** The engine's output type — score plus every contributing factor, explicitly framed in-code as satisfying a "factor explanation" acceptance criterion (not just a bare number).
- **Status:** IMPLEMENTED.
- **Key content:** `riskModelVersion = '1.0.0'` (module-level constant — bump when formula/weights change). `RiskAssessmentResult` fields: `habitationId`, `hazardExposure`, `vulnerabilityIndex`, `hazardWeight`, `vulnerabilityWeight`, `riskScore`, `riskClass`, `contributingHazardZoneIds: List<String>`, `modelVersion`, `assessedAt`, plus M24 additions `environmentalAdjustment: double` (default `0.0`) and `environmentalProvenance: List<LocalEnvironmentalObservation>` (default `const []`).

### `lib/features/risk/domain/risk_class.dart`
- **Purpose:** The four-band risk classification and its thresholds.
- **Status:** IMPLEMENTED.
- **EXACT THRESHOLDS:** `classifyRiskScore(score)`: `>= 0.75 → red`, `>= 0.5 → high`, `>= 0.25 → moderate`, else `low`. `RiskClass.red.isRedZone == true` (all others `false`) — this is the blueprint's "red/high-risk zone" from the demo script.

### `lib/features/risk/domain/vulnerability_provider.dart`
- **Purpose:** The abstract contract risk assessment uses to obtain a vulnerability index, plus the original neutral stand-in implementation.
- **Status:** `VulnerabilityProvider` (abstract) — IMPLEMENTED (contract only). `DefaultVulnerabilityProvider` — **still present but superseded**: every habitation gets a flat `0.5`; kept in the codebase (used as a fixture in several other modules' tests, e.g. `_FixedVulnerabilityProvider` pattern) but no longer the production default — `risk_providers.dart` now wires `RealVulnerabilityProvider` (vulnerability module) instead.
- **Demo/mock content:** `DefaultVulnerabilityProvider` is explicitly a documented placeholder/neutral stand-in ("Neutral stand-in used until M08... computes a real, factor-based index"), now retired from production wiring but not deleted.

### `lib/features/risk/presentation/risk_class_color.dart`
- **Purpose:** Pure UI mapping from `RiskClass` to a `Color` and a human label, used by the map legend/overlay and dashboard — the only presentation-layer file in this module.
- **Status:** IMPLEMENTED.
- **Exact mapping:** `low → Colors.green.shade600` / "Low risk"; `moderate → Colors.yellow.shade800` / "Moderate risk"; `high → Colors.orange.shade700` / "High risk"; `red → Colors.red.shade900` / "Red zone".

### `test/features/risk/risk_assessment_service_test.dart`
- **Purpose:** In-memory-database integration tests of the orchestration layer: persists a row correctly, fails cleanly (writes nothing) for an unknown habitation, increments version on re-assessment, `assessAllHabitations` covers every cached habitation, and — explicitly — the same inputs reproduce the same score across repeated calls (reproducibility guard at the service layer, not just the engine layer).
- **Status:** IMPLEMENTED.

### `test/features/risk/risk_engine_test.dart`
- **Purpose:** Pure unit tests of `RiskEngine`, including an exact numeric check (`high` severity 0.75 intensity × 0.8 confidence = 0.6 hazard exposure), the worst-hazard-wins rule (a `low` and a `critical` overlapping zone yield exposure 1.0, not a sum or average), outside-zone exclusion, vulnerability clamping beyond `[0,1]`, red-zone classification at maximal inputs, and reproducibility.
- **Status:** IMPLEMENTED, and directly verifies the exact weight/formula documented above.

## Data Models

- **`RiskAssessmentResult`** — see fields listed above under its file dossier.
- **`RiskClass`** enum — `low`, `moderate`, `high`, `red`.
- **`LocalRiskAssessment`** (persisted row, `core/database/app_database.dart`) — `habitationId`, `hazardExposure`, `vulnerabilityIndex`, `riskScore`, `riskClass` (string), `modelVersion`, `contributingHazardZoneIdsJson`, `environmentalAdjustment`, `environmentalProvenanceJson`, `assessedAt`, `version`.

## Services / Engines / Repositories

- **`RiskEngine`** (pure): `riskScore = 0.6 * hazardExposure + 0.4 * vulnerabilityIndex`, clamped `[0,1]`; `hazardExposure` = max over overlapping zones of `severity.intensity * zone.confidence`. Model version `'1.0.0'`.
- **`RiskAssessmentService`** (orchestrator): loads inputs, calls the engine, optionally merges an environmental adjustment, persists with version tracking.
- **`RealVulnerabilityProvider`** (vulnerability module, wired here as the `VulnerabilityProvider` implementation) — see `vulnerability.md`.

## Module Data Flow

```
(no direct screen trigger in this module)
RelocationPriorityService.buildQueue()
  → RiskAssessmentService.assessAllHabitations(now)
      → for each LocalHabitation:
          RiskAssessmentService.assessHabitation(id, now)
            → LocalHabitationRepository.getById(id)
            → LocalHazardZoneRepository.getAll()
            → VulnerabilityProvider.vulnerabilityIndexFor(id)   (RealVulnerabilityProvider → VulnerabilityAssessmentService)
            → RiskEngine.assess(habitation, hazardZones, vulnerabilityIndex, now) → RiskAssessmentResult
            → [if EnvironmentalDataService present]
                EnvironmentalDataService.adjustmentFor(id, now) → EnvironmentalRiskAdjustment
                mergeEnvironmentalAdjustment(baseAssessment, adjustment) → adjusted RiskAssessmentResult
            → LocalRiskAssessmentRepository.save(LocalRiskAssessment)   (persisted, versioned)
      → returns List<RiskAssessmentResult>
  → consumed by RelocationPriorityEngine.assess() as the `risk` input

Separately (read-only, no recomputation):
map_data_providers.dart / dashboard_providers.dart
  → LocalRiskAssessmentRepository.getAll()  (whatever was last persisted)
  → riskClassColor(RiskClass.values.byName(row.riskClass)) for map/dashboard coloring
```

## Current Status

**Working**, with one real gap: the engine and orchestration are fully implemented, deterministic, and tested — but **nothing in production code triggers `RiskAssessmentService.assessHabitation`/`assessAllHabitations` except opening the Relocation Priority screen** (`relocationPriorityQueueProvider`, a `FutureProvider.autoDispose`). Until that screen has been opened at least once in a session (or a test/seed has run), `local_risk_assessments` may be empty, and the map/dashboard risk overlays would have nothing to show for a given habitation. The demo map seeder (`lib/features/map/application/demo_map_data_seeder.dart`) explicitly documents that it does **not** run the risk engine itself, deferring to a separate `RiskAssessmentService.assessAllHabitations` call.

## Known Limitations

- Risk assessment is only triggered as a side effect of building the relocation priority queue — there is no independent "recompute risk" action/button/route.
- `hazardExposure` uses worst-zone-wins, not a cumulative/compounding model — two overlapping hazard types do not increase exposure beyond the worse of the two.
- `DefaultVulnerabilityProvider` (flat 0.5) still exists in the codebase and could silently be re-wired in if `risk_providers.dart` were changed carelessly, since nothing enforces `RealVulnerabilityProvider` at the type level.
- No UI in this module surfaces the full factor breakdown (`hazardWeight`, `vulnerabilityWeight`, `contributingHazardZoneIds`) to a user — only the final `riskClass` reaches the map/dashboard.

## Test Coverage

Two test files, both real (in-memory DB / pure unit), no mocked engine internals:
- `risk_engine_test.dart` — pure formula correctness, exact numeric assertions, worst-hazard-wins, clamping, reproducibility, red-zone boundary.
- `risk_assessment_service_test.dart` — persistence, failure-on-unknown-habitation, version increments, batch coverage, reproducibility at the service layer.

**Not covered by any test in this module:** the M24 environmental-merge branch inside `RiskAssessmentService.assessHabitation` (that path is tested instead from the environmental module's `test/features/environmental/risk_assessment_environmental_integration_test.dart`); `risk_class_color.dart`'s color/label mapping has no test in this directory.
