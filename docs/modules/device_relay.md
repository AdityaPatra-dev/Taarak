# MODULE: Device Relay

## Purpose

Device Relay (blueprint milestone "M23") demonstrates a store-and-forward mesh relay decision: when a device receives an emergency packet broadcast by a nearby peer, should THIS device re-broadcast it further? It reuses M22's `EmergencyPacket` model and wire codec exactly, and adds exactly one new rule set on top: relay-specific duplicate suppression — a device never re-relays the same packet id twice, and never relays its own broadcast back into the mesh. Per the blueprint (quoted directly in this module's source), device relay is flagged as "highly innovative but risky" — more so than the SMS fallback — and is scoped identically: a controlled, in-process prototype of the decision logic, not a working mesh network.

**Verified finding on the required check: this module implements NO real Bluetooth/WiFi Direct/nearby-connections transport. It is a pure in-memory SIMULATION, structurally identical to `sms_prototype`'s pattern.**

Evidence, in order of directness:
1. `lib/features/device_relay/application/relay_transport.dart`'s abstract `RelayTransport` interface ships exactly one implementation, `LoopbackRelayTransport`, whose doc comment states: *"The controlled prototype: broadcasts are recorded, not actually sent anywhere, and [simulateIncoming] plays the role of 'a nearby device's broadcast reached this one' — enough to exercise the real relay decision logic (TTL, origin, duplicate suppression) without a mesh."* `broadcast(String encodedPacket)` (lines 28-32) only appends to an in-memory `List<String> broadcastLog` and returns `Result.success(null)` — no Bluetooth API, no WiFi Direct API, no nearby-connections plugin call of any kind.
2. The interface's own doc comment is explicit about why: *"a real implementation (Bluetooth/WiFi Direct nearby-connections) needs runtime location/Bluetooth permissions and physically nearby devices to validate against — neither of which this environment has. Only [LoopbackRelayTransport] is shipped; a real implementation is a future swap-in behind this same interface."*
3. `device_relay_screen.dart`'s on-screen banner text, shown to every user: *"Controlled prototype: nothing leaves this device over Bluetooth/WiFi. This demonstrates the relay decision (TTL, origin, duplicate suppression) that a real nearby-connections transport would use once one is wired in behind the same interface."*
4. `pubspec.yaml` was checked for any Bluetooth/WiFi/nearby-connections package (`bluetooth`, `wifi_direct`, `nearby`, `flutter_blue`, `bluetooth_serial`, `wifi`) — none found. No platform permission (`BLUETOOTH`, `BLUETOOTH_ADMIN`, `ACCESS_FINE_LOCATION` for BLE scanning, `NEARBY_WIFI_DEVICES`) is requested anywhere in this module's Dart source.
5. The screen's "Simulate a broadcast arriving from a nearby device" button fabricates a synthetic peer packet with an id like `'peer-device-<timestamp%1000>'` and feeds it directly into the same device's own `LoopbackRelayTransport.simulateIncoming` — there is no second device, no radio, and no real mesh anywhere in the flow.

The relay decision logic itself (`DeviceRelayEngine.evaluate` — TTL/origin/duplicate-suppression) is real, fully implemented, and independently unit-tested, including a "full relay chain" test that simulates device A → device B by wiring two separate in-process `DeviceRelayService`/`LoopbackRelayTransport` pairs together manually in the test — still entirely in-process, no real inter-device communication.

## User-facing functionality

- **Any authenticated user holding `Permission.sendSos`** (citizens hold this by default; screen `DeviceRelayScreen` at `/device-relay`): sees an explicit "Controlled prototype: nothing leaves this device over Bluetooth/WiFi" banner. "Broadcast my emergency packet" captures a real GPS fix, builds an SOS `EmergencyPacket` via the (shared, cross-module) `SmsPrototypeService.buildPacket`, and "broadcasts" it (records it) via `LoopbackRelayTransport`. "Simulate a broadcast arriving from a nearby device" fabricates a synthetic peer packet (random `peer-device-*` origin id, `critical` priority, `'landslide'` type, fixed demo coordinates) and injects it as if it had arrived from a real neighbor — this is what actually exercises the relay decision, since the device's own broadcasts always short-circuit as "own broadcast." Two running lists are shown: "Broadcasts sent" (raw encoded strings this device has sent/relayed) and "Relay activity" (every incoming-broadcast decision made this session, each tile showing whether it was relayed and why/why not, e.g. "Relayed to nearby devices" or "Not relayed: already relayed").

