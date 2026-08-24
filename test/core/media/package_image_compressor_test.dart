import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:taarak/core/media/package_image_compressor.dart';

void main() {
  late Directory tempDir;
  late String sourcePath;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('taarak_image_compressor_test');

    // A real, largish synthetic photo — not a mock — so compression is
    // genuinely exercised, not just asserted against a canned result.
    final source = img.Image(width: 2000, height: 1200);
    img.fill(source, color: img.ColorRgb8(120, 180, 90));
    for (var x = 0; x < source.width; x += 40) {
      img.drawLine(
        source,
        x1: x,
        y1: 0,
        x2: x,
        y2: source.height - 1,
        color: img.ColorRgb8(20, 40, 200),
      );
    }

    sourcePath = '${tempDir.path}${Platform.pathSeparator}source.jpg';
    File(sourcePath).writeAsBytesSync(img.encodeJpg(source, quality: 95));
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test(
    'CRITICAL TEXT/GPS CAN SYNC EVEN IF MEDIA FAILS — the compression half: an '
    'oversized photo is actually resized and shrunk, not just relabeled',
    () async {
      final compressor = PackageImageCompressor();

      final result = await compressor.compress(
        sourcePath,
        maxDimension: 800,
        quality: 60,
      );

      expect(File(result.path).existsSync(), isTrue);
      expect(result.compressedSizeBytes, lessThan(result.originalSizeBytes));

      final decodedOutput = img.decodeImage(File(result.path).readAsBytesSync())!;
      final longestSide = decodedOutput.width > decodedOutput.height
          ? decodedOutput.width
          : decodedOutput.height;
      expect(longestSide, lessThanOrEqualTo(800));

      // Aspect ratio (5:3 for the 2000x1200 source) is preserved, not distorted.
      expect(
        decodedOutput.width / decodedOutput.height,
        closeTo(2000 / 1200, 0.02),
      );
    },
  );

  test('an image already smaller than maxDimension is not upscaled', () async {
    final small = img.Image(width: 200, height: 150);
    img.fill(small, color: img.ColorRgb8(10, 10, 10));
    final smallPath = '${tempDir.path}${Platform.pathSeparator}small.jpg';
    File(smallPath).writeAsBytesSync(img.encodeJpg(small, quality: 90));

    final compressor = PackageImageCompressor();
    final result = await compressor.compress(smallPath, maxDimension: 800);

    final decodedOutput = img.decodeImage(File(result.path).readAsBytesSync())!;
    expect(decodedOutput.width, 200);
    expect(decodedOutput.height, 150);
  });

  test('an unreadable path throws rather than silently producing garbage', () async {
    final compressor = PackageImageCompressor();
    expect(
      () => compressor.compress('${tempDir.path}/does-not-exist.jpg'),
      throwsA(anything),
    );
  });
}
