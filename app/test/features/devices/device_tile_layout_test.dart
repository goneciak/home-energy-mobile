import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/devices/presentation/device_tile.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fixtures.dart';
import '../../support/test_app.dart';

void main() {
  final now = DateTime.utc(2026, 11, 18, 7, 41);

  testWidgets(
    'a long Polish name with every badge fits 320 dp at text scale 1.5',
    (tester) async {
      tester.view
        ..physicalSize = const Size(320, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final device = listedDevice({
        'name': 'Sterownik kotłowni w piwnicy – źródło ciepła zażółć gęślą',
        'dryRun': true,
        'heatingSuspended': true,
        'activeFaultCount': 3,
        'enabled': false,
        'isHeating': true,
      });
      await tester.pumpWidget(
        testScreen(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 900),
              textScaler: TextScaler.linear(1.5),
            ),
            child: Scaffold(
              body: DeviceTile(device: device, now: now, onTap: () {}),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('zażółć gęślą'), findsOneWidget);
    },
  );

  testWidgets('150 tiles in a lazily built list do not break the layout', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final devices = [
      for (var i = 0; i < 150; i++) listedDevice({'name': 'Urządzenie $i'}),
    ];
    await tester.pumpWidget(
      testScreen(
        Scaffold(
          body: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (_, i) =>
                DeviceTile(device: devices[i], now: now, onTap: () {}),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Urządzenie 0'), findsOneWidget);
    // Built on demand, not all at once.
    expect(find.byType(DeviceTile).evaluate().length, lessThan(20));
  });
}
