/// Our own simplified permission states, kept separate from geolocator's
/// `LocationPermission` enum so the rest of the app never depends on that
/// package's types directly — only [[GeolocatorLocationService]] does.
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}
