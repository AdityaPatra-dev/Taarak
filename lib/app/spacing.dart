/// The app's spacing scale — every screen should build its gaps/padding
/// from these instead of picking ad hoc values (8, 12, 16, 24 mixed
/// without a system), which is what made the UI feel inconsistent before
/// this pass. Base unit is 4px, matching Material's own grid.
class Spacing {
  Spacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Breakpoints for [lib/shared/widgets/responsive.dart] — named for what
/// they mean, not arbitrary pixel counts.
class Breakpoints {
  Breakpoints._();

  /// Below this: a single-column phone-shaped layout.
  static const double tablet = 700;

  /// At or above this: full multi-column layout (the Command Dashboard's
  /// side-by-side panels, wide list screens with a filter rail, etc).
  static const double desktop = 1100;
}
