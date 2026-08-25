import 'package:flutter/material.dart';
import 'package:taarak/app/spacing.dart';

/// A consistent "icon + title (+ trailing action)" row used to open a
/// section within a screen — every screen was hand-rolling a bare `Text`
/// for this before, with no shared visual weight or icon.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: Spacing.xs),
          ],
          Expanded(child: Text(title, style: textTheme.titleMedium)),
          ?trailing,
        ],
      ),
    );
  }
}
