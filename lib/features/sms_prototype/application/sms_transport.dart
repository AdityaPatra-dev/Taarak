import 'dart:async';

import 'package:taarak/core/repository/result.dart';

/// Abstracts sending/receiving raw SMS text behind our own interface —
/// same reasoning as [[LocationService]]/[[NetworkInfo]]/[[SyncTransport]].
/// M22 is explicitly scoped as a controlled prototype (per the blueprint's
/// "what not to build first" list and Play Store's SEND_SMS restrictions),
/// so the only implementation shipped is [LoopbackSmsTransport] — a real
/// carrier-backed implementation is a future swap-in behind this same
/// interface once there's a real device/SIM to validate it against.
abstract class SmsTransport {
  Future<Result<void>> send({required String toNumber, required String body});

  /// Raw text of every message received since this transport was created.
  Stream<String> get incomingMessages;
}

/// The "controlled prototype" itself: nothing leaves the device. `send`
/// just records what would have been sent, and [simulateIncoming] is how
/// a demo (or a test) plays the role of "another device's reply arrived."
/// This is the whole point of scoping M22 this way — the packet protocol
/// (encode/decode/dedupe/TTL/priority) is exercised for real, without a
/// native SMS plugin or the SEND_SMS permission this build doesn't carry.
class LoopbackSmsTransport implements SmsTransport {
  final List<({String toNumber, String body})> sentMessages = [];
  final _incomingController = StreamController<String>.broadcast();

  @override
  Future<Result<void>> send({
    required String toNumber,
    required String body,
  }) async {
    sentMessages.add((toNumber: toNumber, body: body));
    return const Result.success(null);
  }

  @override
  Stream<String> get incomingMessages => _incomingController.stream;

  void simulateIncoming(String rawMessage) =>
      _incomingController.add(rawMessage);

  void dispose() => _incomingController.close();
}
