// TCP forwarder for development (plan §9.6, M0 item 2): a phone in the LAN
// reaches a GI Core that stays published on the PC's loopback.
//
//   dart run tools/dev_lan_proxy/bin/dev_lan_proxy.dart
//       [--listen 0.0.0.0:8080] [--target 127.0.0.1:3000]
//
// In the app (dev flavor) use http://<PC LAN IP>:8080. On Windows allow the
// listen port in the Private firewall profile (README). Ctrl+C stops it.
import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:gi_tools/dev_lan_proxy.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'listen',
      defaultsTo: '0.0.0.0:8080',
      help: 'Address and port to accept connections on.',
    )
    ..addOption(
      'target',
      defaultsTo: '127.0.0.1:3000',
      help: 'Where to forward them (GI Core on the loopback).',
    )
    ..addFlag(
      'quiet',
      abbr: 'q',
      negatable: false,
      help: 'No per-connection log lines.',
    )
    ..addFlag('help', abbr: 'h', negatable: false);

  final ArgResults options;
  final HostPort listen;
  final HostPort target;
  try {
    options = parser.parse(args);
    listen = parseHostPort(options.option('listen')!, defaultHost: '0.0.0.0');
    target = parseHostPort(options.option('target')!);
  } on FormatException catch (e) {
    stderr.writeln('${e.message}: ${e.source}\n\n${parser.usage}');
    exit(64);
  }
  if (options.flag('help')) {
    print(
      'Usage: dart run tools/dev_lan_proxy/bin/dev_lan_proxy.dart '
      '[options]\n\n${parser.usage}',
    );
    return;
  }

  String stamp() => DateTime.now().toIso8601String().substring(11, 23);
  final DevLanProxy proxy;
  try {
    proxy = await DevLanProxy.start(
      listen: listen,
      target: target,
      log: options.flag('quiet') ? null : (line) => print('${stamp()} $line'),
    );
  } on SocketException catch (e) {
    stderr.writeln('Cannot listen on ${listen.host}:${listen.port}: $e');
    exit(1);
  }
  print(
    'dev_lan_proxy: ${proxy.address.address}:${proxy.port} -> '
    '${target.host}:${target.port} (Ctrl+C stops)',
  );
  if (listen.host == '0.0.0.0' || listen.host == '::') {
    for (final interface in await NetworkInterface.list()) {
      for (final address in interface.addresses) {
        if (address.type != InternetAddressType.IPv4) continue;
        print('  http://${address.address}:${proxy.port}  (${interface.name})');
      }
    }
  }

  final stop = Completer<void>();
  void requestStop(ProcessSignal _) {
    if (!stop.isCompleted) stop.complete();
  }

  final subscriptions = [
    ProcessSignal.sigint.watch().listen(requestStop),
    // SIGTERM cannot be watched on Windows.
    if (!Platform.isWindows) ProcessSignal.sigterm.watch().listen(requestStop),
  ];
  await stop.future;
  print('dev_lan_proxy: stopping (${proxy.openConnections} open)');
  await proxy.close();
  for (final subscription in subscriptions) {
    await subscription.cancel();
  }
}
