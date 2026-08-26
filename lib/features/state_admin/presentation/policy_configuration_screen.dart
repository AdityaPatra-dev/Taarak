import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/features/state_admin/application/state_admin_providers.dart';
import 'package:taarak/features/state_admin/domain/app_policy.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// State/Admin's ([Permission.managePolicyConfiguration]) settings screen
/// — starting with the two values that used to be hardcoded constants in
/// `broadcast_alert_screen.dart` and `report_hazard_zone_screen.dart`.
/// Both screens now read from [appPolicyProvider] instead.
class PolicyConfigurationScreen extends ConsumerStatefulWidget {
  const PolicyConfigurationScreen({super.key});

  @override
  ConsumerState<PolicyConfigurationScreen> createState() =>
      _PolicyConfigurationScreenState();
}

class _PolicyConfigurationScreenState
    extends ConsumerState<PolicyConfigurationScreen> {
  final _newValidityHoursController = TextEditingController();
  final _newRadiusMetersController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _newValidityHoursController.dispose();
    _newRadiusMetersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final policyAsync = ref.watch(appPolicyProvider);

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Policy Configuration'),
      body: policyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Unable to load policy')),
        data: (policy) => ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Alert validity options',
                    icon: Icons.campaign_outlined,
                  ),
                  Wrap(
                    spacing: Spacing.sm,
                    children: [
                      for (final duration in policy.alertValidityOptions)
                        Chip(
                          label: Text('${duration.inHours}h'),
                          onDeleted: () => _removeValidityOption(
                            policy,
                            duration,
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newValidityHoursController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Add option (hours)',
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      FilledButton(
                        onPressed: _isSaving
                            ? null
                            : () => _addValidityOption(policy),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  const SectionHeader(
                    title: 'Hazard zone radius options',
                    icon: Icons.warning_amber_outlined,
                  ),
                  Wrap(
                    spacing: Spacing.sm,
                    children: [
                      for (final meters in policy.hazardRadiusOptionsMeters)
                        Chip(
                          label: Text(
                            meters >= 1000
                                ? '${(meters / 1000).toStringAsFixed(meters % 1000 == 0 ? 0 : 1)} km'
                                : '${meters.toInt()} m',
                          ),
                          onDeleted: () => _removeRadiusOption(policy, meters),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newRadiusMetersController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Add option (meters)',
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      FilledButton(
                        onPressed: _isSaving
                            ? null
                            : () => _addRadiusOption(policy),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(AppPolicy policy) async {
    setState(() => _isSaving = true);
    await ref.read(appPolicyDataSourceProvider).write(policy);
    ref.invalidate(appPolicyProvider);
    if (mounted) setState(() => _isSaving = false);
  }

  void _addValidityOption(AppPolicy policy) {
    final hours = int.tryParse(_newValidityHoursController.text.trim());
    if (hours == null || hours <= 0) return;
    _newValidityHoursController.clear();
    _save(
      AppPolicy(
        alertValidityOptions: [
          ...policy.alertValidityOptions,
          Duration(hours: hours),
        ],
        hazardRadiusOptionsMeters: policy.hazardRadiusOptionsMeters,
      ),
    );
  }

  void _removeValidityOption(AppPolicy policy, Duration duration) {
    _save(
      AppPolicy(
        alertValidityOptions: policy.alertValidityOptions
            .where((d) => d != duration)
            .toList(),
        hazardRadiusOptionsMeters: policy.hazardRadiusOptionsMeters,
      ),
    );
  }

  void _addRadiusOption(AppPolicy policy) {
    final meters = double.tryParse(_newRadiusMetersController.text.trim());
    if (meters == null || meters <= 0) return;
    _newRadiusMetersController.clear();
    _save(
      AppPolicy(
        alertValidityOptions: policy.alertValidityOptions,
        hazardRadiusOptionsMeters: [
          ...policy.hazardRadiusOptionsMeters,
          meters,
        ],
      ),
    );
  }

  void _removeRadiusOption(AppPolicy policy, double meters) {
    _save(
      AppPolicy(
        alertValidityOptions: policy.alertValidityOptions,
        hazardRadiusOptionsMeters: policy.hazardRadiusOptionsMeters
            .where((m) => m != meters)
            .toList(),
      ),
    );
  }
}
