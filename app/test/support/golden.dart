import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import 'accessibility.dart';

/// Screen sizes of the golden matrix (plan §17.1, §9.4), in logical pixels.
enum GoldenDevice {
  smallPhone('small_phone', Size(320, 568)),
  largePhone('large_phone', Size(430, 932)),

  /// Android 16 ignores orientation locks on large screens (plan §9.4).
  tabletLandscape('tablet_landscape', Size(840, 600));

  new(this.fileSuffix, this.size);

  final String fileSuffix;
  final Size size;
}

/// Languages and text scales of the golden matrix (plan §17.1).
const goldenLocales = [Locale('pl'), Locale('en')];
const goldenTextScales = [1.0, 1.3, 2.0];

/// The fixed "now" of every golden: a local wall time, so clock times read
/// the same in every time zone (07:41, one minute after the recorded
/// fixtures' `07:40:30`).
final goldenNow = DateTime(2026, 11, 18, 7, 41);

/// [json] with every UTC timestamp (`…Z`) turned into the same wall time
/// in the local zone, to go with [goldenNow]: the recorded fixtures are in
/// UTC, and both `toLocal()` and the ages measured from [goldenNow] would
/// otherwise depend on the time zone of the machine.
Object? localTimes(Object? json) => switch (json) {
  final Map<String, Object?> map => {
    for (final MapEntry(:key, :value) in map.entries) key: localTimes(value),
  },
  final List<Object?> list => [for (final item in list) localTimes(item)],
  final String text when _utcTimestamp.hasMatch(text) => text.substring(
    0,
    text.length - 1,
  ),
  _ => json,
};

final _utcTimestamp = RegExp(r'^\d{4}-\d{2}-\d{2}T[\d:.]+Z$');

/// [localTimes] of a JSON object.
Map<String, Object?> localJson(Map<String, Object?> json) =>
    localTimes(json)! as Map<String, Object?>;

/// Golden tests of one screen state on every [GoldenDevice]: one image per
/// device (`goldens/ci/<fileName>_<device>.png`) holding a scenario per
/// language and text scale.
///
/// [screen] and [overrides] are called once per scenario, after [prepare]
/// (which may set up what the overrides return, e.g. preferences). After
/// [settle], [act] can move the screens to the state under test, e.g. let a
/// poll fail. Every state is then checked for layout errors (a RenderFlex
/// overflow fails the test) and against the accessibility guidelines,
/// text contrast included, before it is compared with the golden.
@isTest
void screenGoldens(
  String description, {
  required String fileName,
  required Widget Function() screen,
  List<Override> Function()? overrides,
  Future<void> Function(WidgetTester tester)? prepare,
  PumpAction settle = onlyPumpAndSettle,
  Future<void> Function(WidgetTester tester)? act,
  Iterable<GoldenDevice> devices = GoldenDevice.values,
}) {
  for (final device in devices) {
    // Declares the test synchronously; the future only tracks that.
    unawaited(
      goldenTest(
        '$description (${device.fileSuffix})',
        fileName: '${fileName}_${device.fileSuffix}',
        pumpWidget: (tester, widget) async {
          await prepare?.call(tester);
          await tester.pumpWidget(widget);
        },
        pumpBeforeTest: (tester) async {
          await settle(tester);
          await act?.call(tester);
        },
        whilePerforming: (tester) async {
          expectNoLayoutErrors(tester);
          await expectAccessibilityGuidelines(tester);
          return null;
        },
        builder: () => GoldenTestGroup(
          columns: goldenTextScales.length,
          children: [
            for (final locale in goldenLocales)
              for (final textScale in goldenTextScales)
                GoldenTestScenario(
                  // ASCII only: the CI goldens draw the labels in Ahem, and a
                  // glyph missing there would fall back to a host font.
                  name:
                      '${locale.languageCode} '
                      'text ${textScale.toStringAsFixed(1)}x',
                  constraints: BoxConstraints.tight(device.size),
                  child: GoldenScreen(
                    size: device.size,
                    locale: locale,
                    textScale: textScale,
                    screen: screen,
                    overrides: overrides ?? () => const [],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// No layout error (such as a RenderFlex overflow) was reported while the
/// screens were built and laid out.
void expectNoLayoutErrors(WidgetTester tester) {
  final error = tester.takeException();
  expect(
    error,
    isNull,
    reason: 'the screen reported a layout error, e.g. a RenderFlex overflow',
  );
}

/// One app screen as a phone or tablet of [size] shows it: the app theme,
/// [locale] and [textScale], its own [ProviderScope] with [overrides].
class GoldenScreen extends StatefulWidget {
  const new({
    required this.size,
    required this.locale,
    required this.textScale,
    required this.screen,
    required this.overrides,
    super.key,
  });

  final Size size;
  final Locale locale;
  final double textScale;
  final Widget Function() screen;
  final List<Override> Function() overrides;

  @override
  State<GoldenScreen> createState() => _GoldenScreenState();
}

class _GoldenScreenState extends State<GoldenScreen> {
  // Created once: a ProviderScope keeps its overrides for its lifetime.
  late final List<Override> _overrides = widget.overrides();
  late final Widget _screen = widget.screen();

  @override
  Widget build(BuildContext context) => ProviderScope(
    retry: (retryCount, error) => null,
    overrides: _overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      locale: widget.locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // The app's MediaQuery comes from the test view, which holds all the
      // scenarios: give each one the size and text scale of its device.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          size: widget.size,
          padding: EdgeInsets.zero,
          viewPadding: EdgeInsets.zero,
          viewInsets: EdgeInsets.zero,
          textScaler: TextScaler.linear(widget.textScale),
        ),
        child: child!,
      ),
      home: _screen,
    ),
  );
}
