import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:taarak/core/media/compressed_image.dart';
import 'package:taarak/core/media/image_compressor.dart';

/// Real [ImageCompressor], built on the pure-Dart `image` package so it
/// works identically on every platform this app targets (including web)
/// without a native codec dependency.
class PackageImageCompressor implements ImageCompressor {
  @override
  Future<CompressedImage> compress(
    String sourcePath, {
    int maxDimension = 1024,
    int quality = 60,
  }) async {
    final sourceFile = File(sourcePath);
    final originalBytes = await sourceFile.readAsBytes();

    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) {
      throw FormatException('Could not decode image at $sourcePath');
    }

    final longestSide = decoded.width > decoded.height ? decoded.width : decoded.height;
    final resized = longestSide > maxDimension
        ? img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? maxDimension : null,
            height: decoded.height > decoded.width ? maxDimension : null,
          )
        : decoded;

    final compressedBytes = img.encodeJpg(resized, quality: quality);

    // Written alongside the source file rather than to a resolved
    // platform cache dir — keeps this compressor free of a platform-
    // channel dependency, so it behaves identically under `flutter test`.
    final outputPath = p.join(
      p.dirname(sourcePath),
      '${p.basenameWithoutExtension(sourcePath)}_compressed.jpg',
    );
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(compressedBytes);

    return CompressedImage(
      path: outputPath,
      originalSizeBytes: originalBytes.length,
      compressedSizeBytes: compressedBytes.length,
    );
  }
}
