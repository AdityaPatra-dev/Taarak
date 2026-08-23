import 'package:taarak/core/config/environment.dart';

/// Central app configuration: which backend to talk to and how patient the
/// API client should be. Backend module base URLs (Identity, Hazard, Risk,
/// ...) will hang off here as they're wired up.
class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final Duration apiTimeout;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.apiTimeout = const Duration(seconds: 20),
  });

  factory AppConfig.development() => const AppConfig(
    environment: Environment.development,
    apiBaseUrl: 'http://localhost:8080/api',
  );

  bool get isProduction => environment == Environment.production;
}
