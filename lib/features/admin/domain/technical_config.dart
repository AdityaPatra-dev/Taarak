/// A System Admin's ([Permission.manageTechnicalConfiguration]) operational
/// knobs — distinct from [AppPolicy]'s domain policy values (alert
/// validity, hazard radius): this is app *mechanics*, not disaster-response
/// rules, so it deliberately stays separate from `config/policy`. Starts
/// with the one concretely hardcoded operational value in the app: how
/// often [syncPollingTriggerProvider] polls for updates.
class TechnicalConfig {
  final int syncIntervalSeconds;

  /// How often [[hazardAutomationTriggerProvider]] re-evaluates every
  /// habitation against live weather data. Deliberately much coarser than
  /// [syncIntervalSeconds] — Open-Meteo's own data only updates
  /// hourly/daily, so polling faster than that is wasted traffic.
  final int hazardAutomationPollIntervalSeconds;

  /// Explicit System Admin opt-in for the Gemini enrichment tier — off by
  /// default even when a key is compiled in ([GeminiConfig.isConfigured]),
  /// and a runtime kill-switch if the embedded key is ever abused, since
  /// disabling it here needs no rebuild.
  final bool geminiEnabled;

  const TechnicalConfig({
    required this.syncIntervalSeconds,
    this.hazardAutomationPollIntervalSeconds = 1800,
    this.geminiEnabled = false,
  });

  static const defaults = TechnicalConfig(syncIntervalSeconds: 45);

  static const minSyncIntervalSeconds = 15;
  static const maxSyncIntervalSeconds = 600;

  static const minHazardAutomationPollIntervalSeconds = 600;
  static const maxHazardAutomationPollIntervalSeconds = 21600;

  TechnicalConfig copyWith({
    int? syncIntervalSeconds,
    int? hazardAutomationPollIntervalSeconds,
    bool? geminiEnabled,
  }) => TechnicalConfig(
    syncIntervalSeconds: syncIntervalSeconds ?? this.syncIntervalSeconds,
    hazardAutomationPollIntervalSeconds:
        hazardAutomationPollIntervalSeconds ?? this.hazardAutomationPollIntervalSeconds,
    geminiEnabled: geminiEnabled ?? this.geminiEnabled,
  );

  factory TechnicalConfig.fromFirestore(Map<String, dynamic> data) {
    final seconds = (data['syncIntervalSeconds'] as num?)?.toInt();
    final validSyncInterval =
        seconds == null || seconds < minSyncIntervalSeconds || seconds > maxSyncIntervalSeconds
        ? defaults.syncIntervalSeconds
        : seconds;

    final hazardPollSeconds = (data['hazardAutomationPollIntervalSeconds'] as num?)?.toInt();
    final validHazardPollInterval =
        hazardPollSeconds == null ||
            hazardPollSeconds < minHazardAutomationPollIntervalSeconds ||
            hazardPollSeconds > maxHazardAutomationPollIntervalSeconds
        ? defaults.hazardAutomationPollIntervalSeconds
        : hazardPollSeconds;

    return TechnicalConfig(
      syncIntervalSeconds: validSyncInterval,
      hazardAutomationPollIntervalSeconds: validHazardPollInterval,
      geminiEnabled: data['geminiEnabled'] as bool? ?? defaults.geminiEnabled,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'syncIntervalSeconds': syncIntervalSeconds,
    'hazardAutomationPollIntervalSeconds': hazardAutomationPollIntervalSeconds,
    'geminiEnabled': geminiEnabled,
  };
}
