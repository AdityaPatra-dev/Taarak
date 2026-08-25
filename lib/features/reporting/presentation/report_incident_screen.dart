import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/media/media_picker_service.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/reporting/application/reporting_providers.dart';
import 'package:taarak/features/reporting/domain/citizen_report_draft.dart';
import 'package:taarak/features/reporting/domain/citizen_report_type.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';

const _hazardIssueTypes = [
  CitizenReportType.landslide,
  CitizenReportType.flood,
  CitizenReportType.roadBlockage,
  CitizenReportType.other,
];

const _severities = ['low', 'medium', 'high', 'critical'];

const _typeIcons = {
  CitizenReportType.landslide: Icons.terrain,
  CitizenReportType.flood: Icons.water,
  CitizenReportType.roadBlockage: Icons.block,
  CitizenReportType.other: Icons.report_problem_outlined,
};

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() =>
      _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  CitizenReportType _type = CitizenReportType.landslide;
  String _severity = 'medium';
  final _descriptionController = TextEditingController();
  final _affectedPeopleController = TextEditingController();
  String? _mediaPath;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _descriptionController.dispose();
    _affectedPeopleController.dispose();
    super.dispose();
  }

  Future<void> _attachPhoto(MediaPickerSource source) async {
    final path = await ref
        .read(mediaPickerServiceProvider)
        .pickPhoto(source: source);
    if (path != null) setState(() => _mediaPath = path);
  }

  Future<void> _submit() async {
    final reporterId = ref.read(currentUserProvider)?.id;
    if (reporterId == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final draft = CitizenReportDraft(
      type: _type,
      description: _descriptionController.text.trim(),
      severity: _severity,
      affectedPeopleCount: int.tryParse(_affectedPeopleController.text.trim()),
      mediaPath: _mediaPath,
    );

    final result = await ref
        .read(citizenReportSubmissionServiceProvider)
        .submitReport(draft, reporterId: reporterId);

    if (!mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report saved and queued to sync')),
        );
        Navigator.of(context).maybePop();
      },
      failure: (failure) => setState(() => _errorMessage = failure.message),
    );
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: ListView(
        children: [
          ContentWidth(
            maxWidth: 560,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'What are you reporting?',
                  icon: Icons.report_outlined,
                ),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: [
                    for (final type in _hazardIssueTypes)
                      ChoiceChip(
                        label: Text(type.label),
                        avatar: Icon(_typeIcons[type], size: 18),
                        selected: _type == type,
                        onSelected: (_) => setState(() => _type = type),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'What did you see? (optional)',
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        Text('Severity', style: textTheme.titleSmall),
                        const SizedBox(height: Spacing.sm),
                        Wrap(
                          spacing: Spacing.sm,
                          children: [
                            for (final severity in _severities)
                              ChoiceChip(
                                label: Text(severity),
                                selected: _severity == severity,
                                onSelected: (_) =>
                                    setState(() => _severity = severity),
                              ),
                          ],
                        ),
                        const SizedBox(height: Spacing.md),
                        TextField(
                          controller: _affectedPeopleController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText:
                                'Roughly how many people affected? (optional)',
                            prefixIcon: Icon(Icons.groups_outlined),
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _attachPhoto(MediaPickerSource.camera),
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: const Text('Camera'),
                              ),
                            ),
                            const SizedBox(width: Spacing.sm),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _attachPhoto(MediaPickerSource.gallery),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Gallery'),
                              ),
                            ),
                          ],
                        ),
                        if (_mediaPath != null) ...[
                          const SizedBox(height: Spacing.sm),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: Spacing.xs),
                              Text(
                                'Photo attached',
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: Spacing.md),
                  Text(_errorMessage!, style: TextStyle(color: scheme.error)),
                ],
                const SizedBox(height: Spacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit report'),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Your GPS location is attached automatically. If you\'re offline, '
                  'this is saved on your device and sent once you\'re back online.',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
