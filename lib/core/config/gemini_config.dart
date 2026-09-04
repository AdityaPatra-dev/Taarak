/// Compile-time Gemini API key, supplied via `--dart-define-from-file=env.json`
/// (see env.json.example at the repo root) — never hardcoded into source,
/// unlike the Google Maps key this app already ships with (see the map
/// module's README notes on that key needing rotation before a real
/// release). This still ends up embedded in the compiled binary and is
/// extractable by decompiling it — the properly secure fix is a backend
/// proxy holding the key server-side, which this app doesn't have. Treat
/// this as a pragmatic, not a final, answer to key handling.
class GeminiConfig {
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static bool get isConfigured => apiKey.isNotEmpty;
}
