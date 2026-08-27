# CORE MODULE: Shared Widgets (`lib/shared/widgets/`)

Six reusable UI components used across multiple features. All are `StatelessWidget`s (one is a `PreferredSizeWidget`), none touch Riverpod or perform I/O directly — they take data/callbacks as constructor parameters and render, keeping them trivially reusable across any feature screen.

## Async/data-state views

### `lib/shared/widgets/async_state_views.dart`
- **Purpose**: The three states almost every data-driven screen needs — loading, empty, and error — as one shared, consistently-styled treatment. The file's own comment states that before this existed, each screen hand-rolled its own version of these with inconsistent wording and layout.
- **Status**: IMPLEMENTED.
- **Key classes**:
  - `LoadingView({message?})` — centered `CircularProgressIndicator`, optional message text below it.
  - `EmptyView({required icon, required title, message?, action?})` — centered icon (44px, `onSurfaceVariant` color) + title (`titleMedium`) + optional message (`bodySmall`) + optional trailing action widget (e.g. a button), all with `Spacing`-scale gaps.
  - `ErrorView({required message, onRetry?})` — centered error icon (`Icons.error_outline`, theme error color) + message + an optional "Retry" `OutlinedButton.icon` wired to `onRetry`.
- **Notable imports**: `app/spacing.dart`.
- **Depends on**: `Spacing` constants only.
- **Depended on by**: widely across `lib/features/` (confirmed directly by `alerts.md`'s module doc listing it as an import of `alerts_screen.dart`); this is the app's standard `AsyncValue.when(loading/error/data)` rendering trio.
- **Mock/demo content**: none — purely presentational, no hardcoded data.

## Severity / status indicators

### `lib/shared/widgets/severity_chip.dart`
- **Purpose**: Small pill widgets that render a severity or free-form status value as a colored badge instead of plain text, so it reads at a glance.
- **Status**: IMPLEMENTED.
- **Key classes**:
  - `SeverityChip({required severity})` — color sourced from `core/gis/severity_palette.dart`'s `severityColor(severity)`; renders uppercase, bold, 15%-opacity fill with a 40%-opacity border in the same color.
  - `StatusPill({required label, required color})` — same visual treatment but for a free-form label with a caller-supplied color (not tied to the fixed severity palette) — e.g. an incident lifecycle state like "assigned"/"resolved."
- **Notable imports**: `app/spacing.dart`, `core/gis/severity_palette.dart`.
- **Depends on**: `severityColor` (see `docs/modules/core_infrastructure.md`).
- **Depended on by**: any screen displaying a hazard/incident/alert severity or a status label — direct usage confirmed for the alerts feature; likely used across map, dashboard, verification, and reporting screens (outside this doc's direct-read scope).
- **Mock/demo content**: none.

## Layout / navigation chrome

### `lib/shared/widgets/section_header.dart`
- **Purpose**: A consistent "icon + title (+ optional trailing action)" row for opening a section within a screen. The file's own comment notes every screen was previously hand-rolling a bare `Text` widget for this, with no shared visual weight or icon.
- **Status**: IMPLEMENTED.
- **Key classes**: `SectionHeader({required title, icon?, trailing?})` — optional leading icon (20px, primary color), title in `titleMedium`, optional trailing widget (uses Dart's `?trailing` null-aware-spread-into-child syntax) right-aligned via `Expanded` on the title.
- **Notable imports**: `app/spacing.dart`.
- **Depended on by**: any screen with multiple logical sections (e.g. dashboards, detail screens) — not exhaustively traced beyond this file.

### `lib/shared/widgets/responsive.dart`
- **Purpose**: The single place every screen's "is this a wide viewport" decision should come from, and a content-width-capping wrapper — the file's comment calls a phone-shaped column of text/cards stretching edge-to-edge on a wide desktop browser window "the single biggest offender the audit found in the web layout."
- **Status**: IMPLEMENTED.
- **Key classes/functions**:
  - `ScreenSize` enum (`mobile`, `tablet`, `desktop`); `_sizeFor(width)` (private) — thresholds against `Breakpoints.desktop` (1100) and `Breakpoints.tablet` (700) from `app/spacing.dart`.
  - `ResponsiveBuilder({required builder})` — wraps `LayoutBuilder`, calls `builder(context, _sizeFor(constraints.maxWidth))`; rebuilds automatically whenever available width crosses a breakpoint.
  - `ContentWidth({required child, maxWidth = 760, padding = EdgeInsets.all(Spacing.md)})` — top-centers content and caps it at `maxWidth`, so text/cards don't stretch full-width on a desktop browser.
- **Notable imports**: `app/spacing.dart` (`Breakpoints`).
- **Depended on by**: any screen needing responsive layout — e.g. wide list screens with a filter rail, the Command Dashboard's side-by-side panels (per `Breakpoints.desktop`'s own doc comment in `app/spacing.dart`).

### `lib/shared/widgets/taarak_app_bar.dart`
- **Purpose**: The app bar every screen should use instead of a bare Flutter `AppBar`, specifically to fix a real, previously-broken back-button behavior.
- **Status**: IMPLEMENTED. This file documents and fixes a genuine prior bug: Flutter's own automatic back button relies on `Navigator.canPop`, which doesn't reliably reflect go_router's own idea of "is there somewhere to go back to." The file's comment states plainly that before this widget existed, "no screen in the app ever showed a working back arrow, no matter how it was navigated to."
- **Key classes**: `TaarakAppBar({required title, actions?, backgroundColor?, foregroundColor?})` implements `PreferredSizeWidget` — uses `GoRouter.maybeOf(context)?.canPop() ?? false` (not the throwing `context.canPop()`) specifically so the widget degrades gracefully to "no back arrow" when mounted without a router ancestor, which the comment notes happens in a few widget tests, rather than crashing there.
- **Notable imports**: `go_router`.
- **Depends on**: `go_router`'s `GoRouter.maybeOf`/`context.pop()`.
- **Depended on by**: intended as the universal app bar for every screen in the app (per its own doc comment); not exhaustively verified against every screen file from this module's scope.

## Auth-specific branding

### `lib/shared/widgets/auth_brand_header.dart`
- **Purpose**: The two visual elements shared by the sign-in and registration screens so they read as the same product rather than one being "the branded one."
- **Status**: IMPLEMENTED.
- **Key classes**:
  - `AuthBrandHeader({tagline = 'Disaster preparedness & response'})` — a 72×72 circular icon badge (`Icons.shield`, `onPrimary` color at 14% background opacity), the "TAARAK" wordmark (`headlineSmall`, letter-spacing 1.2), and the tagline below it (`bodyMedium` at 85% opacity). The tagline text is the closest thing to hardcoded copy in this module — it's a constructor default, not baked into the layout, so a caller can override it.
  - `AuthCard({required child})` — the elevated, 28px-rounded white card both auth screens float their form fields inside, with a soft drop shadow, over the branded background color.
- **Notable imports**: `app/spacing.dart`.
- **Depended on by**: presumably `features/auth/presentation/login_screen.dart` and `register_screen.dart` (not read directly in this module's scope, but this widget's stated purpose is specific to exactly those two screens).
- **Mock/demo content**: none — the default tagline string is real product copy, not placeholder text.

---

## Summary table

| File | Exports | Has real logic beyond styling? |
|---|---|---|
| `async_state_views.dart` | `LoadingView`, `EmptyView`, `ErrorView` | No — pure presentational, trivial |
| `severity_chip.dart` | `SeverityChip`, `StatusPill` | No — delegates color logic to `core/gis/severity_palette.dart` |
| `section_header.dart` | `SectionHeader` | No — trivial |
| `responsive.dart` | `ScreenSize`, `ResponsiveBuilder`, `ContentWidth` | Yes — breakpoint threshold logic (`_sizeFor`), the one piece of real branching logic in this directory |
| `taarak_app_bar.dart` | `TaarakAppBar` | Yes — the `GoRouter.maybeOf(...)?.canPop()` back-button-availability check, which fixes a real, previously-broken behavior |
| `auth_brand_header.dart` | `AuthBrandHeader`, `AuthCard` | No — trivial, purely visual |

No file in this directory reads Riverpod state, performs network/database I/O, or contains mock/demo/placeholder data.
