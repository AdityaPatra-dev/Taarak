# MODULE: Capacity

## Purpose

This module answers, per habitation: "if the population currently exposed to a hazard had to move to shelter right now, is there actually enough *safe, reachable* shelter capacity for them — and if not, by how much are we short?" It is deliberately a per-habitation calculation only — it does not resolve two habitations competing for the same nearby shelter's beds (that contention is the relocation module's job). It also computes hazard exposure independently of the risk module, so a capacity assessment doesn't require a risk assessment to have run first.

## User-facing functionality

**No screens.** This module has no `presentation/` folder at all and nothing in its 4 files renders `CapacityGapResult` to a user. Its output is consumed programmatically by the relocation module.

## Entry points

- `capacityAssessmentServiceProvider` (in `capacity_providers.dart`) has exactly one external consumer found in this scan: `lib/features/relocation/application/relocation_priority_providers.dart` (via `RelocationPriorityService`). No screen or other module calls in directly.

## Architecture

Domain/application layering only — no `presentation/`, no `data/` (persistence via `LocalCapacityAssessmentRepository`, outside this module):

- **domain/** — `CapacityGapResult` + `ContributingShelter` (output types, with `capacityModelVersion`).
- **application/** — `CapacityGapEngine` (pure engine), `CapacityAssessmentService` (orchestrator), `capacity_providers.dart` (Riverpod wiring).

## Files in this module

### `lib/features/capacity/application/capacity_assessment_service.dart`
- **Purpose:** Orchestrates one habitation's capacity-gap assessment: independently determines whether the habitation is currently hazard-exposed (via `isPointHazardExposed`, shared with the relocation module), runs `CapacityGapEngine`, persists the result.
- **Status:** IMPLEMENTED.
- **Key functions:** `CapacityAssessmentService.assessHabitation(habitationId, {accessibleRadiusMeters, now})` → `Result<CapacityGapResult>`; `assessAllHabitations({now})` → best-effort batch (per-habitation failures skipped).
- **Depends on:** `LocalHabitationRepository`, `LocalHazardZoneRepository`, `LocalShelterRepository`, `LocalCapacityAssessmentRepository`, `CapacityGapEngine`, `core/gis/hazard_exposure.isPointHazardExposed`. **Depended on by:** `capacity_providers.dart`, `RelocationPriorityService`.
- **State:** reads `local_habitations`, `local_hazard_zones`, `local_shelters`; reads+writes `local_capacity_assessments` (one current row per habitation, versioned).
- **Demo/mock content:** none.

### `lib/features/capacity/application/capacity_gap_engine.dart`
- **Purpose:** The deterministic core. Filters shelters to only those that are (a) not themselves hazard-exposed and (b) within an accessible radius, sums their spare capacity, and reports the gap against the exposed population.
- **Status:** IMPLEMENTED, pure (documented explicitly: "given the same habitation, shelters and hazard zones, always the same gap").
- **Key functions:** `CapacityGapEngine.assess({habitation, exposedPopulation, shelters, hazardZones, accessibleRadiusMeters, now})` → `CapacityGapResult`.
- **EXACT FORMULA/THRESHOLDS:**
  ```
  defaultAccessibleRadiusMeters = 15000   // 15 km

  For each shelter:
      skip if isPointHazardExposed(shelterPoint, hazardZones)      // hard gate 1
      distance = greatCircleDistance(habitationPoint, shelterPoint)
      skip if distance > accessibleRadiusMeters                     // hard gate 2
      available = shelter.capacityTotal - shelter.occupancy
      skip if available <= 0                                        // hard gate 3
      → included as a ContributingShelter, sorted nearest-first

  availableSafeCapacity = sum(contributing shelters' available capacity)
  capacityGap = exposedPopulation - availableSafeCapacity   // positive = shortfall
  hasSufficientCapacity = capacityGap <= 0
  ```
  Model version: `capacityModelVersion = '1.0.0'`.
- **Depends on:** `core/gis/hazard_exposure.dart`. **Depended on by:** `CapacityAssessmentService`.
- **State:** none (pure).

### `lib/features/capacity/application/capacity_providers.dart`
- **Purpose:** Riverpod wiring.
- **Status:** IMPLEMENTED.
- **Key providers:** `capacityGapEngineProvider`, `capacityAssessmentServiceProvider`.

### `lib/features/capacity/domain/capacity_gap_result.dart`
- **Purpose:** Output types.
- **Status:** IMPLEMENTED.
- **Key content:** `capacityModelVersion = '1.0.0'`. `ContributingShelter` — `shelterId`, `shelterName`, `availableCapacity`, `distanceMeters`. `CapacityGapResult` — `habitationId`, `exposedPopulation` (int — full population if inside a hazard zone, else 0; explicitly framed as exposure, not vulnerability or risk), `availableSafeCapacity`, `capacityGap`, `hasSufficientCapacity` (getter: `capacityGap <= 0`), `contributingShelters: List<ContributingShelter>`, `accessibleRadiusMeters`, `modelVersion`, `assessedAt`.

### `test/features/capacity/capacity_assessment_service_test.dart`
- **Purpose:** In-memory DB integration tests — a habitation outside any hazard zone has zero exposed population and sufficient capacity by definition; a habitation inside a hazard zone counts its full population; unknown-habitation failure writes nothing; a decodable contributing-shelters JSON breakdown is persisted with an exact numeric check (`500 exposed - 300 available = 200` gap); version increments on re-assessment; `assessAllHabitations` covers every cached habitation.
- **Status:** IMPLEMENTED.

### `test/features/capacity/capacity_gap_engine_test.dart`
- **Purpose:** Pure formula tests — zero exposure means no shortfall regardless of shelters; a sufficient nearby shelter closes the gap (negative gap = surplus); insufficient capacity produces a positive gap; a shelter inside a hazard zone contributes nothing; a shelter beyond the accessible radius (~780km test case) is excluded; a full shelter (`occupancy == capacityTotal`) contributes nothing; multiple shelters sum correctly and sort nearest-first; model version is carried through.
- **Status:** IMPLEMENTED, and directly verifies every hard gate and the exact gap arithmetic documented above.

## Data Models

- **`ContributingShelter`** — `shelterId`, `shelterName`, `availableCapacity: int`, `distanceMeters: double`.
- **`CapacityGapResult`** — `habitationId`, `exposedPopulation: int`, `availableSafeCapacity: int`, `capacityGap: int`, `hasSufficientCapacity: bool` (derived), `contributingShelters: List<ContributingShelter>`, `accessibleRadiusMeters: double`, `modelVersion: String`, `assessedAt: DateTime`.
- **`LocalCapacityAssessment`** (persisted row) — `habitationId`, `exposedPopulation`, `availableSafeCapacity`, `capacityGap`, `hasSufficientCapacity`, `contributingSheltersJson`, `accessibleRadiusMeters`, `modelVersion`, `assessedAt`, `version`.

## Services / Engines / Repositories

- **`CapacityGapEngine`** (pure): three hard gates (hazard-exposed shelter excluded; beyond-radius excluded; zero/negative spare capacity excluded), then `capacityGap = exposedPopulation - availableSafeCapacity`. Accessible radius default `15000` m. Model version `'1.0.0'`.
- **`CapacityAssessmentService`** (orchestrator): independently computes hazard exposure (does not depend on the risk module having run), calls the engine, persists.

## Module Data Flow

```
RelocationPriorityService.buildQueue()
  → CapacityAssessmentService.assessAllHabitations(now)
      → for each LocalHabitation:
          CapacityAssessmentService.assessHabitation(id, now)
            → LocalHabitationRepository.getById(id)
            → LocalHazardZoneRepository.getAll()
            → LocalShelterRepository.getAll()
            → isPointHazardExposed(habitationPoint, hazardZones)  → exposedPopulation = pop or 0
            → CapacityGapEngine.assess(habitation, exposedPopulation, shelters, hazardZones, radius, now)
                → CapacityGapResult { availableSafeCapacity, capacityGap, contributingShelters[] }
            → LocalCapacityAssessmentRepository.save(...)          (persisted, versioned)
      → returns List<CapacityGapResult>
  → consumed by RelocationPriorityEngine.assess() as the `capacity` input
    (specifically capacity.exposedPopulation and capacity.capacityGap, via capacityGapRatio)
```

## Current Status

**Working**, with the same triggering gap as risk/vulnerability: nothing in production code calls `CapacityAssessmentService.assessHabitation`/`assessAllHabitations` outside `RelocationPriorityService.buildQueue()`. The engine and orchestration are fully implemented, deterministic, and tested with exact numeric assertions.

## Known Limitations

- Explicitly single-habitation scoped: does not account for two habitations' populations both competing for the same nearby shelter's spare beds — a shelter could be double-counted as "available" for multiple habitations in the same batch run.
- No screen surfaces `CapacityGapResult` to any user directly (only indirectly, as an input to the relocation-priority reasoning text).
- `accessibleRadiusMeters` is a hard cutoff (unlike the relocation module's distance scoring, which degrades gracefully instead of excluding); a shelter one meter beyond 15km contributes nothing at all.

## Test Coverage

Two test files, both thorough with exact numeric assertions rather than only range checks:
- `capacity_gap_engine_test.dart` — every hard gate individually isolated, plus multi-shelter summation/sorting.
- `capacity_assessment_service_test.dart` — persistence, exact gap arithmetic, versioning, batch coverage.

**Not covered by any test in this module:** no test exercises the interaction between two habitations sharing a nearby shelter (consistent with the documented single-habitation scope, but also means that limitation's actual behavior — e.g. does not prevent double-counting — is not verified, just structurally implied).
