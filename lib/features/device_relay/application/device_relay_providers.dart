import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/features/device_relay/application/device_relay_service.dart';
import 'package:taarak/features/device_relay/application/relay_transport.dart';
import 'package:taarak/features/device_relay/domain/device_relay_outcome.dart';

final relayTransportProvider = Provider<LoopbackRelayTransport>((ref) {
  final transport = LoopbackRelayTransport();
  ref.onDispose(transport.dispose);
  return transport;
});

final deviceRelayServiceProvider = Provider<DeviceRelayService>(
  (ref) => DeviceRelayService(transport: ref.watch(relayTransportProvider)),
);

/// Set by the screen once it knows the signed-in user's id, so relay
/// self-suppression ("don't relay my own broadcast") uses the real
/// device/user identity rather than a placeholder.
final thisDeviceIdProvider = StateProvider<String?>((ref) => null);

/// Every relay decision made so far this session, most recent first —
/// the demo screen's activity log.
final relayActivityProvider =
    StateNotifierProvider<RelayActivityNotifier, List<DeviceRelayOutcome>>((
      ref,
    ) {
      final notifier = RelayActivityNotifier(
        ref.watch(deviceRelayServiceProvider),
      );
      final subscription = ref
          .watch(relayTransportProvider)
          .incomingBroadcasts
          .listen((raw) {
            final deviceId = ref.read(thisDeviceIdProvider) ?? 'this-device';
            notifier.handleIncoming(raw, thisDeviceId: deviceId);
          });
      ref.onDispose(subscription.cancel);
      return notifier;
    });

class RelayActivityNotifier extends StateNotifier<List<DeviceRelayOutcome>> {
  final DeviceRelayService _service;

  RelayActivityNotifier(this._service) : super(const []);

  Future<void> handleIncoming(
    String raw, {
    required String thisDeviceId,
  }) async {
    final outcome = await _service.handleIncoming(
      raw,
      thisDeviceId: thisDeviceId,
    );
    if (outcome == null) return;
    state = [outcome, ...state];
  }
}
