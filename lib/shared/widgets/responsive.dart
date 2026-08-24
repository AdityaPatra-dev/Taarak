import 'package:flutter/material.dart';
import 'package:taarak/app/spacing.dart';

enum ScreenSize { mobile, tablet, desktop }

ScreenSize _sizeFor(double width) {
  if (width >= Breakpoints.desktop) return ScreenSize.desktop;
  if (width >= Breakpoints.tablet) return ScreenSize.tablet;
  return ScreenSize.mobile;
}

/// Rebuilds when the available width crosses a breakpoint — the one place
/// every screen's responsive decision should come from, so "wide viewport"
/// means the same thing everywhere in the app.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize size) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, _sizeFor(constraints.maxWidth)),
    );
  }
}

/// Caps content at a readable width and centers it on wide viewports,
/// instead of a phone-shaped column of text/cards stretching edge to edge
/// across a desktop browser window — the single biggest offender the
/// audit found in the web layout.
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = 760,
    this.padding = const EdgeInsets.all(Spacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
