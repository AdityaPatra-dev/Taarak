import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key/value storage for security-sensitive data such as the auth
/// session token — separate from the general local database (M03), which
/// isn't encrypted by default and is meant for bulk entity caching rather
/// than credentials. Abstracted so tests can swap in an in-memory fake
/// instead of hitting the platform keychain/keystore.
abstract class SecureKeyValueStore {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);
}

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  final FlutterSecureStorage _storage;

  const FlutterSecureKeyValueStore([
    this._storage = const FlutterSecureStorage(),
  ]);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
