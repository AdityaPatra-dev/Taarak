import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/config/app_config.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/network/api_client.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/repository/local_repository.dart';
import 'package:taarak/core/repository/result.dart';

/// In-memory stand-in for a real M03 local database, just to prove the
/// [LocalRepository] contract is usable end to end.
class _InMemoryNoteRepository implements LocalRepository<String, int> {
  final Map<int, String> _store = {};

  @override
  Future<Result<String>> save(String item) async {
    final id = _store.length;
    _store[id] = item;
    return Result.success(item);
  }

  @override
  Future<Result<String>> getById(int id) async {
    final value = _store[id];
    if (value == null) return const Result.failure(CacheFailure('missing'));
    return Result.success(value);
  }

  @override
  Future<Result<List<String>>> getAll() async =>
      Result.success(_store.values.toList());

  @override
  Future<Result<void>> delete(int id) async {
    _store.remove(id);
    return const Result.success(null);
  }
}

class _AlwaysOffline implements NetworkInfo {
  @override
  Future<bool> get isConnected async => false;

  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();
}

void main() {
  group('LocalRepository (offline data path)', () {
    test('saves and reads data, including after a fresh instance', () async {
      final repo = _InMemoryNoteRepository();

      final saveResult = await repo.save('landslide near Habitation 12');
      expect(saveResult.isSuccess, isTrue);

      final allResult = await repo.getAll();
      expect(
        allResult.dataOrNull,
        contains('landslide near Habitation 12'),
      );

      final byIdResult = await repo.getById(0);
      expect(byIdResult, isA<Success<String>>());
    });

    test('missing entries surface as a CacheFailure, not an exception', () async {
      final repo = _InMemoryNoteRepository();

      final result = await repo.getById(99);

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('expected failure'),
        failure: (failure) => expect(failure, isA<CacheFailure>()),
      );
    });
  });

  group('ApiClient (remote data path)', () {
    test('without connectivity, requests fail fast with NetworkFailure', () async {
      final client = ApiClient(
        config: AppConfig.development(),
        networkInfo: _AlwaysOffline(),
      );

      final result = await client.get<String>(
        '/hazards',
        parser: (json) => json as String,
      );

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('expected failure while offline'),
        failure: (failure) => expect(failure, isA<NetworkFailure>()),
      );
    });
  });
}
