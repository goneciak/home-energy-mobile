import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/demo/data/demo_core.dart';
import 'package:gi_home/src/features/demo/data/demo_http_client_adapter.dart';
import 'package:gi_home/src/features/history/application/history_downsampler.dart';
import 'package:gi_home/src/features/history/application/history_providers.dart';
import 'package:gi_home/src/features/history/data/history_source.dart';

/// The fixed "now" of the history tests: a local wall time, so the chart
/// axis and the table read the same in every time zone.
final historyNow = DateTime(2026, 11, 22, 7, 30);

const historyDeviceId = 'd1';
const supplyEntityId = 'supply';
const relayEntityId = 'relay';

/// A supply temperature recorded every [step] over [span] before [end],
/// each sample a change: a night dip, a morning rise and noise.
List<HistorySample> temperatureSamples({
  DateTime? end,
  Duration span = const Duration(hours: 24),
  Duration step = const Duration(minutes: 10),
  int seed = 7,
}) {
  final random = math.Random(seed);
  final to = end ?? historyNow;
  final samples = <HistorySample>[];
  double? last;
  for (var at = to.subtract(span); at.isBefore(to); at = at.add(step)) {
    final hours = at.hour + at.minute / 60;
    final value =
        ((45 +
                    6 * math.sin((hours - 9) / 24 * 2 * math.pi) +
                    (random.nextDouble() - 0.5)) *
                10)
            .round() /
        10;
    if (value == last) continue;
    last = value;
    samples.add(
      HistorySample(
        at: at.toUtc(),
        kind: HistorySampleKind.temperature,
        value: value,
        unit: '°C',
      ),
    );
  }
  return samples;
}

/// Relay toggles every [every] over [span] before [end].
List<HistorySample> switchSamples({
  DateTime? end,
  Duration span = const Duration(hours: 24),
  Duration every = const Duration(minutes: 95),
}) {
  final to = end ?? historyNow;
  var on = false;
  return [
    for (var at = to.subtract(span); at.isBefore(to); at = at.add(every))
      HistorySample(
        at: at.toUtc(),
        kind: HistorySampleKind.switch_,
        value: on = !on,
      ),
  ];
}

/// [HistorySource] answering from in-memory series per entity id, or
/// failing with [error].
final class FakeHistorySource implements HistorySource {
  new({this.series = const {}, this.error, this.complete = true});

  final Map<String, List<HistorySample>> series;
  final Object? error;
  final bool complete;
  final List<({String entityId, DateTime from, DateTime to})> reads = [];

  @override
  Future<HistoryData> read(
    String deviceId,
    String entityId, {
    required DateTime from,
    required DateTime to,
  }) async {
    reads.add((entityId: entityId, from: from, to: to));
    if (error case final Exception error) throw error;
    if (error case final Error error) throw error;
    return HistoryData(
      from: from,
      to: to,
      complete: complete,
      samples: [
        for (final sample in series[entityId] ?? const <HistorySample>[])
          if (!sample.at.isBefore(from) && !sample.at.isAfter(to)) sample,
      ],
    );
  }
}

/// A device entity as the history screen names it.
DeviceEntity historyEntity({
  String id = supplyEntityId,
  String name = 'Temperatura zasilania',
  EntityDomain domain = EntityDomain.sensor,
  String? deviceClass = 'temperature',
  String? unit = '°C',
}) => DeviceEntity(
  id: id,
  displayName: name,
  sourceName: id,
  readable: true,
  writable: domain == EntityDomain.switch_,
  availability: true,
  enabled: true,
  domain: domain,
  deviceClass: deviceClass,
  unit: unit,
);

/// Overrides of the history screen: [source], a synchronous downsampler
/// (an isolate never finishes inside the fake-async zone), the clock and
/// the entity names.
List<Override> historyOverrides(
  HistorySource source, {
  List<DeviceEntity>? entities,
}) => [
  historySourceProvider.overrideWithValue(source),
  historyDownsamplerProvider.overrideWithValue(downsampleSynchronously),
  clockProvider.overrideWithValue(() => historyNow),
  for (final entity
      in entities ??
          [
            historyEntity(),
            historyEntity(
              id: relayEntityId,
              name: 'Przekaźnik kotła',
              domain: EntityDomain.switch_,
              deviceClass: null,
              unit: null,
            ),
          ])
    historyEntityProvider(historyDeviceId, entity.id).overrideWithValue(entity),
];

/// Device id of the demo boiler (`demo_core.json`).
const demoBoilerId = '9d3c6a52-1f0e-4c8b-a6d2-0b7e5f4a1c01';

/// A [HistoryRangeReader] over demo mode's in-process GI Core: real JSON
/// over the demo adapter, paged like `GiCoreClient.entityHistoryAll`
/// (pages of [limit], next `from` = last sample, boundary dropped).
HistoryRangeReader demoHistoryReader(
  DemoCore core, {
  int limit = HistoryPaging.maxLimit,
  int maxPages = 4,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://demo.gi-home.invalid/api/v1'))
    ..httpClientAdapter = DemoHttpClientAdapter(core);
  return (deviceId, entityId, from, to) async {
    final pages = <EntityHistory>[];
    DateTime? next = from;
    while (next != null && pages.length < maxPages) {
      final response = await dio.get<Map<String, dynamic>>(
        '/devices/$deviceId/entities/$entityId/history',
        queryParameters: {
          'from': next.toUtc().toIso8601String(),
          'to': to.toUtc().toIso8601String(),
          'limit': limit,
        },
      );
      final page = EntityHistory.fromJson(response.data!);
      pages.add(page);
      next = HistoryPaging.nextFrom(page, limit);
    }
    return (samples: HistoryPaging.mergePages(pages), complete: next == null);
  };
}
