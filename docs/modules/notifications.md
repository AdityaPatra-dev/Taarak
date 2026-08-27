# MODULE: Notifications

## Purpose

Notifications gives every signed-in user a client-only local push notification whenever a new alert is broadcast or a new incident appears, while the app is open or backgrounded — no server-side push infrastructure, no Cloud Functions, no Firebase Cloud Messaging billing required. It works by diffing successive snapshots of two already-existing data streams (alert history, incident list) against their previous state and firing a device notification for anything genuinely new, establishing a baseline on first load so nothing already present when the app opens triggers a spurious notification.

**This module is a real platform integration, not a simulation** — unlike `sms_prototype` and `device_relay`, it uses the genuine `flutter_local_notifications` Flutter plugin (version `^22.3.0`, confirmed present in `pubspec.yaml`) which drives real OS-level notification APIs on Android and the browser's native Notification API on web through the same plugin surface.

## User-facing functionality

- **Any signed-in user** (no explicit permission gate, no dedicated screen): receives a real OS-level notification titled `"New alert: <alert title>"` with the alert's message as the body whenever a non-cancelled alert appears in `alertHistoryProvider` that wasn't there on the previous check; receives a notification titled `"New incident"` with the incident's description (or its type, if the description is empty) as the body whenever a new incident appears in `incidentsProvider`. There is no in-app notifications screen, no notification history/inbox, and no per-user notification preferences anywhere in this module — it is purely a fire-and-forget background watcher wired into the app root (`lib/app/app.dart`), not a feature with its own UI.
- The permission prompt (OS-level "allow notifications?") is requested automatically once, the first time `notificationWatcherProvider` is created (i.e., at app startup), via `PlatformNotifier.requestPermission()` — there is no user-facing settings toggle to grant/revoke this from within the app itself; that lives at the OS level.

## Entry points

Grepped `lib/app/router.dart` and `lib/app/route_guard.dart` for any `notifications`-related route: **none found.** This module owns no route and no screen. It is wired directly into the app root instead: `lib/app/app.dart` line 24, `ref.watch(notificationWatcherProvider)`, alongside the sync-on-reconnect and sync-polling triggers, kept alive for the entire app lifetime (not `.autoDispose` in effective behavior, since it is watched continuously from a widget that never unmounts during a normal session) so it is always listening regardless of which screen is currently on top.

## Architecture

- **`application/`** — one file, `notification_providers.dart`: the diffing/watching logic itself, expressed as a single Riverpod `Provider.autoDispose<void>` whose entire job is its side effects (`ref.listen` callbacks), not its return value.
- **`data/`** — one file, `platform_notifier.dart`: a thin wrapper class (`PlatformNotifier`) around the `flutter_local_notifications` plugin, handling lazy initialization, permission requests, and showing a notification, with defensive try/catch around every plugin call.
- No `domain/` or `presentation/` folder — this module has no domain model of its own (it reuses `LocalAlert`/`LocalIncident` from other modules) and no UI.
- This is the smallest and most tightly-scoped module in the documented set: two files, no route, no repository, no test directory.

## Files in this module

### `lib/features/notifications/data/platform_notifier.dart`
- **Purpose**: Wraps `flutter_local_notifications` behind a small, defensively-coded class — lazy plugin initialization, OS permission request, and a single `show(title, body)` method — so the rest of the app never touches the plugin API directly.
- **Status**: IMPLEMENTED. EXTERNAL DEPENDENCY (`flutter_local_notifications` package) — this is the one file in the module that performs real platform integration.
- **Key classes/functions**: `PlatformNotifier` — `_plugin = FlutterLocalNotificationsPlugin()` (real plugin instance), `_initialized` (bool, memoizes successful init), `_nextId` (int, auto-incrementing notification id so each call to `show` produces a distinct OS notification rather than replacing the previous one); `_ensureInitialized()` — calls `_plugin.initialize(...)` with Android (`AndroidInitializationSettings('@mipmap/launcher_icon')`) and Web (`WebInitializationSettings()`) settings, wrapped in try/catch — returns `false` silently on any failure (explicitly documented: *"No platform channel available (e.g. running under flutter_test, or a platform this plugin doesn't cover) — notifications are a best-effort convenience, never worth crashing over"*); `requestPermission()` — resolves the Android- and Web-specific plugin implementations and calls `requestNotificationsPermission()` on each if present, again fully swallowing any exception; `show({title, body})` — calls `_plugin.show(...)` with an `AndroidNotificationDetails` (channel id `taarak_alerts`, channel name `'TAARAK Alerts'`, `Importance.high`/`Priority.high`) and `WebNotificationDetails()`, also wrapped in try/catch; module-level factory function `createPlatformNotifier() => PlatformNotifier()`.
- **Notable imports**: `flutter_local_notifications` (the real, external plugin package) — no other imports.
- **Depends on**: the `flutter_local_notifications` plugin directly; nothing else in the codebase.
- **Depended on by**: `notification_providers.dart` (`platformNotifierProvider`).
- **State read/written**: no app state (Drift/Firestore); the plugin itself manages OS-level notification-channel state on Android and DOM Notification state on web.
- **External communication**: real OS notification APIs — on Android, the system notification tray via the native plugin channel; on web, the browser's `Notification` API via the plugin's web companion package. This is genuine platform I/O, confirmed by the real dependency in `pubspec.yaml` (`flutter_local_notifications: ^22.3.0`).
- **Mock/demo content**: none — this is a real, working integration, not a stub or simulation. Every failure path (initialization failure, permission-request failure, show failure) is deliberately silent/non-throwing by design, which is a genuine robustness choice, not a placeholder.

