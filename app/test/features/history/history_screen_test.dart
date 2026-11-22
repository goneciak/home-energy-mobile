import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/history/domain/history_window.dart';
import 'package:gi_home/src/features/history/presentation/history_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/history_fixtures.dart';
import '../../support/test_app.dart';

/// Scrolls [finder] to the middle of the list, clear of the app bar.
Future<void> centre(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
}

void main() {
  Future<FakeHistorySource> pumpHistory(
    WidgetTester tester, {
    FakeHistorySource? source,
    String entityId = supplyEntityId,
    HistoryWindow window = HistoryWindow.day,
  }) async {
    final fake =
        source ??
        FakeHistorySource(
          series: {
            supplyEntityId: temperatureSamples(),
            relayEntityId: switchSamples(),
          },
        );
    await tester.pumpWidget(
      testScreen(
        HistoryScreen(
          deviceId: historyDeviceId,
          entityId: entityId,
          initialWindow: window,
        ),
        overrides: historyOverrides(fake),
      ),
    );
    await tester.pumpAndSettle();
    return fake;
  }

  testWidgets('the chart reads as a summary to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpHistory(tester);

    expect(find.byType(LineChart), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp(
          r'^Wykres: Temperatura zasilania, ostatnia doba\. '
          r'Najniżej \d+,\d °C, najwyżej \d+,\d °C, ostatnio \d+,\d °C o .+\. '
          r'Zapisanych zmian: \d+\.$',
        ),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('a switch reads its latest state and the toggles', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpHistory(tester, entityId: relayEntityId);

    expect(
      find.bySemanticsLabel(
        RegExp(
          r'^Wykres: Przekaźnik kotła, ostatnia doba\. Ostatnio '
          r'(wł\.|wył\.) o .+\. Zapisanych przełączeń: \d+\.$',
        ),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('"Pokaż jako tabelę" swaps the chart for paged rows', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpHistory(tester);
    final toggle = find.byKey(const ValueKey('history-toggle-table'));

    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsNothing);
    expect(find.byKey(const ValueKey('history-table')), findsOneWidget);
    expect(find.text('Pokaż wykres'), findsOneWidget);
    // Each row is one screen reader node: "time: value".
    expect(
      find.bySemanticsLabel(RegExp(r'^.+: \d+,\d °C$')),
      findsNWidgets(50),
    );
    expect(find.textContaining('Strona 1 z'), findsOneWidget);

    final older = find.byKey(const ValueKey('history-table-older'));
    await centre(tester, older);
    await tester.tap(older);
    await tester.pumpAndSettle();
    expect(find.textContaining('Strona 2 z'), findsOneWidget);

    await centre(tester, toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.byType(LineChart), findsOneWidget);
    handle.dispose();
  });

  testWidgets('no samples: the change-log explanation', (tester) async {
    await pumpHistory(tester, source: FakeHistorySource());

    expect(find.text('Brak zmian w tym okresie'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('a truncated range says only part is shown', (tester) async {
    await pumpHistory(
      tester,
      source: FakeHistorySource(
        series: {supplyEntityId: temperatureSamples()},
        complete: false,
      ),
    );

    expect(find.byKey(const ValueKey('history-truncated')), findsOneWidget);
  });

  testWidgets('HISTORY_RANGE_INVALID and DEVICE_ENTITY_NOT_FOUND', (
    tester,
  ) async {
    await pumpHistory(
      tester,
      source: FakeHistorySource(
        error: const ApiFailure.domain(
          statusCode: 400,
          code: GiErrorCodes.historyRangeInvalid,
        ),
      ),
    );
    expect(find.textContaining('odrzucił ten zakres czasu'), findsOneWidget);

    await pumpHistory(
      tester,
      source: FakeHistorySource(
        error: const ApiFailure.notFound(
          code: GiErrorCodes.deviceEntityNotFound,
        ),
      ),
    );
    expect(find.text('Spróbuj ponownie'), findsOneWidget);
    expect(find.textContaining('odrzucił'), findsNothing);
  });

  testWidgets('choosing 7 days reads the week ending now', (tester) async {
    final source = await pumpHistory(tester);

    await tester.tap(find.byKey(const ValueKey('history-window-week')));
    await tester.pumpAndSettle();

    final read = source.reads.last;
    expect(read.to, historyNow.toUtc());
    expect(read.to.difference(read.from), const Duration(days: 7));
    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('a text reading is shown only as a table', (tester) async {
    await pumpHistory(
      tester,
      source: FakeHistorySource(
        series: {
          supplyEntityId: [
            HistorySample(
              at: historyNow.toUtc().subtract(const Duration(hours: 1)),
              kind: HistorySampleKind.text,
              value: 'OK',
            ),
          ],
        },
      ),
    );

    expect(find.byType(LineChart), findsNothing);
    expect(find.byKey(const ValueKey('history-table')), findsOneWidget);
    expect(find.byKey(const ValueKey('history-toggle-table')), findsNothing);
  });
}
