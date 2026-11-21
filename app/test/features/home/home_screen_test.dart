import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/widgets/permission_state.dart';
import 'package:gi_home/src/core/widgets/skeleton.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/home/presentation/home_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/accessibility.dart';
import '../../support/fake_device_source.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

void main() {
  late FakeDeviceSource source;
  final now = DateTime.utc(2026, 11, 18, 7, 41);
  late DateTime clock;

  setUp(() {
    clock = now;
    source = FakeDeviceSource(
      deviceList: fixtureDevices(),
      roomList: fixtureRooms(),
    );
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    Size physicalSize = const Size(1200, 4000),
  }) async {
    tester.view
      ..physicalSize = physicalSize
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testScreen(
        const HomeScreen(),
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

  testWidgets('recorded devices are grouped by the recorded rooms', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(
      _top(tester, find.text('Kotłownia')),
      lessThan(_top(tester, find.text('Salon'))),
    );
    expect(
      _top(tester, find.text('Salon')),
      lessThan(_top(tester, find.text('Bez pokoju'))),
    );
    expect(
      _top(tester, find.text('Kotłownia')),
      lessThan(
        _top(tester, find.byKey(const ValueKey('device-${_Ids.boiler}'))),
      ),
    );
    expect(
      _top(tester, find.byKey(const ValueKey('device-${_Ids.lamp}'))),
      lessThan(_top(tester, find.text('Bez pokoju'))),
    );
    expect(
      _top(tester, find.text('Bez pokoju')),
      lessThan(
        _top(tester, find.byKey(const ValueKey('device-${_Ids.sensor}'))),
      ),
    );
    // No device has reported yet: limited data, never "all good".
    expect(find.text('Ograniczone dane'), findsOneWidget);
    expect(find.text('Wszystko w porządku'), findsNothing);
    expect(find.text('Wymaga sprawdzenia'), findsOneWidget);
    expect(
      find.text('Urządzenie nie przesłało jeszcze danych'),
      findsNWidgets(3),
    );
    expect(find.text('Jeszcze nie połączone'), findsNWidgets(3));
    expect(find.text('Nieznany stan łączności'), findsNWidgets(3));
    // Home never asks for details of non-heating devices.
    expect(source.calls.toSet(), {'devices', 'rooms'});
  });

  testWidgets('heating devices and safety cues are marked on the tiles', (
    tester,
  ) async {
    source.deviceList = [
      listedDevice({
        'id': 'heat',
        'name': 'Kocioł',
        'connectivityState': 'ONLINE',
        'lastSeenAt': now
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
        'heatingRelayEntityId': 'relay',
        'heatingSuspended': true,
        'dryRun': true,
        'activeFaultCount': 2,
      }),
      listedDevice({
        'id': 'lamp',
        'name': 'Lampa',
        'connectivityState': 'ONLINE',
        'lastSeenAt': now.toIso8601String(),
      }),
    ];
    source.details['heat'] = fixtureDetail({
      ...entityRichDetailJson(),
      'id': 'heat',
      'roomId': null,
      'diagnostics': null,
    });
    await pumpHome(tester);

    final heatingTile = find.byKey(const ValueKey('device-heat'));
    Finder inHeating(String text) =>
        find.descendant(of: heatingTile, matching: find.text(text));
    expect(inHeating('Urządzenie grzewcze · Bez pokoju'), findsOneWidget);
    expect(inHeating('Ogrzewanie wstrzymane'), findsOneWidget);
    expect(inHeating('Tryb testowy'), findsOneWidget);
    expect(inHeating('2 usterki'), findsOneWidget);
    expect(inHeating('Ostatnio widziane 5 min temu'), findsOneWidget);
    expect(
      find.descendant(
        of: heatingTile,
        matching: find.byIcon(Icons.local_fire_department),
      ),
      findsOneWidget,
    );

    final lampTile = find.byKey(const ValueKey('device-lamp'));
    expect(
      find.descendant(of: lampTile, matching: find.text('Połączone')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: lampTile,
        matching: find.textContaining('Urządzenie grzewcze'),
      ),
      findsNothing,
    );
    // Details are asked for the heating device only.
    expect(source.calls.toSet(), {'devices', 'rooms', 'device:heat'});

    // Heating faults require action; the most severe suggestion comes first.
    expect(find.text('Wymaga działania'), findsOneWidget);
    expect(find.text('2 usterki ogrzewania'), findsOneWidget);
    expect(
      _top(tester, find.text('2 usterki ogrzewania')),
      lessThan(_top(tester, find.text('Ogrzewanie wstrzymane').first)),
    );
  });

  testWidgets('all good when every device is online without faults', (
    tester,
  ) async {
    source.deviceList = [
      listedDevice({'id': 'a', 'name': 'A', 'connectivityState': 'ONLINE'}),
    ];
    await pumpHome(tester);

    expect(find.text('Wszystko w porządku'), findsOneWidget);
    expect(find.text('Wszystkie urządzenia działają prawidłowo.'), findsOne);
    expect(find.text('Wymaga sprawdzenia'), findsNothing);
  });

  testWidgets('an appliance without devices shows the empty state', (
    tester,
  ) async {
    source.deviceList = [];
    await pumpHome(tester);

    expect(find.text('Brak urządzeń'), findsOneWidget);
    expect(
      find.text('Dodaj urządzenia w panelu web GI Home, a pojawią się tutaj.'),
      findsOneWidget,
    );
    expect(find.text('Ograniczone dane'), findsOneWidget);
    expect(
      find.text('GI Home nie ma jeszcze włączonych urządzeń.'),
      findsOneWidget,
    );
  });

  testWidgets('a failed refresh keeps the devices and shows a banner', (
    tester,
  ) async {
    await pumpHome(tester);
    source.devicesFailure = const ApiFailure.unreachable();

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(source.calls.where((c) => c == 'devices'), hasLength(2));
    expect(
      find.textContaining('Brak połączenia z GI Home · dane z'),
      findsOneWidget,
    );
    expect(find.text('Nie udało się pobrać aktualnych danych.'), findsOne);
    expect(find.byKey(const ValueKey('device-${_Ids.boiler}')), findsOne);
    expect(find.text('Kotłownia'), findsOneWidget);
  });

  testWidgets('a server error on refresh names the reason', (tester) async {
    await pumpHome(tester);
    source.devicesFailure = const ApiFailure.server(statusCode: 500);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.textContaining('Nie udało się odświeżyć · dane z'), findsOne);
    expect(find.byKey(const ValueKey('device-${_Ids.lamp}')), findsOne);
  });

  testWidgets('a failed first load offers retry', (tester) async {
    source.devicesFailure = const ApiFailure.unreachable();
    await pumpHome(tester);

    expect(find.text('Spróbuj ponownie'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);

    source.devicesFailure = null;
    await tester.tap(find.text('Spróbuj ponownie'));
    await tester.pumpAndSettle();

    expect(find.text('Spróbuj ponownie'), findsNothing);
    expect(find.text('Kotłownia'), findsOneWidget);
  });

  testWidgets('the first load shows a skeleton instead of a spinner', (
    tester,
  ) async {
    final pending = Completer<void>();
    source.devicesGate = pending.future;
    await tester.pumpWidget(
      testScreen(
        const HomeScreen(),
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
    expect(find.text('Kotłownia'), findsOneWidget);
  });

  testWidgets('a 403 says the role has no access, with no retry', (
    tester,
  ) async {
    source.devicesFailure = const ApiFailure.forbidden(code: 'HTTP_403');
    await pumpHome(tester);

    expect(find.byType(PermissionState), findsOneWidget);
    expect(find.text('Brak dostępu'), findsOneWidget);
    expect(find.text('Spróbuj ponownie'), findsNothing);
    await expectAccessibilityGuidelines(tester);

    await tester.pump(const Duration(minutes: 2));
    expect(source.calls.where((c) => c == 'devices'), hasLength(1));

    // Pulling down asks once more.
    source.devicesFailure = null;
    await tester.fling(find.byType(ListView), const Offset(0, 1200), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Kotłownia'), findsOneWidget);
  });

  testWidgets('without rooms the devices are listed together', (tester) async {
    source.roomsFailure = const ApiFailure.timeout();
    await pumpHome(tester);

    expect(find.text('Urządzenia'), findsOneWidget);
    expect(find.text('Bez pokoju'), findsNothing);
    expect(
      find.text('Nie udało się pobrać pokoi – urządzenia pokazujemy razem.'),
      findsOneWidget,
    );
  });

  testWidgets('a list without an answer turns stale, then outdated', (
    tester,
  ) async {
    source.deviceList = [
      listedDevice({'id': 'a', 'name': 'A', 'connectivityState': 'ONLINE'}),
    ];
    await pumpHome(tester);
    expect(find.text('Wszystko w porządku'), findsOneWidget);
    expect(find.textContaining('Dane mogą być nieaktualne'), findsNothing);

    // The 30 s poll is still in flight 61 s after the data arrived.
    final pending = Completer<void>();
    source.devicesGate = pending.future;
    clock = now.add(const Duration(seconds: 61));
    await tester.pump(const Duration(seconds: 30));

    expect(
      find.textContaining('Dane mogą być nieaktualne (ostatnia aktualizacja'),
      findsOneWidget,
    );
    expect(find.text('Wszystko w porządku'), findsOneWidget);

    // It finally fails after more than 2 minutes: limited, outdated data.
    source.devicesFailure = const ApiFailure.timeout();
    clock = now.add(const Duration(minutes: 3));
    pending.complete();
    await tester.pumpAndSettle();

    expect(find.text('Ograniczone dane'), findsOneWidget);
    expect(find.text('Dane są starsze niż 2 minuty.'), findsOneWidget);
    expect(find.text('Wszystko w porządku'), findsNothing);
    expect(
      find.textContaining('Brak połączenia z GI Home · dane z'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('device-a')), findsOneWidget);
  });

  testWidgets('a heating device gets a card with its readings', (tester) async {
    source.deviceList = [
      ...fixtureDevices().where((d) => d.id != _Ids.boiler),
      listedDevice({
        ...fixtureDeviceJson(id: _Ids.boiler),
        'connectivityState': 'ONLINE',
        'lastSeenAt': now.toIso8601String(),
        'heatingRelayEntityId': 'ent-relay-boiler',
        'pumpRelayEntityId': 'ent-relay-pump',
        'controlTemperatureEntityId': 'ent-supply',
      }),
    ];
    source.details[_Ids.boiler] = fixtureDetail({
      ...entityRichDetailJson(),
      'dryRun': false,
      'diagnostics': null,
    });
    await pumpHome(tester);

    final card = find.byKey(const ValueKey('device-${_Ids.boiler}'));
    Finder inCard(String text) =>
        find.descendant(of: card, matching: find.text(text));
    expect(inCard('Urządzenie grzewcze · Kotłownia'), findsOneWidget);
    expect(inCard('Grzeje'), findsOneWidget);
    expect(inCard('Zatrzymana'), findsOneWidget);
    expect(inCard('54,3 °C'), findsOneWidget);
    // Only the heating device's details are requested.
    expect(source.calls.toSet(), {'devices', 'rooms', 'device:${_Ids.boiler}'});

    await expectNoWriteControls(tester);
    await expectAccessibilityGuidelines(tester);
  });

  testWidgets('a failed heating card limits the condition', (tester) async {
    source.deviceList = [
      listedDevice({
        'id': 'heat',
        'name': 'Kocioł',
        'connectivityState': 'ONLINE',
        'heatingRelayEntityId': 'ent-relay-boiler',
      }),
    ];
    source.details['heat'] = fixtureDetail({
      ...entityRichDetailJson(),
      'id': 'heat',
      'dryRun': false,
      'diagnostics': null,
    });
    source.detailFailure = const ApiFailure.timeout();
    await pumpHome(tester);

    expect(find.text('Ograniczone dane'), findsOneWidget);
    expect(find.text('Wszystko w porządku'), findsNothing);
    expect(
      find.text('Nie udało się pobrać szczegółów ogrzewania.'),
      findsOneWidget,
    );
    // In the attention list and on the card.
    expect(
      find.text('Nie udało się pobrać szczegółów ogrzewania'),
      findsNWidgets(2),
    );

    source.detailFailure = null;
    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Wszystko w porządku'), findsOneWidget);
    expect(find.text('Grzeje'), findsOneWidget);
  });

  testWidgets('only heating cards on screen fetch their details', (
    tester,
  ) async {
    const ids = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];
    source.deviceList = [
      for (final id in ids)
        listedDevice({
          'id': id,
          'name': 'Kocioł $id',
          'connectivityState': 'ONLINE',
          'lastSeenAt': now.toIso8601String(),
          'heatingRelayEntityId': 'ent-relay-boiler',
        }),
    ];
    for (final id in ids) {
      source.details[id] = fixtureDetail({
        ...entityRichDetailJson(),
        'id': id,
        'dryRun': false,
        'diagnostics': null,
      });
    }
    // A phone: 360 × 640 logical pixels.
    await pumpHome(tester, physicalSize: const Size(1080, 1920));

    Set<String> fetched() => {
      for (final call in source.calls)
        if (call.startsWith('device:')) call.substring('device:'.length),
    };
    final firstScreen = fetched();
    expect(firstScreen, contains('h1'));
    expect(firstScreen, isNot(contains('h6')));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('device-h6')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(fetched(), contains('h6'));

    // h1 is out of view now: its card no longer polls.
    expect(find.byKey(const ValueKey('device-h1')), findsNothing);
    final h1Calls = source.calls.where((c) => c == 'device:h1').length;
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();
    expect(source.calls.where((c) => c == 'device:h1').length, h1Calls);
    expect(source.calls.where((c) => c == 'device:h6').length, greaterThan(1));
  });

  testWidgets('no write controls in this milestone', (tester) async {
    source.deviceList = [
      ...fixtureDevices(),
      listedDevice({
        'id': 'heat',
        'name': 'Kocioł',
        'heatingRelayEntityId': 'relay',
        'activeFaultCount': 1,
      }),
    ];
    await pumpHome(tester);

    await expectNoWriteControls(tester);
  });

  testWidgets('meets the accessibility guidelines', (tester) async {
    await pumpHome(tester);

    await expectAccessibilityGuidelines(tester);
  });
}

double _top(WidgetTester tester, Finder finder) => tester.getTopLeft(finder).dy;

abstract final class _Ids {
  static const sensor = '341584fe-d238-44e5-b97b-191ff594bb09';
  static const lamp = 'fbc51583-9b91-420e-bd94-694c691dcf63';
  static const boiler = '60d5a6b9-e974-45b0-b3ee-43e264d1ec85';
}
