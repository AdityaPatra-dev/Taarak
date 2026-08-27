/// A System Admin's ([Permission.manageTechnicalConfiguration]) operational
/// knobs — distinct from [AppPolicy]'s domain policy values (alert
/// validity, hazard radius): this is app *mechanics*, not disaster-response
/// rules, so it deliberately stays separate from `config/policy`. Starts
/// with the one concretely hardcoded operational value in the app: how
/// often [syncPollingTriggerProvider] polls for updates.
class TechnicalConfig {
  final int syncIntervalSeconds;

  const TechnicalConfig({required this.syncIntervalSeconds});

  static const defaults = TechnicalConfig(syncIntervalSeconds: 45);

  static const minSyncIntervalSeconds = 15;
  static const maxSyncIntervalSeconds = 600;

  factory TechnicalConfig.fromFirestore(Map<String, dynamic> data) {
    final seconds = (data['syncIntervalSeconds'] as num?)?.toInt();
    if (seconds == null ||
        seconds < minSyncIntervalSeconds ||
        seconds > maxSyncIntervalSeconds) {
      return defaults;
    }
    return TechnicalConfig(syncIntervalSeconds: seconds);
  }

  Map<String, dynamic> toFirestore() => {
    'syncIntervalSeconds': syncIntervalSeconds,
  };
}
