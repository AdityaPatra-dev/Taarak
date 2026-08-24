import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/media/media_picker_service.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/reporting/application/reporting_providers.dart';
import 'package:taarak/features/reporting/domain/citizen_report_draft.dart';
import 'package:taarak/features/reporting/domain/citizen_report_type.dart';

const _hazardIssueTypes = [
  CitizenReportType.landslide,
  CitizenReportType.flood,
  CitizenReportType.roadBlockage,
  CitizenReportType.other,
];

const _severities = ['low', 'medium', 'high', 'critical'];

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
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
    final path = await ref.read(mediaPickerServiceProvider).pickPhoto(source: source);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('What are you reporting?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final type in _hazardIssueTypes)
                ChoiceChip(
                  label: Text(type.label),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'What did you see? (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Severity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final severity in _severities)
                ChoiceChip(
                  label: Text(severity),
                  selected: _severity == severity,
                  onSelected: (_) => setState(() => _severity = severity),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _affectedPeopleController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Roughly how many people affected? (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _attachPhoto(MediaPickerSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Camera'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _attachPhoto(MediaPickerSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ],
          ),
          if (_mediaPath != null) ...[
            const SizedBox(height: 8),
            Text('Photo attached', style: Theme.of(context).textTheme.bodySmall),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit report'),
          ),
          const SizedBox(height: 8),
          Text(
            'Your GPS location is attached automatically. If you\'re offline, '
            'this is saved on your device and sent once you\'re back online.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
