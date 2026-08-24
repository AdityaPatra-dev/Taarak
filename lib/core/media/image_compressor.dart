import 'package:taarak/core/media/compressed_image.dart';

/// Abstracts image resize/re-encode behind our own interface — same
/// reasoning as [[LocationService]]/[[MediaPickerService]]: keeps the
/// underlying codec swappable and lets tests fake it without touching real
/// files. M21's whole point is that this runs *before* a photo is queued
/// for upload, so a slow/expensive connection only ever sends the smaller
/// version.
abstract class ImageCompressor {
  /// Resizes [sourcePath] so its longest side is at most [maxDimension]
  /// pixels (aspect ratio preserved, never upscaled) and re-encodes it as
  /// JPEG at [quality] (0-100). Throws if [sourcePath] can't be read or
  /// decoded as an image — callers must decide whether that should block
  /// the caller's own operation or just be logged and skipped.
  Future<CompressedImage> compress(
    String sourcePath, {
    int maxDimension = 1024,
    int quality = 60,
  });
}
