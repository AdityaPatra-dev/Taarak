# Demo / Mock / Placeholder Audit

Consolidated from five independent, parallel research passes across all 29 feature modules plus core infrastructure, cross-checked against this session's own direct code edits and one correction applied during final validation (see `docs/modules/vulnerability.md`). Every entry below was verified by reading the actual implementation, not inferred from a filename or a doc comment alone.

## Genuinely fake/demo/placeholder — clearly and correctly labeled in the code itself

| What | File | Behavior | Status |
|---|---|---|---|
| Demo login accounts | `lib/features/auth/data/dev_mock_auth_remote_data_source.dart` + duplicated in `LoginScreen._demoAccounts` | 6 hardcoded role accounts, in-memory only | **DEMO/MOCK** — dormant; `AppConfig.useMockAuth` is always `false` in the app's actual config, so these credentials do not work against the live, deployed app |
| Hazard susceptibility ("AI") model | `lib/features/susceptibility/application/hazard_susceptibility_model.dart` | `UnavailableHazardSusceptibilityModel.predict()` unconditionally returns `null` | **PLACEHOLDER**, deliberately, per its own doc comment. No trained model, no ML inference, no fabricated score, anywhere in this codebase. Also fully disconnected — nothing calls it. |
| Demo map data seeder | `lib/features/map/application/demo_map_data_seeder.dart` | Seeds sample hazard zones/shelters/incidents/habitations | **UNUSED / DEAD CODE** as shipped — confirmed by a repo-wide grep to have no call site anywhere in `lib/`. Its own doc comment describes a "gated behind `AppConfig.isDevMode`" call site that does not exist. It is real, tested, working code with nowhere it's invoked. |
| SMS transport | `lib/features/sms_prototype/application/sms_transport.dart` (`LoopbackSmsTransport`) | Records "sent" packets into an in-memory list; nothing leaves the device | **SIMULATION** — no `SEND_SMS`/`RECEIVE_SMS` permission, no SMS package in `pubspec.yaml`, confirmed by the UI itself displaying "Controlled prototype: no real SMS is sent." |
| Device relay transport | `lib/features/device_relay/application/relay_transport.dart` (`LoopbackRelayTransport`) | Records "broadcast" packets into an in-memory log; nothing leaves the device | **SIMULATION** — no Bluetooth/WiFi package in `pubspec.yaml`, confirmed by the UI's own "nothing leaves this device over Bluetooth/WiFi" banner. |
| `DefaultVulnerabilityProvider` (flat 0.5) | `lib/features/risk/domain/vulnerability_provider.dart` | Returns a constant 0.5 regardless of input | **PLACEHOLDER**, superseded in the actually-wired provider graph by `RealVulnerabilityProvider` — still exists in source as a fallback/default and could be silently reintroduced if `risk_providers.dart` were edited carelessly. |
| `EnvironmentalParameter.riverLevel` | `lib/features/environmental/domain/environmental_parameter.dart` | Defined in the domain model | **PLACEHOLDER for real data** — Open-Meteo (the real, wired data source) cannot supply river level; only the demo data source fabricates a value for this field. |
| `backend/` — the entire secondary Dart package | `backend/lib/src/*.dart` | A `shelf`/`shelf_router` HTTP stub | **UNUSED / DEAD CODE** as far as the running app is concerned — self-described in its own README as a stub, explicitly superseded by the real Firebase backend per the main `pubspec.yaml`'s own comment. Still exercised by `test/integration/backend_stub_integration_test.dart`. |
| `ApiAuthRemoteDataSource` / `ApiSyncTransport` | `lib/features/auth/data/`, `lib/features/sync/application/` | Fully-implemented REST clients for the `backend/` stub above | **UNUSED / DEAD CODE in practice** — never selected, since `AppConfig.development().useFirebaseAuth` is hardcoded `true`. |

## Real, live, production-wired — confirmed, not assumed

