import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/history/application/history_downsampler.dart';
import 'package:gi_home/src/features/history/data/history_source.dart';
import 'package:gi_home/src/features/history/domain/history_series.dart';
import 'package:gi_home/src/features/history/domain/history_window.dart';
import 'package:gi_home/src/features/history/domain/lttb.dart';

List<ChartPoint> line(List<double> ys) => [
  for (var i = 0; i < ys.length; i++) (x: i.toDouble(), y: ys[i]),
];

HistorySample sample(int minute, Object value) => HistorySample(
  at: DateTime.utc(2026, 11, 22).add(Duration(minutes: minute)),
  kind: value is bool
      ? HistorySampleKind.switch_
      : value is num
      ? HistorySampleKind.temperature
      : HistorySampleKind.text,
  value: value,
);

void main() {
  group('lttb', () {
    test('passes through a series not longer than the threshold', () {
      final data = line([1, 5, 2, 8]);
      expect(lttb(data, 4), same(data));
      expect(lttb(data, 10), same(data));
      // Fewer than 3 buckets cannot keep both ends and a middle.
      expect(lttb(data, 2), same(data));
    });

    test('returns exactly threshold points, keeping first and last', () {
      final data = line([for (var i = 0; i < 1000; i++) (i % 17).toDouble()]);
      final sampled = lttb(data, 100);
      expect(sampled, hasLength(100));
      expect(sampled.first, data.first);
      expect(sampled.last, data.last);
      final xs = [for (final p in sampled) p.x];
      expect(xs, orderedEquals([...xs]..sort()), reason: 'ascending x');
    });

    test('keeps a lone spike and a lone dip', () {
      final ys = List<double>.filled(5000, 45);
      ys[1234] = 80;
      ys[3721] = 10;
      final sampled = lttb(line(ys), 50);
      expect(sampled, contains((x: 1234.0, y: 80.0)));
      expect(sampled, contains((x: 3721.0, y: 10.0)));
    });
  });

  group('expandSteps', () {
    test('holds each value until the next change and until the end', () {
      final steps = expandSteps([
        (x: 0, y: 1),
        (x: 10, y: 3),
        (x: 20, y: 3),
        (x: 30, y: 2),
      ], endX: 40);
      expect(steps, [
        (x: 0.0, y: 1.0),
        (x: 10.0, y: 1.0),
        (x: 10.0, y: 3.0),
        // An unchanged value needs no vertical jump.
        (x: 20.0, y: 3.0),
        (x: 30.0, y: 3.0),
        (x: 30.0, y: 2.0),
        (x: 40.0, y: 2.0),
      ]);
    });

    test('is empty without points and never extends backwards', () {
      expect(expandSteps(const [], endX: 5), isEmpty);
      expect(expandSteps([(x: 10, y: 1)], endX: 5), [(x: 10.0, y: 1.0)]);
    });

    test('stepChartPoints keeps at most two points per kept change', () {
      final changes = line([for (var i = 0; i < 20000; i++) (i % 7) * 1.0]);
      final points = stepChartPoints(changes, threshold: 400, endX: 30000);
      expect(points.length, lessThanOrEqualTo(2 * 400 + 1));
      expect(points.first, changes.first);
      expect(points.last, (x: 30000.0, y: changes.last.y));
      for (var i = 1; i < points.length; i++) {
        final a = points[i - 1];
        final b = points[i];
        expect(
          a.x == b.x || a.y == b.y,
          isTrue,
          reason: 'only horizontal and vertical segments ($a → $b)',
        );
      }
    });
  });

  group('changePoints and HistorySummary', () {
    final samples = [
      sample(0, 41.5),
      sample(5, 47.25),
      sample(9, 'tekst'),
      sample(12, 39),
    ];

    test('switches become 0/1 and text is left out', () {
      expect(
        changePoints([sample(0, true), sample(1, false)]).map((p) => p.y),
        [1, 0],
      );
      expect(changePoints(samples), hasLength(3));
    });

    test('summary of numbers: min, max, latest and count', () {
      final summary = HistorySummary.of(samples);
      expect(summary.min, 39);
      expect(summary.max, 47.25);
      expect(summary.last, samples.last);
      expect(summary.count, 4);
    });

    test('a switch has no min or max', () {
      final summary = HistorySummary.of([sample(0, true), sample(1, false)]);
      expect(summary.min, isNull);
      expect(summary.max, isNull);
      expect(summary.last?.value, false);
    });
  });

  group('slices and paging', () {
    final from = DateTime.utc(2026, 11, 15);
    final to = DateTime.utc(2026, 11, 22);
    // One change every 2 minutes for 7 days: 5040 samples.
    final all = [
      for (var m = 0; m < 7 * 24 * 60; m += 2)
        HistorySample(
          at: from.add(Duration(minutes: m)),
          kind: HistorySampleKind.numeric,
          value: m,
        ),
    ];

    /// The server: `from <= at <= to`, ascending, the OLDEST [limit].
    EntityHistory serve(DateTime f, DateTime t, int limit) => EntityHistory(
      entityId: 'e',
      from: f,
      to: t,
      samples: all
          .where((s) => !s.at.isBefore(f) && !s.at.isAfter(t))
          .take(limit)
          .toList(),
    );

    /// A reader paging like `GiCoreClient.entityHistoryAll`.
    HistoryRangeReader pagingReader(int limit, {int maxPages = 100}) =>
        (deviceId, entityId, f, t) async {
          final pages = <EntityHistory>[];
          DateTime? next = f;
          while (next != null && pages.length < maxPages) {
            final page = serve(next, t, limit);
            pages.add(page);
            next = HistoryPaging.nextFrom(page, limit);
          }
          return (
            samples: HistoryPaging.mergePages(pages),
            complete: next == null,
          );
        };

    test(
      'day slices with small pages read every sample exactly once',
      () async {
        final data = await SlicedHistorySource(pagingReader(97))
            .read('d', 'e', from: from, to: to);
        expect(data.complete, isTrue);
        expect(data.samples.map((s) => s.at), all.map((s) => s.at));
      },
    );

    test('the boundary sample shared by two slices is kept once', () {
      final merged = mergeSlices([
        [all[0], all[1], all[2]],
        [all[2], all[3]],
        [all[3], all[4]],
      ]);
      expect(merged, [all[0], all[1], all[2], all[3], all[4]]);
    });

    test('running out of pages marks the range incomplete', () async {
      final data = await SlicedHistorySource(pagingReader(100, maxPages: 2))
          .read('d', 'e', from: from, to: to);
      expect(data.complete, isFalse);
      // The oldest part of each day slice.
      expect(data.samples.first.at, from);
    });

    test('HistoryWindow.parse falls back to 24 h', () {
      expect(HistoryWindow.parse('week'), HistoryWindow.week);
      expect(HistoryWindow.parse('nonsense'), HistoryWindow.day);
      expect(HistoryWindow.parse(null), HistoryWindow.day);
    });
  });

  group('downsampleInIsolate', () {
    test('runs LTTB on a worker isolate, not on the calling one', () async {
      final changes = line([for (var i = 0; i < 20000; i++) (i % 11) * 1.0]);
      final series = await downsampleInIsolate(
        changes,
        threshold: 500,
        endX: 30000,
      );
      expect(series.worker, historyWorkerName);
      expect(series.worker, isNot(Isolate.current.debugName));
      expect(series.sourceCount, 20000);
      expect(series.points.length, lessThanOrEqualTo(1001));
      expect(
        series.points,
        stepChartPoints(changes, threshold: 500, endX: 30000),
      );
    });

    test('a short series is only expanded, without an isolate', () async {
      final series = await downsampleInIsolate(
        line([1, 2]),
        threshold: 500,
        endX: 5,
      );
      expect(series.worker, isNull);
      expect(series.points, hasLength(4));
    });
  });
}
