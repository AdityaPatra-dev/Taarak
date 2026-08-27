# MODULE: Susceptibility

## Purpose

This module is a **deliberate extension point, not a working feature**. It exists to answer a question distinct from the risk module's: risk asks "given hazard zones we already know about, how dangerous is this habitation"; susceptibility is meant to ask "how likely is a hazard to occur at this location *in the first place*, independent of whether anyone has mapped a hazard zone there yet" — the way the Geological Survey of India's own landslide-susceptibility mapping works. As of this codebase, that question has **no working answer**: the module defines the contract and the output shape a real trained model would fill in, and ships exactly one implementation, which always returns nothing.

## User-facing functionality

**None whatsoever.** There is no `presentation/` folder, no screen, and — confirmed by a repository-wide search — **no file outside `lib/features/susceptibility/` references `hazardSusceptibilityModelProvider`, `HazardSusceptibilityModel`, or `HazardSusceptibilityPrediction`**. This module is fully disconnected from the rest of the app. No role can see a susceptibility prediction anywhere in the current UI.

## Entry points

**None.** `hazardSusceptibilityModelProvider` is defined but never watched by any other provider, service, or screen in the codebase. This module is dead wiring today — present, compiling, tested-by-inspection-only, but not reachable from any user action.

## Architecture

Domain/application layering, no presentation layer, no data/repository layer (there is nothing to persist — a prediction is never computed):

- **domain/** — `HazardSusceptibilityPrediction` (the output shape a real model would eventually produce).
- **application/** — `HazardSusceptibilityModel` (abstract contract) + `UnavailableHazardSusceptibilityModel` (the only implementation), `susceptibility_providers.dart` (Riverpod wiring for a provider nothing watches).

## Files in this module

### `lib/features/susceptibility/application/hazard_susceptibility_model.dart`
- **Purpose:** Defines the contract a real trained hazard-susceptibility model would implement, and ships the one implementation that exists today — a model that always declines to predict.
- **Status:** `HazardSusceptibilityModel` (abstract) — PLACEHOLDER (contract only, no working implementation exists). `UnavailableHazardSusceptibilityModel` — **DELIBERATE STUB, verified**, not a bug and not fabricated AI output.
- **Key classes:**
  - `HazardSusceptibilityModel` (abstract) — `Future<HazardSusceptibilityPrediction?> predict({latitude, longitude, now})`.
  - `UnavailableHazardSusceptibilityModel implements HazardSusceptibilityModel` — `predict(...)` unconditionally `async => null`. **This is the exact class and method the handover was asked to verify.**
- **Verified behavior (read directly from source, reproduced verbatim):**
  ```dart
  class UnavailableHazardSusceptibilityModel implements HazardSusceptibilityModel {
    const UnavailableHazardSusceptibilityModel();

    @override
    Future<HazardSusceptibilityPrediction?> predict({
      required double latitude,
      required double longitude,
      DateTime? now,
    }) async => null;
  }
  ```
- **In-code justification (direct quote from the doc comment on this class):** "Always returns `null` — deliberately, not as an oversight. A model that fabricated a number here (even a 'reasonable-looking' deterministic one) would be exactly the kind of fake AI claim this project's own engineering rules rule out: nothing has been trained on real hazard data yet, so nothing should present as if it had been."
- **What a real implementation would require (documented, not built):** a trained model — explicitly specified as logistic regression or a shallow gradient-boosted tree, *not* a deep net, because a linear model's feature weights are directly presentable ("slope contributed 40% to this prediction") — trained offline against GSI's public landslide inventory plus SRTM terrain features and rainfall (sourced via the environmental module's `EnvironmentalDataSource`), then ported into pure Dart the same way the app's other hand-written engines are (no on-device model runtime, no new dependency, fully offline-capable).
- **Depends on:** `HazardSusceptibilityPrediction`. **Depended on by:** `susceptibility_providers.dart` only.
- **State:** none.
- **External communication:** none.
- **Demo/mock content:** `UnavailableHazardSusceptibilityModel` is the module's only "mock," and it is an honest one — it returns `null`, never a fabricated number.

### `lib/features/susceptibility/application/susceptibility_providers.dart`
- **Purpose:** Riverpod wiring, intended so a future real model can be swapped in with every watcher picking up the change automatically.
- **Status:** IMPLEMENTED (as wiring) but UNUSED — no other provider/service/screen watches it.
- **Key providers:** `hazardSusceptibilityModelProvider` → resolves to `const UnavailableHazardSusceptibilityModel()`.

### `lib/features/susceptibility/domain/hazard_susceptibility_prediction.dart`
- **Purpose:** The output shape a real prediction would take, designed to match the rest of the pipeline's "never just a number" convention.
- **Status:** IMPLEMENTED (plain data class), currently unused since nothing ever constructs one outside of what a future real model would.
- **Key content:** `HazardSusceptibilityPrediction` — `score: double`, `modelName: String`, `modelVersion: String`, `featureContributions: Map<String, double>` (e.g. `{'slope': 0.41, 'rainfall_72h': 0.33, ...}` per the doc comment — illustrative only, no such map is ever actually produced today), `confidence: double`, `predictedAt: DateTime`.

## Data Models

- **`HazardSusceptibilityPrediction`** — see fields above. No instance of this class is ever created anywhere in the current codebase outside of what a hypothetical future model would return.

## Services / Engines / Repositories

- **`UnavailableHazardSusceptibilityModel`** — the module's only "service." Not an engine in the sense the rest of this cluster uses the word (no computation happens); it is a typed `null`.

## Module Data Flow

```
(no caller anywhere in the codebase)

Intended future flow, per the module's own doc comments (NOT implemented):
  some caller → HazardSusceptibilityModel.predict(latitude, longitude, now)
    → [a trained logistic-regression/GBT model, ported to pure Dart, evaluated against
       GSI landslide inventory + SRTM terrain + rainfall features]
    → HazardSusceptibilityPrediction { score, featureContributions, confidence }

Actual flow today:
  hazardSusceptibilityModelProvider → UnavailableHazardSusceptibilityModel → predict() → null
```

## Current Status

**PLACEHOLDER / deliberate stub — confirmed, not a bug.** `UnavailableHazardSusceptibilityModel.predict()` unconditionally returns `null` for every input. This is the single most important finding for this module: **there is no trained model, no ML inference, and no fabricated "AI prediction" anywhere in this codebase.** The architecture, contract, and output shape for a future real model are fully designed and documented in code comments, but zero lines of actual prediction logic exist. The module is additionally **unreferenced by the rest of the app** — even if a real model were dropped in tomorrow, nothing currently watches `hazardSusceptibilityModelProvider` to consume its output.

## Known Limitations

- No trained model exists; `predict()` always returns `null`.
- Fully disconnected from the rest of the app — no screen, no other module, nothing calls into this one.
- No data pipeline exists in this codebase for the terrain (SRTM) or landslide-inventory (GSI) features a real model would need — those are named as future requirements in doc comments only.
- `HazardSusceptibilityPrediction.featureContributions` is designed but never populated by anything.

## Test Coverage

**No test directory exists.** `test/features/susceptibility/` is absent from the repository entirely (confirmed by directory listing — `bfs: error: test/features/susceptibility: No such file or directory`). This is itself a finding: the one class that exists in this module (`UnavailableHazardSusceptibilityModel`) has zero automated test coverage, even though its always-`null` contract would be trivial to lock in with a single test. Given the module is unreferenced elsewhere, no other test file incidentally exercises it either.
