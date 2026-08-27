# MODULE: Environmental

## Purpose

This module (internally referred to in code comments as "M24") answers: "does live weather/environmental data — rainfall, river level, soil moisture — suggest a habitation's risk is worse *right now* than the static hazard-zone + vulnerability picture alone would say, and if so, by how much, with visible evidence for the adjustment?" It is explicitly an additive, capped nudge on top of the risk module's base score, never a replacement for hazard/vulnerability assessment, and it enforces a hard rule that stale environmental data is never presented as current.

## User-facing functionality

**No screens.** This module has no `presentation/` folder. Its output (`EnvironmentalRiskAdjustment`, and the `environmentalAdjustment`/`environmentalProvenance` fields it contributes to `RiskAssessmentResult`) is not rendered by any file in this module. Whatever downstream UI shows the adjusted risk score/class (the map/dashboard, per risk.md) does not distinguish "this includes a live-weather nudge" from a pure hazard/vulnerability score, as far as this module's own files show.

## Entry points

- `environmentalDataServiceProvider` (in `environmental_providers.dart`) has exactly one external consumer found in this scan: `lib/features/risk/application/risk_providers.dart`, where it's passed into `RiskAssessmentService` as an optional collaborator. No screen calls into this module directly, and — critically — **nothing in this module or the risk module calls `EnvironmentalDataService.refreshForHabitation()` from production code in this scan.** `RiskAssessmentService.assessHabitation()` only calls `adjustmentFor()`, which reads whatever is already cached locally; it never fetches fresh data itself. This means, absent some other caller of `refreshForHabitation` elsewhere in the app (outside this module's file set), the Open-Meteo integration may never actually be invoked in a running app — only exercised directly by this module's own tests.

## Architecture

Domain/application layering, no presentation, no dedicated data layer folder (persistence via `LocalEnvironmentalObservationRepository`, outside this module):

