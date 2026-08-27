# MODULE: Relocation

## Purpose

This module answers two related but distinct questions. First, per habitation: "if these people need to move, which specific shelters should they go to, ranked best-first, and why?" (`RelocationEngine` / `RelocationPlanningService`). Second, and the module's centerpiece: **across every habitation at once, which ones should be prioritized for relocation first, and why?** (`RelocationPriorityEngine` / `RelocationPriorityService`) — this is the app's relocation priority queue, combining the risk, capacity, and relocation-candidate assessments that already exist into one ranked, explainable list, rather than inventing a new source of truth.

## User-facing functionality

- **Relocation Priority Screen** (`RelocationPriorityScreen`, route `/relocation/priority`): the one screen in this module. Any role that can navigate to this route sees a ranked list (rank 1 = highest priority) of every cached habitation, each card showing its priority tier (Immediate/Short-term/Medium-term/Monitor, color-coded), risk score, population exposed, shelter capacity, shelter deficit, distance to nearest safe shelter, and accessibility rating. Tapping a card opens a dialog with the full plain-language reasoning list and the exact priority score/model version. A refresh icon in the app bar manually invalidates and recomputes the whole queue.
- No screen in this module exposes a single habitation's ranked relocation-candidate list (`RelocationPlan`/`RelocationCandidate`) directly — `RelocationPlanningService` is consumed only as an input to the priority engine in this scan, not rendered on its own.
- There is a separate route `/command/relocation` → `ManageRelocationScreen`, but that screen's source file is **outside this module's scope** (it lives in a different feature folder not listed in this assignment) and is not documented here.

## Entry points

- Route `/relocation/priority` in `lib/app/router.dart` → `RelocationPriorityScreen`.
- `relocationPriorityQueueProvider` (a `FutureProvider.autoDispose<List<RelocationPriorityResult>>`) is watched only by `RelocationPriorityScreen` in this scan — it is the sole trigger for the whole underlying risk/vulnerability/capacity/relocation-planning computation chain across the entire app (see risk.md, vulnerability.md, capacity.md "Current Status" — all three note the same single trigger point).
- `relocationPlanningServiceProvider` (in `relocation_providers.dart`) has exactly one external consumer: `relocation_priority_providers.dart`.

## Architecture

Domain/application/presentation layering, no `data/` folder (persistence via `LocalRelocationPlanRepository`, outside this module):

