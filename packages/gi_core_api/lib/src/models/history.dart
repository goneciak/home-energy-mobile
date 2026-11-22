import 'package:freezed_annotation/freezed_annotation.dart';

part 'history.freezed.dart';
part 'history.g.dart';

/// Kind of a history sample (`history.service.ts`).
@JsonEnum(fieldRename: FieldRename.snake)
enum HistorySampleKind {
  temperature,
  energy,
  numeric,
  @JsonValue('switch')
  switch_,
  text,
  unknown,
}

/// `GET /devices/:deviceId/entities/:entityId/history`.
///
/// [samples] are ascending by [HistorySample.at] and recorded only when the
/// value CHANGED, so the series is a change log (draw it as a step chart).
/// There is no server-side downsampling; a truncated answer holds the OLDEST
/// `limit` samples of the range (see [HistoryPaging]).
@freezed
abstract class EntityHistory with _$EntityHistory {
  const factory({
    required String entityId,
    required DateTime from,
    required DateTime to,
    @Default(<HistorySample>[]) List<HistorySample> samples,
  }) = _EntityHistory;

  factory fromJson(Map<String, dynamic> json) => _$EntityHistoryFromJson(json);
}

/// One recorded value; [value] is a number, a bool or a string by [kind].
@freezed
abstract class HistorySample with _$HistorySample {
  const factory({
    required DateTime at,
    @JsonKey(unknownEnumValue: HistorySampleKind.unknown)
    @Default(HistorySampleKind.unknown)
    HistorySampleKind kind,
    Object? value,
    String? unit,
  }) = _HistorySample;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$HistorySampleFromJson(json);

  /// [value] as a finite number (bools as 0/1); `null` for text and others.
  double? get numericValue => switch (value) {
    final num v when v.isFinite => v.toDouble(),
    final bool v => v ? 1 : 0,
    _ => null,
  };
}

/// A `from`–`to` range of one history request.
typedef HistoryRange = ({DateTime from, DateTime to});

/// Paging rules for the history endpoint, which has no cursor: the range
/// filter is `from <= at <= to` and a full page holds the oldest samples.
abstract final class HistoryPaging {
  /// Server limit range and default.
  static const minLimit = 1;
  static const maxLimit = 5000;
  static const defaultLimit = 1000;

  /// `from` of the request that continues after [page], or `null` when
  /// [page] was not truncated (fewer than [limit] samples) or reached `to`.
  /// The bound is inclusive, so the next page repeats the last sample;
  /// [mergePages] drops it. A full page that cannot advance (all samples at
  /// `page.from`) also yields `null`; [isStuck] tells that case apart.
  static DateTime? nextFrom(EntityHistory page, int limit) {
    if (page.samples.length < limit || page.samples.isEmpty) return null;
    final last = page.samples.last.at;
    if (!last.isAfter(page.from) || !last.isBefore(page.to)) return null;
    return last;
  }

  /// Whether [page] is full (truncated) but its boundary cannot move past
  /// `page.from`, so later samples of the range are unreachable.
  static bool isStuck(EntityHistory page, int limit) =>
      page.samples.isNotEmpty &&
      page.samples.length >= limit &&
      !page.samples.last.at.isAfter(page.from) &&
      page.samples.last.at.isBefore(page.to);

  /// Concatenates ascending pages. Only the inclusive boundary is
  /// deduplicated: leading samples of a page equal to samples the previous
  /// pages already hold at that same instant are dropped. Distinct samples
  /// that share an instant are kept.
  static List<HistorySample> mergePages(Iterable<EntityHistory> pages) {
    final merged = <HistorySample>[];
    for (final page in pages) {
      final boundary = merged.isEmpty ? null : merged.last.at;
      // Samples already merged at the boundary instant, consumed one by one.
      final seen = boundary == null
          ? <HistorySample>[]
          : [
              for (final s in merged.reversed.takeWhile(
                (s) => s.at == boundary,
              ))
                s,
            ];
      for (final sample in page.samples) {
        if (boundary != null && !sample.at.isAfter(boundary)) {
          if (seen.remove(sample)) continue;
          if (sample.at.isBefore(boundary)) continue;
        }
        merged.add(sample);
      }
    }
    return merged;
  }

  /// Splits `from`–`to` into consecutive slices of at most [slice]. Slices
  /// share their bounds; [mergePages] removes the duplicate boundary sample.
  static List<HistoryRange> slices(DateTime from, DateTime to, Duration slice) {
    if (slice <= Duration.zero) {
      throw ArgumentError.value(slice, 'slice', 'must be positive');
    }
    final ranges = <HistoryRange>[];
    var start = from;
    while (start.isBefore(to)) {
      final next = start.add(slice);
      final end = next.isBefore(to) ? next : to;
      ranges.add((from: start, to: end));
      start = end;
    }
    return ranges;
  }
}
