import 'package:flutter/material.dart';
import 'package:taarak/app/spacing.dart';

/// The shield-and-wordmark header shown above both the sign-in and
/// registration cards, so the two screens read as the same product
/// instead of one being "the branded one".
class AuthBrandHeader extends StatelessWidget {
  final String tagline;

  const AuthBrandHeader({
    super.key,
    this.tagline = 'Disaster preparedness & response',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.xl,
        Spacing.lg,
        Spacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield, size: 36, color: scheme.onPrimary),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'TAARAK',
            style: textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            tagline,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// The elevated rounded card both auth screens float their form in, over
/// the branded background.
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.lg),
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.xl,
        Spacing.lg,
        Spacing.lg,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
