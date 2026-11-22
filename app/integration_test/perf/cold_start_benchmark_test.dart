import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/app/bootstrap.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/devices/presentation/device_tile.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cold start budget (plan M4): from launching the app with a saved
/// appliance and session to the Home device list on screen, 90th percentile
/// of 20 runs within 5 s on a phone in the same LAN as the Raspberry Pi.
///
/// This scaffold measures the app's own part of that: `runGiHome` (session
/// restore, the first device list) until the first `DeviceTile` is laid out,
/// restarted `COLD_RUNS` times in one process after a single login. The process
/// start and the engine start are not included; for those, time real
/// launches with `adb shell am start -W` (see docs/development.md). The
/// figure that counts is the release build on a real phone against the real
/// appliance; run it there and give the milliseconds to
/// `dart run tools/load/cold_start_p90.dart`.
///
/// From `app/`, release or profile build on a device, dev flavor:
/// `flutter test integration_test/perf/cold_start_benchmark_test.dart`
/// `-d <id> --flavor dev --dart-define-from-file=config/dev.json`
/// `--dart-define=GI_DEV_EMAIL=... --dart-define=GI_DEV_PASSWORD=...`
/// `--dart-define=GI_CORE_ADDRESS=<pi>:3000 --dart-define=COLD_RUNS=20`
///
/// Every run prints `COLD_START_MS=<n>`.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const email = String.fromEnvironment('GI_DEV_EMAIL');
  const password = String.fromEnvironment('GI_DEV_PASSWORD');
  const address = String.fromEnvironment('GI_CORE_ADDRESS');
  const runs = int.fromEnvironment('COLD_RUNS', defaultValue: 20);
  const limit = Duration(seconds: 5);

  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for $finder');
      }
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('Home is on screen within 5 s (p90 of $runs starts)', (
    tester,
  ) async {
    expect(
      email.isNotEmpty && password.isNotEmpty && address.isNotEmpty,
      isTrue,
      reason: 'Pass GI_DEV_EMAIL, GI_DEV_PASSWORD and GI_CORE_ADDRESS.',
    );
    tester.testTextInput.register();
    addTearDown(tester.testTextInput.unregister);

    // One login (GI Core allows 5 per minute): connect and sign in once,
    // then every run restores that session.
    await SharedPreferencesAsync().clear();
    await const FlutterSecureStorage().deleteAll();
    await runGiHome(config: AppConfig.fromEnvironment(AppFlavor.dev));
    await waitFor(tester, find.byType(TextFormField));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    );
    await tester.enterText(find.byType(TextFormField), address);
    await tester.tap(find.text(l10n.connectSubmit));
    await tester.pump();
    await waitFor(tester, find.text(l10n.connectConfirmYes));
    await tester.tap(find.text(l10n.connectConfirmYes));
    await tester.pump();
    await waitFor(tester, find.text(l10n.loginTitle));
    await tester.enterText(find.byType(TextFormField).first, email);
    await tester.enterText(find.byType(TextFormField).last, password);
    await tester.tap(find.widgetWithText(FilledButton, l10n.loginSubmit));
    await tester.pump();
    await waitFor(tester, find.byType(DeviceTile));

    final millis = <int>[];
    for (var i = 0; i < runs; i++) {
      // Drop the running app, then start it again from its saved state.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));

      final stopwatch = Stopwatch()..start();
      await runGiHome(config: AppConfig.fromEnvironment(AppFlavor.dev));
      await waitFor(tester, find.byType(DeviceTile));
      stopwatch.stop();

      millis.add(stopwatch.elapsedMilliseconds);
      // The log line `tools/load/cold_start_p90.dart` reads.
      // ignore: avoid_print
      print('COLD_START_MS=${stopwatch.elapsedMilliseconds}');
    }

    binding.reportData = {'coldStartMs': millis};
    final sorted = [...millis]..sort();
    final p90 = sorted[(0.9 * sorted.length).ceil() - 1];
    expect(
      p90,
      lessThanOrEqualTo(limit.inMilliseconds),
      reason: 'p90 of $runs starts: $p90 ms',
    );
  });
}
