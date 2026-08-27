# MODULE: Reporting

## Purpose

This module is the citizen's front door for putting ground-truth information into the system: hazard/issue reports (landslide, flood, road blockage, other), SOS ("need help") requests, and "I am safe" status pings. It answers "how does a citizen tell the system what they're seeing or what they need, and does that work when they're offline." The defining behavior is that **every submission is saved locally and queued to sync first, unconditionally** — there is no "submit straight to the backend" path; draining that queue when connectivity returns is the sync module's job, not this one's. This module produces `LocalIncidentReport` rows, which are unlinked ground observations; turning them into tracked, officially-verified `LocalIncident` rows is the `verification` module's job.

## User-facing functionality

- **Citizen** (permissions `submitIncidentReport`, `sendSos`, `updateSafeStatus`):
  - **Report Incident** (`ReportIncidentScreen`): picks one of four hazard/issue types (landslide/flood/road blockage/other, each with an icon), a severity band (low/medium/high/critical), an optional free-text description, an optional estimate of people affected, and an optional photo (camera or gallery). Submitting captures a fresh GPS fix automatically — the form itself never asks for location — and shows "Report saved and queued to sync."
  - **SOS / Need Help** (`SosScreen`): deliberately the lowest-friction screen in the module — one big red circular button, an optional short note, nothing else required. The whole screen background turns error-red until sent, then shows a green confirmation with "Responders will see this as high priority."
  - **I Am Safe** (`IAmSafeScreen`): even simpler — no type/severity picker at all, since it's a status ping, not a hazard report. One "I'M SAFE" button; the service supports an optional note but this screen doesn't collect one. Confirms "Your safe status has been recorded with your current location."
  - All three screens attach GPS automatically and behave identically if offline: the submission still succeeds locally and is queued.

## Entry points

- Route `/report` in `lib/app/router.dart` -> `ReportIncidentScreen`. Guarded by `Permission.submitIncidentReport`.
- Route `/sos` -> `SosScreen`. Guarded by `Permission.sendSos`.
- Route `/safe-status` -> `IAmSafeScreen`. Guarded by `Permission.updateSafeStatus`.
- All three reachable from the home screen's quick-action grid; `/sos` is additionally surfaced as its own prominent `_SosCard` on the home screen (`context.push('/sos')`), separate from the general quick-action list.

## Architecture

Domain / application / presentation layering, no `data/` folder (persistence delegated to `LocalIncidentReportRepository` in `lib/core/database/repositories/`, outside this module):

