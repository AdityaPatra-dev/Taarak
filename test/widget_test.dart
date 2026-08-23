import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taarak/app/app.dart';

void main() {
  testWidgets('App shell boots and shows the foundation home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TaarakApp()));
    await tester.pumpAndSettle();

    expect(find.text('TAARAK'), findsOneWidget);
    expect(
      find.text('Foundation ready — role-based screens land in M02+'),
      findsOneWidget,
    );
  });
}