### `lib/features/notifications/application/notification_providers.dart`
- **Purpose**: The module's only logic — watches two other modules' Riverpod providers (`alertHistoryProvider` from Alerts, `incidentsProvider` from Map) and fires a local notification for anything newly appearing since the last snapshot, establishing a silent baseline on first load.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `platformNotifierProvider` (`Provider<PlatformNotifier>`, constructed via `createPlatformNotifier()`); `notificationWatcherProvider` (`Provider.autoDispose<void>`) — on creation, calls `notifier.requestPermission()` once, then sets up two independent `ref.listen` closures:
  - Alert watcher: maintains `knownAlertIds` (nullable `Set<String>`, closure-captured mutable state — a real, if unconventional, use of a plain local variable as provider-lifetime state rather than a `StateNotifier`). On the *first* emission, it just captures the current id set as the baseline and returns (no notification fired). On every subsequent emission, for each alert whose id was NOT in the previous known set AND whose `cancelledAt == null`, it calls `notifier.show(title: 'New alert: ${alert.title}', body: alert.message)`.
  - Incident watcher: identical pattern with `knownIncidentIds` against `incidentsProvider`, firing `notifier.show(title: 'New incident', body: incident.description.isEmpty ? incident.type : incident.description)` for each newly-seen incident id.
- **Notable imports**: `core/database/app_database.dart` (`LocalAlert`), `features/alerts/application/alert_providers.dart` (`alertHistoryProvider` — cross-module dependency on Alerts), `features/map/application/map_data_providers.dart` (`incidentsProvider` — cross-module dependency on Map), `platform_notifier.dart`.
- **Depends on**: `PlatformNotifier` (this module), `alertHistoryProvider` (alerts module), `incidentsProvider` (map module).
- **Depended on by**: `lib/app/app.dart` (`ref.watch(notificationWatcherProvider)`, watched at the app root alongside sync triggers).
- **State read/written**: reads `local_alerts` (via `alertHistoryProvider`) and `local_incidents` (via `incidentsProvider`) indirectly; writes nothing to Drift or Firestore — its only "write" is firing an OS notification.
- **External communication**: none directly — delegates all platform I/O to `PlatformNotifier`.
- **Mock/demo content**: none — this is real, working diffing logic. Note it is untested (see Test Coverage) despite non-trivial first-emission/baseline semantics that would benefit from a unit test.

## Data Models

This module defines no domain models of its own — it consumes `LocalAlert` (Alerts module) and `LocalIncident` (Map module) purely for their `id`, `title`/`message`/`cancelledAt` (alerts) and `id`/`description`/`type` (incidents) fields, and produces no persisted output of its own; a fired notification exists only as an OS-level artifact, not an app-level record.

## Services / Repositories

- **`PlatformNotifier`** — the module's only "service," a thin wrapper around a real external plugin (`flutter_local_notifications`). Not a repository — it holds no queryable state and persists nothing app-side.
- No repository exists in this module — there is no local table of "notifications sent" or "notifications read," and no way for a user to review past notifications inside the app itself.

## Routes owned by this module

