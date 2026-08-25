import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/app.dart';
import 'package:taarak/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On web, Flutter's service-worker bootstrap can re-run main() a second
  // time within the same page load (install-then-reload on a fresh
  // origin) — Firebase.apps.isEmpty guards against re-registering the
  // default app (and, in release builds, re-creating an already-existing
  // TrustedTypes policy, which throws and leaves the page blank).
  if (Firebase.apps.isEmpty) {
    await _initializeFirebaseWithRetry();
  }
  runApp(const ProviderScope(child: TaarakApp()));
}

/// Works around a long-standing, still-open FlutterFire web bug
/// (firebase/flutterfire#9995 and friends): in a minified release build,
/// `Firebase.initializeApp()` can lose a race against the JS-side plugin
/// registration finishing, throwing `PlatformException(channel-error,
/// ... FirebaseCoreHostApi.initializeCore ...)` and leaving the page
/// blank. It reliably succeeds a moment later once that registration
/// catches up — debug builds never hit this because they're slow enough
/// for the JS side to already be ready — so retrying with backoff is the
/// standard workaround until upstream fixes the race itself.
Future<void> _initializeFirebaseWithRetry() async {
  const maxAttempts = 5;
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      return;
    } catch (_) {
      if (attempt == maxAttempts) rethrow;
      await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
    }
  }
}