| What | Evidence |
|---|---|
| Firebase Authentication + Firestore | Live project `taakrak-d9ed0`, verified directly against the Identity Toolkit Admin API this session; `FirebaseAuthRemoteDataSource`/`FirestoreSyncTransport` are the actual code paths exercised by every login/register/sync in the running app. |
| Open-Meteo weather API | `OpenMeteoDataSource` performs a genuine HTTP GET to `https://api.open-meteo.com/v1/forecast`, confirmed by direct source read — this is the real default, not a stub, even though a `DemoEnvironmentalDataSource` also exists as a fallback/test double. |
| Google Maps | A real, working API key is embedded in `AndroidManifest.xml`/`web/index.html` (value not reproduced — see `15_SECURITY_AUDIT.md`); the map genuinely renders live Google-hosted tiles. |
| `flutter_local_notifications` | Real dependency, real OS notification calls via `PlatformNotifier`, watched live at the app root. |
| Every scoring engine (risk, vulnerability, capacity, relocation) | Pure, deterministic, versioned, unit-tested with exact numeric assertions — no fabricated/random/hardcoded-looking output found anywhere in this cluster. |
| Real hazard/habitation/shelter/incident ingestion pathways | `ReportHazardZoneScreen`, `RegisterHabitationScreen`, `ShelterManagementScreen`, citizen report screens — all real, tested, audited write paths, now the actual (and only) source of data these screens render, distinct from and not dependent on the dormant demo seeder above. |
| Habitation `infrastructureQuality`/`accessQuality` | Real, in-app data entry via `RegisterHabitationScreen`'s dropdowns, feeding the vulnerability engine's indicator resolvers directly — see the correction recorded in `docs/modules/vulnerability.md`. |

## Wired but unconfirmed as actually *triggered* — the most subtle category, and worth reading carefully

This is distinct from both "real" and "fake": the code is genuine, non-stub, production-quality implementation — but no confirmed call site in the running app actually invokes it during normal use, based on everything read across all five research passes.

- **`OpenMeteoDataSource.refreshForHabitation()`** (environmental module) — nothing found calls this in production; only `adjustmentFor()` (reading whatever's already cached) is confirmed reached from the risk pipeline. If nothing ever calls the fetch, the real weather API may never actually be hit outside tests, despite being fully implemented and functional.
- **`RiskAssessmentService.assessHabitation`/`assessAllHabitations`, `CapacityAssessmentService`'s equivalents, `VulnerabilityAssessmentService.assessHabitation`** — confirmed by three independent module documents (`risk.md`, `capacity.md`, `vulnerability.md`) to have exactly one production call chain into them: opening the Relocation Priority screen (`relocationPriorityQueueProvider` → `RelocationPriorityService.buildQueue()`). There is no independent "recompute risk" or "recompute capacity" action anywhere else in the app. This means, structurally, **the Relocation Priority screen is not just a consumer of the scoring pipeline — it is the pipeline's only production trigger.** A District/Command or State/Admin user who never opens that specific screen may be looking at a dashboard whose risk-derived figures were never actually computed this session.
- **`HazardQueryService`** (hazards module) — implemented and tested, but the map/dashboard providers observed in this pass query `LocalHazardZoneRepository` directly rather than through this service; its production adoption outside its own module is unconfirmed.

## Corrections applied during final validation (contradictions found between files, resolved rather than guessed at)

Per this task's own instruction to document contradictions rather than silently pick one: `docs/modules/vulnerability.md`'s original pass claimed infrastructure/access indicators have "no live/configured data source... every habitation gets 0.5." This was checked directly against `lib/features/habitations/presentation/register_habitation_screen.dart` (built earlier in this same development session) and found to be incomplete — a real UI data-entry path exists. The module document was corrected in place with the verification command used, rather than left standing or silently rewritten without explanation.

## What this means for anyone continuing development

Before building on top of any of the "wired but unconfirmed" items above, **trace the actual call site yourself** rather than assuming a screen showing a number means that number was freshly (or ever) computed this session — the pattern this audit found repeatedly is real, tested, correct logic that simply has fewer entry points into it than a casual reading of the module's existence would suggest.