- **domain/** — `RelocationCandidate` + `RelocationPlan` (per-habitation planning output, `relocationModelVersion`); `RelocationPriorityResult` (queue-entry output, `relocationPriorityModelVersion`); `RelocationPriorityTier` enum + `classifyPriorityScore`.
- **application/** — two independent pure engines (`RelocationEngine`, `RelocationPriorityEngine`) and two orchestrating services (`RelocationPlanningService`, `RelocationPriorityService`), plus two provider files (`relocation_providers.dart` for planning, `relocation_priority_providers.dart` for the priority queue — kept separate).
- **presentation/** — `RelocationPriorityScreen` (the queue UI) plus two private widgets (`_PriorityCard`, `_Stat`) in the same file.

## Files in this module

### `lib/features/relocation/application/relocation_engine.dart`
- **Purpose:** Ranks shelters as relocation destinations for one habitation. Two hard gates (hazard-exposed shelter, or no spare capacity) exclude a shelter as a candidate entirely; survivors are scored on four weighted factors. Explicitly documented as differing from the capacity module: distance here is *scored*, not a hard cutoff, so a plan still surfaces the best available option even if it's far.
- **Status:** IMPLEMENTED, pure.
- **Key functions:** `RelocationEngine.plan({habitation, populationToRelocate, shelters, hazardZones, maxRelevantDistanceMeters, now})` → `RelocationPlan`; private `_decodeFacilities`, `_buildReasons`.
- **EXACT FORMULA:**
  ```
  distanceWeight = 0.3
  capacityWeight = 0.3
  accessWeight = 0.2
  facilitiesWeight = 0.2
  defaultMaxRelevantDistanceMeters = 15000   // 15 km
  facilitiesReferenceCount = 3

  Hard gates (shelter excluded entirely, not scored, if either fails):
      isPointHazardExposed(shelterPoint, hazardZones) → excluded
      availableCapacity = capacityTotal - occupancy; <= 0 → excluded

  For each surviving shelter:
      distanceScore    = (1 - distanceMeters / maxRelevantDistanceMeters).clamp(0,1)
      capacityScore    = populationToRelocate <= 0 ? 1.0
                          : (availableCapacity / populationToRelocate).clamp(0,1)
      accessScore       = (1 - (shelter.accessQuality ?? 0.5)).clamp(0,1)
      facilitiesScore   = (facilities.length / 3).clamp(0,1)
      compositeScore    = 0.3*distanceScore + 0.3*capacityScore + 0.2*accessScore + 0.2*facilitiesScore

  Candidates sorted descending by compositeScore.
  ```
  Model version: `relocationModelVersion = '1.0.0'`.
- **Reasons:** every candidate gets exactly 4 plain-language reason strings — distance in km; capacity sufficiency vs. `populationToRelocate`; access quality label (or "Access not yet surveyed" if `accessQuality` is null); facilities list (or "No special facilities recorded").
- **Depends on:** `core/gis/hazard_exposure.dart`. **Depended on by:** `RelocationPlanningService`.
- **Demo/mock content:** none — every factor is a real computation over real repository data (though `accessQuality`/`facilitiesJson` on `LocalShelter` may themselves be unconfigured/empty in practice, same caveat as the vulnerability module's configured indicators).

### `lib/features/relocation/application/relocation_planning_service.dart`
- **Purpose:** Orchestrates one habitation's relocation plan: determines `populationToRelocate` (same hazard-exposure determination the capacity module uses, so both agree on who's at risk, unless overridden), runs `RelocationEngine`, persists.
- **Status:** IMPLEMENTED.
- **Key functions:** `RelocationPlanningService.planForHabitation(habitationId, {populationOverride, maxRelevantDistanceMeters, now})` → `Result<RelocationPlan>` — `populationOverride` lets a caller plan for a hypothetical scenario ("what if we had to move 300 people") even for a non-exposed habitation. `planForAllHabitations({now})` → best-effort batch.
- **Depends on:** `LocalHabitationRepository`, `LocalHazardZoneRepository`, `LocalShelterRepository`, `LocalRelocationPlanRepository`, `RelocationEngine`, `isPointHazardExposed`. **Depended on by:** `relocation_providers.dart`, `RelocationPriorityService`.
- **State:** reads `local_habitations`, `local_hazard_zones`, `local_shelters`; reads+writes `local_relocation_plans` (one current row per habitation, versioned).

### `lib/features/relocation/application/relocation_priority_engine.dart`
- **Purpose:** **The centerpiece.** Answers "which habitations should be prioritized for relocation" by deterministically combining three already-computed assessments (risk, capacity gap, relocation candidates) into one priority score and time-horizon tier, with plain-language reasoning. Explicitly documented as pure — "no I/O — so the same three inputs always produce the same result."
- **Status:** IMPLEMENTED, pure. This is the newest and most heavily documented engine in the codebase.
- **Key functions:** `RelocationPriorityEngine.assess({habitation, risk, capacity, relocationPlan, maxRelevantDistanceMeters, hazardZoneSources, now})` → `RelocationPriorityResult`; private `_buildReasoning`.
- **EXACT FORMULA — THE RELOCATION PRIORITY WEIGHTS:**
  ```
  riskWeight = 0.4
  capacityWeight = 0.3
  distanceWeight = 0.2
  accessibilityWeight = 0.1
  defaultMaxRelevantDistanceMeters = 15000   // matches RelocationEngine's own default

  bestCandidate = relocationPlan.rankedCandidates.isEmpty ? null : rankedCandidates.first

  distanceDifficulty = bestCandidate == null ? 1.0   // no reachable shelter = worst possible, not undefined
                        : (bestCandidate.distanceMeters / maxRelevantDistanceMeters).clamp(0,1)

  capacityGapRatio = capacity.exposedPopulation <= 0 ? 0.0
                      : (capacity.capacityGap / capacity.exposedPopulation).clamp(0,1)

  accessibilityDifficulty = (habitation.accessQuality ?? 0.5).clamp(0,1)

  priorityScore = (0.4 * risk.riskScore
                  + 0.3 * capacityGapRatio
                  + 0.2 * distanceDifficulty
                  + 0.1 * accessibilityDifficulty).clamp(0.0, 1.0)

  priorityTier = classifyPriorityScore(priorityScore)
  ```
  Model version: `relocationPriorityModelVersion = '1.0.0'`.
- **Weight rationale (from in-code doc comment):** risk (0.4) is the foundational "is this place dangerous" signal; capacity shortfall (0.3) is weighted almost as heavily because a moderately-at-risk habitation can still be urgent if nowhere nearby can take the population; distance (0.2) and accessibility (0.1) modulate urgency by how hard the move itself would be — real but secondary to danger + capacity.
- **Reasoning generation:** builds a `List<String>` covering: risk class + score + hazard-exposure% + vulnerability%; exposed-population vs. capacity sufficiency/shortfall wording (or "Not currently inside a mapped hazard zone" if `exposedPopulation == 0`); nearest viable shelter name+distance, or the explicit sentence *"No hazard-free shelter with available capacity was found within range — the most severe finding this assessment can report"* when `bestCandidate` is null; an accessibility warning if `accessibilityDifficulty >= 0.7`; hazard data source attribution if any were supplied; and always a final "Recommended: {tier.recommendedAction}" line.
- **Depends on:** `RiskAssessmentResult`, `CapacityGapResult`, `RelocationCandidate`/`RelocationPlan`, `RelocationPriorityTier`. **Depended on by:** `RelocationPriorityService`.
- **Demo/mock content:** none — this is a real, tested, deterministic formula, not a placeholder despite being the newest engine.

### `lib/features/relocation/application/relocation_priority_providers.dart`
- **Purpose:** Riverpod wiring for the priority engine/service, and the queue provider the screen watches.
- **Status:** IMPLEMENTED.
- **Key providers:** `relocationPriorityEngineProvider`, `relocationPriorityServiceProvider` (wires in `riskAssessmentServiceProvider`, `capacityAssessmentServiceProvider`, `relocationPlanningServiceProvider` — this is the file that ties the entire risk→capacity→relocation pipeline together), `relocationPriorityQueueProvider` — a `FutureProvider.autoDispose`, deliberately not a stream, because recomputing risk/capacity/relocation for every habitation "isn't free"; documented as matching the app's convention of treating assessment refreshes as an explicit action, not continuous.

### `lib/features/relocation/application/relocation_priority_service.dart`
- **Purpose:** Orchestrates the whole priority queue build: re-runs the risk, capacity, and relocation-planning batch methods for every cached habitation, resolves hazard-zone source attribution once per run (not per habitation, for efficiency), combines each habitation's three results through the engine, and sorts the result descending by priority score.
- **Status:** IMPLEMENTED.
- **Key functions:** `RelocationPriorityService.buildQueue({now})` → `Future<List<RelocationPriorityResult>>`.
- **Notable behavior:** a habitation missing *any* of the three assessments (risk, capacity, or plan — e.g. from a transient per-habitation failure inside one of those services' best-effort batch loops) is **skipped entirely, not shown with a fabricated score** — explicitly documented: "the queue never invents a priority for data it doesn't actually have." Hazard-zone `source` strings are looked up once into a `Map<zoneId, source>` and passed through to the engine's reasoning as `hazardZoneSources` for each habitation's `contributingHazardZoneIds`.
- **Depends on:** `LocalHabitationRepository`, `LocalHazardZoneRepository`, `RiskAssessmentService`, `CapacityAssessmentService`, `RelocationPlanningService`, `RelocationPriorityEngine`. **Depended on by:** `relocation_priority_providers.dart`.
- **State:** reads `local_habitations`, `local_hazard_zones`; triggers writes to `local_risk_assessments`, `local_capacity_assessments`, `local_relocation_plans` (via the three services it calls) — this single method is what actually populates those three tables in production, as documented in risk.md/vulnerability.md/capacity.md.

### `lib/features/relocation/application/relocation_providers.dart`
- **Purpose:** Riverpod wiring for the per-habitation planning side (distinct from the priority-queue wiring above).
- **Status:** IMPLEMENTED.
- **Key providers:** `relocationEngineProvider`, `relocationPlanningServiceProvider`.

### `lib/features/relocation/domain/relocation_candidate.dart`
- **Purpose:** Per-habitation planning output types.
- **Status:** IMPLEMENTED.
- **Key content:** `relocationModelVersion = '1.0.0'`. `RelocationCandidate` — `shelterId`, `shelterName`, `availableCapacity`, `distanceMeters`, `distanceScore`, `capacityScore`, `accessScore`, `facilitiesScore`, `compositeScore`, `reasons: List<String>`. `RelocationPlan` — `habitationId`, `populationToRelocate`, `rankedCandidates: List<RelocationCandidate>`, `modelVersion`, `plannedAt`. Explicitly documented: shelters failing the hard gates never appear in `rankedCandidates` at all ("isn't a 'worse candidate', it isn't a candidate").

### `lib/features/relocation/domain/relocation_priority_result.dart`
- **Purpose:** The priority-queue entry output type — "every field a caller... would need to both display a ranked list and let an official interrogate a single entry."
- **Status:** IMPLEMENTED.
- **Key content:** `relocationPriorityModelVersion = '1.0.0'`. `RelocationPriorityResult` fields: `habitationId`, `habitationName`, `priorityScore`, `priorityTier`, `riskScore`, `riskClass`, `populationExposed`, `shelterCapacity`, `capacityGap`, `nearestSafeShelterId`/`nearestSafeShelterName`/`distanceToShelterMeters` (all nullable — null when no viable candidate exists), `accessibilityDifficulty`, `recommendedAction`, `reasoning: List<String>`, `modelVersion`, `assessedAt`.

### `lib/features/relocation/domain/relocation_priority_tier.dart`
- **Purpose:** The time-horizon action bucket a priority score falls into — explicitly distinguished in-code from `RiskClass`: risk says "how dangerous," priority says "how soon do we need to act, given danger, capacity, and how hard the move would be."
- **Status:** IMPLEMENTED.
- **EXACT TIER THRESHOLDS:** `classifyPriorityScore(score)`: `>= 0.75 → immediate`, `>= 0.55 → shortTerm`, `>= 0.35 → mediumTerm`, else `monitor`.
- **Recommended actions (exact strings):**
  - `immediate` → "Begin relocation planning now — coordinate with District/Command."
  - `shortTerm` → "Plan relocation within the current season; confirm shelter capacity."
  - `mediumTerm` → "Schedule a capacity/vulnerability review; no immediate action required."
  - `monitor` → "No action required — continue routine monitoring."

### `lib/features/relocation/presentation/relocation_priority_screen.dart`
- **Purpose:** The queue UI — a ranked `ListView` of `_PriorityCard`s, each tappable for a full-reasoning dialog.
- **Status:** IMPLEMENTED, wired to the real `relocationPriorityQueueProvider` (not mock data).
- **Key classes:** `RelocationPriorityScreen` (`ConsumerWidget`), `_PriorityCard`, `_Stat`, plus module-local helpers `_accessibilityLabel(difficulty)` (Difficult ≥0.7, Moderate ≥0.4, else Easy) and `_tierColor(tier)` (immediate `#B3261E`, shortTerm `#B4540A`, mediumTerm `#8C7A1A`, monitor `#3F7A4D`).
- **Depends on:** `relocationPriorityQueueProvider`, `shared/widgets/async_state_views.dart` (`LoadingView`/`ErrorView`/`EmptyView`), `shared/widgets/severity_chip.dart` (`StatusPill`).
- **State:** none of its own beyond what the provider holds; pull-to-refresh and the app-bar refresh icon both call `ref.invalidate(relocationPriorityQueueProvider)`.

### `test/features/relocation/relocation_engine_test.dart`
- **Purpose:** Pure formula tests — hazard-exposed shelter never a candidate; full shelter never a candidate; a distant-but-safe shelter still appears (contrasted explicitly with the capacity module's hard cutoff) with `distanceScore == 0.0`; best-first ranking by composite score; every candidate carries exactly 4 reasons; unconfigured access quality produces the "Access not yet surveyed" reason; zero `populationToRelocate` yields full-confidence (`1.0`) capacity score; model version/habitation id carried through.
- **Status:** IMPLEMENTED.

### `test/features/relocation/relocation_planning_service_test.dart`
- **Purpose:** Integration tests — non-exposed habitation defaults to zero population to relocate; exposed habitation plans for its full population; `populationOverride` produces a hypothetical-scenario plan; persists a decodable ranked-candidates JSON; unknown-habitation failure writes nothing; version increments; `planForAllHabitations` covers every cached habitation.
- **Status:** IMPLEMENTED.

### `test/features/relocation/relocation_priority_engine_test.dart`
- **Purpose:** Pure formula tests of the priority engine — high risk + large shortfall + no reachable shelter → `immediate` tier with score `> 0.75` and the exact "No hazard-free shelter..." reasoning sentence; low risk + full capacity + nearby shelter → `monitor`; a capacity shortfall raises the score at equal risk (isolates the `capacityWeight` term); difficult site access raises the score (isolates `accessibilityWeight`); hazard-zone sources are surfaced in reasoning only when supplied; reasoning is never empty and always carries the model version.
- **Status:** IMPLEMENTED — this test file is the ground truth for the exact weight formula documented above, verified via isolated single-factor comparisons (e.g. same risk/capacity/distance, only `accessQuality` differs, and the harder-access result scores strictly higher).

### `test/features/relocation/relocation_priority_service_test.dart`
- **Purpose:** Full-pipeline integration test wiring real `RiskAssessmentService`, `CapacityAssessmentService`, and `RelocationPlanningService` instances (not mocks) against an in-memory DB. Verifies an empty habitation table produces an empty queue, and — the module's headline scenario — a habitation inside a hazard zone with no nearby shelter ranks first with tier `immediate` and its hazard zone's `source` string ("Geological Survey of India") appears in the reasoning, while a safe habitation ranks last with no hazard-source mention.
- **Status:** IMPLEMENTED. This is the closest thing in the codebase to an end-to-end test of the entire scoring pipeline (hazards → risk → capacity → relocation → priority) in one file.

## Data Models

- **`RelocationCandidate`** — `shelterId`, `shelterName`, `availableCapacity: int`, `distanceMeters: double`, `distanceScore`, `capacityScore`, `accessScore`, `facilitiesScore`, `compositeScore`, `reasons: List<String>`.
- **`RelocationPlan`** — `habitationId`, `populationToRelocate: int`, `rankedCandidates: List<RelocationCandidate>`, `modelVersion`, `plannedAt`.
- **`RelocationPriorityResult`** — see full field list above.
- **`LocalRelocationPlan`** (persisted row) — `habitationId`, `populationToRelocate`, `rankedCandidatesJson`, `modelVersion`, `plannedAt`, `version`.
- **`RelocationPriorityTier`** — `immediate`, `shortTerm`, `mediumTerm`, `monitor` (each with a `label` and `recommendedAction` string).

## Services / Engines / Repositories

- **`RelocationEngine`** (pure) — per-habitation shelter ranking: `0.3*distance + 0.3*capacity + 0.2*access + 0.2*facilities`, two hard gates (hazard exposure, zero capacity), model version `'1.0.0'`.
- **`RelocationPriorityEngine`** (pure, the flagship engine) — cross-habitation priority scoring: `0.4*risk + 0.3*capacityGapRatio + 0.2*distanceDifficulty + 0.1*accessibilityDifficulty`, tiered at `0.75/0.55/0.35`, model version `'1.0.0'`.
- **`RelocationPlanningService`** (orchestrator) — per-habitation plan persistence.
- **`RelocationPriorityService`** (orchestrator) — the queue-builder that actually drives risk/capacity/relocation computation for the whole app.

## Module Data Flow

```
RelocationPriorityScreen (route /relocation/priority)
  → relocationPriorityQueueProvider (FutureProvider.autoDispose)
      → RelocationPriorityService.buildQueue(now)
          → LocalHabitationRepository.getAll()
          → LocalHazardZoneRepository.getAll()              → sourceByZoneId map
          → RiskAssessmentService.assessAllHabitations(now)        → List<RiskAssessmentResult>      [risk.md]
          → CapacityAssessmentService.assessAllHabitations(now)    → List<CapacityGapResult>          [capacity.md]
          → RelocationPlanningService.planForAllHabitations(now)   → List<RelocationPlan>             [this module]
              → (per habitation) RelocationEngine.plan(...)
          → for each habitation with all three results present:
              RelocationPriorityEngine.assess(habitation, risk, capacity, relocationPlan, hazardZoneSources, now)
                  → RelocationPriorityResult { priorityScore, priorityTier, reasoning[] }
          → queue.sort(by priorityScore, descending)
          → List<RelocationPriorityResult>
  → RelocationPriorityScreen renders _PriorityCard per entry, rank = index + 1
  → tap → dialog shows result.reasoning + priorityScore + modelVersion
```

## Current Status

**Working** — this is the most complete, most heavily tested, and most heavily documented module in the whole scoring cluster. `RelocationPriorityEngine` and `RelocationEngine` are both pure, deterministic, carry model-version constants, and produce explicit weighted-factor breakdowns with human-readable reasoning — fully matching the architectural rule this handover was asked to verify. The one real caveat: this module's `buildQueue()` is simultaneously the *only* production trigger for the risk, vulnerability, and capacity modules' assessment computation (see those modules' "Current Status" sections) — so this screen is not just a consumer of the pipeline, it is structurally the pipeline's ignition switch.

## Known Limitations

- `relocationPriorityQueueProvider` is `autoDispose` and recomputed from scratch (re-running risk + capacity + relocation planning for every habitation) every time the screen opens or is refreshed — no incremental/cached recompute.
- A habitation missing any one of the three underlying assessments is silently dropped from the queue rather than shown with a partial/error state — correct per its own stated design principle (never fabricate a score) but means a transient failure elsewhere is invisible on this screen.
- `RelocationEngine`'s capacity scoring does not account for two habitations in the same batch competing for the same shelter (same limitation as the capacity module, inherited here).
- `ManageRelocationScreen` (route `/command/relocation`) exists in the router but its source is outside this module's assigned scope, so its relationship to `RelocationPlan`/`RelocationCandidate` could not be verified as part of this document.

## Test Coverage

Four test files — the most thorough test coverage of any module in this cluster:
- `relocation_engine_test.dart` — full per-shelter scoring formula, both hard gates, reasons generation.
- `relocation_planning_service_test.dart` — persistence, population-override scenario planning, versioning.
- `relocation_priority_engine_test.dart` — the priority formula verified via isolated single-factor comparisons, tier boundaries, reasoning content (including the exact "No hazard-free shelter..." sentence).
- `relocation_priority_service_test.dart` — a genuine end-to-end integration test across real risk/capacity/relocation-planning service instances, including the hazard-source-attribution flow-through into reasoning text.

**Not covered by any test in this module:** `RelocationPriorityScreen`'s UI (card layout, tier coloring, reasoning dialog) has no widget test in `test/features/relocation/`; no test exercises `relocationPriorityQueueProvider`'s `autoDispose`/recompute-on-invalidate behavior directly (only the underlying service is tested).
