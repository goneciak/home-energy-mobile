/// One request of a simulated phone.
final class RequestRecord {
  const new({
    required this.at,
    required this.status,
    required this.latency,
    required this.notModified,
    this.startup = false,
  });

  /// Time since the start of the run, in run time (see `timeScale`).
  final Duration at;

  /// HTTP status; `0` when the request did not get an answer.
  final int status;
  final Duration latency;

  /// Answered 304 to a conditional request.
  final bool notModified;

  /// The first request of a poller, or the one-off room list: the screen's
  /// load, not its steady polling.
  final bool startup;

  bool get failed => status == 0 || status >= 400;
}

/// Nearest-rank percentile ([p] in 0..100) of [sorted] (ascending).
Duration percentile(List<Duration> sorted, double p) {
  if (sorted.isEmpty) return Duration.zero;
  final rank = (p / 100 * sorted.length).ceil().clamp(1, sorted.length);
  return sorted[rank - 1];
}

/// What one simulated phone sent.
final class ClientStats {
  new(this.index, this.records, this.runDuration);

  final int index;
  final List<RequestRecord> records;

  /// How long the phone ran, in run time.
  final Duration runDuration;

  Iterable<RequestRecord> get steady => records.where((r) => !r.startup);

  int get total => records.length;
  int get startupCount => records.where((r) => r.startup).length;

  double get minutes =>
      runDuration.inMicroseconds / Duration.microsecondsPerMinute;

  /// Steady requests per minute over the whole run (the startup round is
  /// the screen's one-off load and is reported on its own).
  double get requestsPerMinute => minutes <= 0 ? 0 : steady.length / minutes;

  /// Steady requests in each started minute of the run.
  List<int> get perMinute {
    final buckets = List<int>.filled(minutes.ceil().clamp(1, 1 << 20), 0);
    for (final record in steady) {
      final bucket = record.at.inMicroseconds ~/ Duration.microsecondsPerMinute;
      buckets[bucket.clamp(0, buckets.length - 1)]++;
    }
    return buckets;
  }

  int get peakPerMinute => perMinute.fold(0, (a, b) => a > b ? a : b);

  Map<int, int> get statusCounts {
    final counts = <int, int>{};
    for (final record in records) {
      counts[record.status] = (counts[record.status] ?? 0) + 1;
    }
    return Map.fromEntries(
      counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  int get failures => records.where((r) => r.failed).length;

  /// Share of the requests answered 304, 0..1.
  double get notModifiedRatio =>
      records.isEmpty ? 0 : records.where((r) => r.notModified).length / total;

  List<Duration> get _latencies =>
      records.where((r) => r.status != 0).map((r) => r.latency).toList()
        ..sort();

  Duration get p50 => percentile(_latencies, 50);
  Duration get p90 => percentile(_latencies, 90);
  Duration get p99 => percentile(_latencies, 99);
}

/// One `docker stats` reading of the GI Core container.
final class ContainerSample {
  const new({required this.at, required this.cpuPercent, this.memoryMiB});

  final Duration at;

  /// Docker's CPU percentage: 100 is one full core.
  final double cpuPercent;
  final double? memoryMiB;
}

/// Mean and peak of the samples.
final class ContainerSummary {
  const new({
    required this.count,
    required this.meanCpu,
    required this.peakCpu,
    required this.meanMemoryMiB,
  });

  factory of(List<ContainerSample> samples) {
    if (samples.isEmpty) {
      return const ContainerSummary(
        count: 0,
        meanCpu: 0,
        peakCpu: 0,
        meanMemoryMiB: null,
      );
    }
    final cpus = samples.map((s) => s.cpuPercent).toList();
    final memories = samples.map((s) => s.memoryMiB).nonNulls.toList();
    return ContainerSummary(
      count: samples.length,
      meanCpu: cpus.reduce((a, b) => a + b) / cpus.length,
      peakCpu: cpus.reduce((a, b) => a > b ? a : b),
      meanMemoryMiB: memories.isEmpty
          ? null
          : memories.reduce((a, b) => a + b) / memories.length,
    );
  }

  final int count;
  final double meanCpu;
  final double peakCpu;
  final double? meanMemoryMiB;
}
