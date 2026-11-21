// Dev-only mock GI Core (plan §17.1): a shelf server that answers the
// catalog endpoints (GiEndpoints.all) from the recorded fixtures, with a
// minimal in-memory login, refresh-cookie rotation, me and profile.
//
//   dart run tools/mock_core/bin/mock_core.dart [--port 3100]
//       [--host 127.0.0.1] [--fixtures-ref <shortSha>] [--password <pw>]
//
// Android emulator: http://10.0.2.2:3100 in the dev flavor. Not for tests of
// the app (they use the in-process MockCoreAdapter) and never for release.
import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:gi_tools/mock_core.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('port', defaultsTo: '3100', help: 'Port to listen on.')
    ..addOption(
      'host',
      defaultsTo: '127.0.0.1',
      help:
          'Address to bind (127.0.0.1 is enough for the Android emulator '
          'and the iOS simulator; 0.0.0.0 for a phone in the LAN).',
    )
    ..addOption(
      'fixtures-ref',
      help:
          'Backend ref folder under packages/gi_core_api/test/fixtures/core '
          '(default: shortSha of contract/backend.lock, else the newest).',
    )
    ..addOption(
      'password',
      help: 'Only accept this password at login (default: any).',
    )
    ..addOption(
      'access-ttl',
      defaultsTo: '900',
      help:
          'Access token lifetime in seconds (short values exercise the '
          "app's refresh).",
    )
    ..addFlag(
      'fresh-last-seen',
      defaultsTo: true,
      help: "Report the devices' lastSeenAt as the request time.",
    )
    ..addFlag('quiet', abbr: 'q', negatable: false, help: 'No request log.')
    ..addFlag('help', abbr: 'h', negatable: false);

  final ArgResults options;
  final int port;
  final int ttl;
  try {
    options = parser.parse(args);
    port = int.parse(options.option('port')!);
    ttl = int.parse(options.option('access-ttl')!);
  } on FormatException catch (e) {
    stderr.writeln('${e.message}\n\n${parser.usage}');
    exit(64);
  }
  if (options.flag('help')) {
    print(
      'Usage: dart run tools/mock_core/bin/mock_core.dart [options]\n\n'
      '${parser.usage}',
    );
    return;
  }

  final root = findRepoRoot();
  final fixturesDir = resolveFixturesDir(
    fixturesRoot(root),
    options.option('fixtures-ref') ?? readBackendRef(root),
  );
  final core = MockCore(
    fixtures: MockCoreFixtures.load(fixturesDir),
    password: options.option('password'),
    accessTokenTtl: Duration(seconds: ttl),
    freshLastSeen: options.flag('fresh-last-seen'),
  );
  final MockCoreServer server;
  try {
    server = await MockCoreServer.start(
      core: core,
      host: options.option('host')!,
      port: port,
      log: options.flag('quiet') ? null : print,
    );
  } on SocketException catch (e) {
    stderr.writeln('Cannot listen on ${options.option('host')}:$port: $e');
    exit(1);
  }
  print(
    'mock_core: ${server.baseUrl}/api/v1 (fixtures ${core.fixtures.ref}; '
    'Android emulator: http://10.0.2.2:${server.port}). Ctrl+C stops.',
  );

  final stop = Completer<void>();
  void requestStop(ProcessSignal _) {
    if (!stop.isCompleted) stop.complete();
  }

  final subscriptions = [
    ProcessSignal.sigint.watch().listen(requestStop),
    if (!Platform.isWindows) ProcessSignal.sigterm.watch().listen(requestStop),
  ];
  await stop.future;
  await server.close();
  for (final subscription in subscriptions) {
    await subscription.cancel();
  }
}
