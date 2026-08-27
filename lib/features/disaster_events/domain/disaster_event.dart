/// The categories a [DisasterEvent] can carry. Deliberately not tied to
/// one transport (SMS, a government bulletin, a future satellite feed) —
/// whatever channel an event arrives through, it becomes one of these
/// before anything downstream (hazard ingestion, alerts, routing) sees it.
enum DisasterEventType {
  heavyRainfall,
  riverRise,
  landslide,
  roadBlocked,
  evacuationOrder,
  shelterUpdate,
  governmentAlert,
}

/// The envelope every external signal — today just a manually-pasted
/// government alert, later SMS or a store-and-forward relay — is
/// normalized into before it touches any existing service. Intentionally
/// thin: this is not a new source of truth or a new synced table, it's a
/// structured handoff to whichever *existing* pipeline actually owns the
/// data (hazard ingestion, alert broadcasting, ...) — see
/// [DisasterEventProcessor]. Confidence and provenance exist so an event
/// this app didn't originate itself is never silently treated as
/// equal-weight to an official's own direct entry.
class DisasterEvent {
  final String id;
  final DisasterEventType type;
  final String source;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;

  /// One of the same low/medium/high/critical vocabulary
  /// [HazardSeverity]/[severityColor] already use across the app.
  final String severity;

  /// Whatever structured fields the event carries beyond the common
  /// envelope (e.g. `{'rainfall24hMm': 180, 'riverName': 'Teesta'}') —
  /// deliberately a loose map rather than one rigid schema, since
  /// different event types carry genuinely different data.
  final Map<String, dynamic> payload;

  final double confidence;
  final String? provenanceNote;

  const DisasterEvent({
    required this.id,
    required this.type,
    required this.source,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.severity = 'medium',
    this.payload = const {},
    this.confidence = 0.7,
    this.provenanceNote,
  });
}
