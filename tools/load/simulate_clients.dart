// Simulated phones against GI Core: replays the app's polling cadences
// (GET only) and reports the request rate per phone, latency percentiles,
// the share of 304 answers and, when docker is available, the CPU of the
// gi-core container.
//
//   dart run tools/load/simulate_clients.dart --base-url http://127.0.0.1:PORT
//       [--clients 3] [--duration 600] [--cards 2] [--run-id <contract id>]
//       [--out-dir build/load-report/<timestamp>]
//   dart run tools/load/simulate_clients.dart --dry-run
//
// The numbers are a proxy measured on a developer PC, not on a Raspberry Pi.
// Usage and interpretation: docs/development.md, "Obciążenie GI Core".
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:gi_tools/load_simulator.dart';
import 'package:gi_tools/src/repo.dart';

// The budget is the app's own constant.
// ignore: avoid_relative_lib_imports
import '../../app/lib/src/core/polling/polling_budget.dart';

const _usage = 'Usage: dart run tools/load/simulate_clients.dart [options]';

ArgParser _parser() => ArgParser()
  ..addOption('base-url', help: r'GI Core origin (default: $GI_CORE_URL).')
  ..addOption('clients', defaultsTo: '3', help: 'Simulated phones.')
  ..addOption(
    'cards',
    defaultsTo: '2',
    help: "Heating cards on each phone's Home.",
  )
  ..addOption('duration', defaultsTo: '600', help: 'Seconds (run time).')
  ..addOption(
    'run-id',
    help:
        'Contract stack RunId: samples compose project '
        'gi-mobile-contract-<RunId>.',
  )
  ..addOption(
    'container-filter',
    help: 'Compose project of the gi-core container (overrides --run-id).',
  )
  ..addOption('out-dir', help: 'Default: build/load-report/<timestamp>.')
  ..addOption('email', help: 'Default: the ADMIN of tools/seed_accounts*.json.')
  ..addOption('password')
  ..addOption('token', help: 'Access token; skips the login.')
  ..addOption('seed', defaultsTo: '1')
  ..addOption(
    'time-scale',
    help: 'Run time per real time (dry run only; default 30 there).',
  )
  ..addFlag(
    'dry-run',
    negatable: false,
    help: 'Use an in-process fake server instead of GI Core.',
  )
  ..addFlag('help', abbr: 'h', negatable: false);

Future<void> main(List<String> arguments) async {
  final ArgResults args;
  try {
    args = _parser().parse(arguments);
  } on FormatException catch (error) {
    stderr
      ..writeln(error.message)
      ..writeln(_usage)
      ..writeln(_parser().usage);
    exit(64);
  }
  if (args.flag('help')) {
    stdout
      ..writeln(_usage)
      ..writeln(_parser().usage);
    return;
  }

  final dryRun = args.flag('dry-run');
  final clients = int.tryParse(args.option('clients')!) ?? -1;
  final cards = int.tryParse(args.option('cards')!) ?? -1;
  final seconds = int.tryParse(args.option('duration')!) ?? -1;
  if (clients < 1 || cards < 0 || seconds < 1) {
    stderr.writeln('--clients, --cards and --duration must be positive.');
    exit(64);
  }

  FakeCoreServer? fake;
  Uri baseUrl;
  String token;
  if (dryRun) {
    fake = await FakeCoreServer.start(heatingDevices: cards < 1 ? 1 : cards);
    baseUrl = fake.baseUrl;
    token = 'fake-token';
  } else {
    final url = args.option('base-url') ?? Platform.environment['GI_CORE_URL'];
    if (url == null) {
      stderr.writeln('Give --base-url (or set GI_CORE_URL), or use --dry-run.');
      exit(64);
    }
    baseUrl = Uri.parse(url);
    final given = args.option('token');
    if (given != null) {
      token = given;
    } else {
      final account = _account(args);
      try {
        token = await loginForToken(
          baseUrl,
          email: account.$1,
          password: account.$2,
        );
      } on Object catch (error) {
        stderr.writeln('Login failed: $error');
        exit(1);
      }
    }
  }

  final runId = args.option('run-id');
  final project =
      args.option('container-filter') ??
      (runId == null ? null : 'gi-mobile-contract-$runId');
  final sampler = dryRun
      ? const NoContainerSampler('dry run: no container is sampled')
      : project == null
      ? const NoContainerSampler(
          'give --run-id or --container-filter to sample the container',
        )
      : DockerContainerSampler(composeProject: project);

  final scale = dryRun
      ? double.tryParse(args.option('time-scale') ?? '') ?? 30
      : 1.0;
  final config = LoadConfig(
    baseUrl: baseUrl,
    token: token,
    deviceListInterval: PollingBudget.deviceList,
    cardInterval: PollingBudget.heatingCardInterval,
    clients: clients,
    cards: cards,
    duration: Duration(seconds: seconds),
    timeScale: scale,
    seed: int.tryParse(args.option('seed')!) ?? 1,
  );

  stdout.writeln(
    'Running $clients phone(s) with $cards heating card(s) for $seconds s'
    '${dryRun ? ' (dry run, x$scale)' : ''}...',
  );
  final run = await runLoad(config, sampler: sampler);
  await fake?.close();

  final report = LoadReport(
    run: run,
    budgetPerMinute: PollingBudget.homeRequestsPerMinute,
    label: 'proxy measurement on a developer PC, not the Raspberry Pi',
    dryRun: dryRun,
  );
  final out = Directory(
    args.option('out-dir') ?? 'build/load-report/${_timestamp()}',
  )..createSync(recursive: true);
  File('${out.path}/report.json').writeAsStringSync(report.toJson());
  File('${out.path}/report.md').writeAsStringSync(report.toMarkdown());
  stdout
    ..writeln(report.toMarkdown())
    ..writeln('Report: ${out.path}');
  exit(report.passed ? 0 : 1);
}

String _timestamp() =>
    DateTime.now().toUtc().toIso8601String().replaceAll(RegExp('[:.]'), '-');

/// `--email/--password`, else the ADMIN account of the seed file (test-only
/// accounts of the contract stack).
(String, String) _account(ArgResults args) {
  final email = args.option('email');
  final password = args.option('password');
  if (email != null && password != null) return (email, password);
  final root = findRepoRoot(from: Directory.current);
  for (final name in ['seed_accounts.json', 'seed_accounts.example.json']) {
    final file = File('${root.path}/tools/$name');
    if (!file.existsSync()) continue;
    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    for (final account
        in (json['accounts']! as List).cast<Map<String, Object?>>()) {
      if (account['role'] == 'ADMIN') {
        return ('${account['email']}', '${account['password']}');
      }
    }
  }
  stderr.writeln('No ADMIN account found: give --email and --password.');
  exit(64);
}
