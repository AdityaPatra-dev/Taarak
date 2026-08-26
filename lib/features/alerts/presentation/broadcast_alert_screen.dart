import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/alerts/application/alert_providers.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/state_admin/application/state_admin_providers.dart';
import 'package:taarak/features/state_admin/domain/app_policy.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/severity_chip.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

const _severities = ['low', 'medium', 'high', 'critical'];

String _durationLabel(Duration duration) => duration.inHours < 24
    ? '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}'
    : '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';

/// M16: lets a Local Official ([Permission.sendBroadcast]) broadcast to a
/// selected zone — the acceptance criterion — and shows the broadcast
/// history alongside acknowledgement counts.
class BroadcastAlertScreen extends ConsumerStatefulWidget {
  const BroadcastAlertScreen({super.key});

  @override
  ConsumerState<BroadcastAlertScreen> createState() =>
      _BroadcastAlertScreenState();
}

class _BroadcastAlertScreenState extends ConsumerState<BroadcastAlertScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedZoneId;
  String _severity = 'high';
  Duration? _selectedValidity;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(hazardZonesProvider).valueOrNull ?? const [];
    final history = ref.watch(alertHistoryProvider).valueOrNull ?? const [];
    final validityOptions =
        ref.watch(appPolicyProvider).valueOrNull?.alertValidityOptions ??
        AppPolicy.defaults.alertValidityOptions;
    final selectedValidity =
        _selectedValidity ??
        (validityOptions.contains(const Duration(hours: 6))
            ? const Duration(hours: 6)
            : validityOptions.first);

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Broadcast Alert'),
      body: ListView(
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'New broadcast',
                  icon: Icons.campaign_outlined,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedZoneId,
                          decoration: const InputDecoration(
                            labelText: 'Target zone',
                          ),
                          items: [
                            for (final zone in zones)
                              DropdownMenuItem(
                                value: zone.id,
                                child: Text(
                                  '${zone.hazardType} (${zone.severity})',
                                ),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedZoneId = value),
                        ),
                        const SizedBox(height: Spacing.sm),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                        ),
                        const SizedBox(height: Spacing.sm),
                        TextField(
                          controller: _messageController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        DropdownButtonFormField<String>(
                          initialValue: _severity,
                          decoration: const InputDecoration(
                            labelText: 'Severity',
                          ),
                          items: [
                            for (final severity in _severities)
                              DropdownMenuItem(
                                value: severity,
                                child: Text(severity),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _severity = value ?? _severity),
                        ),
                        const SizedBox(height: Spacing.sm),
                        DropdownButtonFormField<Duration>(
                          initialValue: selectedValidity,
                          decoration: const InputDecoration(
                            labelText: 'Valid for',
                          ),
                          items: [
                            for (final duration in validityOptions)
                              DropdownMenuItem(
                                value: duration,
                                child: Text(_durationLabel(duration)),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedValidity = value),
                        ),
                        const SizedBox(height: Spacing.md),
                        FilledButton.icon(
                          onPressed: zones.isEmpty
                              ? null
                              : () => _broadcast(selectedValidity),
                          icon: const Icon(Icons.campaign_outlined),
                          label: const Text('Broadcast'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                const SectionHeader(title: 'History', icon: Icons.history),
                if (history.isEmpty)
                  const EmptyView(
                    icon: Icons.campaign_outlined,
                    title: 'No alerts broadcast yet',
                  )
                else
                  for (final alert in history) _AlertHistoryCard(alert: alert),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _broadcast(Duration validFor) async {
    final zoneId = _selectedZoneId;
    final officialId = ref.read(currentUserProvider)?.id;
    if (zoneId == null || officialId == null) return;
    if (_titleController.text.trim().isEmpty) return;

    final result = await ref
        .read(alertBroadcastServiceProvider)
        .broadcastToZone(
          zoneId: zoneId,
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          severity: _severity,
          validFor: validFor,
          officialId: officialId,
        );

    ref.invalidate(alertHistoryProvider);

    if (!mounted) return;
    result.when(
      success: (_) {
        _titleController.clear();
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert broadcast to zone')),
        );
      },
      failure: (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}

class _AlertHistoryCard extends ConsumerWidget {
  final LocalAlert alert;

  const _AlertHistoryCard({required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive =
        alert.cancelledAt == null && DateTime.now().isBefore(alert.validUntil);
    final acknowledgements = ref
        .watch(_alertAcknowledgementCountProvider(alert.id))
        .valueOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                SeverityChip(severity: alert.severity),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(alert.message),
            const SizedBox(height: Spacing.xs),
            Text(
              '${alert.zoneLabel} · ${isActive
                  ? "Active"
                  : alert.cancelledAt != null
                  ? "Cancelled"
                  : "Expired"} '
              '· valid until ${alert.validUntil.toLocal()}'
              '${acknowledgements == null ? "" : " · $acknowledgements acknowledged"}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (isActive)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _cancel(context, ref),
                  child: const Text('Cancel alert'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final officialId = ref.read(currentUserProvider)?.id;
    if (officialId == null) return;

    await ref
        .read(alertBroadcastServiceProvider)
        .cancelAlert(alertId: alert.id, officialId: officialId);

    ref.invalidate(alertHistoryProvider);
  }
}

final _alertAcknowledgementCountProvider = FutureProvider.autoDispose
    .family<int, String>((ref, alertId) async {
      final result = await ref
          .watch(alertBroadcastServiceProvider)
          .acknowledgementsFor(alertId);
      return result.dataOrNull?.length ?? 0;
    });
