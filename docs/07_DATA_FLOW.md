# Data Flow

Major end-to-end workflows, each traced to real classes and methods verified across this documentation pass. Only workflows confirmed to actually exist are included.

## Login

```
User enters email/password [LoginScreen, AutofillGroup-wrapped]
        ↓
AuthController.login(email, password)  [ref.read — a one-off action]
        ↓
AuthRepositoryImpl.login()
        ↓
FirebaseAuthRemoteDataSource.login()
        ↓
FirebaseAuth.signInWithEmailAndPassword(...)
        ↓
Firestore users/{uid} read → AppUser(id, name, email, role)
        ↓
AuthSession persisted via AuthLocalDataSource (flutter_secure_storage)
        ↓
AuthController.state = AsyncData(session)
        ↓
_RouterRefreshNotifier fires (ref.listen on authControllerProvider)
        ↓
computeRedirect() re-evaluates — session now non-null, current
location (/login) is in _authRoutes → redirect to /
        ↓
HomeScreen renders, role-appropriate quick actions computed from
effective permissions (role defaults merged with any admin override)
```

## Logout

```
User taps logout icon [HomeScreen app bar]
        ↓
AuthController.logout() → AuthRepositoryImpl.logout()
→ AuthLocalDataSource.clearSession()
        ↓
AuthController.state = AsyncData(null)
        ↓
context.go('/login')  ← explicit, not just reactive: replaces the
                          entire navigation stack so no authenticated
                          screen stays reachable via back button
```

## Main dashboard loading (District/Command)

```
User navigates to /dashboard [gated: Permission.monitorZones]
        ↓
CommandDashboardScreen builds, watches dashboardSnapshotProvider
        ↓
DashboardAggregator reads: LocalIncidentRepository.getAll(),
LocalHazardZoneRepository.getAll(), LocalCapacityAssessmentRepository
.getAll() (whatever was last computed — see the P1 gap in
16_IMPLEMENTATION_GAPS.md about assessment-trigger scarcity),
LocalResourceRepository.getAll()
        ↓
DashboardSnapshot assembled — KPI counts, capacity-gap total,
incident/hazard lists
        ↓
Screen renders; a pull-to-refresh or the app-root sync trigger
(syncPollingTriggerProvider, ~45s) invalidates dashboardSnapshotProvider
to pick up fresher data
```

## Important form submission (register a habitation)

```
Official taps the map [RegisterHabitationScreen] to mark a location,
fills population/name/region, selects access & infrastructure quality
        ↓
HabitationRegistrationService.register(...)
        ↓
LocalHabitationRepository.save(...)  [Drift write — succeeds instantly,
                                        no network wait]
        ↓
SyncQueueDao.enqueue(entityTable: 'local_habitations', ...)
        ↓
AuditLogDao.record(actorId, 'habitation.registered', ...)
        ↓
ref.invalidate(habitationsProvider) → screen's own "Registered
habitations" list updates immediately
        ↓
[on next sync trigger] SyncCoordinatorService pushes the queued entry
→ FirestoreSyncTransport → local_habitations/{id} in Firestore
        ↓
Other devices' next pull picks it up; their local Drift cache and
their own relocation-priority computation (if/when triggered) now see
this habitation too
```

## Map interaction

```
User opens /map [RiskMapScreen, gated: Permission.viewRiskMap]
        ↓
Watches hazardZonesProvider, sheltersProvider, incidentsProvider,
habitationsOverviewProvider, routesProvider (all FutureProvider
.autoDispose, each reading its own LocalXRepository.getAll())
        ↓
buildHazardZoneLayer/buildShelterLayer/etc. [map_overlay_layers.dart]
convert domain LatLng → google_maps_flutter LatLng at this boundary
only (per the app's own isolation convention — see 01_ARCHITECTURE.md)
        ↓
User taps a hazard zone polygon → onTap (consumeTapEvents: true) →
a bottom sheet shows source/observed-at/confidence — the provenance
surfacing built this session
        ↓
User taps a shelter marker → _routeToShelter() → RoutingService
.planRoute(origin: userPoint, destination: shelterLatLng)
        ↓
RiskAwareRoutingEngine (checks the route doesn't cross a hazard zone;
falls back to OSRM's public demo server for the actual road-network
path — see 08_API_DOCUMENTATION.md) → RoutePlan
        ↓
ref.invalidate(routesProvider) → polyline renders on the map
```

## Data retrieval (generic pattern, verified across dozens of screens)

```
Screen (ConsumerWidget) → ref.watch(someProvider)  [FutureProvider
.autoDispose]
        ↓
Provider body: ref.watch(someRepositoryProvider).getAll()/getById(...)
        ↓
Repository: Drift query → Result<T>.success(data) or .failure(...)
        ↓
Screen's .when(loading:, error:, data:) renders the appropriate state
```

## Data creation / update (generic pattern)

Every write-capable screen in the app follows the same shape as the habitation-registration flow above: local Drift write first (instant success from the user's perspective) → sync-queue enqueue → (usually) an audit-log entry → explicit `ref.invalidate(...)` of whatever provider the screen itself needs refreshed. See `docs/modules/*.md` for the exact service/repository names per feature.

## Offline operation

See `11_OFFLINE_FIRST.md` for the full OFFLINE FLOW / ONLINE FLOW diagrams — the short version: every write above happens identically whether or not connectivity is present; only the sync-queue drain step differs (deferred until a trigger fires with connectivity available).

## Synchronization

See `11_OFFLINE_FIRST.md` — triggered by `syncOnReconnectTriggerProvider` (offline→online edge) or `syncPollingTriggerProvider` (periodic, admin-configurable interval), both watched once at the app root.

## AI/ML operation

**No AI/ML operation exists in this codebase to trace.** The one candidate, `HazardSusceptibilityModel.predict()`, is a one-line function that returns `null` unconditionally — there is no computation, no model invocation, and (confirmed by the susceptibility module's own research pass) no caller anywhere in the app that would even receive a result if there were one. This is documented here explicitly, rather than omitted, because the source instructions for this handover require confirming the absence of a workflow as clearly as confirming its presence.

## External API operation (weather adjustment — the one confirmed real external-API workflow beyond auth/Firestore/Maps)

```
[Trigger point not confirmed as reached in production — see
12_DEMO_MOCK_AUDIT.md]
OpenMeteoDataSource.refreshForHabitation(habitationId, lat, lng)
        ↓
dio GET https://api.open-meteo.com/v1/forecast?...
        ↓
Response parsed into EnvironmentalObservation rows, persisted via
LocalEnvironmentalObservationRepository (with fetchedAt/observedAt
timestamps for freshness gating)
        ↓
[confirmed reached in production] risk assessment reads cached
observations via EnvironmentalRiskEngine.adjustmentFor(...) →
risk_environmental_merge.dart additively nudges RiskAssessmentResult
.riskScore, capped and tracked with provenance
(RiskAssessmentResult.environmentalProvenance)
```
