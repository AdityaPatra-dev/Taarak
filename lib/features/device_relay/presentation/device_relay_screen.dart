import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/device_relay/application/device_relay_providers.dart';
import 'package:taarak/features/device_relay/domain/device_relay_outcome.dart';
import 'package:taarak/features/sms_prototype/application/emergency_packet_codec.dart';
import 'package:taarak/features/sms_prototype/application/sms_prototype_providers.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet_priority.dart';

final _demoCodec = EmergencyPacketCodec();

/// M23: same "controlled prototype" scoping as M22's SMS fallback, and
/// for the same reasons — see [[RelayTransport]]'s doc comment. This
/// screen demonstrates the actual new behavior M23 adds: when a
/// simulated nearby broadcast arrives, this device decides whether to
/// re-relay it (not expired, not its own, not already relayed) and shows
/// that decision, not just the packet's contents.
class DeviceRelayScreen extends ConsumerStatefulWidget {
  const DeviceRelayScreen({super.key});

  @override
  ConsumerState<DeviceRelayScreen> createState() => _DeviceRelayScreenState();
}

class _DeviceRelayScreenState extends ConsumerState<DeviceRelayScreen> {
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId != null) {
        ref.read(thisDeviceIdProvider.notifier).state = userId;
      }
    });
  }

  Future<void> _broadcastOwnPacket() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    setState(() => _isBusy = true);

    final fixResult = await ref.read(geoTagServiceProvider).captureGeoTag();
    if (fixResult.isSuccess) {
      final fix = fixResult.dataOrNull!.fix;
      final packet = ref
          .read(smsPrototypeServiceProvider)
          .buildPacket(
            originId: userId,
            priority: EmergencyPacketPriority.sos,
            type: 'sos',
            latitude: fix.latitude,
            longitude: fix.longitude,
          );
      await ref.read(deviceRelayServiceProvider).broadcastOwnPacket(packet);
    }

    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  /// Simulates a peer device's broadcast reaching this one — a packet
  /// this device did not originate, so the relay decision actually has
  /// something to decide rather than always hitting the "own broadcast"
  /// short-circuit.
  void _simulateIncomingFromPeer() {
    final packet = ref
        .read(smsPrototypeServiceProvider)
        .buildPacket(
          originId: 'peer-device-${DateTime.now().millisecondsSinceEpoch % 1000}',
          priority: EmergencyPacketPriority.critical,
          type: 'landslide',
          latitude: 12.97,
          longitude: 77.59,
          note: 'Relayed from a nearby device',
        );
    ref.read(relayTransportProvider).simulateIncoming(_demoCodec.encode(packet));
  }

  @override
  Widget build(BuildContext context) {
    final activity = ref.watch(relayActivityProvider);
    final sentLog = ref.watch(relayTransportProvider).broadcastLog;

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Device Relay (Prototype)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Controlled prototype: nothing leaves this device over Bluetooth/WiFi. '
                'This demonstrates the relay decision (TTL, origin, duplicate '
                'suppression) that a real nearby-connections transport would use once '
                'one is wired in behind the same interface.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isBusy ? null : _broadcastOwnPacket,
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Broadcast my emergency packet'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _simulateIncomingFromPeer,
            icon: const Icon(Icons.call_received),
            label: const Text('Simulate a broadcast arriving from a nearby device'),
          ),
          const SizedBox(height: 24),
          Text('Broadcasts sent (${sentLog.length})', style: Theme.of(context).textTheme.titleSmall),
          for (final sent in sentLog)
            ListTile(dense: true, leading: const Icon(Icons.wifi_tethering), title: Text(sent)),
          const SizedBox(height: 24),
          Text('Relay activity (${activity.length})', style: Theme.of(context).textTheme.titleSmall),
          if (activity.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('No broadcasts received yet.'),
            )
          else
            for (final outcome in activity) _RelayOutcomeTile(outcome: outcome),
        ],
      ),
    );
  }
}

class _RelayOutcomeTile extends StatelessWidget {
  final DeviceRelayOutcome outcome;

  const _RelayOutcomeTile({required this.outcome});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        leading: Icon(
          outcome.wasRelayed ? Icons.forward : Icons.block,
          color: outcome.wasRelayed ? Colors.green.shade700 : Colors.grey,
        ),
        title: Text(
          '${outcome.packet.type} from ${outcome.packet.originId} '
          '(${outcome.packet.priority.name})',
        ),
        subtitle: Text(
          outcome.wasRelayed ? 'Relayed to nearby devices' : 'Not relayed: ${outcome.reason}',
        ),
      ),
    );
  }
}
