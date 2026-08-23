import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/gis/geometry_codec.dart';

void main() {
  test('encoding then decoding a polygon round-trips the points', () {
    const points = [LatLng(12.9, 77.5), LatLng(12.91, 77.51), LatLng(12.92, 77.5)];

    final json = encodePolygonPoints(points);
    final decoded = decodePolygonPoints(json);

    expect(decoded, points);
  });

  test('decoding malformed geometry returns an empty list instead of throwing', () {
    expect(decodePolygonPoints('not json'), isEmpty);
    expect(decodePolygonPoints('{"not":"a list"}'), isEmpty);
    expect(decodePolygonPoints('[[1]]'), isEmpty);
  });
}
