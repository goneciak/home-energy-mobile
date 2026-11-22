import 'package:flutter/services.dart';
import 'package:flutter_driver/flutter_driver.dart'
    show Timeline, TimelineSummary;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:gi_home/src/features/demo/data/demo_core.dart';
import 'package:gi_home/src/features/history/application/history_providers.dart';
import 'package:gi_home/src/features/history/data/history_source.dart';
import 'package:gi_home/src/features/history/domain/history_window.dart';
import 'package:gi_home/src/features/history/presentation/history_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

// The demo reader is shared with the host tests.
import '../../test/support/history_fixtures.dart';

/// Performance budget of the history screen (plan §20 M3): a 7-day range
/// is on screen within 3 s on a mid-range Android phone.
///
/// The data is demo mode's synthetic 7-day change log of the supply
/// temperature (~17 600 samples, one change every ~30 s) served by the
/// in-process demo GI Core as real JSON, read in parallel day slices and
/// paged; LTTB runs in its isolate, as in the app. The measured time runs
/// from the first frame of the screen to the chart being laid out, and the
/// frame timeline of that span is reported as `history_7d` (build and
/// raster percentiles, missed frames).
///
/// From `app/`, on a profile build of a real device:
/// `flutter drive --profile --flavor dev`
/// `--dart-define-from-file=config/dev.json`
/// `--driver=test_driver/perf_driver.dart` (any `integrationDriver` with
/// a `responseDataCallback` that writes the timeline summary)
/// `--target=integration_test/perf/history_7d_benchmark_test.dart -d <id>`,
/// or as a plain run (`flutter test integration_test/perf/... -d <id>`),
/// which still enforces the budget.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('7-day history renders within 3 s', (tester) async {
    final fixtures = await rootBundle.loadString(
      'assets/demo_fixtures/demo_core.json',
    );
    final now = DateTime.now();
    final core = DemoCore.fromJsonString(fixtures, now: () => now);
    final source = SlicedHistorySource(demoHistoryReader(core));
    final chart = find.byKey(const ValueKey('history-chart'));

    final stopwatch = Stopwatch();
    await binding.traceAction(() async {
      stopwatch.start();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historySourceProvider.overrideWithValue(source),
            clockProvider.overrideWithValue(() => now),
            historyEntityProvider(
              demoBoilerId,
              'demo-supply',
            ).overrideWithValue(null),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            locale: const Locale('pl'),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HistoryScreen(
              deviceId: demoBoilerId,
              entityId: 'demo-supply',
              initialWindow: HistoryWindow.week,
            ),
          ),
        ),
      );
      // Real time passes between pumps here; pump(duration) does not wait.
      final deadline = DateTime.now().add(const Duration(seconds: 30));
      while (chart.evaluate().isEmpty) {
        if (DateTime.now().isAfter(deadline)) fail('the chart never showed');
        await Future<void>.delayed(const Duration(milliseconds: 8));
        await tester.pump();
      }
      stopwatch.stop();
    }, reportKey: 'history_7d_timeline');

    final timeline = binding.reportData?['history_7d_timeline'];
    if (timeline is Map<String, dynamic>) {
      final summary = TimelineSummary.summarize(Timeline.fromJson(timeline));
      binding.reportData!['history_7d'] = summary.summaryJson;
    }
    binding.reportData ??= <String, dynamic>{};
    binding.reportData!['history_7d_render_ms'] = stopwatch.elapsedMilliseconds;
    debugPrint('history 7d: rendered in ${stopwatch.elapsedMilliseconds} ms');
    expect(stopwatch.elapsed, lessThanOrEqualTo(const Duration(seconds: 3)));
  });
}
