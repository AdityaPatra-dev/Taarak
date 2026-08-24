import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/map/presentation/widgets/map_legend.dart';

void main() {
  testWidgets('starts collapsed to a small chip, not covering the map', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MapLegend())),
    );

    expect(find.text('Legend'), findsOneWidget);
    expect(find.text('High hazard'), findsNothing);
  });

  testWidgets('expands to list every layer type the map can render', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MapLegend())),
    );

    await tester.tap(find.text('Legend'));
    await tester.pump();

    expect(find.text('High hazard'), findsOneWidget);
    expect(find.text('Shelter'), findsOneWidget);
    expect(find.text('Incident'), findsOneWidget);
    expect(find.text('Blocked road'), findsOneWidget);
  });

  testWidgets('can be collapsed again after expanding', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MapLegend())),
    );

    await tester.tap(find.text('Legend'));
    await tester.pump();
    expect(find.text('High hazard'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(find.text('High hazard'), findsNothing);
  });
}
