# MODULE: Profile

## Purpose

This module is the user's own account/status page. Concretely, when a user taps the person icon in the Home screen's app bar, they land here and see two things: who they are (name, email, role — read-only, sourced from their auth session), and where the app currently thinks they are (device location status). The location half is the module's actual functional purpose: it shows whether the app has permission to access GPS, and if so, the most recently captured coordinate fix (latitude/longitude, accuracy in meters, how many seconds old it is, and — if resolvable — which administrative region/ward it falls in). A "Refresh location" button lets the user re-request permission (if it was denied) and capture a fresh GPS fix on demand. This matters in TAARAK's disaster-management context because location is what gets attached to incident reports, SOS calls, and safety-status updates elsewhere in the app — this screen is where a user can verify, before an emergency, that location capture actually works on their device.

## User-facing functionality

- **Profile screen** (`/profile`):
  - A profile card showing the signed-in user's avatar initial, name, email, and role label (read-only — no edit affordance anywhere on this screen).
  - A "Location" section showing:
    - Current permission status with an icon and label: Granted / Denied ("tap Refresh to request") / Denied permanently ("enable location for TAARAK in device settings") / Location services off.
    - If no fix has ever been captured: "No location captured yet."
    - If a fix exists: latitude/longitude (5 decimal places), accuracy in meters, age in seconds since capture, and the resolved administrative region name (or "not available yet (needs GIS boundary data)" if resolution failed/wasn't attempted).
  - A "Refresh location" button (shows a spinner while in flight) that requests permission and attempts to capture a new fix; any failure is shown as inline error text below the status.

## Entry points

- The person-outline icon in `HomeScreen`'s app bar (`lib/features/home/presentation/home_screen.dart`) — the only in-app link to `/profile`, present for every role.
- Direct URL/deep link to `/profile` also works (the route carries no `Permission` requirement — see Routes below).

## Architecture

A partial `application` / `presentation` split — **there is no `domain/` or `data/` folder in this module**. The one non-presentation file, `location_status_controller.dart`, lives in `application/` and contains both a small local data class (`LocationStatus`) and the Riverpod controller — domain and application concerns are combined in one file rather than split out. The screen itself reads two providers it does not own at all: `currentUserProvider` (auth module) and `locationServiceProvider`/`geoTagServiceProvider` (both defined in `core/`, not this module) via `location_status_controller.dart`.

## Files in this module

### `lib/features/profile/presentation/profile_screen.dart`
- **Purpose**: The screen itself — renders the user-identity card and the location-status card, and wires the "Refresh location" button to the controller.
- **Status**: IMPLEMENTED.
- **Key classes**: `ProfileScreen` (`ConsumerStatefulWidget`), `_ProfileScreenState` (`_refreshLocation`), `_LocationStatusView` (`StatelessWidget`, maps `LocationPermissionStatus` to icon/label text).
- **Key logic**: `_refreshLocation()` calls `locationStatusProvider.notifier.refresh()`, and on `Failed` sets a local `_errorMessage` shown beneath the status card — same success/failure `Result.when` pattern used throughout the app (auth, admin, etc.).
- **Notable imports**: `auth/application/auth_controller.dart` (`currentUserProvider`) and `auth/domain/user_role.dart` (role label display) from the auth module; `core/location/location_permission_status.dart` from core; `profile/application/location_status_controller.dart` (same module).
- **State it reads**: `currentUserProvider` (auth module — the signed-in `AppUser`, may be null though the screen is only reachable when authenticated), `locationStatusProvider` (this module's own controller).
- **State it writes**: none directly to itself — delegates the actual location-capture side effect to `locationStatusProvider.notifier.refresh()`.
- **External communication**: none directly — all device/location I/O happens inside `LocationStatusController` and the `core/location/` services it calls.
- **Depends on**: `LocationStatus`/`locationStatusProvider` (this module), `currentUserProvider` (auth). **Depended on by**: `lib/app/router.dart` (registers it at `/profile`), `HomeScreen` (links to it).

### `lib/features/profile/application/location_status_controller.dart`
- **Purpose**: Holds the current location-permission status and most recent GPS fix as Riverpod state; exposes a `refresh()` action that requests permission (if needed) and captures a fresh geotag.
- **Status**: IMPLEMENTED.
- **Key classes**: `LocationStatus` (plain data class: `permission` + nullable `geoTag`) — note this is a *local, module-owned* class, distinct from the `GeoTag` domain model it wraps (which lives in `core/location/`); `locationStatusProvider` (`AsyncNotifierProvider<LocationStatusController, LocationStatus>`); `LocationStatusController` — `build()` (checks current permission on first load, no fix yet), `refresh()` (requests permission, updates state immediately with the new permission + previous fix, then attempts a fresh capture and updates state again on success — a two-step optimistic update so the permission-status UI reflects immediately even before the (potentially slow) GPS fix completes).
- **State it reads**: `locationServiceProvider` (core — `checkPermission()`/`requestPermission()`), `geoTagServiceProvider` (core — `captureGeoTag()`).
- **State it writes**: its own `state` (`AsyncData<LocationStatus>`), no persistence — this state is in-memory only and resets on app restart (there is no local-storage/Drift caching of the last known location visible in this module).
- **External communication**: none directly — delegates to `core/location/location_service.dart` (device GPS/permission APIs, likely via `geolocator` based on a comment seen in `location_permission_status.dart`) and `core/location/geo_tag_service.dart` (which additionally resolves an `AdministrativeContext` from coordinates).
- **Depends on**: `GeoTag`, `LocationPermissionStatus` (core), `Result` (core). **Depended on by**: `ProfileScreen` exclusively within this module — no other module in the documented set reads `locationStatusProvider` (though `GeoTag`/location services themselves are used more broadly by reporting features outside this module's scope).

## Data Models

| Class | Fields | Owner |
|---|---|---|
| `LocationStatus` | `permission` (`LocationPermissionStatus`), `geoTag` (`GeoTag?`) | This module (`location_status_controller.dart`) |
| `GeoTag` *(consumed, not owned)* | `fix` (`GpsFix`), `administrativeContext` (`AdministrativeContext?`) | `core/location/geo_tag.dart` |
| `GpsFix` *(consumed, not owned)* | `latitude`, `longitude`, `accuracyMeters`, `capturedAt` | `core/location/gps_fix.dart` |
| `LocationPermissionStatus` *(consumed, not owned)* (enum) | `granted`, `denied`, `deniedForever`, `serviceDisabled` | `core/location/location_permission_status.dart` |

This module owns only `LocationStatus`; every other model it displays is defined in `core/location/` and shared with other features (e.g. incident/SOS reporting) that also attach geotags.

## Services / Repositories / Data Sources

This module has **no `data/` folder and defines no services or repositories of its own**. It is entirely a consumer of `core/location/` services:

| Component | Owner | Real or Mock |
|---|---|---|
| `locationServiceProvider` (`LocationService`) | `core/location/` | Real (device GPS via platform APIs) in production; the profile test (`profile_screen_test.dart`) overrides it with a `_FakeLocationService` for deterministic testing — no mock exists in the shipped app itself. |
| `geoTagServiceProvider` (`GeoTagService`) | `core/location/` | Real, additionally depends on an `AdministrativeContextResolver` to map coordinates to a named region. |

There is no auth-comparable "mock vs. Firebase" split visible in this module — the only fake implementation found is test-only (`_FakeLocationService`, `_FixedContextResolver` in `profile_screen_test.dart`), not shipped app code.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/profile` | `ProfileScreen` | None — absent from `defaultRoutePermissions` in `lib/app/route_guard.dart`, so any authenticated user of any role can reach it | `HomeScreen`'s app-bar profile icon |

## Module Data Flow

The screen's main action — refreshing location status:

```
ProfileScreen (_refreshLocation)
  → ref.read(locationStatusProvider.notifier).refresh()
    → LocationStatusController.refresh()
      → ref.read(locationServiceProvider).requestPermission()   [core/location/location_service.dart]
        → device GPS/location-permission prompt (or fake, in tests)
      ← LocationPermissionStatus
      → state = AsyncData(LocationStatus(permission: new, geoTag: previous))   [optimistic partial update]
      → ref.read(geoTagServiceProvider).captureGeoTag()          [core/location/geo_tag_service.dart]
        → LocationService.getCurrentFix()  → GpsFix
        → AdministrativeContextResolver.resolve(lat, lng) → AdministrativeContext? (region name)
      ← Result<GeoTag>
      [on Success] → state = AsyncData(LocationStatus(permission, geoTag: new))
      [on Failure] → state unchanged from the optimistic partial update
    ← Result<GeoTag>
  → ProfileScreen shows the failure message inline, or the AsyncNotifier's new state renders
    via ref.watch(locationStatusProvider) → _LocationStatusView
```

Identity display is simpler — a one-way read, no write:

```
ProfileScreen.build()
  → ref.watch(currentUserProvider)   [auth module — derived from authControllerProvider]
  → renders name / email / role.label directly, no local state, no round trip
```

## Current Status

- **Working**: both files are fully implemented; confirmed by reading the code and by a passing widget test that exercises the full permission-request → capture → display flow.
- **No demo/mock production code** found in this module — the only fakes are test doubles, not shipped code.
- **Identity display is read-only** — there is no edit-profile functionality (no way to change name, email, or anything else) anywhere in this module or route table; the profile card is purely a display of what the auth session already holds.

## Known Limitations

- No profile editing whatsoever — a user cannot change their display name, email, or any other field from this screen (or, as far as this module's scope shows, from anywhere in the app). Changing a name currently appears possible only via `FirebaseAuthRemoteDataSource.register()`'s one-time `updateDisplayName` call at account creation, or by an admin's Firestore-side edit outside the app.
- Captured location state (`LocationStatus`) is **held only in memory** (Riverpod provider state) — it is not persisted to local storage or Firestore by this module, so it resets to "no location captured yet" every time the app restarts, even if a fix was captured moments before closing the app.
- The "administrative region" lookup depends on a `AdministrativeContextResolver` that can return `null` — the screen explicitly acknowledges this ("not available yet (needs GIS boundary data)"), indicating the underlying GIS boundary data this depends on may be incomplete or not fully wired up; this module cannot control or diagnose that from its own code.
- No auto-refresh: location status is only ever updated by an explicit user tap on "Refresh location" — the screen does not poll or subscribe to location changes in the background.
- No visible role-specific behavior — every role sees the identical Profile screen; there's nothing here (unlike Home) that varies by permission.

## Test Coverage

`test/features/profile/` exists (unlike `test/features/home/`, which does not) and contains exactly **one file**, `profile_screen_test.dart`, read in full:

- Pumps `ProfileScreen` standalone (not the full `TaarakApp`) inside a `ProviderScope` with `locationServiceProvider` and `administrativeContextResolverProvider` both overridden with test doubles (`_FakeLocationService`, `_FixedContextResolver`).
- Asserts the initial state shows "Denied" permission and "No location captured yet."
- Taps "Refresh location," then asserts the UI updates to show "Granted," the captured latitude ("Lat 10.12300"), and the resolved region name ("Ward 7").

This is a real, meaningful end-to-end widget test of the module's core interaction loop (permission request → capture → display), but it leaves several things **not covered**:
- The user-identity card (name/email/role display) is not asserted on at all — the test's `MaterialApp(home: ProfileScreen())` wrapper provides no `currentUserProvider` override, so `user` is implicitly null throughout the test and that card branch (`if (user != null)`) is never exercised.
- Failure paths are not tested — no test simulates `LocationService`/`GeoTagService` returning a `Failed` result to verify the inline error-message rendering.
- The other three `LocationPermissionStatus` states (`deniedForever`, `serviceDisabled`) and their distinct label text are not exercised — only `denied` → `granted` is tested.
- The "no administrative context resolved" branch (`administrativeContext == null` → "not available yet") is not tested — the test's `_FixedContextResolver` always returns a non-null result.
- No test exists for reaching `/profile` via routing/navigation (e.g. tapping the Home screen's profile icon) — the test constructs `ProfileScreen` directly.
