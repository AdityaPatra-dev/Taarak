import 'dart:async';

import 'package:taarak/core/repository/result.dart';

/// Abstracts broadcasting to nearby devices behind our own interface —
/// same reasoning as [[SmsTransport]]. M23 is scoped the same way M22
/// was and for the same reasons: the blueprint itself flags device relay
/// as "highly innovative but risky" (more so than SMS), and a real
/// implementation (Bluetooth/WiFi Direct nearby-connections) needs
/// runtime location/Bluetooth permissions and physically nearby devices
/// to validate against — neither of which this environment has. Only
/// [LoopbackRelayTransport] is shipped; a real implementation is a future
/// swap-in behind this same interface.
abstract class RelayTransport {
  Future<Result<void>> broadcast(String encodedPacket);

  Stream<String> get incomingBroadcasts;
}

/// The controlled prototype: broadcasts are recorded, not actually sent
/// anywhere, and [simulateIncoming] plays the role of "a nearby device's
/// broadcast reached this one" — enough to exercise the real relay
/// decision logic (TTL, origin, duplicate suppression) without a mesh.
class LoopbackRelayTransport implements RelayTransport {
  final List<String> broadcastLog = [];
  final _incomingController = StreamController<String>.broadcast();

  @override
  Future<Result<void>> broadcast(String encodedPacket) async {
    broadcastLog.add(encodedPacket);
    return const Result.success(null);
  }

  @override
  Stream<String> get incomingBroadcasts => _incomingController.stream;

  void simulateIncoming(String rawMessage) =>
      _incomingController.add(rawMessage);

  void dispose() => _incomingController.close();
}
