import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taarak/features/map/domain/map_search_result.dart';
import 'package:taarak/features/map/presentation/widgets/map_search_bar.dart';

void main() {
  testWidgets('typing filters results and tapping one fires onSelect', (
    tester,
  ) async {
    MapSearchResult? selected;
    final index = const [
      MapSearchResult(label: 'Community Hall', point: LatLng(1, 1)),
      MapSearchResult(label: 'Government School', point: LatLng(2, 2)),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapSearchBar(index: index, onSelect: (r) => selected = r),
        ),
      ),
    );

    expect(find.text('Community Hall'), findsNothing);

    await tester.enterText(find.byType(TextField), 'community');
    await tester.pump();

    expect(find.text('Community Hall'), findsOneWidget);
    expect(find.text('Government School'), findsNothing);

    await tester.tap(find.text('Community Hall'));
    await tester.pump();

    expect(selected?.label, 'Community Hall');
    expect(find.text('Community Hall'), findsNothing);
  });
}
