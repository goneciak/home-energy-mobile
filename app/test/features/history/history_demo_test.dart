import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/demo/data/demo_core.dart';
import 'package:gi_home/src/features/history/data/history_source.dart';

import '../../support/history_fixtures.dart';
import '../demo/demo_core_test.dart' show demoFixtures;

/// The history screen in demo mode (plan §19.5): the synthetic 7-day change
/// log read in day slices, paged, without gaps or duplicates.
void main() {
  final now = DateTime.utc(2026, 11, 22, 7, 30);
  late DemoCore core;

  setUp(() => core = DemoCore.fromJsonString(demoFixtures(), now: () => now));

  test('7 days of the supply temperature, in small pages', () async {
    final from = now.subtract(const Duration(days: 7));
    final data = await SlicedHistorySource(
      demoHistoryReader(core, limit: 997, maxPages: 10),
    ).read(demoBoilerId, 'demo-supply', from: from, to: now);

    expect(data.complete, isTrue);
    expect(data.samples.length, greaterThan(15000));
    for (var i = 1; i < data.samples.length; i++) {
      expect(
        data.samples[i].at.isAfter(data.samples[i - 1].at),
        isTrue,
        reason: 'strictly ascending, no boundary duplicate at $i',
      );
    }
    // The same samples as one unsliced read.
    final whole = await demoHistoryReader(core, maxPages: 10)(
      demoBoilerId,
      'demo-supply',
      from,
      now,
    );
    expect(data.samples, whole.samples);
  });

  test('a relay log is boolean switch samples', () async {
    final data = await SlicedHistorySource(demoHistoryReader(core)).read(
      demoBoilerId,
      'demo-relay-boiler',
      from: now.subtract(const Duration(hours: 24)),
      to: now,
    );
    expect(data.samples, isNotEmpty);
    expect(data.samples.every((s) => s.value is bool), isTrue);
  });
}
