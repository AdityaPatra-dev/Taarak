import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/auth/data/auth_local_data_source.dart';
import 'package:taarak/features/auth/data/auth_remote_data_source.dart';
import 'package:taarak/features/auth/data/auth_repository.dart';
import 'package:taarak/features/auth/data/auth_repository_impl.dart';
import 'package:taarak/features/auth/data/dev_mock_auth_remote_data_source.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockAuth) {
    return DevMockAuthRemoteDataSource();
  }
  return ApiAuthRemoteDataSource(ref.watch(apiClientProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final source = AuthLocalDataSource(ref.watch(secureKeyValueStoreProvider));
  // The API client needs the current token on every request; binding it
  // here keeps that wiring in one place instead of scattering it across
  // every feature that eventually calls apiClientProvider.
  ref.watch(apiClientProvider).attachTokenProvider(source.readToken);
  return source;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
  );
});
