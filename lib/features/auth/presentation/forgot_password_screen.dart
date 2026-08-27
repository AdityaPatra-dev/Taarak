import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/shared/widgets/auth_brand_header.dart';

/// Reached from [LoginScreen]'s "Forgot password?" link — sends a
/// Firebase-issued reset email via [AuthController.sendPasswordResetEmail].
/// Shows the real result rather than a blanket "check your email" message
/// regardless of outcome: this app's own rules elsewhere rule out fake
/// success states, and a wrong-email typo is exactly the kind of mistake a
/// citizen under stress needs to actually see, not have silently swallowed.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _goBackToLogin(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(email: _emailController.text.trim());

    if (!mounted) return;
    result.when(
      success: (_) {
        TextInput.finishAutofillContext();
        setState(() => _sent = true);
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
      backgroundColor: scheme.primary,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const AuthBrandHeader(tagline: 'Reset your password'),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: AuthCard(
                        child: _sent
                            ? _buildSentState(scheme, textTheme)
                            : _buildFormFields(scheme, textTheme),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: Spacing.sm,
              left: Spacing.sm,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: scheme.onPrimary),
                tooltip: 'Back',
                onPressed: () => _goBackToLogin(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentState(ColorScheme scheme, TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 40, color: scheme.primary),
        const SizedBox(height: Spacing.sm),
        Text('Check your email', style: textTheme.headlineSmall),
        const SizedBox(height: Spacing.xs),
        Text(
          'If an account exists for ${_emailController.text.trim()}, a '
          'password reset link is on its way.',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: Spacing.lg),
        FilledButton(
          onPressed: () => _goBackToLogin(context),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: const Text('Back to sign in'),
        ),
      ],
    );
  }

  Widget _buildFormFields(ColorScheme scheme, TextTheme textTheme) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reset password', style: textTheme.headlineSmall),
            const SizedBox(height: Spacing.xs),
            Text(
              'Enter the email on your account and we\'ll send a link to '
              'reset your password.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) => (value == null || !value.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 18,
                      color: scheme.onErrorContainer,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send reset link'),
            ),
            const SizedBox(height: Spacing.xs),
            TextButton(
              onPressed: () => _goBackToLogin(context),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
