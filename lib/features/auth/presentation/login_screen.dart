import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    result.when(
      success: (_) {},
      failure: (failure) => setState(() => _errorMessage = failure.message),
    );
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final useMockAuth = ref.watch(appConfigProvider).useMockAuth;

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.shield_outlined, size: 40, color: scheme.primary),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'TAARAK',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xl),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        (value == null || !value.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: Spacing.sm),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your password'
                        : null,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: Spacing.sm),
                    Text(_errorMessage!, style: TextStyle(color: scheme.error)),
                  ],
                  const SizedBox(height: Spacing.lg),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text("Don't have an account? Register"),
                  ),
                  if (useMockAuth) ...[
                    const Divider(height: Spacing.xl),
                    Text(
                      'Demo accounts (dev mode — no backend yet)',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'citizen@taarak.dev / citizen123\n'
                      'responder@taarak.dev / responder123\n'
                      'official@taarak.dev / official123\n'
                      'command@taarak.dev / command123\n'
                      'stateadmin@taarak.dev / stateadmin123\n'
                      'sysadmin@taarak.dev / sysadmin123',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
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
