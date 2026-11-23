import 'dart:convert';
import 'dart:io';

import 'package:gi_tools/load_simulator.dart';
import 'package:test/test.dart';

// The cadences under test are the app's own.
// ignore: avoid_relative_lib_imports
import '../../app/lib/src/core/polling/polling_budget.dart';

RequestRecord _record(
  int seconds, {
  int status = 200,
  int ms = 10,
  bool startup = false,
  bool notModified = false,
}) => RequestRecord(
  at: Duration(seconds: seconds),
  status: notModified ? 304 : status,
  latency: Duration(milliseconds: ms),
  notModified: notModified,
  startup: startup,
);

void main() {
  group('report math', () {
    test('percentiles use the nearest rank', () {
      final sorted = [for (var i = 1; i <= 100; i++) Duration(milliseconds: i)];
      expect(percentile(sorted, 50), const Duration(milliseconds: 50));
      expect(percentile(sorted, 90), const Duration(milliseconds: 90));
      expect(percentile(sorted, 99), const Duration(milliseconds: 99));
      expect(percentile(sorted, 100), const Duration(milliseconds: 100));
      expect(percentile([], 50), Duration.zero);
      expect(
        percentile([const Duration(seconds: 1)], 99),
        const Duration(seconds: 1),
      );
    });

    test('steady rate leaves out the startup requests', () {
      final stats = ClientStats(0, [
        _record(0, startup: true),
        _record(0, startup: true),
        for (var s = 5; s < 120; s += 10) _record(s),
      ], const Duration(minutes: 2));

      expect(stats.total, 14);
      expect(stats.startupCount, 2);
      expect(stats.steady, hasLength(12));
      expect(stats.requestsPerMinute, 6);
      expect(stats.perMinute, [6, 6]);
      expect(stats.peakPerMinute, 6);
    });

    test('counts statuses, failures and the 304 ratio', () {
      final stats = ClientStats(0, [
        _record(1),
        _record(2, notModified: true),
        _record(3, notModified: true),
        _record(4, status: 429),
        _record(5, status: 0),
      ], const Duration(minutes: 1));

      expect(stats.statusCounts, {0: 1, 200: 1, 304: 2, 429: 1});
      expect(stats.failures, 2);
      expect(stats.notModifiedRatio, closeTo(0.4, 1e-9));
    });

    test('latency percentiles ignore requests that got no answer', () {
      final stats = ClientStats(0, [
        for (var i = 1; i <= 10; i++) _record(i, ms: i * 10),
        _record(11, status: 0, ms: 5000),
      ], const Duration(minutes: 1));

      expect(stats.p50, const Duration(milliseconds: 50));
      expect(stats.p99, const Duration(milliseconds: 100));
    });

    test('a container summary is the mean and the peak', () {
      final summary = ContainerSummary.of([
        const ContainerSample(
          at: Duration.zero,
          cpuPercent: 10,
          memoryMiB: 100,
        ),
        const ContainerSample(
          at: Duration(seconds: 5),
          cpuPercent: 30,
          memoryMiB: 200,
        ),
      ]);
      expect(summary.meanCpu, 20);
      expect(summary.peakCpu, 30);
      expect(summary.meanMemoryMiB, 150);
      expect(ContainerSummary.of([]).count, 0);
    });

    test('docker stats output is parsed', () {
      final sample = parseDockerStats(
        jsonEncode({'CPUPerc': '12.50%', 'MemUsage': '256MiB / 7.6GiB'}),
        const Duration(seconds: 5),
      );
      expect(sample!.cpuPercent, 12.5);
      expect(sample.memoryMiB, 256);
      expect(
        parseDockerStats(
          jsonEncode({'CPUPerc': '0.00%', 'MemUsage': '1.5GiB / 7.6GiB'}),
          Duration.zero,
        )!.memoryMiB,
        1536,
      );
      expect(parseDockerStats('not json', Duration.zero), isNull);
      expect(parseDockerStats('{"CPUPerc": "--"}', Duration.zero), isNull);
    });
  });

  group('verdict and rendering', () {
    LoadRun runOf(int perMinute) => LoadRun(
      config: LoadConfig(
        baseUrl: Uri.parse('http://x'),
        token: 't',
        deviceListInterval: PollingBudget.deviceList,
        cardInterval: PollingBudget.heatingCardInterval,
      ),
      startedAt: DateTime.utc(2026, 11, 22),
      clients: [
        ClientStats(0, [
          for (var i = 0; i < perMinute * 2; i++) _record(i % 120),
        ], const Duration(minutes: 2)),
      ],
      samples: const [],
      warnings: const ['docker is not available'],
    );

    test('within the budget passes', () {
      final report = LoadReport(
        run: runOf(12),
        budgetPerMinute: 12,
        label: 'l',
      );
      expect(report.passed, isTrue);
      expect(report.toMarkdown(), contains('# Load report: PASS'));
      expect(report.toMarkdown(), contains('docker is not available'));
    });

    test('over the budget fails', () {
      final report = LoadReport(
        run: runOf(13),
        budgetPerMinute: 12,
        label: 'l',
      );
      expect(report.passed, isFalse);
      expect(report.toMarkdown(), contains('OVER'));
      final json = jsonDecode(report.toJson()) as Map<String, Object?>;
      expect(json['verdict'], 'fail');
    });

    test('the report says the container figures are a proxy', () {
      final report = LoadReport(
        run: runOf(1),
        budgetPerMinute: 12,
        label: 'proxy measurement on a developer PC, not the Raspberry Pi',
      );
      expect(report.toMarkdown(), contains('not the Raspberry'));
    });
  });

  group('dry run', () {
    test('replays the app cadences against the in-process fake', () async {
      final fake = await FakeCoreServer.start();
      addTearDown(fake.close);

      final run = await runLoad(
        LoadConfig(
          baseUrl: fake.baseUrl,
          token: 'fake-token',
          deviceListInterval: PollingBudget.deviceList,
          cardInterval: PollingBudget.heatingCardInterval,
          clients: 2,
          cards: 3,
          duration: const Duration(minutes: 5),
          timeScale: 120,
        ),
      );
      final report = LoadReport(
        run: run,
        budgetPerMinute: 12,
        label: 'test',
        dryRun: true,
      );

      expect(run.clients, hasLength(2));
      for (final client in run.clients) {
        // 3 cards: the list at 2 a minute plus 3 cards every 18 s.
        expect(client.requestsPerMinute, inInclusiveRange(8, 12.5));
        expect(client.failures, 0);
        expect(client.startupCount, 5, reason: 'rooms, list and 3 cards');
        expect(client.notModifiedRatio, greaterThan(0));
      }
      expect(report.passed, isTrue);
      expect(fake.requests, isNotEmpty);
      expect(
        fake.requests.where((r) => !r.startsWith('GET ')),
        isEmpty,
        reason: 'the phones only read',
      );
      expect(
        fake.requests.where((r) => r.startsWith('GET /api/v1/devices/')),
        isNotEmpty,
      );
    });

    test('faster polling than the budget fails the verdict', () async {
      final fake = await FakeCoreServer.start(heatingDevices: 1);
      addTearDown(fake.close);
      final run = await runLoad(
        LoadConfig(
          baseUrl: fake.baseUrl,
          token: 'fake-token',
          deviceListInterval: PollingBudget.deviceList,
          cardInterval: PollingBudget.heatingCardInterval,
          clients: 1,
          cards: 1,
          duration: const Duration(minutes: 2),
          timeScale: 120,
        ),
      );

      // The same run judged against a tighter budget.
      expect(
        LoadReport(run: run, budgetPerMinute: 2, label: 'l').passed,
        isFalse,
      );
    });

    test('writes report.json and report.md through the CLI', () async {
      final out = Directory.systemTemp.createTempSync('load_report');
      addTearDown(() => out.deleteSync(recursive: true));

      final result = await Process.run(Platform.resolvedExecutable, [
        'run',
        'load/simulate_clients.dart',
        '--dry-run',
        '--clients',
        '1',
        '--cards',
        '2',
        '--duration',
        '120',
        '--out-dir',
        out.path,
      ]);

      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
      final json = jsonDecode(
        File('${out.path}/report.json').readAsStringSync(),
      ) as Map<String, Object?>;
      expect(json['verdict'], 'pass');
      expect(json['dryRun'], isTrue);
      expect(
        File('${out.path}/report.md').readAsStringSync(),
        contains('PASS'),
      );
    });
  });
}
