import 'package:latlong2/latlong.dart';

/// Used only when no real GPS fix is available yet (permission not
/// granted, or still resolving) — geographic center of India, shown
/// zoomed out, so the map never pretends to know where the user actually
/// is. Every map screen should prefer the user's real cached location
/// ([LocationStatus.geoTag]) over this.
const LatLng defaultMapCenter = LatLng(20.5937, 78.9629);
const double defaultMapZoom = 5;
