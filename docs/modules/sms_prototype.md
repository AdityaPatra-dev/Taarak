# MODULE: SMS Prototype

## Purpose

SMS Prototype (blueprint milestone "M22") demonstrates the wire protocol a real SMS-based emergency fallback would use when a device has no data connection at all — a compact, single-segment "emergency packet" (id/origin/priority/type/location/TTL/version/note) that can be encoded to and decoded from a plain string short enough for one GSM SMS. It is explicitly and repeatedly documented in its own source as a **controlled prototype, not a real SMS integration** — see Verified Finding below.

**Verified finding on the required check: this module reads/sends NO real device SMS. It is a pure in-memory SIMULATION.**

Evidence, in order of directness:
1. `lib/features/sms_prototype/application/sms_transport.dart` defines an abstract `SmsTransport` interface and ships exactly one implementation, `LoopbackSmsTransport`. Its class doc comment states outright: *"The 'controlled prototype' itself: nothing leaves the device. `send` just records what would have been sent, and [simulateIncoming] is how a demo (or a test) plays the role of 'another device's reply arrived.'"* `send()` (line 30-36) only appends `(toNumber, body)` to an in-memory `List` and returns `Result.success(null)` — no platform channel, no plugin call, no network I/O of any kind. Incoming messages arrive only via `simulateIncoming(String rawMessage)` (line 41), which pushes directly into a local `StreamController` — there is no code path anywhere that listens to an actual device SMS inbox.
2. `lib/features/sms_prototype/presentation/sms_prototype_screen.dart`'s class doc comment: *"M22: a controlled prototype, not a real SMS integration."* Its on-screen UI text, shown to every user of the screen, states verbatim: *"Controlled prototype: no real SMS is sent. This demonstrates the compact packet format (id, TTL, priority, dedup) that a real carrier-backed transport would use once one is wired in behind the same interface."*
3. `pubspec.yaml` contains no SMS/telephony package of any kind (checked for `sms`, `telephony`, `sim_card`, `permission_handler` — none present), and no `AndroidManifest.xml`/`Info.plist` permission for `SEND_SMS`/`RECEIVE_SMS` is referenced anywhere in this module's source, consistent with the transport file's own comment: *"Play Store's SEND_SMS restrictions... the only implementation shipped is [LoopbackSmsTransport] — a real carrier-backed implementation is a future swap-in behind this same interface once there's a real device/SIM to validate it against."*
4. The "Send test SOS packet" button in the UI sends to a hardcoded destination number `'112'`, and a second button, "Simulate this packet arriving on another device," exists specifically to let the user manually trigger the receive path on the same device/session — there is no second device or real carrier involved anywhere in the flow.

The packet encode/decode/dedup/TTL/priority logic itself (`EmergencyPacketCodec`, `EmergencyPacketEngine`) is real, fully-implemented, and independently unit-tested — it is only the transport (actually getting the string onto/off of a cellular network) that is simulated.

## User-facing functionality

- **Any authenticated user holding `Permission.sendSos`** (citizens hold this by default per `rolePermissions`; screen `SmsPrototypeScreen` at `/sms-prototype`): sees an explicit "Controlled prototype: no real SMS is sent" banner, a note text field, and a "Send test SOS packet" button. Tapping it captures a real GPS fix via `GeoTagService`, builds an `EmergencyPacket` (priority `sos`, type `'sos'`, 6-hour TTL), encodes it, and "sends" it (records it) to the hardcoded number `112` via `LoopbackSmsTransport`. The encoded string and its character count are shown. A "Simulate this packet arriving on another device" button then feeds that exact encoded string back into the transport's incoming stream, which decodes it and shows it in a "Received" list below — demonstrating the full round trip on a single device/session. Both a running "Sent" list and a running "Received" list (each showing raw body / decoded fields) are visible at all times.

## Entry points

Grepped from `lib/app/router.dart` and `lib/app/route_guard.dart`:

| Route | Screen | Permission required |
|---|---|---|
| `/sms-prototype` | `SmsPrototypeScreen` | `Permission.sendSos` |

Single flat route, no path params. `Permission.sendSos` is held by `UserRole.citizen` by default (see `lib/features/auth/domain/user_role.dart`).

## Architecture