- **domain/** — `CitizenReportDraft` (what the UI collects before submission), `CitizenReportType` (the six report kinds and their storage vocabulary).
- **application/** — `CitizenReportSubmissionService` (the one orchestrator behind all three screens: capture GPS, save locally, enqueue sync, best-effort enqueue a compressed photo), `reporting_providers.dart` (Riverpod wiring, including the media-picker/compressor providers).
- **presentation/** — `ReportIncidentScreen`, `SosScreen`, `IAmSafeScreen`.

## Files in this module

### `lib/features/reporting/application/citizen_report_submission_service.dart`
- **Purpose:** The single orchestrator behind every citizen submission. Captures a fresh GPS fix via `GeoTagService` (fails the whole submission with no writes if location can't be determined), writes a `LocalIncidentReport` row, and unconditionally enqueues a sync-queue entry — its own doc comment: "there's no 'submit straight to the backend' path here: every report is saved locally and queued first ... regardless of current connectivity." If a photo is attached, best-effort compresses and enqueues it as a separate, lower-priority sync entry so a slow connection or a compression failure never blocks the critical text/GPS data.
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `CitizenReportSubmissionService` — `submitReport(draft, {reporterId, now?})` returns `Result<LocalIncidentReport>` (the core path); `submitSos({note, reporterId, now?})` is a convenience wrapper submitting a `CitizenReportType.sos` draft with `severity: 'critical'`; `submitSafeStatus({note, reporterId, now?})` is a convenience wrapper for `CitizenReportType.safeStatus` with no severity. Private `_enqueueMedia(report)` wraps the compress+enqueue step in try/catch; any failure (unreadable file, unsupported format, a web blob URL `dart:io` can't open) is logged via `AppLogger.warning` and silently dropped, never allowed to fail or delay the already-completed report submission.
- **Notable imports:** `core/location/geo_tag_service.dart`/`geo_tag.dart` (GPS capture), `core/media/image_compressor.dart` (optional — constructor accepts null, in which case a photo path is silently skipped entirely), `sync/application/sync_engine.dart` (`SyncEngine.mediaAttachmentsTable` — the sync-queue table name for the separate media entry).
- **Depends on:** `LocalIncidentReportRepository`, `SyncQueueDao`, `GeoTagService`, `ImageCompressor?`. **Depended on by:** `reporting_providers.dart`, all three screens directly, and — as the sole way `LocalIncidentReport` rows are created by a real user action — the `verification` module's `IncidentVerificationService.acknowledgeReport`, which consumes these rows.
- **State:** writes `local_incident_reports` (via repository) and `sync_queue` (report entry, plus an optional separate media entry keyed `'${report.id}-media'`).
- **External communication:** device GPS via `GeoTagService`/`LocationService` (real device location API, `geolocator` package under `geolocator_location_service.dart`, outside this module). No direct Firestore access — sync propagation is the sync module's concern, reached only via the enqueued `sync_queue` rows (whose `entityTable` value, `'local_incident_reports'`, becomes the Firestore collection name once the sync module drains the queue).
- **Demo/mock content:** none — this is the real, only write path for citizen reports.

### `lib/features/reporting/application/reporting_providers.dart`
- **Purpose:** Riverpod wiring for the submission service and its media dependencies.
- **Status:** IMPLEMENTED.
- **Key providers:** `mediaPickerServiceProvider` (-> `ImagePickerMediaService`, a real `image_picker`-backed implementation), `imageCompressorProvider` (-> `PackageImageCompressor`, a real compression implementation), `citizenReportSubmissionServiceProvider`.
- **Depends on:** `core/providers/core_providers.dart` (`localIncidentReportRepositoryProvider`, `syncQueueDaoProvider`, `geoTagServiceProvider`). **Depended on by:** all three presentation screens.

### `lib/features/reporting/domain/citizen_report_draft.dart`
- **Purpose:** The in-progress form state a screen builds before handing off to the service. Deliberately excludes GPS — its own comment: "GPS is deliberately not part of this: it's captured fresh at submit time ... not something the form asks the citizen for."
- **Status:** IMPLEMENTED (plain data class).
- **Key classes:** `CitizenReportDraft` — `type: CitizenReportType`, `description` (default `''`), `severity` (default `'unknown'` — one of low/medium/high/critical, or unknown if unspecified), `affectedPeopleCount: int?`, `mediaPath: String?`.

### `lib/features/reporting/domain/citizen_report_type.dart`
- **Purpose:** The six kinds of citizen submission — four hazard/issue types plus the two special-case actions the blueprint names by name ("SOS and I Am Safe") — all sharing the same underlying storage (`LocalIncidentReports`) since they're all GPS+timestamped ground observations, just with very different UI friction.
- **Status:** IMPLEMENTED.
- **Key classes/functions:** `CitizenReportType` (`landslide`, `flood`, `roadBlockage`, `other`, `sos`, `safeStatus`) — `storageValue` (`landslide`/`flood`/`road_blockage`/`other`/`sos`/`safe_status`), `label`, `isHazardIssue` (true only for the four hazard/issue types — used by `ReportIncidentScreen` to know which types belong in its picker), `fromStorageValue(String)`.

### `lib/features/reporting/presentation/i_am_safe_screen.dart`
- **Purpose:** "I Am Safe -> update status" — a status ping, no type/severity picker at all.
- **Status:** IMPLEMENTED and wired to the real service (`_markSafe` calls `citizenReportSubmissionServiceProvider.submitSafeStatus` for real).
- **Key classes:** `IAmSafeScreen` (stateful) / `_IAmSafeScreenState` — `_isSubmitting`, `_wasSent`, `_errorMessage` local state; no note field is actually wired into the UI despite `submitSafeStatus` supporting one.
- **Depends on:** `citizenReportSubmissionServiceProvider`, `currentUserProvider` (auth module). **Depended on by:** router (`/safe-status`).
- **Demo/mock content:** none.

### `lib/features/reporting/presentation/report_incident_screen.dart`
- **Purpose:** The full hazard/issue report form — type picker (4 choice chips), description, severity picker (4 choice chips), affected-people-count field, camera/gallery photo attach.
- **Status:** IMPLEMENTED and wired to the real service (`_submit` calls `citizenReportSubmissionServiceProvider.submitReport` for real, building a `CitizenReportDraft` from form state).
- **Key classes:** `ReportIncidentScreen` (stateful) / `_ReportIncidentScreenState`. `_attachPhoto(MediaPickerSource)` calls `mediaPickerServiceProvider.pickPhoto`.
- **Notable imports:** `core/media/media_picker_service.dart` (`MediaPickerSource.camera`/`.gallery`).
- **Depends on:** `citizenReportSubmissionServiceProvider`, `mediaPickerServiceProvider`, `currentUserProvider`. **Depended on by:** router (`/report`).
- **External communication:** device camera/gallery via `mediaPickerServiceProvider` (real `image_picker`-backed implementation, not a stub).
- **Demo/mock content:** none.

### `lib/features/reporting/presentation/sos_screen.dart`
- **Purpose:** The lowest-friction screen in the app — a full-bleed red emergency button, an optional note, nothing else. Its own doc comment: "deliberately minimal friction: one button, an optional note, nothing else required."
- **Status:** IMPLEMENTED and wired to the real service (`_sendSos` calls `citizenReportSubmissionServiceProvider.submitSos` for real).
- **Key classes:** `SosScreen` (stateful) / `_SosScreenState`.
- **Depends on:** `citizenReportSubmissionServiceProvider`, `currentUserProvider`. **Depended on by:** router (`/sos`), and the home screen's dedicated `_SosCard`.
- **Demo/mock content:** none.

## Data Models

- **`CitizenReportDraft`** — `type: CitizenReportType`, `description: String` (default `''`), `severity: String` (default `'unknown'`), `affectedPeopleCount: int?`, `mediaPath: String?`.
- **`CitizenReportType`** — enum `landslide`/`flood`/`roadBlockage`/`other`/`sos`/`safeStatus`.
- **`LocalIncidentReport`** (Drift row, `core/database/tables/local_incident_reports_table.dart`) — `id`, `incidentId: String?` (null until the `verification` module links it to a fused incident), `reporterId: String?`, `latitude`, `longitude`, `reportType` (a `CitizenReportType.storageValue`), `description` (default `''`), `severity` (default `'unknown'`), `affectedPeopleCount: int?`, `mediaPath: String?`, `createdAt`, `updatedAt`, `version`, `isSynced` (default false — its own table comment: "always false at submission time ... only [the sync module's] future sync pass flips this once the backend has it").

## Services / Repositories

- **`CitizenReportSubmissionService`** — the sole service in this module; the write path for every citizen ground observation. See Files above for full detail.
- **`LocalIncidentReportRepository`** (outside this module, in `core/database/repositories/`) — the actual Drift persistence layer.
- **`GeoTagService`** (outside this module, in `core/location/`) — real device GPS capture used by this module but not owned by it.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/report` | `ReportIncidentScreen` | `Permission.submitIncidentReport` | Home screen quick actions (Citizen). |
| `/sos` | `SosScreen` | `Permission.sendSos` | Home screen quick actions and dedicated `_SosCard` (Citizen). |
| `/safe-status` | `IAmSafeScreen` | `Permission.updateSafeStatus` | Home screen quick actions (Citizen). |

## Module Data Flow

A citizen submits a hazard report with a photo, while offline:

```
ReportIncidentScreen._submit()
  -> CitizenReportDraft(type, description, severity, affectedPeopleCount, mediaPath)
  -> ref.read(citizenReportSubmissionServiceProvider).submitReport(draft, reporterId: currentUserProvider.id)
      CitizenReportSubmissionService.submitReport()
        -> GeoTagService.captureGeoTag()             [real device GPS - geolocator package]
            -> on failure (e.g. no GPS fix): return Result.failure immediately, NOTHING written
        -> LocalIncidentReport(id: uuid.v4(), ..., isSynced: false)
        -> LocalIncidentReportRepository.save(report)              [written locally regardless of connectivity]
        -> SyncQueueDao.enqueue(entityTable: 'local_incident_reports', operation: 'create', payload)
        -> if mediaPath != null:
            _enqueueMedia(report)
              -> ImageCompressor.compress(mediaPath)                [best-effort; try/catch]
                  success -> SyncQueueDao.enqueue(entityTable: SyncEngine.mediaAttachmentsTable,
                                                   entityId: '${report.id}-media', ...)
                  failure -> AppLogger.warning(...) - report submission is UNAFFECTED, already returned Success
        -> Result.success(report)
  -> snackbar: "Report saved and queued to sync"

Later, once connectivity returns (sync module, out of this module's scope):
  SyncEngine drains sync_queue -> FirestoreSyncTransport writes to Firestore collection 'local_incident_reports'
  -> LocalIncidentReport.isSynced flips true

Downstream (verification module, out of this module's scope):
  IncidentVerificationService.acknowledgeReport(reportId)
    -> turns this unlinked LocalIncidentReport into a tracked LocalIncident (or merges it into an existing one)
```

## Current Status

**Working.** All three screens are wired to the real `CitizenReportSubmissionService`, which is itself fully implemented with genuine offline-first semantics (local save + sync-queue enqueue happen unconditionally, before any network attempt) and a real GPS capture dependency. This is the actual data-entry front door feeding the `verification` module's pipeline, not a placeholder.

## Known Limitations

- If GPS capture fails (no fix, permission denied), the **entire submission fails with nothing written** — there is no "submit without location, backfill GPS later" fallback. For SOS specifically, this means a citizen in a genuine emergency with a poor/no GPS fix cannot send an SOS at all through this path.
- `IAmSafeScreen`'s UI does not expose the optional `note` parameter `submitSafeStatus` supports — the service can carry a note, but the citizen-facing screen never collects one.
- `severity` is a free-form string constrained only by the four severity chip options in `ReportIncidentScreen`'s UI (low/medium/high/critical) — there is no enum-level validation in `CitizenReportDraft` or the service itself preventing an arbitrary string from being passed programmatically.
- Photo compression/upload is fully best-effort with no user-visible retry — if `ImageCompressor.compress` throws, the photo is silently dropped from the sync queue entirely (not retried, not surfaced to the citizen as "your photo didn't attach").
- No de-duplication or rate-limiting — a citizen could submit the same SOS or report repeatedly with no cooldown; each becomes a distinct `LocalIncidentReport` row (fusion/deduplication across reports, once acknowledged into incidents, is the `verification` module's ground-truth fusion engine's job, not this module's).

## Test Coverage

`test/features/reporting/` contains two files:

- **`citizen_report_submission_service_test.dart`** — thorough: the offline-save-and-queue path is explicitly labeled "the acceptance criterion" and verified end-to-end (saved locally, marked `isSynced: false`, queued with the correct `entityTable`); a report with no location fix fails cleanly and writes nothing (neither the report table nor the sync queue); `submitSos` records a critical, sos-typed report; `submitSafeStatus` records a `safe_status` report with no severity implied; each submission gets a distinct id. A dedicated media-attachment test group covers: a photo enqueues a separate, lower-priority sync entry; no photo means no media entry; a compression failure is explicitly labeled "the acceptance criterion" for critical text/GPS syncing even if media fails, and verified the report submission still succeeds with only its own entry queued; no compressor configured skips media entirely without error.
- **`citizen_report_type_test.dart`** — every type round-trips through its storage value; an unrecognized storage value maps to null; only the four hazard/issue types are `isHazardIssue`.

**Not covered by any test in this module:** `ReportIncidentScreen`, `SosScreen`, and `IAmSafeScreen` have no widget tests in `test/features/reporting/` — form validation, the photo-attach UI flow, and the submitting/success/error state transitions are all untested at this layer. `reporting_providers.dart` has no dedicated provider-wiring test. The real `GeoTagService`/`LocationService`/`ImagePickerMediaService`/`PackageImageCompressor` implementations (device GPS, camera/gallery, compression) are exercised only through fakes in the service test — there is no test of the real device-API integrations within this module's test directory.
