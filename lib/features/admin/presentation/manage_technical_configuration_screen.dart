import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/features/admin/application/admin_providers.dart';
import 'package:taarak/features/admin/domain/technical_config.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// System Admin's ([Permission.manageTechnicalConfiguration]) operational
/// settings — kept deliberately small and separate from
/// [PolicyConfigurationScreen]: this is app mechanics (how often it syncs),
/// not disaster-response policy. [technicalConfigProvider] is watched
/// directly by [syncPollingTriggerProvider], so a change here reaches a
/// running session without anyone needing to restart the app.
class ManageTechnicalConfigurationScreen extends ConsumerStatefulWidget {
  const ManageTechnicalConfigurationScreen({super.key});

  @override
  ConsumerState<ManageTechnicalConfigurationScreen> createState() =>
      _ManageTechnicalConfigurationScreenState();
}

class _ManageTechnicalConfigurationScreenState
    extends ConsumerState<ManageTechnicalConfigurationScreen> {
  final _syncIntervalController = TextEditingController();
  final _hazardPollIntervalController = TextEditingController();
  bool _isSaving = false;
  String? _error;
  String? _hazardPollError;

  @override
  void dispose() {
    _syncIntervalController.dispose();
    _hazardPollIntervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(technicalConfigProvider);

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Technical Configuration'),
      body: configAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: 'Could not load technical configuration: $error',
          onRetry: () => ref.invalidate(technicalConfigProvider),
        ),
        data: (config) {
          if (_syncIntervalController.text.isEmpty) {
            _syncIntervalController.text = '${config.syncIntervalSeconds}';
          }
          if (_hazardPollIntervalController.text.isEmpty) {
            _hazardPollIntervalController.text =
                '${config.hazardAutomationPollIntervalSeconds}';
          }
          return ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Background sync interval',
                      icon: Icons.sync_outlined,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                      ),
                      child: Text(
                        'How often every signed-in device checks for new '
                        'hazard zones, incidents, alerts and shelters. '
                        'Lower during an active emergency; raise it back '
                        'to save battery and data otherwise. '
                        '(${TechnicalConfig.minSyncIntervalSeconds}–'
                        '${TechnicalConfig.maxSyncIntervalSeconds} seconds.)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _syncIntervalController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Seconds',
                                errorText: _error,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    const SectionHeader(
                      title: 'Automatic hazard zone engine',
                      icon: Icons.auto_awesome_outlined,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                      ),
                      child: Text(
                        'How often every Local Official/Admin session '
                        're-checks live weather data at each habitation '
                        'and auto-creates or removes a hazard zone. '
                        '(${TechnicalConfig.minHazardAutomationPollIntervalSeconds}–'
                        '${TechnicalConfig.maxHazardAutomationPollIntervalSeconds} seconds.)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                      ),
                      child: TextField(
                        controller: _hazardPollIntervalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Seconds',
                          errorText: _hazardPollError,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Enrich with Gemini rationale'),
                      subtitle: const Text(
                        'When a compiled-in Gemini key is available, adds a '
                        'short explanation to auto-created zones. Never '
                        'changes a zone’s severity or the create/delete '
                        'decision itself — disabling this only removes '
                        'the explanation text.',
                      ),
                      value: config.geminiEnabled,
                      onChanged: _isSaving
                          ? null
                          : (value) => _saveAll(config.copyWith(geminiEnabled: value)),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _isSaving ? null : () => _save(config),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save'),
                        ),
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

  Future<void> _save(TechnicalConfig current) async {
    final seconds = int.tryParse(_syncIntervalController.text.trim());
    final hazardPollSeconds = int.tryParse(_hazardPollIntervalController.text.trim());
    var hasError = false;

    if (seconds == null ||
        seconds < TechnicalConfig.minSyncIntervalSeconds ||
        seconds > TechnicalConfig.maxSyncIntervalSeconds) {
      _error =
          'Enter a value between ${TechnicalConfig.minSyncIntervalSeconds} '
          'and ${TechnicalConfig.maxSyncIntervalSeconds}';
      hasError = true;
    } else {
      _error = null;
    }

    if (hazardPollSeconds == null ||
        hazardPollSeconds < TechnicalConfig.minHazardAutomationPollIntervalSeconds ||
        hazardPollSeconds > TechnicalConfig.maxHazardAutomationPollIntervalSeconds) {
      _hazardPollError =
          'Enter a value between '
          '${TechnicalConfig.minHazardAutomationPollIntervalSeconds} and '
          '${TechnicalConfig.maxHazardAutomationPollIntervalSeconds}';
      hasError = true;
    } else {
      _hazardPollError = null;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    await _saveAll(
      current.copyWith(
        syncIntervalSeconds: seconds,
        hazardAutomationPollIntervalSeconds: hazardPollSeconds,
      ),
    );
  }

  Future<void> _saveAll(TechnicalConfig config) async {
    setState(() {
      _isSaving = true;
      _error = null;
      _hazardPollError = null;
    });

    await ref.read(technicalConfigDataSourceProvider).write(config);
    ref.invalidate(technicalConfigProvider);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Technical configuration saved')));
  }
}
