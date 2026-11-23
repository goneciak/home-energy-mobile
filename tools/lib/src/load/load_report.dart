import 'dart:convert';

import 'package:gi_tools/src/load/load_stats.dart';
import 'package:gi_tools/src/load/phone_simulator.dart';

/// The outcome of a load run: the numbers, the verdict against the request
/// budget, and the two renderings (`report.json`, `report.md`).
final class LoadReport {
  new({
    required this.run,
    required this.budgetPerMinute,
    required this.label,
    this.dryRun = false,
  }) : container = ContainerSummary.of(run.samples);

  final LoadRun run;

  /// Requests per minute one phone may send on Home.
  final int budgetPerMinute;

  /// What the container figures are (a proxy, not the Raspberry Pi).
  final String label;

  /// The run used the in-process fake: nothing about GI Core was measured.
  final bool dryRun;

  final ContainerSummary container;

  List<ClientStats> get clients => run.clients;

  /// Every phone stayed within the budget.
  bool get passed =>
      clients.isNotEmpty &&
      clients.every((c) => c.requestsPerMinute <= budgetPerMinute);

  String toJson() => const JsonEncoder.withIndent('  ').convert({
    'verdict': passed ? 'pass' : 'fail',
    'dryRun': dryRun,
    'label': label,
    'budgetRequestsPerMinute': budgetPerMinute,
    'startedAt': run.startedAt.toUtc().toIso8601String(),
    'config': {
      'clients': run.config.clients,
      'cards': run.config.cards,
      'durationSeconds': run.config.duration.inSeconds,
      'timeScale': run.config.timeScale,
    },
    'warnings': run.warnings,
    'clients': [
      for (final c in clients)
        {
          'index': c.index,
          'requests': c.total,
          'startupRequests': c.startupCount,
          'steadyRequestsPerMinute': _round(c.requestsPerMinute),
          'peakRequestsPerMinute': c.peakPerMinute,
          'requestsPerMinute': c.perMinute,
          'status': {
            for (final e in c.statusCounts.entries) '${e.key}': e.value,
          },
          'failures': c.failures,
          'notModifiedRatio': _round(c.notModifiedRatio),
          'latencyMs': {
            'p50': c.p50.inMilliseconds,
            'p90': c.p90.inMilliseconds,
            'p99': c.p99.inMilliseconds,
          },
        },
    ],
    'container': {
      'samples': container.count,
      'meanCpuPercent': _round(container.meanCpu),
      'peakCpuPercent': _round(container.peakCpu),
      'meanMemoryMiB': container.meanMemoryMiB == null
          ? null
          : _round(container.meanMemoryMiB!),
    },
  });

  String get _scaleNote {
    final scale = run.config.timeScale;
    return scale == 1 ? '' : ' (run time, x$scale faster than real time)';
  }

  String toMarkdown() {
    final b = StringBuffer()
      ..writeln('# Load report: ${passed ? 'PASS' : 'FAIL'}')
      ..writeln();
    if (dryRun) {
      b
        ..writeln(
          '> Dry run against an in-process fake server: this checks the '
          'tool, not GI Core.',
        )
        ..writeln();
    }
    b
      ..writeln(
        '- Phones: ${run.config.clients}, each with Home open and '
        '${run.config.cards} heating card(s)',
      )
      ..writeln(
        '- Duration: ${run.config.duration.inSeconds} s'
        '$_scaleNote',
      )
      ..writeln(
        '- Budget: at most $budgetPerMinute requests per minute per phone '
        '(steady polling; the first request of each poller is reported as '
        'startup)',
      )
      ..writeln('- Started: ${run.startedAt.toUtc().toIso8601String()}')
      ..writeln();
    for (final warning in run.warnings) {
      b.writeln('- Warning: $warning');
    }
    if (run.warnings.isNotEmpty) b.writeln();
    b
      ..writeln('## Requests per phone')
      ..writeln()
      ..writeln(
        '| Phone | Steady req/min | Peak minute | Startup | Failed | 304 | '
        'p50 | p90 | p99 | Budget |',
      )
      ..writeln('|---|---|---|---|---|---|---|---|---|---|');
    for (final c in clients) {
      final ok = c.requestsPerMinute <= budgetPerMinute;
      b.writeln(
        '| ${c.index + 1} | ${_round(c.requestsPerMinute)} | '
        '${c.peakPerMinute} | ${c.startupCount} | ${c.failures} | '
        '${(c.notModifiedRatio * 100).round()}% | ${c.p50.inMilliseconds} ms | '
        '${c.p90.inMilliseconds} ms | ${c.p99.inMilliseconds} ms | '
        '${ok ? 'ok' : 'OVER'} |',
      );
    }
    b
      ..writeln()
      ..writeln('Status codes (all phones):');
    final totals = <int, int>{};
    for (final c in clients) {
      for (final e in c.statusCounts.entries) {
        totals[e.key] = (totals[e.key] ?? 0) + e.value;
      }
    }
    for (final e
        in (totals.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))) {
      b.writeln('- ${e.key == 0 ? 'no answer' : e.key}: ${e.value}');
    }
    b
      ..writeln()
      ..writeln('## GI Core container ($label)')
      ..writeln();
    if (container.count == 0) {
      b.writeln('No samples were taken (see the warnings above).');
    } else {
      b
        ..writeln('- Samples: ${container.count}')
        ..writeln(
          '- CPU: mean ${_round(container.meanCpu)}%, peak '
          '${_round(container.peakCpu)}% (100% is one core)',
        );
      if (container.meanMemoryMiB case final memory?) {
        b.writeln('- Memory: mean ${_round(memory)} MiB');
      }
    }
    b
      ..writeln()
      ..writeln(
        'This is a proxy measurement on a developer PC, not the Raspberry '
        'Pi: it shows the request rate and how the load scales, not the '
        "Pi's CPU.",
      );
    return b.toString();
  }
}

double _round(double value) => (value * 100).round() / 100;
