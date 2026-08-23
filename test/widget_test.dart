import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taarak/app/app.dart';
import 'package:taarak/core/providers/core_providers.dart';

import 'support/fake_secure_key_value_store.dart';

void main() {
  testWidgets('App shell boots and, unauthenticated, lands on Sign in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(
            FakeSecureKeyValueStore(),
          ),
        ],
        child: const TaarakApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
  });
}
