import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/golden.dart';

/// The golden harness itself (test/support/golden.dart).
void main() {
  group('localTimes', () {
    test('keeps the wall time of UTC timestamps, in the local zone', () {
      final json = localJson({
        'lastSeenAt': '2026-11-18T07:40:30.000Z',
        'nested': [
          {'createdAt': '2026-11-17T22:06:20.443Z'},
        ],
        'name': 'Z',
        'count': 2,
      });

      final lastSeen = DateTime.parse(json['lastSeenAt']! as String);
      expect(lastSeen.isUtc, isFalse);
      expect(lastSeen, DateTime(2026, 11, 18, 7, 40, 30));
      expect(goldenNow.difference(lastSeen), const Duration(seconds: 30));
      expect(json['nested'], [
        {'createdAt': '2026-11-17T22:06:20.443'},
      ]);
      expect(json['name'], 'Z');
      expect(json['count'], 2);
    });
  });

  testWidgets('a scenario gets its device size, locale and text scale', (
    tester,
  ) async {
    late MediaQueryData media;
    late Locale locale;
    await tester.pumpWidget(
      Center(
        child: SizedBox.fromSize(
          size: GoldenDevice.smallPhone.size,
          child: GoldenScreen(
            size: GoldenDevice.smallPhone.size,
            locale: const Locale('en'),
            textScale: 2,
            screen: () => Builder(
              builder: (context) {
                media = MediaQuery.of(context);
                locale = Localizations.localeOf(context);
                return const SizedBox();
              },
            ),
            overrides: () => const [],
          ),
        ),
      ),
    );

    expect(media.size, const Size(320, 568));
    expect(media.textScaler, const TextScaler.linear(2));
    expect(media.padding, EdgeInsets.zero);
    expect(locale, const Locale('en'));
  });

  testWidgets('an overflowing layout fails the layout check', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 100,
            child: Row(children: [SizedBox(width: 200, height: 20)]),
          ),
        ),
      ),
    );

    expect(() => expectNoLayoutErrors(tester), throwsA(isA<TestFailure>()));
  });

  testWidgets('a clean layout passes the layout check', (tester) async {
    await tester.pumpWidget(const SizedBox());

    expectNoLayoutErrors(tester);
  });
}
