import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/location/administrative_context.dart';
import 'package:taarak/core/location/gps_fix.dart';
import 'package:taarak/core/location/location_permission_status.dart';
import 'package:taarak/core/location/location_service.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/profile/presentation/profile_screen.dart';

import '../../support/fake_secure_key_value_store.dart';

class _FakeLocationService implements LocationService {
  LocationPermissionStatus permission = LocationPermissionStatus.denied;

  @override
  Future<LocationPermissionStatus> checkPermission() async => permission;

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    permission = LocationPermissionStatus.granted;
    return permission;
  }

  @override
  Future<Result<GpsFix>> getCurrentFix() async => Result.success(
    GpsFix(
      latitude: 10.123,
      longitude: 20.456,
      accuracyMeters: 12,
      capturedAt: DateTime.now(),
    ),
  );
}

class _FixedContextResolver implements AdministrativeContextResolver {
  @override
  Future<AdministrativeContext?> resolve(
    double latitude,
    double longitude,
  ) async => const AdministrativeContext(id: 'r1', name: 'Ward 7');
}

void main() {
  testWidgets(
    'tapping refresh requests permission and shows a captured fix',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureKeyValueStoreProvider.overrideWithValue(
              FakeSecureKeyValueStore(),
            ),
            locationServiceProvider.overrideWithValue(_FakeLocationService()),
            administrativeContextResolverProvider.overrideWithValue(
              _FixedContextResolver(),
            ),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Denied'), findsOneWidget);
      expect(find.text('No location captured yet.'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Refresh location'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Granted'), findsOneWidget);
      expect(find.textContaining('Lat 10.12300'), findsOneWidget);
      expect(find.textContaining('Ward 7'), findsOneWidget);
    },
  );
}
