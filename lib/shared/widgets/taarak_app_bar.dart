import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Every screen in the app should use this instead of a bare [AppBar].
///
/// Flutter's own automatic back button relies on `Navigator.canPop`, which
/// doesn't reliably reflect go_router's own idea of "is there somewhere to
/// go back to" — `context.canPop()` is the signal go_router itself expects
/// callers to check instead. Using a bare `AppBar` per screen meant no
/// screen in the app ever showed a working back arrow, no matter how it
/// was navigated to.
class TaarakAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const TaarakAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // GoRouter.maybeOf, not the throwing context.canPop() — this widget is
    // also mounted directly (no router ancestor) in a few widget tests, and
    // should degrade to "no back arrow" there rather than crash.
    final canPop = GoRouter.maybeOf(context)?.canPop() ?? false;
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () => context.pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
