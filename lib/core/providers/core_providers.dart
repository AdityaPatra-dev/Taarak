import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/config/app_config.dart';
import 'package:taarak/core/network/api_client.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/storage/secure_key_value_store.dart';

/// Cross-cutting wiring shared by every feature. Feature-specific providers
/// (auth, hazards, incidents, ...) build on top of these.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.development());

final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    config: ref.watch(appConfigProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final secureKeyValueStoreProvider = Provider<SecureKeyValueStore>(
  (ref) => const FlutterSecureKeyValueStore(),
);
