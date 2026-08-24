import 'package:latlong2/latlong.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/geometry_codec.dart';
import 'package:taarak/core/gis/point_in_polygon.dart';

const String alertModelVersion = '1.0.0';

/// M16's deterministic core: whether a broadcast is still in force, and
/// whether it targets a given location. Kept pure (no clock/IO reads) so
/// "is this alert active right now" is a testable function of ([LocalAlert],
/// now) rather than something only observable by hitting the database.
class AlertEngine {
  bool isActive(LocalAlert alert, DateTime now) {
    if (alert.cancelledAt != null) return false;
    return now.isBefore(alert.validUntil) && !now.isBefore(alert.issuedAt);
  }

  bool appliesToLocation(LocalAlert alert, LatLng point) =>
      isPointInPolygon(point, decodePolygonPoints(alert.geometryJson));

  /// Active alerts (per [isActive]) whose zone contains [point] — the
  /// citizen-facing "what applies to me right now" query.
  List<LocalAlert> activeAlertsForLocation({
    required List<LocalAlert> alerts,
    required LatLng point,
    required DateTime now,
  }) {
    return alerts
        .where((alert) => isActive(alert, now) && appliesToLocation(alert, point))
        .toList();
  }
}
