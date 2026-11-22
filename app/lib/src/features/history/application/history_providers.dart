import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/devices/application/device_detail_notifier.dart';
import 'package:gi_home/src/features/history/application/history_downsampler.dart';
import 'package:gi_home/src/features/history/data/history_source.dart';
import 'package:gi_home/src/features/history/domain/history_series.dart';
import 'package:gi_home/src/features/history/domain/history_window.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_providers.g.dart';

/// Entity history of the saved appliance; only read once signed in.
@Riverpod(keepAlive: true)
HistorySource historySource(Ref ref) {
  final client = ref.watch(giCoreClientProvider);
  if (client == null) return const _Detached();
  return SlicedHistorySource.client(client);
}

/// Where the chart line is downsampled; tests replace the isolate.
@Riverpod(keepAlive: true)
HistoryDownsampler historyDownsampler(Ref ref) => downsampleInIsolate;

/// Samples of entity [entityId] of device [deviceId] over the [window]
/// ending now; read again on pull-to-refresh.
@riverpod
Future<HistoryData> entityHistory(
  Ref ref,
  String deviceId,
  String entityId,
  HistoryWindow window,
) {
  final to = ref.read(clockProvider)().toUtc();
  return ref
      .watch(historySourceProvider)
      .read(deviceId, entityId, from: to.subtract(window.span), to: to);
}

/// The chart line of [entityHistoryProvider], with at most [threshold]
/// change points (about one per logical pixel of the chart width, so at
/// most two points per pixel once expanded into steps).
@riverpod
Future<HistoryChartSeries> historyChart(
  Ref ref,
  String deviceId,
  String entityId,
  HistoryWindow window,
  int threshold,
) async {
  final data = await ref.watch(
    entityHistoryProvider(deviceId, entityId, window).future,
  );
  final downsample = ref.watch(historyDownsamplerProvider);
  return await downsample(
    changePoints(data.samples),
    threshold: threshold,
    endX: data.to.millisecondsSinceEpoch.toDouble(),
  );
}

/// The source while there is no client (see `device_repositories.dart`).
final class _Detached implements HistorySource {
  const new();

  @override
  Future<HistoryData> read(
    String deviceId,
    String entityId, {
    required DateTime from,
    required DateTime to,
  }) => Future.error(StateError('No appliance profile'));
}

/// Entity [entityId] of device [deviceId] as the device details last read
/// it (name, unit, domain), or `null` while unknown.
@riverpod
DeviceEntity? historyEntity(Ref ref, String deviceId, String entityId) => ref
    .watch(
      deviceDetailProvider(deviceId)
          .select((state) => state.data?.value.entities),
    )
    ?.where((entity) => entity.id == entityId)
    .firstOrNull;
