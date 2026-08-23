import 'package:taarak/core/config/environment.dart';

/// Central app configuration: which backend to talk to and how patient the
/// API client should be. Backend module base URLs (Identity, Hazard, Risk,
/// ...) will hang off here as they're wired up.
class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final Duration apiTimeout;

  /// When true, auth uses an in-memory demo directory instead of the real
  /// Identity backend (blueprint section 7), which doesn't exist yet. Flip
  /// to false once that service is reachable at [apiBaseUrl].
  final bool useMockAuth;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.apiTimeout = const Duration(seconds: 20),
    this.useMockAuth = false,
  });

  factory AppConfig.development() => const AppConfig(
    environment: Environment.development,
    apiBaseUrl: 'http://localhost:8080/api',
    useMockAuth: true,
  );

  bool get isProduction => environment == Environment.production;
}
