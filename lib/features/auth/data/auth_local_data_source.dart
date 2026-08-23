import 'dart:convert';

import 'package:taarak/core/storage/secure_key_value_store.dart';
import 'package:taarak/features/auth/domain/auth_session.dart';

/// Persists the current device's session so login survives an app restart.
/// Deliberately separate from the general local database (M03): a session
/// token is a credential and always belongs in encrypted storage,
/// regardless of what technology the bulk entity cache ends up using.
class AuthLocalDataSource {
  static const _sessionKey = 'taarak.auth.session';

  final SecureKeyValueStore _store;

  AuthLocalDataSource(this._store);

  Future<void> saveSession(AuthSession session) =>
      _store.write(_sessionKey, jsonEncode(session.toJson()));

  Future<AuthSession?> readSession() async {
    final raw = await _store.read(_sessionKey);
    if (raw == null) return null;
    try {
      return AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  Future<String?> readToken() async => (await readSession())?.token;

  Future<void> clearSession() => _store.delete(_sessionKey);
}
