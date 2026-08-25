import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/location/geo_tag.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/sms_prototype/application/sms_prototype_providers.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet.dart';
import 'package:taarak/features/sms_prototype/domain/emergency_packet_priority.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// M22: a controlled prototype, not a real SMS integration — see
/// [[SmsTransport]]'s doc comment for why. This screen exists to
/// demonstrate the packet protocol end to end (build → encode → "send" →
/// "receive" → decode → dedupe/TTL/priority) using the in-memory
/// [[LoopbackSmsTransport]], which is the acceptance criterion's
/// "controlled prototype exchanges a minimal emergency packet."
class SmsPrototypeScreen extends ConsumerStatefulWidget {
  const SmsPrototypeScreen({super.key});

  @override
  ConsumerState<SmsPrototypeScreen> createState() => _SmsPrototypeScreenState();
}

class _SmsPrototypeScreenState extends ConsumerState<SmsPrototypeScreen> {
  final _noteController = TextEditingController();
  bool _isSending = false;
  String? _lastEncoded;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _sendPacket() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSending = true);

    final fixResult = await ref.read(geoTagServiceProvider).captureGeoTag();
    final service = ref.read(smsPrototypeServiceProvider);

    if (fixResult case Failed<GeoTag>(:final failure)) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not get a location fix: ${failure.message}'),
        ),
      );
      return;
    }

    final geoTag = fixResult.dataOrNull!;
    final packet = service.buildPacket(
      originId: user.id,
      priority: EmergencyPacketPriority.sos,
      type: 'sos',
      latitude: geoTag.fix.latitude,
      longitude: geoTag.fix.longitude,
      note: _noteController.text.trim(),
    );
    final sendResult = await service.sendPacket(
      packet: packet,
      toNumber: '112',
    );
    if (!mounted) return;
    setState(() {
      _lastEncoded = sendResult.dataOrNull;
      _isSending = false;
    });
  }

  void _simulateIncoming() {
    final encoded = _lastEncoded;
    if (encoded == null) return;
    ref.read(smsTransportProvider).simulateIncoming(encoded);
  }

  @override
  Widget build(BuildContext context) {
    final sentMessages = ref.watch(smsTransportProvider).sentMessages;
    final receivedPackets = ref.watch(receivedPacketsProvider);

    return Scaffold(
      appBar: const TaarakAppBar(title: 'SMS Fallback (Prototype)'),
      body: ListView(
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Controlled prototype: no real SMS is sent. This demonstrates the '
                      'compact packet format (id, TTL, priority, dedup) that a real '
                      'carrier-backed transport would use once one is wired in behind '
                      'the same interface.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Short note (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isSending ? null : _sendPacket,
                  icon: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sms_outlined),
                  label: const Text('Send test SOS packet'),
                ),
                if (_lastEncoded != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Encoded (${_lastEncoded!.length} chars): ${_lastEncoded!}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _simulateIncoming,
                    icon: const Icon(Icons.call_received),
                    label: const Text(
                      'Simulate this packet arriving on another device',
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Sent (${sentMessages.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                for (final sent in sentMessages)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.outbox_outlined),
                    title: Text('to ${sent.toNumber}'),
                    subtitle: Text(sent.body),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Received (${receivedPackets.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (receivedPackets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('No packets received yet.'),
                  )
                else
                  for (final packet in receivedPackets)
                    _ReceivedPacketTile(packet: packet),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivedPacketTile extends StatelessWidget {
  final EmergencyPacket packet;

  const _ReceivedPacketTile({required this.packet});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.priority_high,
          color: packet.priority == EmergencyPacketPriority.sos
              ? Colors.red
              : packet.priority == EmergencyPacketPriority.critical
              ? Colors.orange
              : Colors.grey,
        ),
        title: Text(
          '${packet.type} from ${packet.originId} (${packet.priority.name})',
        ),
        subtitle: Text(
          '${packet.latitude.toStringAsFixed(4)}, ${packet.longitude.toStringAsFixed(4)}'
          '${packet.note.isEmpty ? '' : ' · ${packet.note}'}\n'
          'expires ${packet.expiresAt.toLocal()}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
