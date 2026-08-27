import 'package:latlong2/latlong.dart';
import 'package:taarak/core/gis/circle_geometry.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/disaster_events/domain/disaster_event.dart';
import 'package:taarak/features/hazards/application/hazard_ingestion_service.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';

/// Default footprint drawn around a [DisasterEvent]'s single point when it
/// doesn't carry its own boundary — deliberately conservative (a real
/// landslide/flood observation entered by an official through the existing
/// hazard-report screen draws an actual boundary and is more precise than
/// this). This is a fallback for signals that only ever carry a point.
const double _defaultEventRadiusMeters = 500;

/// Routes a [DisasterEvent] into whichever *existing* pipeline actually
/// owns its kind of data — this class deliberately owns no storage and no
/// business rules of its own, matching Rule 3 (reuse existing
/// providers/services) and the spec's own instruction that the important
/// part is a shared entry point, not a new subsystem.
///
/// Only event types that already map cleanly onto a hazard zone
/// (landslide, riverRise → flood) are actually ingested. Everything else
/// is left as an honest "not yet wired" case rather than being forced
/// through a pipeline that doesn't fit it — see [DisasterEventProcessingOutcome].
/// In particular [DisasterEventType.heavyRainfall] is NOT auto-converted
/// into a hazard zone: rainfall alone describes weather, not a bounded
/// affected area, and inventing a polygon from it would be exactly the
/// kind of fabricated-looking data Rule 7 rules out. Rainfall belongs to
/// the existing [EnvironmentalRiskEngine]/[OpenMeteoDataSource] signal
/// path, not hazard ingestion.
class DisasterEventProcessor {
  final HazardIngestionService _hazardIngestionService;

  DisasterEventProcessor({required HazardIngestionService hazardIngestionService})
    : _hazardIngestionService = hazardIngestionService;

  Future<DisasterEventProcessingOutcome> process(
    DisasterEvent event, {
    DateTime? now,
  }) async {
    final hazardType = switch (event.type) {
      DisasterEventType.landslide => 'landslide',
      DisasterEventType.riverRise => 'flood',
      _ => null,
    };

    if (hazardType == null) {
      return DisasterEventProcessingOutcome.notActionable(
        'Event type "${event.type.name}" has no existing pipeline wired '
        'to it yet — recorded but not acted on.',
      );
    }

    final latitude = event.latitude;
    final longitude = event.longitude;
    if (latitude == null || longitude == null) {
      return DisasterEventProcessingOutcome.notActionable(
        'Event carries no coordinates — a human must confirm a location '
        'on the map before this can become a hazard zone.',
      );
    }

    final severityScore = _severityToScore(event.severity);
    final boundary = circlePolygonPoints(
      LatLng(latitude, longitude),
      _defaultEventRadiusMeters,
    );

    final ingestResult = await _hazardIngestionService.ingest(
      id: event.id,
      observation: RawHazardObservation(
        hazardType: hazardType,
        severityScore: severityScore,
        boundaryPoints: boundary,
        source: event.source,
        observedAt: event.timestamp,
        sourceConfidence: event.confidence,
      ),
      now: now,
    );

    return switch (ingestResult) {
      Success() => DisasterEventProcessingOutcome.ingestedAsHazardZone(),
      Failed(:final failure) => DisasterEventProcessingOutcome.rejected(
        failure.message,
      ),
    };
  }

  double _severityToScore(String severity) => switch (severity) {
    'critical' => 1.0,
    'high' => 0.75,
    'medium' => 0.5,
    'low' => 0.25,
    _ => 0.5,
  };
}

enum DisasterEventProcessingStatus { ingestedAsHazardZone, notActionable, rejected }

/// What actually happened to one [DisasterEvent] — never silently dropped.
/// A caller (e.g. a simulation-import screen) uses this to tell an
/// official plainly what did or didn't happen, rather than assuming
/// success.
class DisasterEventProcessingOutcome {
  final DisasterEventProcessingStatus status;
  final String? detail;

  const DisasterEventProcessingOutcome._(this.status, this.detail);

  factory DisasterEventProcessingOutcome.ingestedAsHazardZone() =>
      const DisasterEventProcessingOutcome._(
        DisasterEventProcessingStatus.ingestedAsHazardZone,
        null,
      );

  factory DisasterEventProcessingOutcome.notActionable(String detail) =>
      DisasterEventProcessingOutcome._(
        DisasterEventProcessingStatus.notActionable,
        detail,
      );

  factory DisasterEventProcessingOutcome.rejected(String detail) =>
      DisasterEventProcessingOutcome._(
        DisasterEventProcessingStatus.rejected,
        detail,
      );
}
