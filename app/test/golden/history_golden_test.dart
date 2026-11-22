@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/history/domain/history_window.dart';
import 'package:gi_home/src/features/history/presentation/history_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../support/golden.dart';
import '../support/history_fixtures.dart';

/// Entity history (plan §4.2, path 6): the step chart of a temperature and
/// of a relay, the accessible table and the empty change log. The app has
/// one (dark) theme (D11), so there is no light variant.
void main() {
  const phones = [GoldenDevice.smallPhone, GoldenDevice.largePhone];

  FakeHistorySource source() => FakeHistorySource(
    series: {
      supplyEntityId: [
        ...temperatureSamples(
          end: historyNow.subtract(const Duration(days: 1)),
          span: const Duration(days: 6),
          step: const Duration(minutes: 30),
        ),
        ...temperatureSamples(),
      ],
      relayEntityId: switchSamples(),
    },
  );

  screenGoldens(
    'History: temperature, 24 h',
    fileName: 'history_temperature_day',
    screen: () => const HistoryScreen(
      deviceId: historyDeviceId,
      entityId: supplyEntityId,
    ),
    overrides: () => historyOverrides(source()),
  );

  screenGoldens(
    'History: temperature, 7 days',
    fileName: 'history_temperature_week',
    devices: phones,
    screen: () => const HistoryScreen(
      deviceId: historyDeviceId,
      entityId: supplyEntityId,
      initialWindow: HistoryWindow.week,
    ),
    overrides: () => historyOverrides(source()),
  );

  screenGoldens(
    'History: relay on/off band',
    fileName: 'history_relay_day',
    devices: phones,
    screen: () =>
        const HistoryScreen(deviceId: historyDeviceId, entityId: relayEntityId),
    overrides: () => historyOverrides(source()),
  );

  screenGoldens(
    'History: as a table',
    fileName: 'history_table',
    devices: phones,
    screen: () => const HistoryScreen(
      deviceId: historyDeviceId,
      entityId: supplyEntityId,
    ),
    overrides: () => historyOverrides(source()),
    act: (tester) async {
      final toggles = find.byKey(const ValueKey('history-toggle-table'));
      for (final element in toggles.evaluate().toList()) {
        await Scrollable.ensureVisible(element, alignment: 0.5);
        await tester.pumpAndSettle();
        final button = element.widget as TextButton;
        button.onPressed!();
        await tester.pumpAndSettle();
      }
    },
  );

  screenGoldens(
    'History: no changes recorded',
    fileName: 'history_empty',
    devices: phones,
    screen: () => const HistoryScreen(
      deviceId: historyDeviceId,
      entityId: supplyEntityId,
    ),
    overrides: () => historyOverrides(FakeHistorySource()),
  );
}