- **domain/** — `EnvironmentalParameter` (fixed 3-value enum), `EnvironmentalRiskAdjustment` (engine output with visible provenance).
- **application/** — `EnvironmentalDataSource` (abstract contract) + two implementations (`DemoEnvironmentalDataSource`, `OpenMeteoDataSource`); `EnvironmentalRiskEngine` (pure engine); `EnvironmentalDataService` (orchestrator: fetch → cache → evaluate); `risk_environmental_merge.dart` (the pure function that folds this module's output into the risk module's result type); `environmental_providers.dart` (Riverpod wiring).

## Files in this module

### `lib/features/environmental/application/demo_environmental_data_source.dart`
- **Purpose:** A deterministic stand-in for a real weather/satellite/river-gauge API. Kept in the codebase after Open-Meteo became the default — used as a test double and documented fallback reference, not deleted.
- **Status:** DEMO/MOCK — explicitly and honestly labeled as such in its own doc comment ("Stands in for a real weather/satellite/river-gauge API, which this project doesn't have"). No longer the production default (see `environmental_providers.dart`).
- **Key classes:** `DemoEnvironmentalDataSource.fetchReadings({latitude, longitude, now})` — seeds a `Random` from `(lat*1000).round()*31 + (lng*1000).round()` so the same location always produces the same synthetic readings (deterministic, not random-per-call — matching every other engine's reproducibility requirement).
- **EXACT SYNTHETIC VALUES (verbatim from source, all fake data clearly source-attributed as "(demo feed)"):**
  ```
  rainfall24h:   value = (random * 180).roundToDouble()  mm, source 'IMD (demo feed)',       observedAt = now - 1h,   confidence 0.85
  riverLevel:    value = 2 + random * 9                  m,  source 'CWC River Gauge (demo feed)', observedAt = now - 30min, confidence 0.8
  soilMoisture:  value = random (0-1)                    idx, source 'Bhuvan Satellite (demo feed)', observedAt = now - 3 days, confidence 0.6
  ```
  Soil moisture is **deliberately** given a stale (3-day-old) timestamp specifically so `EnvironmentalRiskEngine`'s freshness gate has something real to demonstrate excluding.
- **Demo/mock content:** the entire file. Every value is synthetic, but transparently labeled as such via the `source` field's "(demo feed)" suffix — this is not disguised as real data anywhere.

### `lib/features/environmental/application/environmental_data_service.dart`
- **Purpose:** Orchestrates fetch → cache → evaluate: pulls readings from whichever `EnvironmentalDataSource` is wired in, caches them locally (one current row per habitation/parameter pair, overwritten not accumulated), and computes the risk adjustment for a habitation from whatever's cached.
- **Status:** IMPLEMENTED.
- **Key functions:** `refreshForHabitation({habitationId, latitude, longitude, now})` → `List<LocalEnvironmentalObservation>` (fetches + persists); `observationsFor(habitationId)` → filters the full cached set; `adjustmentFor(habitationId, {now})` → `EnvironmentalRiskAdjustment` (reads cache only, does **not** fetch).
- **Depends on:** `EnvironmentalDataSource`, `LocalEnvironmentalObservationRepository`, `EnvironmentalRiskEngine`. **Depended on by:** `environmental_providers.dart`, `RiskAssessmentService` (risk module, via `adjustmentFor` only).
- **State:** reads+writes `local_environmental_observations` (row id = `'{habitationId}-{parameterStorageValue}'`, so exactly one row per habitation per parameter, versioned on overwrite).
- **External communication:** none directly — delegated entirely to whichever `EnvironmentalDataSource` is injected.

### `lib/features/environmental/application/environmental_data_source.dart`
- **Purpose:** The abstraction a real API integration plugs into, plus the raw-reading value type.
- **Status:** IMPLEMENTED (contract + value type).
- **Key content:** `RawEnvironmentalReading` — `parameter`, `value`, `source`, `observedAt`, `confidence` (default `0.7`). `EnvironmentalDataSource` (abstract) — `fetchReadings({latitude, longitude, now})`.

### `lib/features/environmental/application/environmental_providers.dart`
- **Purpose:** Riverpod wiring — and the file that documents the module's real/demo swap.
- **Status:** IMPLEMENTED. **Confirmed: `environmentalDataSourceProvider` now defaults to `OpenMeteoDataSource`, not the demo source.** Doc comment: "M24 originally shipped with `DemoEnvironmentalDataSource` as the default... It now defaults to the real Open-Meteo feed; the demo source stays in the codebase for tests and as a fallback reference, not deleted."
- **Key providers:** `environmentalDataSourceProvider` → `OpenMeteoDataSource(networkInfo: ...)`, `environmentalRiskEngineProvider`, `environmentalDataServiceProvider`.

### `lib/features/environmental/application/environmental_risk_engine.dart`
- **Purpose:** The deterministic core — decides which cached observations are fresh enough to trust, and how much they should nudge a risk score.
- **Status:** IMPLEMENTED, pure (no I/O; caller supplies the cached observations and `now`).
- **Key functions:** `EnvironmentalRiskEngine.evaluate({observations, now})` → `EnvironmentalRiskAdjustment`; private `_normalize(parameter, value)`.
- **EXACT FORMULA/THRESHOLDS:**
  ```
  freshnessThreshold = Duration(hours: 24)   // "do not present stale environmental data as current"
  maxAdjustment = 0.15                        // caps how far this module alone can move a risk score

  Split observations into fresh (age <= 24h) and stale (age > 24h).
  If no fresh observations → adjustment = 0.

  Per-parameter normalization to a 0-1 "how concerning" figure (thresholds explicitly
  documented as illustrative, not meteorologically authoritative):
      rainfall24h → (value / 200).clamp(0,1)
      riverLevel  → (value / 10).clamp(0,1)
      soilMoisture→ value.clamp(0,1)             // already a 0-1 index

  weightedTotal = sum over fresh observations of: normalize(param, value) * confidence.clamp(0,1)
  adjustment = (weightedTotal / freshCount * maxAdjustment).clamp(0.0, maxAdjustment)
  ```
  Model version: `environmentalModelVersion = '1.0.0'`. An observation whose `parameter` string doesn't map to a known `EnvironmentalParameter` is silently skipped (safe degradation, tested explicitly).
- **Depends on:** `EnvironmentalParameter`, `EnvironmentalRiskAdjustment`. **Depended on by:** `EnvironmentalDataService`.

### `lib/features/environmental/application/open_meteo_data_source.dart`
- **Purpose:** **The real, live external API integration.** Backed by Open-Meteo — chosen explicitly for being free, requiring no API key, and having good India coverage.
- **Status:** IMPLEMENTED and REAL — confirmed by direct source reading, not inferred from the name. This is not a stub; it performs an actual HTTP GET via `Dio`.
- **EXACT ENDPOINT AND PARAMETERS:**
  ```
  GET https://api.open-meteo.com/v1/forecast
  Query params: latitude, longitude, daily=precipitation_sum, hourly=soil_moisture_0_to_1cm,
                past_days=1, forecast_days=1, timezone=UTC
  Dio timeouts: connectTimeout=8s, receiveTimeout=8s
  ```
- **Key classes/functions:** `OpenMeteoDataSource.fetchReadings({latitude, longitude, now})` — checks `NetworkInfo.isConnected` first and returns `[]` without attempting a request if offline (verified by test: "offline: never even attempts the request"); on `DioException` logs a warning and returns `[]`; on any parse error logs an error and returns `[]` — **never throws to the caller**. `_parseRainfall(daily)` — takes `daily.precipitation_sum`'s **first** entry, which (given `past_days=1`) is yesterday's completed total, not today's still-accumulating partial sum; parsed as a UTC calendar day, `observedAt` stamped at `23:59` of that day. `_parseSoilMoisture(hourly, now)` — picks the hourly entry closest to but not after `now` (never a future reading).
- **Honest gap, explicitly documented:** `EnvironmentalParameter.riverLevel` is **never** returned by this source — "Open-Meteo has no river-gauge product... an honest gap rather than a fabricated reading." (Only `DemoEnvironmentalDataSource` ever produces a `riverLevel` reading, and it's clearly labeled synthetic.)
- **Depends on:** `dio` (external package), `core/network/network_info.dart`, `core/logging/app_logger.dart`. **Depended on by:** `environmental_providers.dart` (as the production default).
- **State:** none locally (stateless HTTP client wrapper).
- **External communication:** **real HTTP GET to `https://api.open-meteo.com/v1/forecast`**, confirmed.
- **Demo/mock content:** none — this file contains zero fabricated data; every value it returns traces back to a live API response.

### `lib/features/environmental/application/risk_environmental_merge.dart`
- **Purpose:** The pure function that folds this module's adjustment into the risk module's result type, re-deriving the risk class from the adjusted score.
- **Status:** IMPLEMENTED, pure.
- **Key function:** `mergeEnvironmentalAdjustment(RiskAssessmentResult base, EnvironmentalRiskAdjustment environmental)` → `RiskAssessmentResult` — `adjustedScore = (base.riskScore + environmental.adjustment).clamp(0,1)`; `riskClass = classifyRiskScore(adjustedScore)` (re-derived, not left stale); `hazardExposure`/`vulnerabilityIndex` passed through unchanged (additive, not a replacement).
- **Depends on:** `RiskAssessmentResult`, `RiskClass`/`classifyRiskScore` (risk module). **Depended on by:** `RiskAssessmentService`.

### `lib/features/environmental/domain/environmental_parameter.dart`
- **Purpose:** The fixed, closed set of environmental signals this module tracks.
- **Status:** IMPLEMENTED. `EnvironmentalParameter.rainfall24h` / `.riverLevel` / `.soilMoisture`, each with a `storageValue` (`rainfall_24h`/`river_level`/`soil_moisture`), a `label`, and a `unit` (`mm`/`m`/`index`).

### `lib/features/environmental/domain/environmental_risk_adjustment.dart`
- **Purpose:** The engine's output — not just a number, but which observations produced it and which were excluded for staleness, matching the "visible provenance" acceptance criterion referenced throughout this module's tests.
- **Status:** IMPLEMENTED (plain data class). `EnvironmentalRiskAdjustment` — `adjustment: double`, `influencing: List<LocalEnvironmentalObservation>`, `stale: List<LocalEnvironmentalObservation>`.

### `test/features/environmental/demo_environmental_data_source_test.dart`
- **Purpose:** Confirms determinism (same location → same values), location-sensitivity (different locations → different values), full parameter coverage, non-empty source attribution, and the deliberate soil-moisture staleness.
- **Status:** IMPLEMENTED.

### `test/features/environmental/environmental_data_service_test.dart`
- **Purpose:** Integration tests — `refreshForHabitation` caches one row per parameter; refreshing again **overwrites** the same row (version increments, no history accumulation); `observationsFor` scopes correctly per habitation; and directly, the acceptance-criterion test "EXTERNAL DATA CAN INFLUENCE RISK WITH VISIBLE PROVENANCE" — a rain-only fixed source produces a positive adjustment with exactly one influencing observation, source attribution intact.
- **Status:** IMPLEMENTED.

### `test/features/environmental/environmental_risk_engine_test.dart`
- **Purpose:** Pure formula tests — no observations → zero adjustment; a reading exactly at the 24h threshold is still fresh (boundary inclusive); a reading one minute past the threshold is excluded as stale with zero adjustment; mixed fresh/stale only lets fresh influence; adjustment never exceeds `maxAdjustment` even for an extreme (10,000mm) reading; a zero reading contributes ~zero; lower confidence contributes less than identical higher confidence; an unrecognized parameter string is safely ignored.
- **Status:** IMPLEMENTED, and directly verifies every constant/threshold documented above.

### `test/features/environmental/open_meteo_data_source_test.dart`
- **Purpose:** Verifies the real HTTP integration against a scripted `Dio` interceptor (no real network calls in tests) — confirms rainfall+soil-moisture are returned and river-level never is; rainfall picks yesterday's completed total (`42.5`, not today's `3.0`); soil moisture picks the entry closest to but not after `now` (the `10:00` entry, not the future `11:00` one); offline mode never even attempts the request; a network failure and a malformed response body both degrade to an empty list rather than throwing; a response missing one of the two data blocks still returns whatever's parseable from the other.
- **Status:** IMPLEMENTED — this is the file that most concretely proves `OpenMeteoDataSource` is a real, carefully-behaved API client, not a stub.

### `test/features/environmental/risk_assessment_environmental_integration_test.dart`
- **Purpose:** Proves the acceptance criterion end-to-end: a real `EnvironmentalDataService` wired into `RiskAssessmentService` measurably raises the persisted risk score and writes provenance into the DB row; a `RiskAssessmentService` built *without* one behaves byte-identical to pre-M24 (`environmentalAdjustment == 0`, `environmentalProvenanceJson == '[]'`) — an explicit regression guard; a stale-only cache does not influence the score.
- **Status:** IMPLEMENTED.

### `test/features/environmental/risk_environmental_merge_test.dart`
- **Purpose:** Pure tests of `mergeEnvironmentalAdjustment` — zero adjustment leaves the result identical; a positive adjustment raises the score and carries provenance with an exact numeric check (`0.5 + 0.1 = 0.6`); the merged score never exceeds `1.0` even near-maximal; `riskClass` is re-derived (a score nudged across the `red` boundary actually reclassifies); `contributingHazardZoneIds`/`modelVersion`/`assessedAt` pass through unchanged.
- **Status:** IMPLEMENTED.

## Data Models

- **`RawEnvironmentalReading`** — `parameter: EnvironmentalParameter`, `value: double`, `source: String`, `observedAt: DateTime`, `confidence: double` (default 0.7).
- **`EnvironmentalRiskAdjustment`** — `adjustment: double`, `influencing: List<LocalEnvironmentalObservation>`, `stale: List<LocalEnvironmentalObservation>`.
- **`LocalEnvironmentalObservation`** (persisted row) — `id` (`'{habitationId}-{parameter}'`), `habitationId`, `parameter`, `value`, `source`, `observedAt`, `fetchedAt`, `confidence`, `version`.

## Services / Engines / Repositories

- **`EnvironmentalRiskEngine`** (pure) — freshness gate (24h) + weighted normalization capped at `0.15` total adjustment. Model version `'1.0.0'`.
- **`EnvironmentalDataService`** (orchestrator) — fetch/cache/evaluate; the **only** caller of the data source's `fetchReadings`.
- **`DemoEnvironmentalDataSource`** — deterministic, clearly-labeled synthetic data. Not the production default.
- **`OpenMeteoDataSource`** — **real HTTP client**, `GET https://api.open-meteo.com/v1/forecast`. The production default.

## Module Data Flow

```
[No confirmed production caller of refreshForHabitation() — see "Entry points" above]

If/when refreshed:
  EnvironmentalDataService.refreshForHabitation(habitationId, lat, lng, now)
    → OpenMeteoDataSource.fetchReadings(lat, lng, now)
        → Dio.get('https://api.open-meteo.com/v1/forecast', {daily, hourly, past_days=1, ...})
        → [rainfall24h, soilMoisture]  (riverLevel never produced)
    → LocalEnvironmentalObservationRepository.save(...)   (one row per parameter, overwritten)

RiskAssessmentService.assessHabitation(habitationId, now)     [risk module]
  → EnvironmentalDataService.adjustmentFor(habitationId, now)   (reads cache only, no fetch)
      → observationsFor(habitationId) → LocalEnvironmentalObservationRepository.getAll() (filtered)
      → EnvironmentalRiskEngine.evaluate(observations, now) → EnvironmentalRiskAdjustment
  → mergeEnvironmentalAdjustment(baseAssessment, adjustment) → adjusted RiskAssessmentResult
```

## Current Status

**Working, and REAL — not a stub.** The single most important finding for this module: **`OpenMeteoDataSource` performs a genuine HTTP GET to `https://api.open-meteo.com/v1/forecast`** (verified by reading the source directly), and is the production-wired default as of `environmental_providers.dart`. The demo/mock data source (`DemoEnvironmentalDataSource`) still exists but has been demoted to a test double/fallback reference. The engine's freshness gating and adjustment capping are real, tested, deterministic logic. The one structural gap: no caller in this module's or the risk module's file set ever invokes `refreshForHabitation()` in production — `adjustmentFor()` only reads whatever's already cached, so without some other trigger (not found in this scan) actually calling the fetch, the live API may never be hit in a running app despite being fully wired and functional.

## Known Limitations

- `EnvironmentalParameter.riverLevel` is defined in the domain model but Open-Meteo can never supply it — an honest, documented gap, not a bug, but the field exists in the type system with no real-data path to populate it (only the demo source fabricates it).
- No confirmed production trigger for `refreshForHabitation()` — the fetch-and-cache step may be unreachable outside tests, even though the read-and-adjust step (`adjustmentFor`) is wired into every risk assessment.
- The per-parameter "concerning" normalization thresholds (`rainfall/200`, `riverLevel/10`) are explicitly documented in-code as illustrative placeholders, not meteorologically validated for any specific region.
- No UI surfaces environmental provenance or the adjustment magnitude to any user.

## Test Coverage

Six test files — the most thorough coverage in this document, appropriately so given this module makes a real external network call:
- `demo_environmental_data_source_test.dart` — determinism and staleness-by-design.
- `open_meteo_data_source_test.dart` — the real API client's parsing, offline behavior, error handling, and edge cases, all against a scripted `Dio` interceptor.
- `environmental_risk_engine_test.dart` — full formula and freshness-boundary coverage.
- `environmental_data_service_test.dart` — cache-overwrite behavior and the fetch→cache→adjust pipeline.
- `risk_environmental_merge_test.dart` — pure merge-function correctness including reclassification.
- `risk_assessment_environmental_integration_test.dart` — true end-to-end proof against the risk module, plus an explicit pre-M24 regression guard.

**Not covered by any test in this module:** no test in this directory calls the real, non-scripted Open-Meteo endpoint (appropriately, for determinism/CI reasons) — so live-API contract drift (e.g. Open-Meteo changing its response shape) would not be caught by this suite; no test confirms whether `refreshForHabitation` is actually invoked anywhere in a running app.
