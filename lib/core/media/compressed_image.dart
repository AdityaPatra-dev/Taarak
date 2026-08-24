/// Result of [ImageCompressor.compress]: a new file, distinct from the
/// original, plus the before/after sizes so a caller can decide whether
/// the compression was worth queuing (or just log the savings).
class CompressedImage {
  final String path;
  final int originalSizeBytes;
  final int compressedSizeBytes;

  const CompressedImage({
    required this.path,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
  });
}
