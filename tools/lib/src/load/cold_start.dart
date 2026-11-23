import 'dart:math';

/// Cold start budget: the 90th percentile of the runs stays within this.
const coldStartLimit = Duration(seconds: 5);

/// Runs needed for the figure to count.
const coldStartMinRuns = 20;

/// The milliseconds in [text]: one per line or separated by commas or
/// spaces. A line may be a log line carrying `COLD_START_MS=<n>`, and lines
/// that start with `#` are comments. Anything else is skipped.
List<int> parseColdStartRuns(String text) {
  final runs = <int>[];
  for (final line in text.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final tagged = RegExp(r'COLD_START_MS=(\d+)').allMatches(trimmed);
    if (tagged.isNotEmpty) {
      runs.addAll(tagged.map((m) => int.parse(m.group(1)!)));
      continue;
    }
    for (final part in trimmed.split(RegExp(r'[,\s;]+'))) {
      final value = int.tryParse(part);
      if (value != null && value >= 0) runs.add(value);
    }
  }
  return runs;
}

/// Summary of cold start runs, in milliseconds.
final class ColdStartSummary {
  const new _({
    required this.runs,
    required this.min,
    required this.median,
    required this.mean,
    required this.p90,
    required this.max,
  });

  /// [runs] must not be empty.
  factory of(List<int> runs) {
    if (runs.isEmpty) throw ArgumentError('no runs');
    final sorted = [...runs]..sort();
    final mean = sorted.reduce((a, b) => a + b) / sorted.length;
    return ColdStartSummary._(
      runs: sorted.length,
      min: sorted.first,
      median: _rank(sorted, 50),
      mean: mean,
      p90: _rank(sorted, 90),
      max: sorted.last,
    );
  }

  final int runs;
  final int min;
  final int median;
  final double mean;

  /// Nearest-rank 90th percentile.
  final int p90;
  final int max;

  /// Enough runs and the p90 within [limit].
  bool passes({
    Duration limit = coldStartLimit,
    int minRuns = coldStartMinRuns,
  }) => runs >= minRuns && p90 <= limit.inMilliseconds;

  /// A table to paste into the cold start report.
  String toMarkdown({
    Duration limit = coldStartLimit,
    int minRuns = coldStartMinRuns,
  }) {
    final enough = runs >= minRuns;
    final verdict = !enough
        ? 'NOT ENOUGH RUNS ($runs of $minRuns)'
        : passes(limit: limit, minRuns: minRuns)
        ? 'PASS'
        : 'FAIL';
    final row =
        '| $runs | $min ms | $median ms | ${mean.round()} ms | $p90 ms | '
        '$max ms | ${limit.inMilliseconds} ms | $verdict |';
    return [
      '| Runs | Min | Median | Mean | p90 | Max | Limit (p90) | Verdict |',
      '|---|---|---|---|---|---|---|---|',
      row,
    ].join('\n');
  }
}

int _rank(List<int> sorted, double p) {
  final rank = max(1, (p / 100 * sorted.length).ceil());
  return sorted[min(rank, sorted.length) - 1];
}
