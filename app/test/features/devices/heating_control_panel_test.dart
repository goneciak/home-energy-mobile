import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/widgets/hold_to_confirm_button.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/presentation/device_detail_screen.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/heating_control_panel.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/strategy_editor_sheet.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fake_device_source.dart';
import '../../support/heating_fixtures.dart';
import '../../support/switch_fixtures.dart';
import '../../support/test_app.dart';

const deviceId = '60d5a6b9-e974-45b0-b3ee-43e264d1ec85';

void main() {
  final now = DateTime.utc(2026, 11, 18, 7, 41);
  final patchedAt = now.add(const Duration(seconds: 1));
  late DateTime clock;
  late FakeDeviceSource devices;
  late FakeCommandSource commands;
  late UserRole role;
  final l10n = lookupAppLocalizations(const Locale('pl'));

  setUp(() {
    clock = now;
    role = UserRole.owner;
    devices = FakeDeviceSource(details: {deviceId: heatingDetail()});
    commands = FakeCommandSource()
      ..suspendResult = (suspended) =>
          patchedDevice(updatedAt: patchedAt, suspended: suspended);
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

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
  }

  final hold = find.byKey(const ValueKey('heating-suspend-hold'));

  /// Past the tap's press timeout, then the whole hold, frame by frame.
  Future<void> holdLongEnough(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 150));
    for (var i = 0; i < 4; i++) {
      await tester.pump(HoldToConfirmButton.defaultHoldDuration ~/ 3);
    }
  }

  final holdArea = find.descendant(
    of: hold,
    matching: find.byType(GestureDetector),
  );

  group('role gating', () {
    for (final r in [UserRole.user, UserRole.service]) {
      testWidgets('${r.name}: no heating controls at all', (tester) async {
        role = r;
        await pumpDetail(tester);
        expect(find.byType(HeatingControlPanel), findsOneWidget);
        expect(find.text(l10n.heatingControlSection), findsNothing);
        expect(hold, findsNothing);
        expect(find.byKey(const ValueKey('strategy-edit')), findsNothing);
        await unmount(tester);
      });
    }
  });

  group('hold to suspend', () {
    testWidgets('a short tap does nothing but explain', (tester) async {
      await pumpDetail(tester);
      await tester.tap(holdArea);
      await tester.pump();
      expect(commands.suspendCalls, isEmpty);
      expect(find.byKey(const ValueKey('hold-hint')), findsOneWidget);
      expect(find.text(l10n.suspendHoldHint), findsOneWidget);

      // Released before the hold completes: still nothing.
      final gesture = await tester.startGesture(tester.getCenter(holdArea));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pump(const Duration(seconds: 1));
      expect(commands.suspendCalls, isEmpty);
      await unmount(tester);
    });

    testWidgets('holding sends the suspension, then shows the GI Edge relay '
        'report without a physical claim', (tester) async {
      await pumpDetail(tester);
      final gesture = await tester.startGesture(tester.getCenter(holdArea));
      await holdLongEnough(tester);
      await gesture.up();
      await tester.pump();
      expect(commands.suspendCalls, [(deviceId, true)]);
      expect(find.text(l10n.suspendAwaiting), findsOneWidget);
      // Never optimistic: the suspend control stays until GI Core says so.
      expect(hold, findsOneWidget);

      devices.details[deviceId] = heatingDetail(
        heatingSuspended: true,
        lastSeenAt: now,
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text(l10n.suspendAppliedAwaitingHeartbeat), findsOneWidget);
      expect(find.byKey(const ValueKey('heating-resume')), findsOneWidget);

      final heartbeat = patchedAt.add(const Duration(seconds: 3));
      devices.details[deviceId] = heatingDetail(
        heatingSuspended: true,
        lastSeenAt: heartbeat,
        relays: [false, false, false],
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(
        find.textContaining('wyjścia przekaźników wyłączone'),
        findsOneWidget,
      );
      expect(find.textContaining('nie potwierdza fizycznego'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('LEGACY: says the relays are not switched by the command', (
      tester,
    ) async {
      devices.details[deviceId] = heatingDetail(mode: 'LEGACY_ESPHOME');
      await pumpDetail(tester);
      final gesture = await tester.startGesture(tester.getCenter(holdArea));
      await holdLongEnough(tester);
      await gesture.up();
      devices.details[deviceId] = heatingDetail(
        mode: 'LEGACY_ESPHOME',
        heatingSuspended: true,
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text(l10n.suspendAppliedLegacy), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('screen readers: the button activates a confirmation '
        'dialog instead of the hold', (tester) async {
      final semantics = tester.ensureSemantics();
      final holdSemantics = find.bySemanticsLabel(l10n.suspendHoldAction);
      await pumpDetail(tester);
      final node = tester.getSemantics(holdSemantics);
      expect(node.label, l10n.suspendHoldAction);
      expect(node.hint, l10n.suspendA11yHint);
      expect(node.flagsCollection.isButton, isTrue);

      tester.semantics.tap(find.semantics.byLabel(l10n.suspendHoldAction));
      await tester.pumpAndSettle();
      expect(find.text(l10n.suspendConfirmTitle), findsOneWidget);
      expect(find.text(l10n.consequenceStopsHeating), findsOneWidget);

      // Cancel sends nothing.
      await tester.tap(find.text(l10n.actionCancel));
      await tester.pumpAndSettle();
      expect(commands.suspendCalls, isEmpty);

      tester.semantics.tap(find.semantics.byLabel(l10n.suspendHoldAction));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('suspend-confirm')));
      await tester.pump();
      await tester.pump();
      expect(commands.suspendCalls, [(deviceId, true)]);
      await unmount(tester);
      semantics.dispose();
    });

    testWidgets('suspending stays available on stale data', (tester) async {
      devices.details[deviceId] = heatingDetail(connectivity: 'STALE');
      await pumpDetail(tester);
      expect(hold, findsOneWidget);
      expect(
        find.byKey(const ValueKey('strategy-edit-locked')),
        findsOneWidget,
      );
      await unmount(tester);
    });
  });

  group('resume', () {
    testWidgets('the sheet names the consequences, the setting that will '
        'apply and the temperature with its age; cancel sends nothing', (
      tester,
    ) async {
      devices.details[deviceId] = heatingDetail(heatingSuspended: true);
      await pumpDetail(tester);
      expect(hold, findsNothing);
      expect(find.text(l10n.heatingSuspendedBanner), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('heating-resume')));
      await tester.pumpAndSettle();
      expect(find.byType(ResumeSheet), findsOneWidget);
      expect(find.text(l10n.consequenceBoilerMayStartSoon), findsOneWidget);
      expect(find.text(l10n.consequenceRestoresBaseOrSchedule), findsOneWidget);
      expect(
        find.text(l10n.resumeSheetWillApply('55,0 °C, histereza 4,0 °C, Auto')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('resume-temperature')),
          matching: find.textContaining('Temperatura sterująca: 54,'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text(l10n.actionCancel));
      await tester.pumpAndSettle();
      expect(commands.suspendCalls, isEmpty);
      await unmount(tester);
    });

    testWidgets('confirming resumes and waits for the restored mode', (
      tester,
    ) async {
      devices.details[deviceId] = heatingDetail(heatingSuspended: true);
      await pumpDetail(tester);
      await tester.tap(find.byKey(const ValueKey('heating-resume')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('resume-confirm')));
      await tester.pump();
      await tester.pump();
      expect(commands.suspendCalls, [(deviceId, false)]);
      expect(find.text(l10n.resumeAwaiting), findsOneWidget);

      devices.details[deviceId] = heatingDetail();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text(l10n.resumeApplied), findsOneWidget);
      expect(hold, findsOneWidget);
      await unmount(tester);
    });

    testWidgets('stale data locks resuming with the reason', (tester) async {
      devices.details[deviceId] = heatingDetail(
        heatingSuspended: true,
        connectivity: 'OFFLINE',
      );
      await pumpDetail(tester);
      expect(find.byKey(const ValueKey('heating-resume')), findsNothing);
      expect(find.text(l10n.lockStaleData), findsWidgets);
      await unmount(tester);
    });
  });

  group('strategy editor', () {
    Future<void> openEditor(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('strategy-edit')));
      await tester.pumpAndSettle();
      expect(find.byType(StrategyEditorSheet), findsOneWidget);
    }

    Future<void> enter(WidgetTester tester, String key, String text) async {
      await tester.enterText(find.byKey(ValueKey(key)), text);
      await tester.pump();
    }

    Future<void> save(WidgetTester tester) async {
      await tester.ensureVisible(find.byKey(const ValueKey('strategy-save')));
      await tester.tap(find.byKey(const ValueKey('strategy-save')));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('starts from the BASE values and validates like GI Core '
        'within the UI limits', (tester) async {
      await pumpDetail(tester);
      await openEditor(tester);
      expect(find.text('55,0'), findsOneWidget);
      expect(find.text('4,0'), findsOneWidget);

      await enter(tester, 'strategy-target', '90');
      expect(find.text(l10n.strategyErrorRange('5,0', '80,0')), findsOne);
      await enter(tester, 'strategy-target', '55,3');
      expect(find.text(l10n.strategyErrorStep('0,5')), findsOneWidget);
      await enter(tester, 'strategy-target', 'abc');
      expect(find.text(l10n.strategyErrorNotANumber), findsOneWidget);
      await enter(tester, 'strategy-hysteresis', '0,5');
      expect(find.text(l10n.strategyErrorRange('1,0', '20,0')), findsOne);

      await save(tester);
      expect(commands.strategyCalls, isEmpty);
      expect(devices.calls.where((c) => c == 'device:$deviceId'), hasLength(1));
      await unmount(tester);
    });

    testWidgets('success: all three fields, base and effective shown', (
      tester,
    ) async {
      commands.strategyResult = const ControlStrategyUpdateResult(
        configurationVersion: 9,
        baseControlStrategy: ControlStrategy(
          targetTemperatureCelsius: 60,
          hysteresisCelsius: 3,
          mode: ControlStrategyMode.manual,
        ),
        controlStrategy: ControlStrategy(
          targetTemperatureCelsius: 60,
          hysteresisCelsius: 3,
          mode: ControlStrategyMode.manual,
        ),
      );
      await pumpDetail(tester);
      await openEditor(tester);
      await enter(tester, 'strategy-target', '60');
      await enter(tester, 'strategy-hysteresis', '3');
      await tester.tap(find.text(l10n.strategyModeManualShort));
      await tester.pump();
      await save(tester);

      expect(commands.strategyCalls, [
        (
          deviceId,
          const ControlStrategy(
            targetTemperatureCelsius: 60,
            hysteresisCelsius: 3,
            mode: ControlStrategyMode.manual,
          ),
        ),
      ]);
      expect(find.byKey(const ValueKey('strategy-saved')), findsOneWidget);
      expect(
        find.textContaining(
          l10n.strategySavedEffective('60,0 °C, histereza 3,0 °C, Ręczny'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('strategy-close')));
      await tester.pumpAndSettle();
      expect(find.byType(StrategyEditorSheet), findsNothing);
      await unmount(tester);
    });

    testWidgets('a large raise asks first (ConfirmationPolicy)', (
      tester,
    ) async {
      await pumpDetail(tester);
      await openEditor(tester);
      await enter(tester, 'strategy-target', '70');
      await save(tester);
      await tester.pumpAndSettle();
      expect(find.text(l10n.consequenceLargeTargetRaise), findsOneWidget);
      await tester.tap(find.text(l10n.actionCancel).last);
      await tester.pumpAndSettle();
      expect(commands.strategyCalls, isEmpty);
      await unmount(tester);
    });

    testWidgets('base changed elsewhere: diff, then discard reloads the '
        'current values', (tester) async {
      await pumpDetail(tester);
      await openEditor(tester);
      await enter(tester, 'strategy-target', '57');
      devices.details[deviceId] = heatingDetail(
        base: strategyJson(50, 4, 'AUTO'),
      );
      await save(tester);

      expect(find.byKey(const ValueKey('strategy-conflict')), findsOneWidget);
      expect(find.text(l10n.strategyConflictTitle), findsOneWidget);
      expect(
        find.textContaining(
          l10n.strategyConflictRow(l10n.strategyFieldTarget, '55,0', '50,0'),
        ),
        findsOneWidget,
      );
      expect(commands.strategyCalls, isEmpty);

      await tester.tap(find.byKey(const ValueKey('strategy-discard')));
      await tester.pump();
      expect(find.text('50,0'), findsOneWidget);
      expect(find.byKey(const ValueKey('strategy-save')), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('suspended elsewhere: diff, reapply saves against the new '
        'values and explains the effective mode stays OFF', (tester) async {
      commands.strategyResult = const ControlStrategyUpdateResult(
        configurationVersion: 9,
        baseControlStrategy: ControlStrategy(
          targetTemperatureCelsius: 57,
          hysteresisCelsius: 4,
          mode: ControlStrategyMode.auto,
        ),
        controlStrategy: ControlStrategy(
          targetTemperatureCelsius: 57,
          hysteresisCelsius: 4,
          mode: ControlStrategyMode.off,
        ),
      );
      await pumpDetail(tester);
      await openEditor(tester);
      await enter(tester, 'strategy-target', '57');
      devices.details[deviceId] = heatingDetail(heatingSuspended: true);
      await save(tester);
      expect(
        find.textContaining(
          l10n.strategyConflictRow(
            l10n.strategyFieldSuspended,
            l10n.strategyValueActive,
            l10n.strategyValueSuspended,
          ),
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey('strategy-reapply')),
      );
      await tester.tap(find.byKey(const ValueKey('strategy-reapply')));
      await tester.pump();
      await tester.pump();
      expect(commands.strategyCalls, hasLength(1));
      expect(find.textContaining(l10n.strategySavedSuspended), findsOneWidget);
      expect(
        find.byKey(const ValueKey('strategy-suspended-note')),
        findsOneWidget,
      );
      await unmount(tester);
    });

    testWidgets('a 400 from GI Core is shown and the editor stays open', (
      tester,
    ) async {
      commands.failure = const ApiFailure.validation(
        details: {
          'hysteresisCelsius': ['hysteresisCelsius must not be less than 1'],
        },
      );
      await pumpDetail(tester);
      await openEditor(tester);
      await save(tester);
      expect(find.byKey(const ValueKey('strategy-failed')), findsOneWidget);
      expect(find.byKey(const ValueKey('strategy-save')), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('above the PV safe maximum: warning while typing', (
      tester,
    ) async {
      devices.details[deviceId] = heatingDetail(safeMax: 60);
      await pumpDetail(tester);
      await openEditor(tester);
      expect(
        find.byKey(const ValueKey('strategy-above-safe-max')),
        findsNothing,
      );
      await enter(tester, 'strategy-target', '62');
      expect(
        find.byKey(const ValueKey('strategy-above-safe-max')),
        findsOneWidget,
      );
      await unmount(tester);
    });
  });
}
