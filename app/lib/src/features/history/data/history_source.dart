import 'package:gi_core_api/gi_core_api.dart';
import 'package:meta/meta.dart';

/// Samples of one entity over a range, ascending by time.
@immutable
final class HistoryData {
  const new({
    required this.from,
    required this.to,
    required this.samples,
    this.complete = true,
  });

  final DateTime from;
  final DateTime to;
  final List<HistorySample> samples;

  /// `false` when the range held more samples than the app reads (L18):
  /// only the oldest part of a slice was loaded.
  final bool complete;
}

/// Reads every sample of `from`–`to` of one entity, paging as needed.
typedef HistoryRangeReader =
    Future<({List<HistorySample> samples, bool complete})> Function(
      String deviceId,
      String entityId,
      DateTime from,
      DateTime to,
    );

/// `GET /devices/:d/entities/:e/history` (plan §4.2) for a whole range.
abstract interface class HistorySource {
  Future<HistoryData> read(
    String deviceId,
    String entityId, {
    required DateTime from,
    required DateTime to,
  });
}

/// [HistorySource] that splits a long range into [slice]-long parts read in
/// parallel, each paged by a [HistoryRangeReader] (the server has no cursor
/// and returns the OLDEST samples of a truncated range). Slices share their
/// bounds and the bounds are inclusive, so the repeated boundary sample is
/// dropped when the slices are merged.
final class SlicedHistorySource implements HistorySource {
  const new(this._readRange, {this.slice = const Duration(days: 1)});

  /// Reads through [client]: pages of 5000 samples, at most [maxPages] per
  /// slice.
  factory client(GiCoreClient client, {int maxPages = 4}) =>
      SlicedHistorySource(
        (deviceId, entityId, from, to) => client.entityHistoryAll(
          deviceId,
          entityId,
          from: from,
          to: to,
          maxPages: maxPages,
        ),
      );

  final HistoryRangeReader _readRange;
  final Duration slice;

  @override
  Future<HistoryData> read(
    String deviceId,
    String entityId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final ranges = HistoryPaging.slices(from, to, slice);
    final parts = await Future.wait([
      for (final range in ranges)
        _readRange(deviceId, entityId, range.from, range.to),
    ]);
    return HistoryData(
      from: from,
      to: to,
      samples: mergeSlices([for (final part in parts) part.samples]),
      complete: parts.every((part) => part.complete),
    );
  }
}

/// Concatenates ascending slices, dropping a sample that is not later than
/// the one before it (the inclusive boundary shared by two slices).
List<HistorySample> mergeSlices(Iterable<List<HistorySample>> slices) {
  final merged = <HistorySample>[];
  for (final slice in slices) {
    for (final sample in slice) {
      if (merged.isNotEmpty && !sample.at.isAfter(merged.last.at)) continue;
      merged.add(sample);
    }
  }
  return merged;
}
