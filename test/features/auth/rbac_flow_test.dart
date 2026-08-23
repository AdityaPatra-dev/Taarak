import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/app/app.dart';
import 'package:taarak/core/providers/core_providers.dart';

import '../../support/fake_secure_key_value_store.dart';

Future<void> _login(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    password,
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'each role lands on Home with only its own permitted-module list',
    (tester) async {
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

      // Unauthenticated: router redirects straight to /login.
      expect(find.text('Sign in'), findsWidgets);

      await _login(tester, 'citizen@taarak.dev', 'citizen123');

      expect(find.text('Welcome, Citizen Demo'), findsOneWidget);
      expect(find.text('Send SOS / need help'), findsOneWidget);
      expect(find.text('Manage accounts'), findsNothing);
      expect(find.text('Monitor zones'), findsNothing);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsWidgets);

      await _login(tester, 'sysadmin@taarak.dev', 'sysadmin123');

      expect(find.text('Welcome, System Admin Demo'), findsOneWidget);
      expect(find.text('Manage accounts'), findsOneWidget);
      expect(find.text('Review audit log'), findsOneWidget);
      expect(find.text('Send SOS / need help'), findsNothing);
    },
  );

  testWidgets('a wrong password is rejected and keeps the user on login', (
    tester,
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

    await _login(tester, 'citizen@taarak.dev', 'not-the-password');

    expect(find.text('Invalid email or password'), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
  });
}
