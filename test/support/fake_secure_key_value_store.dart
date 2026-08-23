import 'package:taarak/core/storage/secure_key_value_store.dart';

/// In-memory stand-in for the platform keychain/keystore, so tests never
/// touch `flutter_secure_storage`'s method channel.
class FakeSecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }
}
