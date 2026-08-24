import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:taarak_backend/src/taarak_backend.dart';

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args.first) ?? 8080 : 8080;

  final backend = TaarakBackend();
  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(backend.handler);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

  // ignore: avoid_print
  print('TAARAK backend stub listening on http://${server.address.host}:${server.port}');
  // ignore: avoid_print
  print(
    'Point the app at this by setting AppConfig.apiBaseUrl to '
    'http://localhost:${server.port}/api and useMockAuth to false.',
  );
  // ignore: avoid_print
  print('Seeded accounts (same as the app\'s dev mock):');
  for (final account in backend.accountsByEmail.values) {
    // ignore: avoid_print
    print('  ${account.email} / ${account.password}  (${account.role})');
  }
}
