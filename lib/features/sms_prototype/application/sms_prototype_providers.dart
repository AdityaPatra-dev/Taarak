import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/features/sms_prototype/application/sms_prototype_service.dart';
import 'package:taarak/features/sms_prototype/application/sms_transport.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';

/// Kept alive for the screen's lifetime (not `.autoDispose`) so packets
/// sent/received earlier in a demo session are still visible after
/// navigating away and back — this is a controlled, in-memory prototype,
/// not something backed by the local database.
final smsTransportProvider = Provider<LoopbackSmsTransport>((ref) {
  final transport = LoopbackSmsTransport();
  ref.onDispose(transport.dispose);
  return transport;
});

final smsPrototypeServiceProvider = Provider<SmsPrototypeService>(
  (ref) => SmsPrototypeService(transport: ref.watch(smsTransportProvider)),
);

/// Every packet received so far, already run through
/// [EmergencyPacketEngine]'s TTL/dedup/priority pipeline — listens to the
/// transport directly rather than polling, so a simulated incoming
/// message shows up immediately.
final receivedPacketsProvider =
    StateNotifierProvider<ReceivedPacketsNotifier, List<EmergencyPacket>>((ref) {
      final service = ref.watch(smsPrototypeServiceProvider);
      final notifier = ReceivedPacketsNotifier(service);
      final subscription = service.incomingRawMessages.listen(notifier.addRawMessage);
      ref.onDispose(subscription.cancel);
      return notifier;
    });

class ReceivedPacketsNotifier extends StateNotifier<List<EmergencyPacket>> {
  final SmsPrototypeService _service;

  ReceivedPacketsNotifier(this._service) : super(const []);

  void addRawMessage(String raw) {
    state = _service.receiveMessages([raw], alreadySeen: state);
  }
}
