import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/core/gis/point_in_polygon.dart';

void main() {
  final square = [
    const LatLng(0, 0),
    const LatLng(0, 10),
    const LatLng(10, 10),
    const LatLng(10, 0),
  ];

  test('a point inside the polygon is detected', () {
    expect(isPointInPolygon(const LatLng(5, 5), square), isTrue);
  });

  test('a point outside the polygon is not detected', () {
    expect(isPointInPolygon(const LatLng(50, 50), square), isFalse);
  });

  test('fewer than 3 points can never contain a point', () {
    expect(isPointInPolygon(const LatLng(0, 0), const [LatLng(0, 0), LatLng(1, 1)]), isFalse);
  });
}
