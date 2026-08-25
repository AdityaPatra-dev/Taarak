import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:taarak_backend/src/account.dart';

const _jsonHeaders = {'content-type': 'application/json'};

/// One entity the sync client has pushed, keyed by `<table>:<entityId>`.
class _SyncedEntity {
  final int version;
  final String payloadJson;
  const _SyncedEntity(this.version, this.payloadJson);
}

/// The backend stub itself: validates TAARAK's auth + sync client contract
/// end to end — see backend/README.md for what this is (and isn't) for.
///
/// Storage is in-memory and resets on restart, by design: this exists to
/// prove the wire contract the Flutter app already speaks actually works
/// against a real server, not to be a deployable, persistent service.
class TaarakBackend {
  final Map<String, Account> _accountsByEmail = {
    for (final account in seedAccounts) account.email: account,
  };
  final Map<String, String> _tokenToEmail = {};
  final Map<String, _SyncedEntity> _synced = {};

  /// Read-only views for tests.
  Map<String, Account> get accountsByEmail =>
      Map.unmodifiable(_accountsByEmail);
  Map<String, int> get syncedVersions => {
    for (final entry in _synced.entries) entry.key: entry.value.version,
  };

  Handler get handler {
    final router = Router();
    router.post('/api/auth/login', _login);
    router.post('/api/auth/register', _register);
    router.post('/api/sync/<table>', _sync);
    router.get('/api/sync/<table>', _pull);
    return router.call;
  }

  Future<Response> _login(Request request) async {
    final body = await _readJson(request);
    if (body == null) return _badRequest();

    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final account = email == null ? null : _accountsByEmail[email];

    if (account == null || account.password != password) {
      return Response(
        401,
        body: jsonEncode({'message': 'Invalid email or password'}),
        headers: _jsonHeaders,
      );
    }

    return Response.ok(
      jsonEncode(_sessionJson(account)),
      headers: _jsonHeaders,
    );
  }

  Future<Response> _register(Request request) async {
    final body = await _readJson(request);
    if (body == null) return _badRequest();

    final email = body['email'] as String?;
    final name = body['name'] as String?;
    final password = body['password'] as String?;

    if (email == null || email.isEmpty) return _badRequest();
    if (_accountsByEmail.containsKey(email)) {
      return Response(
        422,
        body: jsonEncode({
          'message': 'An account with this email already exists',
        }),
        headers: _jsonHeaders,
      );
    }

    // Public self-registration is always Citizen — same restriction the
    // Flutter app's own dev mock enforces (see DevMockAuthRemoteDataSource).
    final account = Account(
      id: email,
      name: name ?? email,
      email: email,
      password: password ?? '',
      role: 'citizen',
    );
    _accountsByEmail[email] = account;

    return Response.ok(
      jsonEncode(_sessionJson(account)),
      headers: _jsonHeaders,
    );
  }

  Map<String, dynamic> _sessionJson(Account account) {
    final token = 'server-token-${account.email}';
    _tokenToEmail[token] = account.email;
    return {'user': account.toJson(), 'token': token};
  }

  /// Version-based conflict resolution, matching what the app's own
  /// `SyncEngine.resolveConflict` already expects: a push whose payload
  /// version isn't strictly newer than what's already stored comes back
  /// as a conflict (with the server's version attached) instead of
  /// silently overwriting; a genuinely newer push is accepted.
  Future<Response> _sync(Request request, String table) async {
    final body = await _readJson(request);
    if (body == null) return _badRequest();

    final entityId = body['entityId'] as String?;
    final payloadJson = body['payload'] as String?;
    if (entityId == null || payloadJson == null) return _badRequest();

    final incomingVersion = _versionOf(payloadJson);
    final key = '$table:$entityId';
    final existing = _synced[key];

    if (existing != null && incomingVersion <= existing.version) {
      return Response.ok(
        jsonEncode({'conflict': true, 'serverVersion': existing.version}),
        headers: _jsonHeaders,
      );
    }

    _synced[key] = _SyncedEntity(incomingVersion, payloadJson);
    return Response.ok(jsonEncode({'conflict': false}), headers: _jsonHeaders);
  }

  /// The pull side of sync: every entity pushed for [table] by any
  /// device, so a second device (a different login, or a different role)
  /// can actually see what the first one created. Without this, `_sync`
  /// above only ever receives data — nothing a client pushes would ever
  /// be visible anywhere else.
  Future<Response> _pull(Request request, String table) async {
    final prefix = '$table:';
    final records = [
      for (final entry in _synced.entries)
        if (entry.key.startsWith(prefix))
          {
            'entityId': entry.key.substring(prefix.length),
            'payload': entry.value.payloadJson,
            'version': entry.value.version,
          },
    ];
    return Response.ok(jsonEncode(records), headers: _jsonHeaders);
  }

  int _versionOf(String payloadJson) {
    try {
      final decoded = jsonDecode(payloadJson);
      if (decoded is Map && decoded['version'] is int) {
        return decoded['version'] as int;
      }
    } on FormatException {
      // Not JSON, or no version field — treated as version 1 below.
    }
    return 1;
  }

  Future<Map<String, dynamic>?> _readJson(Request request) async {
    try {
      final decoded = jsonDecode(await request.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Response _badRequest() => Response(
    400,
    body: jsonEncode({'message': 'Malformed request body'}),
    headers: _jsonHeaders,
  );
}
