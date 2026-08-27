# MODULE: Fusion

## Purpose

**This module is not part of the hazard/risk/vulnerability/capacity/relocation scoring pipeline at all, despite living alongside those modules.** Its actual job: when a citizen submits a new incident report (e.g. "landslide near X"), decide whether it describes something already being tracked or something new — and if it matches an existing tracked incident, merge it in, recompute how many independent sources have now corroborated that incident, and escalate severity if the new report is worse. In the codebase's own terms (referenced in doc comments as "M14"), this is **ground-truth fusion of citizen incident reports into verified incidents** — a deduplication/clustering engine for crowd-sourced reports, not a fusion of hazard/environmental/susceptibility signals as the module's position in this document set might suggest. This was explicitly flagged as a "check what this module actually does, do not assume from the name" item, and the finding is: it is a **report-deduplication and corroboration-counting engine for the citizen-reporting/verification feature**, consumed by `lib/features/verification/`, a feature entirely outside this handover's assigned module list.

## User-facing functionality

**No screens in this module.** There is no `presentation/` or `domain`-facing UI here. The engine is consumed by `lib/features/verification/application/incident_verification_service.dart` (outside this module's scope), which presumably backs whatever citizen-reporting/incident-verification screens exist elsewhere in the app — not documented here since that feature folder wasn't part of this assignment.

## Entry points

- `groundTruthFusionEngineProvider` (in `fusion_providers.dart`) has exactly one external consumer found in this scan: `lib/features/verification/application/incident_verification_service.dart` and its own `verification_providers.dart` wiring — both in the `verification` feature, not in any of the eight assigned modules. **No risk/vulnerability/capacity/relocation/hazards/environmental/susceptibility file references this module at all.**

## Architecture

Domain/application layering only, no presentation, no persistence of its own (it operates on `LocalIncident`/`LocalIncidentReport` rows supplied by its caller, doesn't read or write the database itself):

- **domain/** — `GroundTruthMatch` (the engine's decision output).
- **application/** — `GroundTruthFusionEngine` (pure engine), `fusion_providers.dart` (Riverpod wiring).

## Files in this module

### `lib/features/fusion/application/fusion_providers.dart`
- **Purpose:** Riverpod wiring for the one engine in this module.
- **Status:** IMPLEMENTED.
- **Key providers:** `groundTruthFusionEngineProvider` → `GroundTruthFusionEngine()`.
- **Depended on by:** `lib/features/verification/application/verification_providers.dart` (outside this module).

### `lib/features/fusion/application/ground_truth_fusion_engine.dart`
- **Purpose:** Decides whether a new incident report describes an already-tracked real-world event or a new one, by clustering on hazard type + spatial proximity + time proximity, and — if it's a match — recomputes the corroborating-source count, confidence, and worst-case severity for that incident.
- **Status:** IMPLEMENTED, pure — takes its inputs (`newReport`, `existingIncidents`, `reportsByIncidentId`) entirely as parameters, does no I/O itself.
- **Key functions:** `GroundTruthFusionEngine.evaluate({newReport, existingIncidents, reportsByIncidentId})` → `GroundTruthMatch`.
- **EXACT FORMULA/THRESHOLDS:**
  ```
  clusterRadiusMeters = 500
  clusterTimeWindow = Duration(hours: 6)

  A candidate existing incident is eligible to match only if ALL of:
      incident.type == newReport.reportType
      incident.status not in {rejected, resolved}                (closed incidents never re-absorb reports)
      |newReport.createdAt - incident.createdAt| <= 6 hours
      greatCircleDistance(newReport, incident) <= 500 meters

  Among eligible candidates, the CLOSEST one (by distance) is chosen — not the first found.

  If no match:
      matchedIncidentId = null (new incident)
      independentSourceCount = 1
      confidence = confidenceFor(1) = 0.5
      severity = newReport.severity

  If matched:
      existingReporterIds = distinct reporterIds of all reports already on that incident,
                             plus the new report's reporterId if non-null
      sourceCount = existingReporterIds.isEmpty ? 1 : existingReporterIds.length
                     (an anonymous/null-reporterId report still counts as >=1 source,
                      just can't be deduplicated by identity)
      confidence = confidenceFor(sourceCount)
      severity = worse of (existing incident's severity, new report's severity)
                  — rank: critical=4, high=3, medium=2, low=1; ties/unknowns favor the existing value

  confidenceFor(sourceCount) = (0.5 + 0.1 * (sourceCount - 1)).clamp(0.0, 0.95)
      // 1 source → 0.5 (same neutral baseline hazard ingestion uses for unconfigured confidence)
      // each additional distinct source → +0.1, capped short of certainty at 0.95
  ```
- **Depends on:** `core/database/app_database.dart` (`LocalIncidentReport`, `LocalIncident`), `features/verification/domain/incident_verification_status.dart` (`IncidentVerificationStatus`). **Depended on by:** `fusion_providers.dart`, and transitively `verification`'s `IncidentVerificationService`.
- **State:** none — pure function of its inputs.
- **External communication:** none.
- **Demo/mock content:** none — every constant is a real, tested threshold.

### `lib/features/fusion/domain/ground_truth_match.dart`
- **Purpose:** The engine's decision output type.
- **Status:** IMPLEMENTED (plain data class).
- **Key content:** `GroundTruthMatch` — `matchedIncidentId: String?` (null = start a new incident), `independentSourceCount: int`, `confidence: double`, `severity: String`, plus a derived getter `isNewIncident => matchedIncidentId == null`.

### `test/features/fusion/ground_truth_fusion_engine_test.dart`
- **Purpose:** Comprehensive pure-function tests: a report with no nearby incidents starts a new single-source match; the headline acceptance scenario "REPEATED REPORTS BECOME ONE INCIDENT WITH MULTIPLE SOURCES" (a second report near an existing incident merges and raises source count to 2); a different incident type at the same place never merges; a report outside the 500m radius never merges; a report outside the 6h window never merges; a `rejected` or `resolved` incident is never a merge candidate; among two candidate incidents the closer one is chosen, not the first in the list; repeated reports from the *same* reporter do not inflate the source count; an anonymous (`reporterId: null`) new report still counts as a source without being deduplicable; merging escalates severity to the worse of the two and never downgrades; confidence rises by exactly `0.1` per additional distinct source (explicit `0.7` check at 3 sources) and is capped at `0.95` even with many sources.
- **Status:** IMPLEMENTED — this single test file exhaustively verifies every branch and every constant in the engine documented above.

## Data Models

- **`GroundTruthMatch`** — `matchedIncidentId: String?`, `independentSourceCount: int`, `confidence: double`, `severity: String`, `isNewIncident: bool` (derived).
- Operates on (but does not own) `LocalIncident` and `LocalIncidentReport` — persisted rows belonging to the `verification`/incident-reporting feature, outside this module's scope. Relevant fields inferred from test fixtures: `LocalIncident` has `id`, `type`, `status`, `latitude`, `longitude`, `description`, `severity`, `independentSourceCount`, `confidence`, `createdAt`, `updatedAt`, `version`, `isSynced`. `LocalIncidentReport` has `id`, `reporterId` (nullable), `latitude`, `longitude`, `reportType`, `description`, `severity`, `createdAt`, `updatedAt`, `version`, `isSynced`.

## Services / Engines / Repositories

- **`GroundTruthFusionEngine`** (pure) — the module's only engine. Clustering: 500m radius, 6h time window, same-type-only, excludes closed incidents. Confidence: `0.5 + 0.1*(sources-1)`, capped `0.95`. Severity: worst-of-two, never downgrades. No `modelVersion` constant exists on this engine or on `GroundTruthMatch` — unlike every engine in the hazards/risk/vulnerability/capacity/relocation cluster, this module does **not** follow the versioned-model-constant convention (a real deviation from that architectural pattern, worth flagging since fusion sits in the same directory tier as those modules).

## Module Data Flow

```
(caller is entirely outside this handover's scope — lib/features/verification/)

IncidentVerificationService (verification module, not documented here)
  → GroundTruthFusionEngine.evaluate(newReport, existingIncidents, reportsByIncidentId)
      → GroundTruthMatch { matchedIncidentId, independentSourceCount, confidence, severity }
  → (presumably) either creates a new LocalIncident or updates an existing one's
    independentSourceCount/confidence/severity — the actual persistence call is made by
    IncidentVerificationService, not by this module, and was not verified as part of this scan.
```

## Current Status

**Working**, as a pure, well-tested engine — but structurally **not related to the hazard/risk/vulnerability/capacity/relocation/susceptibility/environmental scoring pipeline this document set otherwise covers.** It is citizen-report deduplication logic for a separate "incident verification" feature. This is the key finding for this module: **do not assume "fusion" means combining hazard/environmental/susceptibility signals — it does not.** No file in the risk, vulnerability, capacity, relocation, hazards, environmental, or susceptibility modules imports or references anything in this module, and vice versa.

## Known Limitations

- No `modelVersion` constant, unlike the rest of the scoring-engine family — `GroundTruthMatch` results are not traceable to a specific formula version if the clustering/confidence logic changes later.
- The engine assumes its caller has already loaded the relevant candidate incidents and their report histories (`existingIncidents`, `reportsByIncidentId`) — it does no filtering/querying of its own, so an inefficient or incomplete caller-side query would silently produce wrong matches without this engine ever knowing.
- Clustering uses only great-circle distance and wall-clock time delta — no consideration of hazard-zone geometry, direction of spread, or report reliability/reputation beyond simple reporter-id deduplication.
- Since this module's actual consumer (`verification`) is outside this handover's scope, this document cannot confirm what happens to a `GroundTruthMatch` after `evaluate()` returns — whether it's actually persisted, surfaced to an official for review, or used to auto-verify an incident.

## Test Coverage

One test file, but exhaustive for the engine's actual size: `ground_truth_fusion_engine_test.dart` covers every branch (new vs. merge, type mismatch, radius/time-window exclusion, closed-incident exclusion, closest-of-several selection, reporter deduplication, anonymous-reporter handling, severity escalation rules, and the exact confidence formula at multiple source counts).

**Not covered by any test in this module:** nothing verifies what happens downstream of a `GroundTruthMatch` (i.e. whether/how `verification`'s service actually applies it to the database) — that's out of this module's test scope by design, since `GroundTruthFusionEngine` itself is pure and has no persistence responsibility.
