import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _wasSent ? null : scheme.errorContainer,
      appBar: AppBar(
        title: const Text('SOS / Need Help'),
        backgroundColor: _wasSent ? null : scheme.errorContainer,
        foregroundColor: _wasSent ? null : scheme.onErrorContainer,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_wasSent) ...[
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    Text(
                      'SOS sent',
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Your location has been recorded and queued to send as '
                      'soon as you\'re online. Responders will see this as '
                      'high priority.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ] else ...[
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: scheme.onErrorContainer.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emergency_outlined,
                        color: scheme.onErrorContainer,
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'This sends your current location as a high-priority '
                      'request for help.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    Container(
                      padding: const EdgeInsets.all(Spacing.sm),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Add a short note (optional)',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: Spacing.sm),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: scheme.error),
                      ),
                    ],
                    const SizedBox(height: Spacing.xl),
                    SizedBox(
                      width: 176,
                      height: 176,
                      child: Material(
                        color: scheme.error,
                        shape: const CircleBorder(),
                        elevation: 6,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _isSubmitting ? null : _sendSos,
                          child: Center(
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.sos,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      SizedBox(height: Spacing.xs),
                                      Text(
                                        'SEND SOS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
