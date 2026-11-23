// Simulator of a GI Edge boiler-room controller for the contract stack
// (contract/compose.contract.yml, service gi-edge-sim). See
// docs/gi-edge-simulator.md.
//
//   gi_edge_sim              serve (settings come from environment variables)
//   gi_edge_sim --healthcheck   exit 0 when the local server answers /healthz
import 'dart:async';
import 'dart:io';

import 'package:gi_edge_sim/gi_edge_sim.dart';

Future<void> main(List<String> args) async {
  final env = Platform.environment;
  final config = SimConfig.fromEnv(env, ip: await _ownIpv4());

  if (args.contains('--healthcheck')) {
    exit(await _healthcheck(config.port) ? 0 : 1);
  }

  final identity = IdentityStore(path: config.stateFile);
  final sim = Simulator(
    config: config,
    identity: identity,
    log: (message) => stdout.writeln('[sim] $message'),
  );
  await DeviceServer(sim).bind(config.port);
  await ControlServer(sim).bind(config.controlPort);
  sim.start();
  stdout.writeln(
    'gi_edge_sim as ${config.ip}: device API :${config.port}, '
    'control :${config.controlPort}, core ${config.coreUrl ?? '(from activation)'}, '
    'provisioned=${sim.provisioned}',
  );
  ProcessSignal.sigterm.watch().listen((_) => exit(0));
  await Completer<void>().future;
}

/// The container's own private IPv4 (what GI Core resolves the host to).
Future<String> _ownIpv4() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  for (final interface in interfaces) {
    for (final address in interface.addresses) {
      if (!address.isLoopback) return address.address;
    }
  }
  return '127.0.0.1';
}

Future<bool> _healthcheck(int port) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
  try {
    final request = await client.get('127.0.0.1', port, '/healthz');
    final response = await request.close().timeout(const Duration(seconds: 2));
    await response.drain<void>();
    return response.statusCode == 200;
  } on Object {
    return false;
  } finally {
    client.close(force: true);
  }
}
