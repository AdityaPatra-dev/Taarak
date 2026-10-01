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
/// Both screens now read from [appPolicyProvider] instead. Also owns the
/// automatic hazard-zone engine's thresholds — disaster-response judgment
/// calls ("how sure before the engine warns/stands down"), same category
/// as the hazard-radius options above them.
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
  final _createThresholdController = TextEditingController();
  final _deleteThresholdController = TextEditingController();
  final _deleteConfirmationPollsController = TextEditingController();
  final _autoRadiusMetersController = TextEditingController();
  bool _isSaving = false;
  String? _autoHazardError;

  @override
  void dispose() {
    _newValidityHoursController.dispose();
    _newRadiusMetersController.dispose();
    _createThresholdController.dispose();
    _deleteThresholdController.dispose();
    _deleteConfirmationPollsController.dispose();
    _autoRadiusMetersController.dispose();
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
        data: (policy) {
          if (_createThresholdController.text.isEmpty) {
            _createThresholdController.text = '${policy.autoHazardCreateThreshold}';
          }
          if (_deleteThresholdController.text.isEmpty) {
            _deleteThresholdController.text = '${policy.autoHazardDeleteThreshold}';
          }
          if (_deleteConfirmationPollsController.text.isEmpty) {
            _deleteConfirmationPollsController.text =
                '${policy.autoHazardDeleteConfirmationPolls}';
          }
          if (_autoRadiusMetersController.text.isEmpty) {
            _autoRadiusMetersController.text = '${policy.autoHazardRadiusMeters}';
          }
          return ListView(
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
                    const SizedBox(height: Spacing.lg),
                    const SectionHeader(
                      title: 'Automatic hazard zone thresholds',
                      icon: Icons.auto_awesome_outlined,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                      child: Text(
                        'How sure the automatic engine needs to be, from live '
                        'weather data alone, before it creates a zone with no '
                        'human involved — and how many consecutive checks of '
                        'improving conditions it needs before removing one '
                        'again. Scores are 0–1.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                      child: Column(
                        children: [
                          TextField(
                            controller: _createThresholdController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Create threshold (0–1)',
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          TextField(
                            controller: _deleteThresholdController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Delete threshold (0–1, below create)',
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          TextField(
                            controller: _deleteConfirmationPollsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Consecutive low checks before deleting',
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          TextField(
                            controller: _autoRadiusMetersController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Auto zone radius (meters)',
                            ),
                          ),
                          if (_autoHazardError != null) ...[
                            const SizedBox(height: Spacing.sm),
                            Text(
                              _autoHazardError!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: Spacing.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton(
                              onPressed: _isSaving ? null : () => _saveAutoHazardThresholds(policy),
                              child: const Text('Save thresholds'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
      _withUnchangedAutoHazard(
        policy,
        alertValidityOptions: [
          ...policy.alertValidityOptions,
          Duration(hours: hours),
        ],
      ),
    );
  }

  void _removeValidityOption(AppPolicy policy, Duration duration) {
    _save(
      _withUnchangedAutoHazard(
        policy,
        alertValidityOptions: policy.alertValidityOptions
            .where((d) => d != duration)
            .toList(),
      ),
    );
  }

  void _addRadiusOption(AppPolicy policy) {
    final meters = double.tryParse(_newRadiusMetersController.text.trim());
    if (meters == null || meters <= 0) return;
    _newRadiusMetersController.clear();
    _save(
      _withUnchangedAutoHazard(
        policy,
        hazardRadiusOptionsMeters: [
          ...policy.hazardRadiusOptionsMeters,
          meters,
        ],
      ),
    );
  }

  void _removeRadiusOption(AppPolicy policy, double meters) {
    _save(
      _withUnchangedAutoHazard(
        policy,
        hazardRadiusOptionsMeters: policy.hazardRadiusOptionsMeters
            .where((m) => m != meters)
            .toList(),
      ),
    );
  }

  AppPolicy _withUnchangedAutoHazard(
    AppPolicy policy, {
    List<Duration>? alertValidityOptions,
    List<double>? hazardRadiusOptionsMeters,
  }) => AppPolicy(
    alertValidityOptions: alertValidityOptions ?? policy.alertValidityOptions,
    hazardRadiusOptionsMeters: hazardRadiusOptionsMeters ?? policy.hazardRadiusOptionsMeters,
    autoHazardCreateThreshold: policy.autoHazardCreateThreshold,
    autoHazardDeleteThreshold: policy.autoHazardDeleteThreshold,
    autoHazardDeleteConfirmationPolls: policy.autoHazardDeleteConfirmationPolls,
    autoHazardRadiusMeters: policy.autoHazardRadiusMeters,
  );

  void _saveAutoHazardThresholds(AppPolicy policy) {
    final createThreshold = double.tryParse(_createThresholdController.text.trim());
    final deleteThreshold = double.tryParse(_deleteThresholdController.text.trim());
    final deleteConfirmationPolls = int.tryParse(
      _deleteConfirmationPollsController.text.trim(),
    );
    final autoRadius = double.tryParse(_autoRadiusMetersController.text.trim());

    if (createThreshold == null || createThreshold < 0 || createThreshold > 1) {
      setState(() => _autoHazardError = 'Create threshold must be between 0 and 1');
      return;
    }
    if (deleteThreshold == null || deleteThreshold < 0 || deleteThreshold > 1) {
      setState(() => _autoHazardError = 'Delete threshold must be between 0 and 1');
      return;
    }
    if (deleteThreshold >= createThreshold) {
      setState(() => _autoHazardError = 'Delete threshold must be below create threshold');
      return;
    }
    if (deleteConfirmationPolls == null || deleteConfirmationPolls < 1) {
      setState(() => _autoHazardError = 'Consecutive checks must be at least 1');
      return;
    }
    if (autoRadius == null || autoRadius <= 0) {
      setState(() => _autoHazardError = 'Auto zone radius must be greater than 0');
      return;
    }

    setState(() => _autoHazardError = null);
    _save(
      AppPolicy(
        alertValidityOptions: policy.alertValidityOptions,
        hazardRadiusOptionsMeters: policy.hazardRadiusOptionsMeters,
        autoHazardCreateThreshold: createThreshold,
        autoHazardDeleteThreshold: deleteThreshold,
        autoHazardDeleteConfirmationPolls: deleteConfirmationPolls,
        autoHazardRadiusMeters: autoRadius,
      ),
    );
  }
}
