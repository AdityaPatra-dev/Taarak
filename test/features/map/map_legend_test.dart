import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/map/presentation/widgets/map_legend.dart';

void main() {
  testWidgets('lists every layer type the map can render', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MapLegend())),
    );

    expect(find.text('High hazard'), findsOneWidget);
    expect(find.text('Shelter'), findsOneWidget);
    expect(find.text('Incident'), findsOneWidget);
    expect(find.text('Blocked road'), findsOneWidget);
  });
}