- **`domain/`** — two plain immutable value classes: `EmergencyPacket` (the payload) and `EmergencyPacketPriority` (enum with a single-character wire code).
- **`application/`** — four files, cleanly separated by responsibility: `emergency_packet_codec.dart` (pure wire-format encode/decode, no IO), `emergency_packet_engine.dart` (pure TTL/dedup/priority pipeline, no IO), `sms_transport.dart` (the abstract transport interface + its only implementation, `LoopbackSmsTransport`, which is explicitly the simulation boundary), `sms_prototype_service.dart` (orchestrates codec + engine + transport), `sms_prototype_providers.dart` (Riverpod wiring, including a `StateNotifierProvider` that listens to the transport's stream).
- **`presentation/`** — one screen.
- The layering is genuinely clean: swapping `LoopbackSmsTransport` for a real carrier-backed `SmsTransport` implementation (mentioned as future work in multiple doc comments) would require touching only `sms_prototype_providers.dart`'s `smsTransportProvider` — no change to the codec, engine, service, or (in principle) the screen.

## Files in this module

### `lib/features/sms_prototype/domain/emergency_packet.dart`
- **Purpose**: The minimal emergency payload — small enough to fit inside a single SMS segment budget. Explicitly documented as NOT the full citizen-report shape; a last-resort fallback for zero-connectivity situations.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `EmergencyPacket` — `id` (short, not a UUID), `originId`, `priority` (`EmergencyPacketPriority`), `type` (free-form short string, e.g. `'sos'`, `'safe_status'`, or a hazard type), `latitude`/`longitude` (double, required — no nullable-location concept here, unlike Disaster Events' `DisasterEvent`), `expiresAt` (DateTime — TTL), `version` (int, default 1), `note` (String, default `''`); `isExpired(DateTime now)`.
- **Notable imports**: only `emergency_packet_priority.dart`.
- **Depends on**: nothing.
- **Depended on by**: every other file in the module, both test files.
- **State read/written**: none — pure value object, never persisted to Drift.
- **External communication**: none.
- **Mock/demo content**: none in the class itself (it's a real data shape); consumed exclusively by the simulated transport, as documented above.

### `lib/features/sms_prototype/domain/emergency_packet_priority.dart`
- **Purpose**: A compact three-tier urgency scheme reusing the same ordering as the app's sync-queue prioritization (SOS > critical > routine), with a single-character wire code for space efficiency.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `EmergencyPacketPriority` enum (`sos`, `critical`, `routine`); `.code` getter (`'S'`/`'C'`/`'R'`); `static fromCode(String)` — linear search back to the enum value, returns `null` for an unrecognized code.
- **Notable imports**: none.
- **Depends on**: nothing.
- **Depended on by**: `EmergencyPacket`, codec, engine, service, screen, all test files.
- **State read/written**: none.
- **External communication**: none.
- **Mock/demo content**: none.

### `lib/features/sms_prototype/application/emergency_packet_codec.dart`
- **Purpose**: The wire format — encodes an `EmergencyPacket` into a pipe-delimited string prefixed with a protocol tag (`TAARAK1`) and decodes it back, budgeted to 140 characters (conservative margin below the 160-char GSM-7 single-segment limit).
- **Status**: IMPLEMENTED, real and fully working (verified by its own test suite's round-trip tests).
- **Key classes/functions**: `EmergencyPacketCodec.maxEncodedLength = 140` (static const); `encode(EmergencyPacket)` — joins `[protocolTag, id, originId, priority.code, type, lat(4dp), lng(4dp), expiresAt(unix seconds), version]` with `|`, then appends a `note` field truncated to whatever budget remains (with any literal `|` in the note replaced by a space first, so a pipe inside a note can never be mistaken for a field delimiter); `decode(String raw)` — splits on `|`, validates the protocol tag and minimum field count (returns `null`, never throws, for anything malformed — "a stray SMS is not an error"), parses each fixed field, rejoins any extra trailing parts as the note (in case the note itself contained pipes replaced only partially — actually the encode already stripped pipes from the note, so this rejoin is a defensive no-op in practice for packets this codec itself produced, but tolerant of a hand-crafted or foreign message with pipes in its tail).
- **Notable imports**: only the two domain files.
- **Depends on**: nothing external.
- **Depended on by**: `sms_prototype_service.dart`, `emergency_packet_codec_test.dart`.
- **State read/written**: none — pure function, no IO.
- **External communication**: none.
- **Mock/demo content**: none — this is real, tested wire-format logic, not a stub.

### `lib/features/sms_prototype/application/sms_transport.dart`
- **Purpose**: Abstracts "send/receive raw SMS text" behind an interface, matching the app's usual pattern of abstracting device/platform boundaries (compared explicitly in the doc comment to `LocationService`/`NetworkInfo`/`SyncTransport`). Ships exactly one implementation.
- **Status**: `SmsTransport` (abstract interface) — IMPLEMENTED as a contract, no real implementation exists. `LoopbackSmsTransport` — DEMO/MOCK / SIMULATION, explicitly and intentionally so (this is the definitive evidence file for the module's "real vs. simulated" verification).
- **Key classes/functions**: `SmsTransport` (abstract) — `send({toNumber, body}) -> Future<Result<void>>`; `incomingMessages -> Stream<String>`. `LoopbackSmsTransport implements SmsTransport` — `sentMessages: List<({String toNumber, String body})>` (public, in-memory, readable by the UI directly); `send()` appends to `sentMessages` and always succeeds; `incomingMessages` backed by a broadcast `StreamController<String>`; `simulateIncoming(String rawMessage)` — the only way any message ever enters the "incoming" side, called only by the screen's own "Simulate this packet arriving on another device" button (and by tests); `dispose()`.
- **Notable imports**: `dart:async`, `core/repository/result.dart` — notably NO platform channel package, NO telephony/SMS plugin, NO `dart:io` Socket/HttpClient — nothing capable of touching a real network or radio.
- **Depends on**: nothing beyond `Result`.
- **Depended on by**: `sms_prototype_providers.dart` (`smsTransportProvider`), `sms_prototype_service.dart`, `sms_prototype_screen.dart` (reads `.sentMessages` and calls `.simulateIncoming` directly), `sms_prototype_service_test.dart`.
- **State read/written**: in-memory only — `sentMessages` list and the stream controller's internal buffer; nothing touches Drift, Firestore, or any device API.
- **External communication**: **NONE. This is the file that proves the module does not send or receive real SMS.** No platform channel, no plugin, no permission request, no network call.
- **Mock/demo content**: **Explicitly and unambiguously simulated.** `LoopbackSmsTransport`'s own doc comment: *"nothing leaves the device."* This is the single most load-bearing file for the module's "real hardware integration vs. simulation" classification — it settles the question definitively in favor of simulation.

### `lib/features/sms_prototype/application/emergency_packet_engine.dart`
- **Purpose**: The receive-side pure logic — given a batch of already-decoded packets, which are still worth acting on and in what order (TTL exclusion, deduplication by id, priority-then-urgency ordering).
- **Status**: IMPLEMENTED, real and fully working.
- **Key classes/functions**: `EmergencyPacketEngine.deduplicate(List<EmergencyPacket>)` — first-seen-wins by `id`; `excludeExpired(List<EmergencyPacket>, DateTime now)` — drops any packet where `isExpired(now)` (a packet expiring exactly at `now` counts as expired, per its own `!now.isBefore(expiresAt)` semantics); `prioritize(List<EmergencyPacket>)` — sorts by `priority.index` ascending (sos=0 first) then by `expiresAt` ascending as a tiebreaker (soonest-expiring first within a tier); `process(List<EmergencyPacket>, DateTime now)` — the full pipeline: `prioritize(deduplicate(excludeExpired(...)))`.
- **Notable imports**: only `emergency_packet.dart`.
- **Depends on**: nothing external.
- **Depended on by**: `sms_prototype_service.dart` (`receiveMessages`), `emergency_packet_engine_test.dart`.
- **State read/written**: none — pure function.
- **External communication**: none.
- **Mock/demo content**: none — real, tested logic.

### `lib/features/sms_prototype/application/sms_prototype_service.dart`
- **Purpose**: Orchestrates the full send/receive lifecycle — builds a packet, encodes+sends it through whatever `SmsTransport` is injected, and decodes+processes raw incoming message bodies through the engine before a screen ever sees them.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `SmsPrototypeService` (constructor DI: `SmsTransport` required, `EmergencyPacketCodec`/`EmergencyPacketEngine`/`Random` all optional/injectable for tests); `_generateShortId()` — 6 random characters from a 36-symbol alphabet (~31 bits of entropy, "plenty to make id collisions... negligible"); `buildPacket({originId, priority, type, latitude, longitude, note, ttl=6h, now})`; `sendPacket({packet, toNumber}) -> Future<Result<String>>` — encodes then calls `transport.send`, returns the encoded string on success; `receiveMessages(List<String> rawMessages, {alreadySeen=[], now}) -> List<EmergencyPacket>` — decodes every raw message (silently dropping anything that fails to parse as a TAARAK packet — "a stray SMS is not an error"), merges with `alreadySeen` so dedup spans multiple receive batches, runs the full engine pipeline; `incomingRawMessages` — passthrough getter to the transport's stream.
- **Notable imports**: `dart:math` (`Random`), the four other application/domain files.
- **Depends on**: `SmsTransport` (abstract — receives `LoopbackSmsTransport` in practice), `EmergencyPacketCodec`, `EmergencyPacketEngine`.
- **Depended on by**: `sms_prototype_providers.dart`, `sms_prototype_screen.dart`, `sms_prototype_service_test.dart`.
- **State read/written**: none of its own — delegates to the injected transport's in-memory state.
- **External communication**: none directly — inherits whatever the injected `SmsTransport` does, which in the shipped configuration is nothing (loopback only).
- **Mock/demo content**: this file itself is real orchestration logic; it becomes a simulation only because of what it's wired to (`LoopbackSmsTransport`).

### `lib/features/sms_prototype/application/sms_prototype_providers.dart`
- **Purpose**: Riverpod wiring — notably keeps the transport and service alive for the screen's lifetime (plain `Provider`, not `.autoDispose`) specifically so packets sent/received earlier in a demo session remain visible after navigating away and back, since nothing here is backed by the local database.
- **Status**: IMPLEMENTED.
- **Key classes/functions**: `smsTransportProvider` (`Provider<LoopbackSmsTransport>` — the concrete simulated type is named directly in the provider's type signature, not hidden behind the abstract `SmsTransport`, making the simulation explicit even at the DI layer); `smsPrototypeServiceProvider`; `receivedPacketsProvider` (`StateNotifierProvider<ReceivedPacketsNotifier, List<EmergencyPacket>>` — subscribes to `service.incomingRawMessages` directly rather than polling, so a simulated incoming message updates the UI immediately); `ReceivedPacketsNotifier` — `addRawMessage(String raw)` re-runs `service.receiveMessages([raw], alreadySeen: state)` and replaces state, so the full dedup/TTL/priority pipeline re-applies on every new message including against everything already received.
- **Notable imports**: the service, transport, and `EmergencyPacket` domain files.
- **Depends on**: `SmsPrototypeService`, `LoopbackSmsTransport` (concretely, not just the interface).
- **Depended on by**: `sms_prototype_screen.dart`.
- **State read/written**: none beyond in-memory provider state.
- **External communication**: none.
- **Mock/demo content**: the provider's explicit binding to the concrete `LoopbackSmsTransport` type (rather than the abstract `SmsTransport`) is itself evidence that no alternate/real implementation is currently selectable at runtime — there is no environment flag or build config anywhere in this module that swaps in a different transport.

### `lib/features/sms_prototype/presentation/sms_prototype_screen.dart`
- **Purpose**: The module's only UI — demonstrates the full packet protocol end to end (build → encode → "send" → "receive" → decode → dedupe/TTL/priority) on a single device, using a hardcoded destination number and a manual "simulate incoming" trigger.
- **Status**: IMPLEMENTED as a demonstration/prototype screen (its documented purpose).
- **Key classes/functions**: `SmsPrototypeScreen`/`_SmsPrototypeScreenState` — `_sendPacket()` (captures a real GPS fix via `geoTagServiceProvider.captureGeoTag()`, builds an SOS packet via the service, sends to hardcoded `'112'`); `_simulateIncoming()` (feeds the last encoded string back into `smsTransportProvider.simulateIncoming`); private `_ReceivedPacketTile` (color-codes by priority: red=sos, orange=critical, grey=routine).
- **Notable imports**: `core/location/geo_tag.dart`, `core/providers/core_providers.dart` (`geoTagServiceProvider` — the one piece of this screen that IS real device I/O: an actual GPS fix), `core/repository/result.dart`, `features/auth/application/auth_controller.dart` (`currentUserProvider`), `sms_prototype_providers.dart`, both domain files.
- **Depends on**: `geoTagServiceProvider` (real GPS, core module), `currentUserProvider` (auth), `smsPrototypeServiceProvider`, `smsTransportProvider`, `receivedPacketsProvider` (this module).
- **Depended on by**: routed at `/sms-prototype`.
- **State read/written**: local widget state (`_isSending`, `_lastEncoded`, note controller) plus the in-memory transport/notifier state described above; no Drift/Firestore writes.
- **External communication**: real GPS location capture only (via `GeoTagService`, shared with the rest of the app); no SMS, no other network call.
- **Mock/demo content**: **the entire screen is explicitly labeled as a controlled prototype**, both in its doc comment and in a permanent on-screen banner ("Controlled prototype: no real SMS is sent..."). The destination number `'112'` is hardcoded (a plausible real emergency number, but not configurable and not actually dialed/messaged anywhere).

### `test/features/sms_prototype/emergency_packet_codec_test.dart`
- **Purpose**: Pure unit tests of `EmergencyPacketCodec` — no IO.
- **Status**: IMPLEMENTED.
- **Key tests**: a test explicitly named `'CONTROLLED PROTOTYPE EXCHANGES A MINIMAL EMERGENCY PACKET — the acceptance criterion: a packet round-trips through encode/decode unchanged'`; the encoded packet fits within `maxEncodedLength` even with a 200-char note; a too-long note is truncated, not dropped; a pipe character embedded in the note does not corrupt other fields; a non-TAARAK message (e.g. `'Your OTP is 483920'`) and an empty string both decode to `null` rather than throwing; a truncated/corrupted TAARAK message decodes to `null`; an unrecognized priority code decodes to `null`; all three priority codes round-trip correctly.
- **External communication**: none.

### `test/features/sms_prototype/emergency_packet_engine_test.dart`
- **Purpose**: Pure unit tests of `EmergencyPacketEngine` — no IO.
- **Status**: IMPLEMENTED.
- **Key tests**: `deduplicate` (repeated id collapses to first-seen; no duplicates means nothing dropped); `excludeExpired` (an expired packet dropped; a packet expiring at exactly `now` is treated as expired); `prioritize` (SOS < critical < routine ordering; within a tier, soonest-expiring first); a test explicitly named `'CONTROLLED PROTOTYPE EXCHANGES A MINIMAL EMERGENCY PACKET — the acceptance criterion: process() combines TTL, dedup and priority in one pass'`.
- **External communication**: none.

### `test/features/sms_prototype/sms_prototype_service_test.dart`
- **Purpose**: Tests `SmsPrototypeService` wired to a real (but in-memory/loopback) `LoopbackSmsTransport` — as close to an integration test as this module gets, though still entirely in-process.
- **Status**: IMPLEMENTED.
- **Key tests**: `buildPacket` produces a 6-character id with the requested fields; two packets built back-to-back get different ids; a test explicitly named `'CONTROLLED PROTOTYPE EXCHANGES A MINIMAL EMERGENCY PACKET — the acceptance criterion, end to end through the service and loopback transport'` — sends a packet, confirms `transport.sentMessages` recorded it, then feeds the exact sent bytes into `receiveMessages` and confirms the "other device" gets back the same id/note; `receiveMessages` silently ignores non-TAARAK text; `receiveMessages` dedupes against a prior batch (simulating a retransmit); the incoming raw-message stream surfaces whatever `simulateIncoming` pushes.
- **External communication**: none — `LoopbackSmsTransport` used directly, confirming the test suite itself treats the loopback as the only transport that exists.

## Data Models

`EmergencyPacket` (plain Dart class, not a Drift table — never persisted locally or remotely):
- `id` (String, 6 chars) — short-form, not a UUID, used for dedup.
- `originId` (String) — sender's user id.
- `priority` (`EmergencyPacketPriority`: sos/critical/routine).
- `type` (String) — e.g. `'sos'`, `'safe_status'`, or a hazard type.
- `latitude`/`longitude` (double, required).
- `expiresAt` (DateTime) — TTL.
- `version` (int, default 1).
- `note` (String, default `''`).

`EmergencyPacketPriority` enum: `sos` (code `'S'`), `critical` (code `'C'`), `routine` (code `'R'`).

Wire format (produced by `EmergencyPacketCodec.encode`): `TAARAK1|<id>|<originId>|<priorityCode>|<type>|<lat.4dp>|<lng.4dp>|<expiresAtUnixSeconds>|<version>|<note>`.

## Services / Repositories

- **`SmsPrototypeService`** — the module's only service; orchestrates packet building, sending (via the transport), and receiving (decode + engine pipeline). No repository exists — nothing in this module is persisted to Drift or Firestore.
- **`LoopbackSmsTransport`** — functions as a fake/simulated "repository" for sent/received messages, entirely in-memory, explicitly documented as not leaving the device.

## Routes owned by this module

| Path | Screen | Guarding Permission | Reachable from |
|---|---|---|---|
| `/sms-prototype` | `SmsPrototypeScreen` | `Permission.sendSos` | Citizen menu/navigation (outside this module) — any role holding `sendSos` |

## Module Data Flow

**Send → simulate receive (the module's only real flow, entirely on one device):**

```
SmsPrototypeScreen: user taps "Send test SOS packet"
  -> GeoTagService.captureGeoTag()                          [REAL device GPS]
  -> SmsPrototypeService.buildPacket(originId, priority:sos, type:'sos', lat, lng, note, ttl:6h)
    <- EmergencyPacket (6-char random id)
  -> SmsPrototypeService.sendPacket(packet, toNumber:'112')
     -> EmergencyPacketCodec.encode(packet)                  [pure: TAARAK1|... string, <=140 chars]
     -> LoopbackSmsTransport.send(toNumber:'112', body:encoded)
        -> appends to in-memory sentMessages list            [NOT a real SMS — nothing leaves the device]
  <- Result.success(encodedString)
  UI shows encoded string + "Sent" list entry

user taps "Simulate this packet arriving on another device"
  -> LoopbackSmsTransport.simulateIncoming(encodedString)
     -> pushes into the transport's StreamController
  -> receivedPacketsProvider's subscription fires -> ReceivedPacketsNotifier.addRawMessage(raw)
     -> SmsPrototypeService.receiveMessages([raw], alreadySeen: currentState)
        -> EmergencyPacketCodec.decode(raw)                  [pure: string -> EmergencyPacket, or null if malformed]
        -> EmergencyPacketEngine.process([...alreadySeen, decoded], now)
           -> excludeExpired -> deduplicate -> prioritize
  <- List<EmergencyPacket>
  UI "Received" list updates immediately (stream-driven, not polled)
```

## Current Status

**Working as a prototype/demonstration — confirmed simulation, not real hardware integration.** The packet protocol (codec + engine) is fully implemented and thoroughly tested. The transport layer is, by explicit design and documentation, a loopback that never leaves the device. There is no code anywhere in this module (or found via a `pubspec.yaml`/permission search) that sends or receives a real SMS.

## Known Limitations

- **No real SMS capability exists.** This is the module's defining, intentional limitation, not a bug — see the Verified Finding at the top of this document. A production deployment of this feature would require implementing a new `SmsTransport` (a native platform-channel plugin with `SEND_SMS`/`RECEIVE_SMS` permissions) and wiring it in behind `smsTransportProvider`; no such implementation exists in this codebase.
- The destination number is hardcoded to `'112'` with no way to configure it from the UI.
- `sms_prototype_providers.dart`'s `smsTransportProvider` types itself concretely as `LoopbackSmsTransport` rather than the abstract `SmsTransport` — swapping in a real implementation later would require changing this provider's declared type as well as its body.
- Packets/messages exist only in-memory for the lifetime of the app process (the provider is kept alive, not `.autoDispose`, but is not persisted) — a full app restart loses all sent/received history shown in this screen.
- `EmergencyPacketCodec`'s wire format has no checksum/integrity field — a bit-flipped-but-still-well-formed message (e.g. a corrupted digit that still parses as a valid double) would decode "successfully" with wrong data; the codec only guards against structurally malformed input, not silently-corrupted-but-well-formed input.

## Test Coverage

- `test/features/sms_prototype/emergency_packet_codec_test.dart` — thorough: round-trip fidelity, size budget, note truncation, pipe-character safety, malformed/foreign-message rejection, unrecognized-priority rejection, all-priority round-trip.
- `test/features/sms_prototype/emergency_packet_engine_test.dart` — thorough: dedup (both directions), expiry boundary (exactly-at-now), priority ordering, tiebreak-by-soonest-expiry, and the combined `process()` pipeline.
- `test/features/sms_prototype/sms_prototype_service_test.dart` — covers `buildPacket` (id shape, uniqueness), full send→receive round trip through the real `LoopbackSmsTransport`, non-TAARAK message rejection, cross-batch dedup, and the incoming-stream surfacing behavior.
- All three test files literally name at least one test after "the acceptance criterion," confirming the developers treated packet round-tripping through the loopback transport as the definition of "done" for M22 — consistent with this module never being intended to include real SMS transport.
- **Not covered by any test**: `sms_prototype_providers.dart` (no provider-container test — the `.autoDispose`-vs-kept-alive behavior and the stream-subscription wiring in `receivedPacketsProvider` are unverified by automated tests beyond what the service-level tests indirectly exercise), `sms_prototype_screen.dart` (no widget test — the GPS-capture-then-build-then-send flow, the location-failure `SnackBar` path, and the UI's priority-color-coding are all unverified by automated tests).