**None.** This module has no screen and no route entry in `lib/app/router.dart`. It is instantiated as a side-effecting provider watched from `lib/app/app.dart`'s root widget (`TaarakApp.build`, line 24), active for the full lifetime of the app regardless of the current route or the user's role/permissions.

## Module Data Flow

**A new alert triggers a notification (the module's only real flow):**

```
App root (TaarakApp.build) -> ref.watch(notificationWatcherProvider)   [held alive for the app's lifetime]
  on creation: PlatformNotifier.requestPermission()                     [real OS permission prompt, Android + Web]

Elsewhere: an official broadcasts a new alert (Alerts module)
  -> AlertBroadcastService.broadcastToZone(...) writes local_alerts
  -> alertHistoryProvider re-fetches (via its own invalidation elsewhere, or a periodic poll from the Sync module)

notificationWatcherProvider's ref.listen(alertHistoryProvider, ...) fires
  -> compares new alert id set against knownAlertIds (previous snapshot)
  -> for each new, non-cancelled alert:
     -> PlatformNotifier.show(title: 'New alert: <title>', body: <message>)
        -> FlutterLocalNotificationsPlugin.show(...)                    [REAL OS notification: Android tray / browser Notification API]
  -> knownAlertIds updated to the new full set

(identical pattern independently for incidentsProvider -> 'New incident' notifications)
```

## Current Status

**Working**, and the only one of the eight documented modules that involves genuine external platform integration rather than an internal simulation. Evidence: `flutter_local_notifications: ^22.3.0` is a real dependency in `pubspec.yaml`; `PlatformNotifier` calls the plugin's real `initialize`/`show`/`requestNotificationsPermission` APIs; the provider is wired at the app root (`lib/app/app.dart`) so it is genuinely active throughout a real session, not just reachable from an isolated demo screen.

## Known Limitations

- **No test coverage at all** (see below) — the first-emission baseline logic and the new-vs-known diffing are both non-trivial and currently unverified by any automated test.
- **No in-app notification history.** Once a local notification is shown, there is no record of it inside the app itself — no inbox screen, no "mark as read," no way to review what was previously notified. `PlatformNotifier._nextId` only exists to keep the OS from collapsing distinct notifications into one, not as a durable log.
- **All initialization/permission/show failures are silently swallowed** (`catch (_) {}` with a comment explaining the tradeoff as intentional — "notifications are a best-effort convenience, never worth crashing over"). This is a defensible design choice, but it also means there is no user-visible or developer-visible signal anywhere in this module if notifications are silently failing on a given device (e.g. permission denied, plugin not supported on a platform) — a user might simply never receive alerts and have no way to tell from within the app why.
- The diffing state (`knownAlertIds`/`knownIncidentIds`) is held as plain closure-captured local variables inside `notificationWatcherProvider`'s builder function rather than in a dedicated `StateNotifier` or class — functionally correct for a `Provider.autoDispose` that's expected to live once for the app's lifetime, but an unconventional pattern that would be easy to break if this provider were ever accidentally recreated (e.g. if its watcher were removed and re-added, the `.autoDispose` semantics would reset both id sets and re-establish a fresh baseline, silently suppressing notifications for anything that changed during the gap).
- No de-duplication against alerts/incidents the user has already acted on elsewhere in the app (e.g. an already-acknowledged alert on the Alerts screen would still trigger a "New alert" notification if it's the first time this particular provider instance has seen its id) — the two systems (Alerts' acknowledgement state and this module's notification-seen state) are entirely independent.
- Notifications only fire while the Riverpod provider tree is alive (app open or backgrounded per the plugin's OS-level behavior) — there is no server-side push (FCM) fallback for when the app is fully terminated, which is explicitly the documented scope boundary, not an oversight.

## Test Coverage

**None.** `test/features/notifications/` does not exist — confirmed by directory listing of `test/features/` (entries: `admin, alerts, audit, auth, capacity, dashboard, device_relay, disaster_events, environmental, fusion, habitations, hazards, map, profile, relocation, reporting, risk, routing, shelters, sms_prototype, sync, verification, vulnerability` — no `notifications`). There is no unit test for the first-emission baseline behavior, the new-vs-known diffing logic in `notificationWatcherProvider`, or the cancelled-alert exclusion; no test (mocked or otherwise) for `PlatformNotifier` against a fake/mocked `flutter_local_notifications` plugin. This is a complete, explicit test gap for the entire module.
