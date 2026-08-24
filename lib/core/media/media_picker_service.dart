enum MediaPickerSource { camera, gallery }

/// Abstracts photo attachment behind our own interface rather than calling
/// `image_picker` directly from feature code — same reasoning as
/// [[LocationService]]/[[NetworkInfo]]: keeps the plugin swappable and
/// lets tests fake it. M21 (low-bandwidth media) will build compression/
/// upload-priority on top of whatever this returns, not replace it.
abstract class MediaPickerService {
  /// Returns the local file path of the picked photo, or null if the
  /// citizen cancelled.
  Future<String?> pickPhoto({required MediaPickerSource source});
}
