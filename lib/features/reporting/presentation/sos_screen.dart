import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/reporting/application/reporting_providers.dart';

/// "SOS/Need Help → high-priority location-linked request" (blueprint
/// section 9) — deliberately minimal friction: one button, an optional
/// note, nothing else required.
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  bool _wasSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _sendSos() async {
    final reporterId = ref.read(currentUserProvider)?.id;
    if (reporterId == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(citizenReportSubmissionServiceProvider)
        .submitSos(note: _noteController.text.trim(), reporterId: reporterId);

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
      appBar: AppBar(title: const Text('SOS / Need Help')),
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
                  'Your SOS has been recorded with your location and queued '
                  'to send as soon as you\'re online.',
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const Text(
                  'This sends your current location as a high-priority '
                  'request for help.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Add a short note (optional)',
                    border: OutlineInputBorder(),
                  ),
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
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: _isSubmitting ? null : _sendSos,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SEND SOS', style: TextStyle(fontSize: 20)),
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
