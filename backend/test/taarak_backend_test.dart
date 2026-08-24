import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:taarak_backend/src/taarak_backend.dart';
import 'package:test/test.dart';

Request _post(String path, Map<String, dynamic> body) => Request(
  'POST',
  Uri.parse('http://localhost$path'),
  body: jsonEncode(body),
  headers: const {'content-type': 'application/json'},
);

Future<Map<String, dynamic>> _bodyOf(Response response) async {
  final raw = await response.readAsString();
  return jsonDecode(raw) as Map<String, dynamic>;
}

void main() {
  late TaarakBackend backend;

  setUp(() => backend = TaarakBackend());

  group('POST /api/auth/login', () {
    test(
      'INTRODUCE GENUINE BACKEND CONNECTIVITY — the acceptance criterion: a seeded '
      'demo account logs in and gets a session matching AuthSession.fromJson',
      () async {
        final response = await backend.handler(
          _post('/api/auth/login', {'email': 'citizen@taarak.dev', 'password': 'citizen123'}),
        );

        expect(response.statusCode, 200);
        final body = await _bodyOf(response);
        expect(body['token'], isNotEmpty);
        expect(body['user']['email'], 'citizen@taarak.dev');
        expect(body['user']['role'], 'citizen');
        expect(body['user']['id'], isNotEmpty);
        expect(body['user']['name'], isNotEmpty);
      },
    );

    test('a wrong password is rejected with 401', () async {
      final response = await backend.handler(
        _post('/api/auth/login', {'email': 'citizen@taarak.dev', 'password': 'wrong'}),
      );
      expect(response.statusCode, 401);
    });

    test('an unknown email is rejected with 401, not a different error', () async {
      final response = await backend.handler(
        _post('/api/auth/login', {'email': 'nobody@taarak.dev', 'password': 'anything'}),
      );
      expect(response.statusCode, 401);
    });

    test('every seeded role can log in with its documented credentials', () async {
      final roleCredentials = {
        'citizen@taarak.dev': 'citizen123',
        'responder@taarak.dev': 'responder123',
        'official@taarak.dev': 'official123',
        'command@taarak.dev': 'command123',
        'stateadmin@taarak.dev': 'stateadmin123',
        'sysadmin@taarak.dev': 'sysadmin123',
      };
      for (final entry in roleCredentials.entries) {
        final response = await backend.handler(
          _post('/api/auth/login', {'email': entry.key, 'password': entry.value}),
        );
        expect(response.statusCode, 200, reason: '${entry.key} should log in');
      }
    });
  });

  group('POST /api/auth/register', () {
    test('a new email registers as a citizen and can then log in', () async {
      final registerResponse = await backend.handler(
        _post('/api/auth/register', {
          'name': 'New Citizen',
          'email': 'new@taarak.dev',
          'password': 'password123',
        }),
      );
      expect(registerResponse.statusCode, 200);
      final body = await _bodyOf(registerResponse);
      expect(body['user']['role'], 'citizen');

      final loginResponse = await backend.handler(
        _post('/api/auth/login', {'email': 'new@taarak.dev', 'password': 'password123'}),
      );
      expect(loginResponse.statusCode, 200);
    });

    test('registering an already-used email fails with 422', () async {
      final response = await backend.handler(
        _post('/api/auth/register', {
          'name': 'Duplicate',
          'email': 'citizen@taarak.dev',
          'password': 'whatever',
        }),
      );
      expect(response.statusCode, 422);
    });
  });

  group('POST /api/sync/<table>', () {
    test('a brand-new entity is accepted with no conflict', () async {
      final response = await backend.handler(
        _post('/api/sync/local_incident_reports', {
          'entityId': 'report-1',
          'operation': 'create',
          'payload': jsonEncode({'id': 'report-1', 'version': 1}),
        }),
      );

      expect(response.statusCode, 200);
      expect((await _bodyOf(response))['conflict'], false);
      expect(backend.syncedVersions['local_incident_reports:report-1'], 1);
    });

    test(
      'INTRODUCE GENUINE BACKEND CONNECTIVITY — the acceptance criterion: pushing a '
      'strictly newer version is accepted and overwrites the stored one',
      () async {
        await backend.handler(
          _post('/api/sync/local_incident_reports', {
            'entityId': 'report-1',
            'operation': 'create',
            'payload': jsonEncode({'id': 'report-1', 'version': 1}),
          }),
        );

        final response = await backend.handler(
          _post('/api/sync/local_incident_reports', {
            'entityId': 'report-1',
            'operation': 'update',
            'payload': jsonEncode({'id': 'report-1', 'version': 2}),
          }),
        );

        expect((await _bodyOf(response))['conflict'], false);
        expect(backend.syncedVersions['local_incident_reports:report-1'], 2);
      },
    );

    test(
      'pushing a version that is not strictly newer than what is stored is a '
      'conflict, and does not overwrite the stored data',
      () async {
        await backend.handler(
          _post('/api/sync/local_incident_reports', {
            'entityId': 'report-1',
            'operation': 'create',
            'payload': jsonEncode({'id': 'report-1', 'version': 3}),
          }),
        );

        final response = await backend.handler(
          _post('/api/sync/local_incident_reports', {
            'entityId': 'report-1',
            'operation': 'update',
            'payload': jsonEncode({'id': 'report-1', 'version': 2}),
          }),
        );

        final body = await _bodyOf(response);
        expect(body['conflict'], true);
        expect(body['serverVersion'], 3);
        expect(backend.syncedVersions['local_incident_reports:report-1'], 3); // unchanged
      },
    );

    test('a payload with no version field is treated as version 1', () async {
      final response = await backend.handler(
        _post('/api/sync/local_shelters', {
          'entityId': 'shelter-1',
          'operation': 'create',
          'payload': jsonEncode({'id': 'shelter-1'}),
        }),
      );

      expect((await _bodyOf(response))['conflict'], false);
      expect(backend.syncedVersions['local_shelters:shelter-1'], 1);
    });

    test('different tables with the same entityId are tracked independently', () async {
      await backend.handler(
        _post('/api/sync/local_incidents', {
          'entityId': 'x1',
          'operation': 'create',
          'payload': jsonEncode({'version': 5}),
        }),
      );
      await backend.handler(
        _post('/api/sync/local_alerts', {
          'entityId': 'x1',
          'operation': 'create',
          'payload': jsonEncode({'version': 1}),
        }),
      );

      expect(backend.syncedVersions['local_incidents:x1'], 5);
      expect(backend.syncedVersions['local_alerts:x1'], 1);
    });
  });
}
