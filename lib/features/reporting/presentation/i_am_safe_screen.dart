import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/reporting/application/reporting_providers.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final safeGreen = Colors.green.shade600;

    return Scaffold(
      appBar: const TaarakAppBar(title: 'I Am Safe'),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: safeGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _wasSent
                          ? Icons.check_circle
                          : Icons.health_and_safety_outlined,
                      color: safeGreen,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  if (_wasSent) ...[
                    Text(
                      'You\'re marked safe',
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Your safe status has been recorded with your current location.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ] else ...[
                    Text(
                      'Let responders know you\'re safe',
                      style: textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Your current location is attached automatically.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
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
                      width: double.infinity,
                      height: 64,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: safeGreen,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _markSafe,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check, color: Colors.white),
                        label: const Text("I'M SAFE"),
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
