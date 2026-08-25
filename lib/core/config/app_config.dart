import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:taarak/core/config/environment.dart';

/// Central app configuration: which backend to talk to and how patient the
/// API client should be. Backend module base URLs (Identity, Hazard, Risk,
/// ...) will hang off here as they're wired up.
class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final Duration apiTimeout;

  /// When true, auth uses an in-memory demo directory instead of a real
  /// backend. Checked before [useFirebaseAuth] — see that field for why
  /// both exist.
  final bool useMockAuth;

  /// When true, auth (and eventually sync) goes through the real, hosted
  /// Firebase project instead of [apiBaseUrl]'s never-deployed backend/
  /// stub. Only meaningful once `flutterfire configure` has generated
  /// `firebase_options.dart` and `main.dart` calls `Firebase.initializeApp`
  /// — stays false until then so the app keeps working without a Firebase
  /// project. Takes priority over [useMockAuth] when both could apply.
  final bool useFirebaseAuth;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.apiTimeout = const Duration(seconds: 20),
    this.useMockAuth = false,
    this.useFirebaseAuth = false,
  });

  factory AppConfig.development() => const AppConfig(
    environment: Environment.development,
    apiBaseUrl: 'http://localhost:8080/api',
    useMockAuth: true,
  );

  bool get isProduction => environment == Environment.production;

  /// Gates dev-only convenience affordances (e.g. the SMS/device-relay
  /// prototype screens) that should never be reachable in a real build.
  /// Tied to Flutter's actual compile-time build mode rather than
  /// [environment] — `environment` only ever gets constructed as
  /// `.development()` today (there's no real per-environment config yet),
  /// so gating on it would have shipped these into `flutter build --release`
  /// too. `kReleaseMode` is the one signal that's genuinely different
  /// between a debug run and a real release build.
  bool get isDevMode => !kReleaseMode;
}
