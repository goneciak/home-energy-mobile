import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/widgets/permission_state.dart';
import 'package:gi_home/src/core/widgets/skeleton.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/presentation/device_detail_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/accessibility.dart';
import '../../support/fake_device_source.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

void main() {
  late FakeDeviceSource source;
  final now = DateTime.utc(2026, 11, 18, 7, 41);
  late DateTime clock;
  final seeded = fixtureDetail();
  final rich = DeviceDetail.fromJson(entityRichDetailJson());

  setUp(() {
    clock = now;
    source = FakeDeviceSource(
      deviceList: fixtureDevices(),
      roomList: fixtureRooms(),
      details: {seeded.id: seeded, rich.id: rich},
    );
  });

  Future<void> pumpDetail(WidgetTester tester, String id) async {
    tester.view
      ..physicalSize = const Size(1200, 12000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testScreen(
        DeviceDetailScreen(deviceId: id),
        overrides: [
          deviceReadSourceProvider.overrideWithValue(source),
          currentUserProvider.overrideWithValue(null),
          appForegroundProvider.overrideWithValue(AppForeground()),
          clockProvider.overrideWithValue(() => clock),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder row(String label, String value) => find.ancestor(
    of: find.text(value),
    matching: find.ancestor(
      of: find.text(label),
      matching: find.byType(ListTile),
    ),
  );

  Finder entity(String id) => find.byKey(ValueKey('entity-$id'));

  Finder inEntity(String id, String text) =>
      find.descendant(of: entity(id), matching: find.text(text));

  testWidgets('the recorded device: no entities, no diagnostics', (
    tester,
  ) async {
    await pumpDetail(tester, seeded.id);

    expect(find.widgetWithText(AppBar, 'Czujnik bez pokoju'), findsOneWidget);
    expect(find.text('Łączenie…'), findsOneWidget);
    expect(find.text('Nieznany stan łączności'), findsOneWidget);
    expect(find.text('Jeszcze nie połączone'), findsOneWidget);
    expect(row('Pokój', 'Bez pokoju'), findsOneWidget);
    expect(row('Producent', '—'), findsOneWidget);
    expect(find.text('To urządzenie nie ma jeszcze elementów.'), findsOne);
    expect(
      find.text('Urządzenie nie przesłało jeszcze diagnostyki.'),
      findsOne,
    );
    // Fault count from the cached list, with its source; the list has no
    // controller state for this device.
    expect(row('Aktywne usterki', 'Brak usterek'), findsOneWidget);
    expect(find.textContaining('Z listy urządzeń · '), findsOneWidget);
    expect(row('Stan sterownika', '—'), findsOneWidget);
    expect(source.calls, containsAll(['device:${seeded.id}', 'devices']));
  });

  testWidgets('entities render whatever value type they carry', (tester) async {
    await pumpDetail(tester, rich.id);

    expect(find.widgetWithText(AppBar, 'Sterownik kotłowni'), findsOneWidget);
    expect(inEntity('ent-relay-boiler', 'Wł.'), findsOneWidget);
    expect(
      find.descendant(
        of: entity('ent-relay-boiler'),
        matching: find.textContaining('Przekaźnik kotła · Przełącznik'),
      ),
      findsOneWidget,
    );
    expect(inEntity('ent-relay-pump', 'Wył.'), findsOneWidget);
    expect(
      find.descendant(
        of: entity('ent-relay-pump'),
        matching: find.textContaining('Przekaźnik pompy'),
      ),
      findsOneWidget,
    );
    expect(inEntity('ent-supply', '54,3 °C'), findsOneWidget);
    expect(
      find.descendant(
        of: entity('ent-supply'),
        matching: find.textContaining('Temperatura sterująca · Czujnik'),
      ),
      findsOneWidget,
    );
    expect(inEntity('ent-mode', 'eco'), findsOneWidget);
    expect(inEntity('ent-blob', '{"target":21,"mode":"heat"}'), findsOne);
    expect(inEntity('ent-return', 'Niedostępny'), findsOneWidget);
    expect(inEntity('ent-old', 'Wyłączony'), findsOneWidget);
    expect(
      find.descendant(
        of: entity('ent-old'),
        matching: find.textContaining('Inny element'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('flags, room, information and diagnostics', (tester) async {
    await pumpDetail(tester, rich.id);

    expect(row('Pokój', 'Kotłownia'), findsOneWidget);
    expect(row('Producent', 'GI Industries'), findsOneWidget);
    expect(row('Model', 'kotlownia'), findsOneWidget);
    expect(row('Wersja oprogramowania', '1.4.2'), findsOneWidget);
    expect(row('Urządzenie grzewcze', 'Tak'), findsOneWidget);
    expect(row('Ogrzewanie wstrzymane', 'Nie'), findsOneWidget);
    expect(
      row('Tryb testowy (bez przełączania przekaźników)', 'Tak'),
      findsOneWidget,
    );
    expect(row('Dogrzewanie z nadwyżki PV', 'Tak'), findsOneWidget);
    expect(
      find.text('Tryb testowy: przekaźniki nie przełączają się fizycznie'),
      findsOneWidget,
    );
    expect(find.text('Działa'), findsOneWidget);
    expect(find.text('Połączone'), findsOneWidget);

    expect(row('Sygnał Wi-Fi', '-61 dBm'), findsOneWidget);
    expect(row('Czas pracy od uruchomienia', '1 d 2 godz.'), findsOneWidget);
    expect(row('Liczba uruchomień', '12'), findsOneWidget);
    expect(row('Wykryto pętlę restartów', 'Nie'), findsOneWidget);
    expect(row('Blokada bezpieczeństwa aktywna', 'Nie'), findsOneWidget);
    expect(row('Usterki w diagnostyce', '1'), findsOneWidget);
  });

  testWidgets('a fault only diagnostics report still asks for attention', (
    tester,
  ) async {
    await pumpDetail(tester, rich.id);

    // The recorded list has no currentState and no faults for it, received
    // at the same time as the details: the state comes from diagnostics,
    // the fault count from the list, but the diagnostics fault still counts.
    expect(row('Stan sterownika', 'Grzanie'), findsOneWidget);
    expect(find.textContaining('Z diagnostyki urządzenia · '), findsOneWidget);
    expect(row('Aktywne usterki', 'Brak usterek'), findsOneWidget);
    expect(find.textContaining('Z listy urządzeń · '), findsOneWidget);
    expect(row('Usterki w diagnostyce', '1'), findsOneWidget);
    expect(
      find.text('Wymaga uwagi – sprawdź urządzenie w panelu web.'),
      findsOneWidget,
    );
  });

  testWidgets('newer diagnostics replace an older list value', (tester) async {
    await pumpDetail(tester, rich.id);

    // The next detail poll arrives later than the cached list.
    clock = now.add(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(row('Aktywne usterki', '1 usterka'), findsOneWidget);
    expect(
      find.textContaining('Z diagnostyki urządzenia · '),
      findsNWidgets(2),
    );
  });

  testWidgets('a fault reported by the list asks for attention', (
    tester,
  ) async {
    source.deviceList = [
      listedDevice({
        'id': rich.id,
        'name': rich.name,
        'currentState': 'SAFE_MODE',
        'activeFaultCount': 2,
      }),
    ];
    await pumpDetail(tester, rich.id);

    expect(row('Stan sterownika', 'Tryb awaryjny'), findsOneWidget);
    expect(row('Aktywne usterki', '2 usterki'), findsOneWidget);
    expect(find.textContaining('Z listy urządzeń · '), findsNWidgets(2));
    expect(
      find.text('Wymaga uwagi – sprawdź urządzenie w panelu web.'),
      findsOneWidget,
    );
  });

  testWidgets('no write controls in this milestone', (tester) async {
    await pumpDetail(tester, rich.id);

    await expectNoWriteControls(tester);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('meets the accessibility guidelines', (tester) async {
    await pumpDetail(tester, rich.id);

    await expectAccessibilityGuidelines(tester);
  });

  testWidgets('details without an answer for 10 s are marked stale', (
    tester,
  ) async {
    await pumpDetail(tester, rich.id);
    expect(find.textContaining('Dane mogą być nieaktualne'), findsNothing);

    // The next poll (after 5 s) is still in flight 11 s after the data.
    final pending = Completer<void>();
    source.detailGate = pending.future;
    clock = now.add(const Duration(seconds: 11));
    await tester.pump(const Duration(seconds: 5));

    expect(
      find.textContaining('Dane mogą być nieaktualne (ostatnia aktualizacja'),
      findsOneWidget,
    );
    expect(inEntity('ent-supply', '54,3 °C'), findsOneWidget);

    pending.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('a failed refresh keeps the details and shows a banner', (
    tester,
  ) async {
    await pumpDetail(tester, rich.id);
    source.detailFailure = const ApiFailure.unreachable();

    // Pull far enough to arm the indicator on the tall test viewport.
    await tester.fling(find.byType(ListView), const Offset(0, 1600), 1000);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Brak połączenia z GI Home · dane z'),
      findsOneWidget,
    );
    expect(inEntity('ent-supply', '54,3 °C'), findsOneWidget);
  });

  testWidgets('a removed device says so', (tester) async {
    await pumpDetail(tester, 'gone');

    expect(find.text('Urządzenie zostało usunięte lub zmienione.'), findsOne);
  });

  testWidgets('a failed first load offers retry', (tester) async {
    source.detailFailure = const ApiFailure.server(statusCode: 503);
    await pumpDetail(tester, seeded.id);

    expect(find.text('Spróbuj ponownie'), findsOneWidget);

    source.detailFailure = null;
    await tester.tap(find.text('Spróbuj ponownie'));
    await tester.pumpAndSettle();

    expect(find.text('To urządzenie nie ma jeszcze elementów.'), findsOne);
  });

  testWidgets('the first load shows a skeleton, announced as loading', (
    tester,
  ) async {
    final pending = Completer<void>();
    source.detailGate = pending.future;
    await tester.pumpWidget(
      testScreen(
        DeviceDetailScreen(deviceId: rich.id),
        overrides: [
          deviceReadSourceProvider.overrideWithValue(source),
          currentUserProvider.overrideWithValue(null),
          appForegroundProvider.overrideWithValue(AppForeground()),
          clockProvider.overrideWithValue(() => clock),
        ],
      ),
    );
    await tester.pump();

    expect(find.byType(Skeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.bySemanticsLabel('Ładowanie…'), findsOneWidget);

    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(Skeleton), findsNothing);
    expect(find.widgetWithText(AppBar, 'Sterownik kotłowni'), findsOneWidget);
  });

  testWidgets('a 403 says the role has no access, with no retry', (
    tester,
  ) async {
    source.detailFailure = const ApiFailure.forbidden(code: 'HTTP_403');
    await pumpDetail(tester, rich.id);

    expect(find.byType(PermissionState), findsOneWidget);
    expect(find.text('Brak dostępu'), findsOneWidget);
    expect(find.text('Spróbuj ponownie'), findsNothing);
    expect(find.text('Zamknij'), findsOneWidget);
    await expectAccessibilityGuidelines(tester);

    // Nothing is asked again behind the user's back.
    await tester.pump(const Duration(minutes: 1));
    expect(source.calls.where((c) => c == 'device:${rich.id}'), hasLength(1));
  });

  testWidgets('touching the details keeps the 5 s cadence (plan §11)', (
    tester,
  ) async {
    await pumpDetail(tester, rich.id);
    int runs() => source.calls.where((c) => c == 'device:${rich.id}').length;
    // The phone clock follows the test's fake time, 1 s at a time.
    Future<void> wait(Duration duration) async {
      for (var s = 0; s < duration.inSeconds; s++) {
        clock = clock.add(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
      }
    }

    await wait(const Duration(seconds: 100));
    await tester.drag(find.byType(ListView), const Offset(0, -40));
    await wait(const Duration(seconds: 90));
    var before = runs();
    await wait(const Duration(seconds: 25));
    expect(runs() - before, 5, reason: 'still every 5 s at 3:35');

    // Untouched since 1:40: idle from 3:40, then every 15 s.
    await wait(const Duration(seconds: 10));
    before = runs();
    await wait(const Duration(seconds: 30));
    expect(runs() - before, 2);

    // A touch on a section header, which navigates nowhere.
    await tester.tap(find.text('Stan'));
    await wait(const Duration(seconds: 10));
    expect(runs() - before, 2 + 3, reason: 'at once, then every 5 s');
  });
}
