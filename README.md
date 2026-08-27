# TAARAK

Disaster preparedness & response app (SIH26191) — six roles (Citizen, Field
Responder, Local Official, District/Command, State/Admin, System Admin),
offline-first local cache backed by a live Firebase project, Google Maps
for the risk map.

Primary, actively tested targets are **Android** and **Web**. iOS/macOS/
Windows/Linux project folders exist (default `flutter create` scaffolding)
but have not been built or run as part of this project's development —
treat them as untested, not as broken.

## Prerequisites

Install these before doing anything else:

| Tool | Version used to build/verify this project | Notes |
|---|---|---|
| Flutter SDK | **3.44.8**, stable channel (bundles Dart 3.12.2) | `pubspec.yaml` requires Dart `^3.12.2`; any Flutter stable release that bundles Dart 3.12.2 or newer works. Install via [flutter.dev/get-started](https://docs.flutter.dev/get-started/install). |
| Android SDK | Platform 36, build-tools 36.0.0 | Installed automatically by Android Studio's SDK Manager, or auto-downloaded by Gradle on first build if `sdkmanager` is on your PATH. You don't need to hand-install a specific version — Flutter's tooling pins the exact one it needs. |
| JDK | 17 or newer | Required to run Gradle (AGP 9.0.1 / Gradle 9.1.0). Easiest source: the JBR bundled with Android Studio (Settings → Build Tools → Gradle → Gradle JDK). If Flutter can't find one, point it explicitly: `flutter config --jdk-dir="/path/to/jdk"`. |
| Android Studio | Recent stable | Not strictly required (a terminal + the Flutter/Android SDKs are enough), but the easiest way to get the Android SDK, an emulator, and a working JDK all at once. Install the Flutter/Dart plugins if you want in-IDE support. |
| Chrome or Edge | Any recent version | Needed to run/debug the web target (`flutter run -d chrome`). |

Run `flutter doctor` after installing and resolve anything it flags before
continuing.

**Nothing else needs installing.** No global CLI tools, no `.env` files, no
manually-downloaded SDKs beyond what's in the table above.

## Quick start

```bash
git clone <this-repo>
cd Taarak
flutter pub get
flutter analyze   # should report 0 errors (a handful of pre-existing lint infos is normal)
flutter test      # 440 tests, all should pass
flutter run       # pick a device when prompted (emulator, physical Android device, or Chrome)
```

That's it — the app talks to a real, already-configured Firebase project
and a real Google Maps API key out of the box (see below for why no keys
need to be supplied). A `flutter build apk --release` was verified against
this exact sequence, including with `android/local.properties` deleted
first to confirm it's genuinely auto-generated on a machine that's never
opened this project before.

### Building

```bash
flutter build web --release --no-minify-js   # web (see note below on --no-minify-js)
flutter build apk --release                  # Android APK
```

`--no-minify-js` is **required**, not optional, for the web build:
dart2js minification breaks JS-interop plugin registration for both
`firebase_core` and `google_maps_flutter_web` in this Flutter version —
without it, the deployed site silently fails to initialize Firebase and/or
render the map. This was isolated by diffing compiled `main.dart.js`
output between minified and unminified builds; it isn't a config mistake,
it's a real toolchain bug to work around.

## Firebase — already configured, nothing to set up

`lib/firebase_options.dart` contains real, working configuration for a
live Firebase project (`taakrak-d9ed0`), committed intentionally. This is
safe and normal: a Firebase **client** config (as opposed to a server API
key) only identifies which project to talk to — it grants no access by
itself. Actual access control is enforced by `firestore.rules` (deployed
separately, see below) and Firebase Authentication, not by keeping this
file secret. Every Firebase/Flutter starter template documents this same
practice.

Practically: `main.dart` calls `Firebase.initializeApp()` unconditionally
and `AppConfig.development().useFirebaseAuth` is always `true` — there is
no mock-auth fallback path in the current build, and no environment
variable or flag to set. A clone of this repo talks to the same backend
the original developer used, with the same six test/role accounts (ask
the project owner for credentials, or register a new citizen account
in-app — anyone can self-register as a citizen).

If you deliberately want your **own** Firebase project instead (e.g. to
avoid touching shared production data), install the FlutterFire CLI and
run `flutterfire configure` from the repo root — it overwrites
`firebase_options.dart` with your project's values. You'd then also need
to deploy `firestore.rules` to your project (`firebase deploy --only
firestore:rules`) since the app depends on those exact rules to function
correctly for each role.

`backend/` is a **historical stub**, fully disconnected from the app —
skip it entirely unless you're specifically curious about the
client/server sync contract the app was originally validated against
before it moved to Firebase. See `backend/README.md`.

## Google Maps — already configured, one thing to know

Both `android/app/src/main/AndroidManifest.xml` and `web/index.html`
already contain a real, working Google Maps API key (the same key value
in both places). Nothing to configure for local development or building.

**Before any public/production release**, be aware:

- The key has no application-identity restriction (no Android
  package+SHA-1 restriction, no web HTTP-referrer restriction). This is
  deliberate, not an oversight: a single key can only carry *one*
  restriction type, and this key is shared between Android and Web, which
  need different restriction types (Android-app vs. HTTP-referrer). Split
  it into two dedicated keys before locking either one down.
- Don't add an Android-app restriction to this shared key even after
  splitting, until real release signing exists (see below). The debug
  keystore that signs local/CI builds is generated **per machine** — the
  first time any Android tooling builds on a machine, a fresh
  `~/.android/debug.keystore` is created if one doesn't exist, with a
  random signature unique to that machine. Restricting the key to one
  machine's debug SHA-1 would silently break Maps for every other
  developer who clones this repo.
- The key belongs to a Google Cloud "Maps Platform" trial project with no
  billing account attached. It's realistically fine for demo/development
  traffic, but is not something to depend on for real production load.

## Android release signing — currently uses the debug key

`android/app/build.gradle.kts`'s `release` build type is explicitly
signed with the debug keystore (see the `// TODO` comment there) so that
`flutter run --release` and `flutter build apk --release` work without
any extra setup — which is exactly what this audit verified. This is
**intentional for development-stage reproducibility**, not an oversight:
generating a real release keystore now, before there's a decision about
who owns/stores it, would trade "builds on any machine" for a key that
has to be manually distributed to every contributor. Before a real Play
Store submission, generate a dedicated release keystore (`keytool`), wire
it into `signingConfigs.release`, and store the keystore + passwords
somewhere durable (losing it means losing the ability to update the app
under that Play Store listing).

The `applicationId`/`namespace` is still the Flutter default,
`com.example.taarak`. This blocks Play Store submission outright and
should be changed to a real id before release — it wasn't changed as part
of this audit because both the Firebase Android app registration and any
future Maps API key Android-app restriction would need to be updated to
match at the same time, which is a deliberate release-prep decision, not
a "fix quietly" one.

## Generated code

`lib/core/database/app_database.g.dart` (Drift's generated database code)
is committed to the repo, so `flutter analyze`/`flutter test`/`flutter
build` all work immediately after `flutter pub get` with no `build_runner`
step. This was verified directly as part of this audit (clean `flutter
clean` → `flutter pub get` → `flutter analyze`/`test`/`build`, no
generation step in between).

If you change a Drift table (anything under
`lib/core/database/tables/`), regenerate before building:

```bash
dart run build_runner build --delete-conflicting-outputs
```

`web/sqlite3.wasm` and `web/drift_worker.js` are also committed — these
are one-time manual-copy assets Drift's web backend needs and Flutter's
build does not generate them itself. They're already present; you don't
need to do anything unless you upgrade the `drift`/`sqlite3` packages to
a version that changes these files, in which case follow drift's own web
setup docs to refresh them.

## App icon

The launcher icon is generated from `assets/icon/icon_master.png` (full
icon) and `assets/icon/icon_foreground.png` (Android adaptive-icon
foreground) via `flutter_launcher_icons`. The generated per-platform icon
files are already committed; regenerate only if you change the source
images:

```bash
dart run flutter_launcher_icons
```

## Tests

```bash
flutter test
```

440 tests, all passing as of this audit. A handful of tests intentionally
exercise a "not cached locally" error path during sync — you'll see red
`CacheException` blocks scroll by in the output; that's expected logged
output from a passing test, not a failure (check the final `+401: All
tests passed!` line).

## Troubleshooting

**`flutter build apk` fails with a desugaring error mentioning
`flutter_local_notifications`** — make sure you're on a Flutter version
recent enough that `android/app/build.gradle.kts`'s
`isCoreLibraryDesugaringEnabled = true` + the `desugar_jdk_libs`
dependency actually apply; these are already in the committed Gradle
config, so this shouldn't occur on a fresh clone, but if it does, confirm
your JDK is 17+.

**Web build shows a blank map or Firebase silently doesn't initialize** —
you built without `--no-minify-js`. See the "Building" section above.

**`android/local.properties` errors ("flutter.sdk not set")** — this file
is gitignored and machine-specific by design; Flutter regenerates it
automatically on the first Android-targeted build/run. If it's somehow
missing and not regenerating, run `flutter build apk` once from a clean
checkout, or open the `android/` folder in Android Studio.

**Emulator can't load map tiles / Firestore** — check the emulator has
internet access (`adb shell ping -c1 8.8.8.8`); both Firebase and Google
Maps need real network access, there's no offline/emulated backend.

**"Authorization failure" from Google Maps on Android specifically, while
web works** — this happened once during development because the Maps API
key's project didn't have "Maps SDK for Android" enabled (a separate
toggle from "Maps JavaScript API" in Google Cloud Console) — already
fixed on the current key. If you swap in your own key, make sure both
APIs are enabled for it.

## What this audit changed

This repository was audited for clone-and-run reliability. Fixes made
(all documentation/comment corrections and repo-hygiene — no
functionality, architecture, or behavior was changed):

- Corrected several stale comments that actively contradicted the current
  state of the repo: `lib/firebase_options.dart`'s header claimed the file
  was a placeholder needing `flutterfire configure` (it isn't — it has
  real, working values); `pubspec.yaml` claimed Firebase auth was "never
  selected by default" (it's unconditional); the Google Maps key comments
  in `AndroidManifest.xml`/`web/index.html` said `REPLACE_WITH_YOUR_MAPS_API_KEY`
  next to an already-real key; a `sqlite3` comment described a manual FFI
  setup step that no longer applies (the package now resolves its native
  library automatically).
- Added a clarifying note to `backend/README.md` so a new developer
  doesn't mistake the historical stub for something the app still needs.
- Replaced this file (previously the unedited `flutter create` template)
  with real project documentation.
- Verified, with a genuinely clean local state (`flutter clean`, deleted
  `android/local.properties`, fresh `flutter pub get`), that
  `analyze`/`test`/`build web`/`build apk` all succeed with zero manual
  setup beyond the Prerequisites table above.

Known, pre-existing gaps that were deliberately **not** silently changed
(each would need an explicit decision, and changing them without one
risks breaking currently-working configuration): the Flutter-default
`applicationId`, debug-keystore release signing, and the unrestricted
shared Maps API key — all documented above with the reasoning for why
they're still the case.
