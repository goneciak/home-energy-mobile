import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/widgets/freshness_label.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/presentation/device_detail_screen.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/switch_command_panel.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fake_device_source.dart';
import '../../support/switch_fixtures.dart';
import '../../support/test_app.dart';

const deviceId = '60d5a6b9-e974-45b0-b3ee-43e264d1ec85';

void main() {
  final now = DateTime.utc(2026, 11, 18, 7, 41);
  final requestedAt = now.add(const Duration(seconds: 1));
  late DateTime clock;
  late FakeDeviceSource devices;
  late FakeCommandSource commands;
  late UserRole role;
  final l10n = lookupAppLocalizations(const Locale('pl'));

  setUp(() {
    clock = now;
    role = UserRole.owner;
    devices = FakeDeviceSource(details: {deviceId: switchDeviceDetail()});
    commands = FakeCommandSource();
  });

  Future<void> pumpDetail(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1200, 12000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testScreen(
        const DeviceDetailScreen(deviceId: deviceId),
        overrides: [
          deviceReadSourceProvider.overrideWithValue(devices),
          deviceCommandSourceProvider.overrideWithValue(commands),
          currentUserProvider.overrideWithValue(
            CurrentUser(
              id: 'u1',
              email: 'owner@example.com',
              firstName: 'Ola',
              mustChangePassword: false,
              role: role,
            ),
          ),
          appForegroundProvider.overrideWithValue(AppForeground()),
          clockProvider.overrideWithValue(() => clock),
        ],
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Finder control(String entityId) =>
      find.byKey(ValueKey('switch-control-$entityId'));

  Finder inControl(String entityId, Finder finder) =>
      find.descendant(of: control(entityId), matching: finder);

  Finder toggle(String entityId) =>
      inControl(entityId, find.byKey(const ValueKey('switch-toggle')));

  testWidgets('OWNER: the ordinary switch has a toggle; heating and pump '
      'relays are read-only with the reason', (tester) async {
    await pumpDetail(tester);

    expect(toggle(lightEntityId), findsOneWidget);
    for (final relay in ['ent-relay-boiler', 'ent-relay-pump']) {
      expect(toggle(relay), findsNothing);
      expect(
        inControl(relay, find.text(l10n.lockHeatingOrPumpRelay)),
        findsOneWidget,
      );
    }
  });

  testWidgets('GI_EDGE: the toggle and value row show the reported output, '
      'never the optimistic entity value', (tester) async {
    // After a timeout and Refresh: GI Core wrote value=true on enqueue, the
    // controller still reports the relay off.
    devices.details[deviceId] = switchDeviceDetail(
      lightOn: true,
      relay3: {'output': false, 'commanded': false},
    );
    await pumpDetail(tester);

    final toggleWidget = tester.widget<Switch>(toggle(lightEntityId));
    expect(toggleWidget.value, isFalse);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('entity-$lightEntityId')),
        matching: find.text(l10n.entityValueOff),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('entity-$lightEntityId')),
        matching: find.text(l10n.entityValueOn),
      ),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('heating and pump relays show what the controller commands; '
      'dry-run says what it would set', (tester) async {
    devices.details[deviceId] = switchDeviceDetail(
      transform: (json) => {
        ...json,
        'diagnostics': {
          ...json['diagnostics']! as Map<String, Object?>,
          'relay1': {'output': true, 'commanded': true},
        },
      },
    );
    await pumpDetail(tester);
    expect(
      inControl(
        'ent-relay-boiler',
        find.text(l10n.switchControllerCommanded(l10n.entityValueOn)),
      ),
      findsOneWidget,
    );
    // An ordinary relay outside dry-run has no hint.
    expect(
      inControl(lightEntityId, find.byKey(const ValueKey('switch-commanded'))),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox());

    devices.details[deviceId] = switchDeviceDetail(
      dryRun: true,
      relay3: {'output': false, 'commanded': true},
    );
    await pumpDetail(tester);
    expect(
      inControl(
        lightEntityId,
        find.text(l10n.switchDryRunWouldSet(l10n.entityValueOn)),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('USER: no toggle at all, relays still explained', (tester) async {
    role = UserRole.user;
    await pumpDetail(tester);

    expect(find.byKey(const ValueKey('switch-toggle')), findsNothing);
    expect(control(lightEntityId), findsOneWidget);
    expect(
      inControl(lightEntityId, find.byKey(const ValueKey('switch-lock'))),
      findsNothing,
    );
    expect(
      inControl('ent-relay-boiler', find.text(l10n.lockHeatingOrPumpRelay)),
      findsOneWidget,
    );
  });

  testWidgets('stale data: the toggle is replaced by the lock with the data '
      'age', (tester) async {
    await pumpDetail(tester);
    clock = now.add(const Duration(seconds: 11));
    devices.detailGate = Completer<void>().future;
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(toggle(lightEntityId), findsNothing);
    expect(
      inControl(lightEntityId, find.text(l10n.lockStaleData)),
      findsOneWidget,
    );
    expect(
      inControl(lightEntityId, find.byType(FreshnessLabel)),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('suspended: ON is locked with the reason', (tester) async {
    devices.details[deviceId] = switchDeviceDetail(heatingSuspended: true);
    await pumpDetail(tester);

    expect(toggle(lightEntityId), findsNothing);
    expect(
      inControl(lightEntityId, find.text(l10n.lockSuspendedOnRequest)),
      findsOneWidget,
    );
  });

  testWidgets('ON asks first; cancel sends nothing', (tester) async {
    await pumpDetail(tester);

    await tester.tap(toggle(lightEntityId));
    await tester.pumpAndSettle();
    expect(find.byType(SwitchConfirmationSheet), findsOneWidget);
    expect(find.text(l10n.consequenceCommandNotPhysicallyVerified), findsOne);

    await tester.tap(find.text(l10n.actionCancel));
    await tester.pumpAndSettle();
    expect(commands.calls, isEmpty);
    expect(toggle(lightEntityId), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('GI_EDGE: queued, waits for a heartbeat, then reports the '
      'controller without claiming the relay switched', (tester) async {
    commands.result = SwitchCommandResult(
      entityId: lightEntityId,
      confirmedAt: requestedAt,
      state: true,
      availability: true,
    );
    await pumpDetail(tester);

    await tester.tap(toggle(lightEntityId));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.switchConfirmSend));
    await tester.pump();
    await tester.pump();

    expect(commands.calls, [(deviceId, lightEntityId, true)]);
    expect(
      inControl(lightEntityId, find.text(l10n.switchCommandAwaitingHeartbeat)),
      findsOneWidget,
    );
    expect(toggle(lightEntityId), findsNothing);

    // The optimistic write: the entity already says "on", the device-level
    // heartbeat is older than the command. Still waiting, no switch shown.
    devices.details[deviceId] = switchDeviceDetail(
      lightOn: true,
      relay3: {'output': false, 'commanded': false},
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(
      inControl(lightEntityId, find.text(l10n.switchCommandAwaitingHeartbeat)),
      findsOneWidget,
    );

    devices.details[deviceId] = switchDeviceDetail(
      lightOn: true,
      lastSeenAt: requestedAt.add(const Duration(seconds: 2)),
      relay3: {'output': true, 'commanded': true},
    );
    clock = now.add(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(
      inControl(
        lightEntityId,
        find.text(
          l10n.switchCommandHeartbeatObserved(
            l10n.entityValueOn,
            l10n.entityValueOn,
          ),
        ),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('OFF needs no confirmation; a failure explains and offers '
      'Refresh', (tester) async {
    devices.details[deviceId] = switchDeviceDetail(
      mode: 'LEGACY_ESPHOME',
      lightOn: true,
    );
    commands.failure = const ApiFailure.server(
      statusCode: 503,
      errorCode: 'DEVICE_OFFLINE',
    );
    await pumpDetail(tester);

    await tester.tap(toggle(lightEntityId));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SwitchConfirmationSheet), findsNothing);
    expect(commands.calls, [(deviceId, lightEntityId, false)]);
    expect(
      inControl(lightEntityId, find.text(l10n.errorDeviceOffline)),
      findsOneWidget,
    );

    await tester.tap(
      inControl(lightEntityId, find.byKey(const ValueKey('switch-refresh'))),
    );
    await tester.pump();
    await tester.pump();
    expect(
      inControl(lightEntityId, find.text(l10n.errorDeviceOffline)),
      findsNothing,
    );
    expect(toggle(lightEntityId), findsOneWidget);
    expect(commands.calls, hasLength(1));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('LEGACY: "the device confirmed the command"', (tester) async {
    devices.details[deviceId] = switchDeviceDetail(
      mode: 'LEGACY_ESPHOME',
      lightOn: true,
    );
    commands.result = SwitchCommandResult(
      entityId: lightEntityId,
      confirmedAt: requestedAt,
      state: false,
    );
    await pumpDetail(tester);

    await tester.tap(toggle(lightEntityId));
    await tester.pump();
    await tester.pump();

    expect(
      inControl(
        lightEntityId,
        find.textContaining('Urządzenie potwierdziło polecenie: Wył.'),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });
}