## Entry points

Grepped from `lib/app/router.dart` and `lib/app/route_guard.dart`:

| Route | Screen | Permission required |
|---|---|---|
| `/device-relay` | `DeviceRelayScreen` | `Permission.sendSos` |

Single flat route, no path params. Same permission as `/sms-prototype`.

## Architecture

- **`domain/`** — one file, `device_relay_outcome.dart`: a plain result holder (`DeviceRelayOutcome`) explaining what happened to one incoming broadcast and why, so the UI can show a reason, not just a fact.
- **`application/`** — four files: `relay_transport.dart` (abstract interface + the only implementation, `LoopbackRelayTransport` — the simulation boundary, structurally identical in design to `sms_prototype`'s `SmsTransport`/`LoopbackSmsTransport`), `device_relay_engine.dart` (pure decision logic — TTL/origin/dedup, no IO), `device_relay_service.dart` (orchestrates codec + engine + transport, and is the one place that tracks per-device relay history), `device_relay_providers.dart` (Riverpod wiring, including a `StateProvider<String?>` for "this device's id" set from the signed-in user).
- **`presentation/`** — one screen.
- **Deliberate reuse across modules**: this module does not define its own packet model or codec — it imports `EmergencyPacket`, `EmergencyPacketPriority`, and `EmergencyPacketCodec` directly from `lib/features/sms_prototype/` rather than duplicating them ("Reuses M22's EmergencyPacket/TTL exactly per the spec's 'TTL/origin/version'"). This is a genuine, intentional cross-module dependency, not an accident — `device_relay` cannot function without `sms_prototype`'s domain/codec files present.

## Files in this module

### `lib/features/device_relay/domain/device_relay_outcome.dart`
- **Purpose**: Surfaces what `DeviceRelayService.handleIncoming` did with one incoming broadcast — the decoded packet, whether it was relayed, and a human-readable reason — so a UI can explain "why," not just "what."
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `DeviceRelayOutcome` — `packet` (`EmergencyPacket`, imported from `sms_prototype`), `wasRelayed` (bool), `reason` (String — one of `'relayed'`, `'expired'`, `'own broadcast'`, `'already relayed'`, per `DeviceRelayEngine`'s literal return values).
- **Notable imports**: `features/sms_prototype/domain/emergency_packet.dart` — cross-module dependency confirmed at the domain layer, not just application.
- **Depends on**: `EmergencyPacket` (sms_prototype module).
- **Depended on by**: `device_relay_service.dart`, `device_relay_providers.dart`, `device_relay_screen.dart`.
- **State read/written**: none — pure value object, never persisted.
- **External communication**: none.
- **Mock/demo content**: none in the class itself.

### `lib/features/device_relay/application/relay_transport.dart`
- **Purpose**: Abstracts "broadcast to nearby devices" behind an interface, explicitly modeled on `sms_prototype`'s `SmsTransport` pattern for the same reason. Ships exactly one implementation.
- **Status**: `RelayTransport` (abstract) — IMPLEMENTED as a contract only. `LoopbackRelayTransport` — DEMO/MOCK / SIMULATION, explicitly and intentionally so (this is the definitive evidence file for this module's "real vs. simulated" verification, parallel to `sms_transport.dart` in the SMS Prototype module).
- **Key classes/functions**: `RelayTransport` (abstract) — `broadcast(String encodedPacket) -> Future<Result<void>>`; `incomingBroadcasts -> Stream<String>`. `LoopbackRelayTransport implements RelayTransport` — `broadcastLog: List<String>` (public, in-memory, read directly by the UI); `broadcast()` appends to the log and always succeeds; `incomingBroadcasts` backed by a broadcast `StreamController<String>`; `simulateIncoming(String rawMessage)` — the only way a message ever enters the "incoming" side; `dispose()`.
- **Notable imports**: `dart:async`, `core/repository/result.dart` — no Bluetooth/WiFi/platform-channel package of any kind.
- **Depends on**: nothing beyond `Result`.
- **Depended on by**: `device_relay_providers.dart` (`relayTransportProvider`), `device_relay_service.dart`, `device_relay_screen.dart` (reads `.broadcastLog` directly, calls `.simulateIncoming` directly), `device_relay_service_test.dart`.
- **State read/written**: in-memory only.
- **External communication**: **NONE. This is the file that proves the module does not use real Bluetooth/WiFi/nearby-connections.**
- **Mock/demo content**: **Explicitly and unambiguously simulated** — same class of finding as `sms_prototype`'s `LoopbackSmsTransport`.

### `lib/features/device_relay/application/device_relay_engine.dart`
- **Purpose**: The module's actual new logic on top of M22 — pure decision function for whether THIS device should re-broadcast an incoming packet: not expired, not its own origin, not already relayed by this device.
- **Status**: IMPLEMENTED, real and fully working.
- **Key classes/functions**: `DeviceRelayEngine.evaluate({packet, thisDeviceId, alreadyRelayedIds, now}) -> ({bool shouldRelay, String reason})` (returns a Dart record) — check order: expired first (`packet.isExpired(now)` → `'expired'`), then own-origin (`packet.originId == thisDeviceId` → `'own broadcast'`), then already-relayed (`alreadyRelayedIds.contains(packet.id)` → `'already relayed'`), else `(true, 'relayed')`. The expiry-checked-first ordering is deliberate and tested (an expired own-packet reports `'expired'`, not `'own broadcast'`).
- **Notable imports**: only `features/sms_prototype/domain/emergency_packet.dart`.
- **Depends on**: `EmergencyPacket` (sms_prototype).
- **Depended on by**: `device_relay_service.dart`, `device_relay_engine_test.dart`.
- **State read/written**: none — pure function, `alreadyRelayedIds` is passed in by the caller each time rather than owned here.
- **External communication**: none.
- **Mock/demo content**: none — real, tested decision logic.

### `lib/features/device_relay/application/device_relay_service.dart`
- **Purpose**: Orchestrates both directions — broadcasting this device's own packet, and (the module's real new behavior) deciding whether an incoming peer packet should be re-broadcast, while tracking a running set of already-relayed packet ids for the lifetime of this service instance.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `DeviceRelayService` (constructor DI: `RelayTransport` required, `EmergencyPacketCodec`/`DeviceRelayEngine` optional/injectable); private `_relayedIds: Set<String>` (mutable, owned by this instance — NOT persisted to Drift, lost on app restart); `relayedIds` getter (returns an unmodifiable view); `broadcastOwnPacket(EmergencyPacket)` — encodes and sends via the transport; `handleIncoming(String raw, {thisDeviceId, now}) -> Future<DeviceRelayOutcome?>` — decodes (returns `null` for anything that doesn't parse as a TAARAK packet — "a stray nearby broadcast is not this module's concern"), evaluates via `DeviceRelayEngine`, and if `shouldRelay` is true, adds the id to `_relayedIds` and re-broadcasts the *original raw string* (not re-encoded) via the transport before returning the outcome; `incomingBroadcasts` — passthrough to the transport's stream.
- **Notable imports**: `core/repository/result.dart`, `device_relay_engine.dart`, `relay_transport.dart`, `device_relay_outcome.dart`, `features/sms_prototype/application/emergency_packet_codec.dart` (cross-module reuse — no separate codec exists for this module), `features/sms_prototype/domain/emergency_packet.dart`.
- **Depends on**: `RelayTransport` (abstract — receives `LoopbackRelayTransport` in practice), `EmergencyPacketCodec` (sms_prototype), `DeviceRelayEngine`.
- **Depended on by**: `device_relay_providers.dart`, `device_relay_screen.dart`, `device_relay_service_test.dart`.
- **State read/written**: `_relayedIds` is in-memory, per-instance state — not shared across app restarts, not shared across two different `DeviceRelayService` instances (the "full relay chain" test explicitly constructs two separate instances to model device A vs. device B, each with its own transport and its own `_relayedIds`).
- **External communication**: none directly — inherits whatever the injected `RelayTransport` does, which in the shipped configuration is nothing (loopback only).
- **Mock/demo content**: real orchestration logic; becomes a simulation only through its wiring to `LoopbackRelayTransport`.

### `lib/features/device_relay/application/device_relay_providers.dart`
- **Purpose**: Riverpod wiring, plus one piece of state unique to this module: `thisDeviceIdProvider`, which the screen populates from the signed-in user's real id so relay self-suppression uses a genuine identity rather than a placeholder.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `relayTransportProvider` (`Provider<LoopbackRelayTransport>` — concrete simulated type named directly, same pattern as `sms_prototype`'s `smsTransportProvider`); `deviceRelayServiceProvider`; `thisDeviceIdProvider` (`StateProvider<String?>`, starts `null`, set by the screen's `initState`); `relayActivityProvider` (`StateNotifierProvider<RelayActivityNotifier, List<DeviceRelayOutcome>>` — subscribes to the transport's `incomingBroadcasts` stream, and on each raw message reads `thisDeviceIdProvider` — falling back to the literal string `'this-device'` if it hasn't been set yet — and calls `service.handleIncoming`); `RelayActivityNotifier.handleIncoming` — prepends the new outcome to state (most-recent-first), skips entirely if `handleIncoming` returned `null` (non-TAARAK message).
- **Notable imports**: `device_relay_service.dart`, `relay_transport.dart`, `device_relay_outcome.dart`.
- **Depends on**: `DeviceRelayService`, `LoopbackRelayTransport` (concretely).
- **Depended on by**: `device_relay_screen.dart`.
- **State read/written**: in-memory provider state only.
- **External communication**: none.
- **Mock/demo content**: same evidentiary weight as `sms_prototype_providers.dart` — the provider's concrete binding to `LoopbackRelayTransport` (not the abstract `RelayTransport`) confirms no alternate/real transport is selectable anywhere in the current build.

### `lib/features/device_relay/presentation/device_relay_screen.dart`
- **Purpose**: The module's only UI — demonstrates the relay decision when a simulated nearby broadcast arrives, and separately lets the user originate and "broadcast" their own emergency packet.
- **Status**: IMPLEMENTED as a demonstration/prototype screen (its documented purpose).
- **Key classes/functions**: `DeviceRelayScreen`/`_DeviceRelayScreenState` — `initState` sets `thisDeviceIdProvider` from the signed-in user's id via a post-frame callback; `_broadcastOwnPacket()` (captures a real GPS fix, builds an SOS packet via the cross-module `smsPrototypeServiceProvider.buildPacket`, calls `deviceRelayServiceProvider.broadcastOwnPacket`); `_simulateIncomingFromPeer()` (fabricates a synthetic peer packet with a semi-random origin id derived from `DateTime.now().millisecondsSinceEpoch % 1000`, fixed demo coordinates `12.97, 77.59`, `critical`/`'landslide'`, encodes it with a locally-instantiated `_demoCodec`, and pushes it via `relayTransportProvider.simulateIncoming`); private `_RelayOutcomeTile` (green forward icon + "Relayed to nearby devices" when relayed, grey block icon + "Not relayed: `<reason>`" otherwise).
- **Notable imports**: `core/providers/core_providers.dart` (`geoTagServiceProvider` — real GPS, the one piece of real device I/O in this screen), `features/auth/application/auth_controller.dart`, `device_relay_providers.dart`, `device_relay_outcome.dart`, `features/sms_prototype/application/emergency_packet_codec.dart` (instantiates its own local `EmergencyPacketCodec` instance, `_demoCodec`, rather than reusing one from a provider — a minor duplication), `features/sms_prototype/application/sms_prototype_providers.dart` (`smsPrototypeServiceProvider` — cross-module reuse for packet building), `features/sms_prototype/domain/emergency_packet_priority.dart`.
- **Depends on**: `geoTagServiceProvider` (real GPS, core), `currentUserProvider` (auth), `smsPrototypeServiceProvider` (sms_prototype module — cross-module), `deviceRelayServiceProvider`, `relayTransportProvider`, `relayActivityProvider`, `thisDeviceIdProvider` (this module).
- **Depended on by**: routed at `/device-relay`.
- **State read/written**: local widget state (`_isBusy`) plus in-memory transport/notifier state; no Drift/Firestore writes.
- **External communication**: real GPS location capture only (shared `GeoTagService`); no Bluetooth, no WiFi, no other network call.
- **Mock/demo content**: **the entire screen is explicitly labeled as a controlled prototype**, both in its doc comment and a permanent on-screen banner. The simulated peer's origin id (`'peer-device-<ms%1000>'`) and coordinates (`12.97, 77.59`) are hardcoded demo values, not derived from any real nearby device.

### `test/features/device_relay/device_relay_engine_test.dart`
- **Purpose**: Pure unit tests of `DeviceRelayEngine.evaluate` — no IO.
- **Status**: IMPLEMENTED.
- **Key tests**: a test explicitly named `'NEARBY-DEVICE RELAY WITH TTL/ORIGIN/VERSION AND DUPLICATE SUPPRESSION — the acceptance criterion: a fresh packet from a peer is relayed'`; an expired packet is never relayed; a device never relays its own broadcast; an already-relayed packet id is not relayed again; a *different* id from the same already-relayed set is still relayed (confirms dedup is per-id, not a blanket block); an explicit ordering test confirming expiry is checked before origin/dedup ("an expired own-packet still reports expired").
- **External communication**: none.

### `test/features/device_relay/device_relay_service_test.dart`
- **Purpose**: Tests `DeviceRelayService` wired to a real (in-memory) `LoopbackRelayTransport`.
- **Status**: IMPLEMENTED.
- **Key tests**: `broadcastOwnPacket` encodes and sends through the transport; a test explicitly named `'NEARBY-DEVICE RELAY WITH TTL/ORIGIN/VERSION AND DUPLICATE SUPPRESSION — the acceptance criterion, through the service: a peer packet is decoded and relayed'`; the same packet arriving twice is only relayed once (`broadcastLog` stays length 1); a device does not relay a packet it originated; an expired packet is not relayed; a non-TAARAK message returns `null`; a "full relay chain" test explicitly modeling device A broadcasting and device B relaying it, by manually constructing two separate `DeviceRelayService`/`LoopbackRelayTransport` pairs in the test and passing the encoded string between them by hand — this is still an in-process simulation (no real transport between "device A" and "device B"), but it is the closest thing in this module to a multi-device scenario.
- **External communication**: none — confirms the test suite itself only ever exercises `LoopbackRelayTransport`.

## Data Models

This module defines only one new domain type; everything else (`EmergencyPacket`, `EmergencyPacketPriority`) is reused directly from `sms_prototype`:

`DeviceRelayOutcome` (plain Dart class, never persisted):
- `packet` (`EmergencyPacket`, from sms_prototype)
- `wasRelayed` (bool)
- `reason` (String: `'relayed'` | `'expired'` | `'own broadcast'` | `'already relayed'`)

## Services / Repositories

- **`DeviceRelayService`** — the module's only service; broadcasts this device's own packets and decides/executes relay of incoming peer packets, tracking relayed-id history in-memory per instance.
- **`LoopbackRelayTransport`** — functions as a fake/simulated "repository" for broadcast/incoming messages, entirely in-memory, explicitly documented as never leaving the device.
- No Drift table, no repository, no sync-queue involvement anywhere in this module — identical in this respect to `sms_prototype`.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/device-relay` | `DeviceRelayScreen` | `Permission.sendSos` | Citizen menu/navigation (outside this module) — any role holding `sendSos` |

## Module Data Flow

**Simulate a peer broadcast → relay decision (the module's most distinctive flow):**

```
DeviceRelayScreen: user taps "Simulate a broadcast arriving from a nearby device"
  -> _simulateIncomingFromPeer()
     -> SmsPrototypeService.buildPacket(originId:'peer-device-<rand>', priority:critical, type:'landslide', lat/lng: hardcoded demo point)
        [cross-module reuse of sms_prototype's packet builder]
     -> _demoCodec.encode(packet)                              [pure: TAARAK1|... string]
     -> LoopbackRelayTransport.simulateIncoming(encoded)        [NOT a real Bluetooth/WiFi broadcast]

relayActivityProvider's subscription fires
  -> RelayActivityNotifier.handleIncoming(raw, thisDeviceId: <signed-in user id>)
     -> DeviceRelayService.handleIncoming(raw, thisDeviceId, now)
        -> EmergencyPacketCodec.decode(raw)                     [pure: string -> EmergencyPacket, or null]
        -> DeviceRelayEngine.evaluate(packet, thisDeviceId, _relayedIds, now)
           -> checks: expired? -> own broadcast? -> already relayed? -> else relay
        -> if shouldRelay: _relayedIds.add(packet.id); LoopbackRelayTransport.broadcast(raw)  [re-recorded, not re-sent anywhere real]
        <- DeviceRelayOutcome(packet, wasRelayed, reason)
  state = [outcome, ...state]                                   [prepended, most-recent-first]

UI "Relay activity" list updates immediately (stream-driven); "Broadcasts sent" list also grows if the packet was relayed
```

## Current Status

**Working as a prototype/demonstration — confirmed simulation, not real hardware integration.** The relay decision logic (`DeviceRelayEngine`) is fully implemented and thoroughly tested, including cross-instance ("two devices") scenarios at the test level. The transport layer is, by explicit design and documentation, a loopback that never touches Bluetooth/WiFi/any nearby-connections API. No code anywhere in this module (or found via a `pubspec.yaml`/permission search) implements real device-to-device communication.

## Known Limitations

- **No real device-to-device transport exists.** This is the module's defining, intentional limitation — see the Verified Finding at the top of this document. A production implementation would require a native Bluetooth/WiFi Direct/nearby-connections plugin with the corresponding runtime permissions, wired in behind `RelayTransport`; none exists in this codebase, and the blueprint itself (quoted in-source) flags this as "highly innovative but risky," suggesting it was a deliberately deferred scope decision rather than an oversight.
- `DeviceRelayService._relayedIds` is in-memory, per-instance, unbounded, and never persisted — a real multi-hour mesh deployment would need this deduplication history to survive app restarts and to be pruned (it currently only grows, with no eviction even for expired packet ids).
- The "full relay chain" test constructs two independent `DeviceRelayService` instances manually to represent two devices; there is no code path in the actual app (only in the test) that models more than one device's state at once — the real app only ever runs as "this device."
- `device_relay_screen.dart` instantiates its own local `_demoCodec = EmergencyPacketCodec()` rather than obtaining one via a provider — minor inconsistency with how the rest of the app wires shared instances through Riverpod, though `EmergencyPacketCodec` is stateless so this has no functional consequence.
- `relayActivityProvider`'s subscription falls back to the literal string `'this-device'` for `thisDeviceId` if `thisDeviceIdProvider` hasn't been set yet (e.g. if a broadcast is simulated before `initState`'s post-frame callback has run) — a narrow race window where the self-suppression check could use a placeholder id instead of the real signed-in user's id.

## Test Coverage

- `test/features/device_relay/device_relay_engine_test.dart` — thorough: fresh-packet-relayed (the named acceptance-criterion test), expired exclusion, own-broadcast exclusion, already-relayed exclusion, different-id-still-relayed (dedup precision), and an explicit check-ordering test (expiry checked before origin).
- `test/features/device_relay/device_relay_service_test.dart` — thorough: `broadcastOwnPacket` round-trip, the named acceptance-criterion test (peer packet decoded and relayed through the full service), only-relayed-once behavior, own-packet exclusion, expired-packet exclusion, non-TAARAK-message rejection, and a two-device relay-chain scenario.
- Both test files literally name a test after "the acceptance criterion" (`'NEARBY-DEVICE RELAY WITH TTL/ORIGIN/VERSION AND DUPLICATE SUPPRESSION'`), confirming the relay *decision* logic, exercised through the loopback transport, was the definition of "done" for M23 — consistent with real device-to-device transport never being in scope for this module as built.
- **Not covered by any test**: `device_relay_providers.dart` (no provider-container test — `thisDeviceIdProvider`'s fallback-to-`'this-device'` behavior and the stream-subscription wiring in `relayActivityProvider` are unverified by automated tests beyond what the service-level tests indirectly exercise), `device_relay_screen.dart` (no widget test — the GPS-capture-then-build-then-broadcast flow, the `initState` post-frame device-id assignment, and the synthetic-peer-packet generation are all unverified by automated tests).
