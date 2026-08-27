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
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _syncIntervalController.dispose();
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
                          FilledButton(
                            onPressed: _isSaving ? null : _save,
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

  Future<void> _save() async {
    final seconds = int.tryParse(_syncIntervalController.text.trim());
    if (seconds == null ||
        seconds < TechnicalConfig.minSyncIntervalSeconds ||
        seconds > TechnicalConfig.maxSyncIntervalSeconds) {
      setState(
        () => _error =
            'Enter a value between ${TechnicalConfig.minSyncIntervalSeconds} '
            'and ${TechnicalConfig.maxSyncIntervalSeconds}',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    await ref
        .read(technicalConfigDataSourceProvider)
        .write(TechnicalConfig(syncIntervalSeconds: seconds));
    ref.invalidate(technicalConfigProvider);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Technical configuration saved')));
  }
}
