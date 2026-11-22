import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/features/home/presentation/widgets/heating_card.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/accessibility.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

void main() {
  final now = DateTime.utc(2026, 11, 18, 7, 41);

  /// The recorded boiler controller, as listed, wired up for heating.
  DeviceListItem heatingDevice([Map<String, Object?> overrides = const {}]) =>
      listedDevice({
        'id': '60d5a6b9-e974-45b0-b3ee-43e264d1ec85',
        'name': 'Sterownik kotłowni',
        'roomId': '15a6de6e-f36c-4741-9775-53cd03413ccb',
        'connectivityState': 'ONLINE',
        'lastSeenAt': now.toIso8601String(),
        'heatingRelayEntityId': 'ent-relay-boiler',
        'pumpRelayEntityId': 'ent-relay-pump',
        'controlTemperatureEntityId': 'ent-supply',
        ...overrides,
      });

  /// `DevicesController_get/no_room_no_entities.json` shaped as a heating
  /// controller (boiler relay on, pump relay off, 54.25 °C supply), without
  /// diagnostics unless given.
  DeviceDetail heatingDetail([Map<String, Object?> overrides = const {}]) =>
      fixtureDetail({
        ...entityRichDetailJson(),
        'dryRun': false,
        'diagnostics': null,
        ...overrides,
      });

  /// The recorded-shape entities with [changes] applied by entity id.
  List<Map<String, Object?>> entitiesWith(
    Map<String, Map<String, Object?>> changes,
  ) => [
    for (final entity
        in (entityRichDetailJson()['entities']! as List)
            .cast<Map<String, Object?>>())
      {...entity, ...?changes[entity['id']]},
  ];

  Future<void> pumpCard(
    WidgetTester tester, {
    DeviceListItem? device,
    PolledData<DeviceDetail>? detail,
    DateTime? at,
    String? roomName = 'Kotłownia',
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      testScreen(
        Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HeatingCard(
                device: device ?? heatingDevice(),
                listFetchedAt: now,
                detail:
                    detail ?? PolledData(data: Fetched(heatingDetail(), now)),
                roomName: roomName,
                now: at ?? now,
                onTap: onTap ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
  }

  String valueOf(WidgetTester tester, String key) {
    final row = find.byKey(ValueKey(key));
    expect(row, findsOneWidget);
    final texts = tester
        .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
        .map((t) => t.data)
        .toList();
    return texts.last!;
  }

  testWidgets('name, room and the readings of the recorded entity shape', (
    tester,
  ) async {
    await pumpCard(tester);

    expect(find.text('Sterownik kotłowni'), findsOneWidget);
    expect(find.text('Urządzenie grzewcze · Kotłownia'), findsOneWidget);
    expect(valueOf(tester, 'reading-boiler'), 'Grzeje');
    expect(valueOf(tester, 'reading-pump'), 'Zatrzymana');
    expect(valueOf(tester, 'reading-temperature'), '54,3 °C');
    expect(
      find.text('Stan przekaźników według polecenia sterownika'),
      findsOneWidget,
    );
    // Fresh details carry no freshness note.
    expect(find.textContaining('Dane z'), findsNothing);

    final temperature = tester.widget<Text>(find.text('54,3 °C'));
    expect(temperature.style?.fontFamily, 'JetBrains Mono');
    expect(
      temperature.style?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  testWidgets('relays off, 0/1 telemetry and text values', (tester) async {
    await pumpCard(
      tester,
      detail: PolledData(
        data: Fetched(
          heatingDetail({
            'entities': entitiesWith({
              'ent-relay-boiler': {'value': false},
              // GI Edge telemetry reports relays as 0/1.
              'ent-relay-pump': {'value': 1},
            }),
          }),
          now,
        ),
      ),
    );

    expect(valueOf(tester, 'reading-boiler'), 'Nie grzeje');
    expect(valueOf(tester, 'reading-pump'), 'Pracuje');
    expect(find.byIcon(Icons.power_off), findsOneWidget);
    expect(find.byIcon(Icons.power), findsOneWidget);
  });

  testWidgets('a missing or unavailable entity is never shown as off', (
    tester,
  ) async {
    await pumpCard(
      tester,
      detail: PolledData(
        data: Fetched(
          heatingDetail({
            // The boiler relay points at an entity the device does not have.
            'heatingRelayEntityId': 'ent-gone',
            'entities': entitiesWith({
              'ent-supply': {'availability': false},
            }),
          }),
          now,
        ),
      ),
    );

    expect(valueOf(tester, 'reading-boiler'), '—');
    // "—" alone reads as nothing to a screen reader.
    final missing = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('reading-boiler')),
        matching: find.text('—'),
      ),
    );
    expect(missing.semanticsLabel, 'Brak danych');
    expect(valueOf(tester, 'reading-temperature'), 'Niedostępny');
    expect(find.text('Nie grzeje'), findsNothing);
  });

  testWidgets('no pump relay and no control temperature hide their rows', (
    tester,
  ) async {
    await pumpCard(
      tester,
      detail: PolledData(
        data: Fetched(
          heatingDetail({
            'pumpRelayEntityId': null,
            'controlTemperatureEntityId': null,
          }),
          now,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('reading-boiler')), findsOneWidget);
    expect(find.byKey(const ValueKey('reading-pump')), findsNothing);
    expect(find.byKey(const ValueKey('reading-temperature')), findsNothing);
  });

  testWidgets('suspended heating and dry-run come from the list as badges', (
    tester,
  ) async {
    await pumpCard(
      tester,
      device: heatingDevice({'heatingSuspended': true, 'dryRun': true}),
    );

    final suspended = find.byKey(const ValueKey('heating-suspended'));
    expect(
      find.descendant(
        of: suspended,
        matching: find.text('Ogrzewanie wstrzymane'),
      ),
      findsOneWidget,
    );
    // Never colour alone: the badge carries an icon.
    expect(
      find.descendant(
        of: suspended,
        matching: find.byIcon(Icons.pause_circle_outline),
      ),
      findsOneWidget,
    );
    final dryRun = find.byKey(const ValueKey('dry-run'));
    expect(
      find.descendant(of: dryRun, matching: find.text('Tryb testowy')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dryRun,
        matching: find.byIcon(Icons.science_outlined),
      ),
      findsOneWidget,
    );
  });

  testWidgets('controller state and faults are merged from the list', (
    tester,
  ) async {
    await pumpCard(
      tester,
      device: heatingDevice({'currentState': 'FAULT', 'activeFaultCount': 2}),
    );

    expect(find.text('Awaria'), findsOneWidget);
    expect(find.text('2 usterki'), findsOneWidget);
  });

  testWidgets('diagnostics newer than the list provide the controller state', (
    tester,
  ) async {
    await pumpCard(
      tester,
      detail: PolledData(
        data: Fetched(
          heatingDetail({
            'diagnostics': {
              'currentState': 'HEATING',
              'activeFaults': <String>[],
            },
          }),
          now.add(const Duration(seconds: 1)),
        ),
      ),
      at: now.add(const Duration(seconds: 1)),
    );

    expect(find.text('Grzanie'), findsOneWidget);
    expect(find.textContaining('usterk'), findsNothing);
  });

  testWidgets('without controller data the card says so', (tester) async {
    await pumpCard(tester);

    expect(find.text('Czekamy na dane ze sterownika'), findsOneWidget);
  });

  testWidgets('needs configuration from the details is shown', (tester) async {
    await pumpCard(
      tester,
      detail: PolledData(
        data: Fetched(heatingDetail({'status': 'needs_configuration'}), now),
      ),
    );

    expect(find.text('Wymaga konfiguracji'), findsOneWidget);
  });

  testWidgets('details older than 2× the interval show their time', (
    tester,
  ) async {
    await pumpCard(tester, at: now.add(const Duration(seconds: 30)));
    expect(find.textContaining('Dane z'), findsNothing);

    await pumpCard(tester, at: now.add(const Duration(seconds: 31)));
    expect(find.textContaining(RegExp(r'^Dane z \d\d:\d\d$')), findsOneWidget);
  });

  testWidgets('a failed fetch keeps the last details and says so', (
    tester,
  ) async {
    await pumpCard(
      tester,
      detail: PolledData(
        data: Fetched(heatingDetail(), now),
        error: const ApiFailure.timeout(),
      ),
      at: now.add(const Duration(seconds: 20)),
    );

    expect(
      find.textContaining('Nie udało się pobrać szczegółów · dane z'),
      findsOneWidget,
    );
    expect(valueOf(tester, 'reading-boiler'), 'Grzeje');
  });

  testWidgets('first load and a failed first load', (tester) async {
    await pumpCard(
      tester,
      detail: const PolledData<DeviceDetail>(isRefreshing: true),
    );
    expect(find.text('Pobieranie szczegółów…'), findsOneWidget);
    expect(find.byKey(const ValueKey('reading-boiler')), findsNothing);

    await pumpCard(
      tester,
      detail: const PolledData<DeviceDetail>(error: ApiFailure.unreachable()),
    );
    expect(
      find.text('Nie udało się pobrać szczegółów ogrzewania'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('reading-boiler')), findsNothing);
  });

  testWidgets('without a room it says so', (tester) async {
    await pumpCard(tester, roomName: null);

    expect(find.text('Urządzenie grzewcze · Bez pokoju'), findsOneWidget);
  });

  testWidgets('tap opens the device', (tester) async {
    var taps = 0;
    await pumpCard(tester, onTap: () => taps++);

    await tester.tap(find.text('Sterownik kotłowni'));
    expect(taps, 1);
  });

  testWidgets('read-only and accessible', (tester) async {
    await pumpCard(
      tester,
      device: heatingDevice({'heatingSuspended': true, 'dryRun': true}),
    );

    await expectNoWriteControls(tester);
    await expectAccessibilityGuidelines(tester);
  });
}
