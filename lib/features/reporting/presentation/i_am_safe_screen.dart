import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/reporting/application/reporting_providers.dart';

/// "I Am Safe → update status" (blueprint section 9) — a status ping, not
/// a hazard report, so no severity/type picker at all.
class IAmSafeScreen extends ConsumerStatefulWidget {
  const IAmSafeScreen({super.key});

  @override
  ConsumerState<IAmSafeScreen> createState() => _IAmSafeScreenState();
}

class _IAmSafeScreenState extends ConsumerState<IAmSafeScreen> {
  bool _isSubmitting = false;
  bool _wasSent = false;
  String? _errorMessage;

  Future<void> _markSafe() async {
    final reporterId = ref.read(currentUserProvider)?.id;
    if (reporterId == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(citizenReportSubmissionServiceProvider)
        .submitSafeStatus(reporterId: reporterId);

    if (!mounted) return;
    result.when(
      success: (_) => setState(() => _wasSent = true),
      failure: (failure) => setState(() => _errorMessage = failure.message),
    );
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('I Am Safe')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_wasSent) ...[
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Your safe status has been recorded with your location.',
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const Text(
                  'Let responders know you\'re safe. Your current location '
                  'is attached automatically.',
                  textAlign: TextAlign.center,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 72,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _markSafe,
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('I\'M SAFE', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
