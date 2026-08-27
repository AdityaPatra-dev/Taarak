# Build / Run Instructions

Adapted from the repository's own `README.md` (written and verified via a genuinely clean rebuild earlier in this project's development, re-verified for this documentation pass — `flutter test` was re-run directly and shows **440 tests, all passing** as of this pass; the README's stale "401" figure has been corrected to match).

## Requirements

| Tool | Version | Notes |
|---|---|---|
| Flutter SDK | 3.44.8, stable channel (bundles Dart 3.12.2) | `pubspec.yaml` requires Dart `^3.12.2` |
| Android SDK | Platform 36, build-tools 36.0.0 | Auto-managed by Android Studio / Gradle |
| JDK | 17+ | Required for Gradle (AGP 9.0.1 / Gradle 9.1.0) |
| Android Studio | Recent stable | Optional but convenient |
| Chrome or Edge | Any recent version | For the web target |

Run `flutter doctor` after installing.

**No `.env` files, no manually-downloaded SDKs, no API keys to supply.** Verified directly this documentation pass: `find . -iname "*.env*"` returns nothing in the repo, and `AppConfig`/`firebase_options.dart` are fully committed, working configuration — see `17_ENVIRONMENT_CONFIG.md`.

## Installation

```bash
git clone <this-repo>
cd Taarak
flutter pub get
```

## Running

```bash
flutter run       # pick a device: emulator, physical Android device, or Chrome
```

The app talks to a real, already-configured, live Firebase project (`taakrak-d9ed0`) and a real Google Maps API key out of the box.

## Testing

```bash
flutter test
```

440 tests as of this pass, all passing. A handful of tests intentionally exercise a "not cached locally" error path during sync — red `CacheException` blocks in the console output during a test run are expected logged output from a *passing* test, not a failure; check the final `+440: All tests passed!` line.

```bash
flutter analyze
```

0 errors/warnings expected; a stable set of `info`-level `prefer_initializing_formals` lints exists across the codebase (a deliberate, consistently-applied style — every service/repository constructor assigns constructor parameters to fields in the initializer list rather than via Dart's shorthand `this.x` syntax) and is not a defect.

## Building

```bash
flutter build web --release --no-minify-js   # web
flutter build apk --release                  # Android
```

**`--no-minify-js` is required, not optional**, for the web build — dart2js minification breaks JS-interop plugin registration for `firebase_core` and `google_maps_flutter_web` in this Flutter version. Without it, the deployed site silently fails to initialize Firebase and/or render the map. Isolated this project by diffing compiled `main.dart.js` output between minified and unminified builds — a real toolchain issue, not a configuration mistake.

## Deployment (manual — no CI/CD pipeline exists)

```bash
firebase deploy --only hosting           # deploy the built web/ directory
firebase deploy --only firestore:rules   # deploy firestore.rules
```

Both were run repeatedly and successfully during this project's development against the live `taakrak-d9ed0` project, most recently in this same session. There is no automated pipeline — every deploy observed was a manually-run `firebase deploy` command by a developer.

## Generated code

`lib/core/database/app_database.g.dart` (Drift's generated database code) is committed — `flutter analyze`/`test`/`build` work immediately after `flutter pub get`, no `build_runner` step required for a fresh clone. If you change a Drift table (`lib/core/database/tables/`), regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

`web/sqlite3.wasm` and `web/drift_worker.js` are also committed (one-time manual-copy assets Drift's web backend needs; Flutter's build does not generate them).

## App icon

```bash
dart run flutter_launcher_icons
```

Regenerates from `assets/icon/icon_master.png` / `assets/icon/icon_foreground.png`. Already-generated per-platform icon files are committed; only needed if you change the source images.

## Known build issues and their fixes (verified, not theoretical)

- **Blank map / Firebase silently fails to initialize on web** → you built without `--no-minify-js`.
- **`flutter build apk` desugaring error mentioning `flutter_local_notifications`** → confirm JDK 17+; `isCoreLibraryDesugaringEnabled = true` + `desugar_jdk_libs` are already in the committed Gradle config.
- **`android/local.properties` errors ("flutter.sdk not set")** → this file is gitignored and machine-specific; Flutter regenerates it automatically on first Android build.
- **Emulator can't load map tiles / Firestore** → check the emulator has real internet access; there is no offline/emulated backend for either service.
- **"Authorization failure" from Google Maps on Android only, web works fine** → historically caused by "Maps SDK for Android" not being enabled for the API key's Google Cloud project (a separate toggle from "Maps JavaScript API") — already fixed on the current key; relevant again only if a different key is swapped in.

## What's deliberately NOT set up yet (see `16_IMPLEMENTATION_GAPS.md` for the prioritized list)

- Android `applicationId`/`namespace` is still the Flutter-default `com.example.taarak` — blocks Play Store submission.
- Android release builds are signed with the debug keystore, not a real release key — intentional for now (see `15_SECURITY_AUDIT.md`), must change before a real release.
- The Google Maps API key has no application-identity restriction (no Android package+SHA-1, no web HTTP-referrer) — see `15_SECURITY_AUDIT.md`.
- No CI/CD pipeline of any kind.
