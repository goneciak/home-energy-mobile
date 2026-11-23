import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gi_tools/src/load/load_stats.dart';

/// Where CPU samples of the GI Core container come from.
abstract interface class ContainerSampler {
  /// Why sampling is not possible (docker missing, no such container), or
  /// `null` when it works. Called once before the run.
  Future<String?> prepare();

  /// A reading now; `null` when it could not be taken.
  Future<ContainerSample?> sample(Duration at);
}

/// Output of `docker stats --no-stream --format "{{json .}}"` for one
/// container, as a sample at [at]; `null` when it does not parse.
ContainerSample? parseDockerStats(String json, Duration at) {
  final Object? decoded;
  try {
    decoded = jsonDecode(json.trim());
  } on FormatException {
    return null;
  }
  if (decoded is! Map) return null;
  final cpu = double.tryParse(
    '${decoded['CPUPerc'] ?? ''}'.replaceAll('%', '').trim(),
  );
  if (cpu == null) return null;
  return ContainerSample(
    at: at,
    cpuPercent: cpu,
    memoryMiB: _memoryMiB('${decoded['MemUsage'] ?? ''}'),
  );
}

/// "123.4MiB / 7.6GiB" gives 123.4 (the first figure, in MiB).
double? _memoryMiB(String usage) {
  final match = RegExp(r'^\s*([\d.]+)\s*([KMG]i?B|B)').firstMatch(usage);
  if (match == null) return null;
  final value = double.tryParse(match.group(1)!);
  if (value == null) return null;
  return switch (match.group(2)!.toLowerCase()) {
    'b' => value / (1024 * 1024),
    'kib' || 'kb' => value / 1024,
    'mib' || 'mb' => value,
    'gib' || 'gb' => value * 1024,
    _ => null,
  };
}

/// Samples the `gi-core` container of a compose project with the docker CLI.
final class DockerContainerSampler implements ContainerSampler {
  new({required this.composeProject, this.service = 'gi-core'});

  final String composeProject;
  final String service;
  String? _container;

  @override
  Future<String?> prepare() async {
    final ProcessResult result;
    try {
      result = await Process.run('docker', [
        'ps',
        '--filter',
        'label=com.docker.compose.project=$composeProject',
        '--filter',
        'label=com.docker.compose.service=$service',
        '--format',
        '{{.ID}}',
      ]);
    } on ProcessException {
      return 'docker is not available; container CPU is not sampled';
    }
    if (result.exitCode != 0) {
      return 'docker ps failed (${'${result.stderr}'.trim()}); '
          'container CPU is not sampled';
    }
    final id = '${result.stdout}'.trim().split('\n').first.trim();
    if (id.isEmpty) {
      return 'no running "$service" container in compose project '
          '$composeProject; container CPU is not sampled';
    }
    _container = id;
    return null;
  }

  @override
  Future<ContainerSample?> sample(Duration at) async {
    final container = _container;
    if (container == null) return null;
    try {
      final result = await Process.run('docker', [
        'stats',
        '--no-stream',
        '--format',
        '{{json .}}',
        container,
      ]);
      if (result.exitCode != 0) return null;
      return parseDockerStats('${result.stdout}', at);
    } on ProcessException {
      return null;
    }
  }
}

/// No sampling, with the reason ([prepare] returns it).
final class NoContainerSampler implements ContainerSampler {
  const new(this.reason);

  final String reason;

  @override
  Future<String?> prepare() async => reason;

  @override
  Future<ContainerSample?> sample(Duration at) async => null;
}
