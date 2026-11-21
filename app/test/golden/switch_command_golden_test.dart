@Tags(['golden'])
library;

import 'dart:async';

import 'package:alchemist/alchemist.dart' show onlyPumpAndSettle, pumpNTimes;
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:gi_home/src/features/devices/domain/switch_command_state.dart';
import 'package:gi_home/src/features/devices/presentation/device_detail_screen.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/switch_command_panel.dart';
import 'package:material_ui/material_ui.dart';

import '../support/fake_device_source.dart';
import '../support/fixtures.dart';
import '../support/golden.dart';
import '../support/switch_fixtures.dart';
import 'golden_devices.dart';

/// Switch commands (plan §12.2, G2/G3): every state of the command panel on
/// the smallest phone, and the details screen of an OWNER with the
/// ordinary switch, the read-only heating and pump relays, and the stale
/// lock.
void main() {
  final requestedAt = goldenNow.subtract(const Duration(seconds: 20));
  final heartbeatAt = goldenNow.subtract(const Duration(seconds: 15));

  void panelGolden(
    String description, {
    required String fileName,
    required SwitchCommandState command,
    SafetyDecision decision = const Allowed(),
    bool? current = false,
    DateTime? fetchedAt,
  }) => screenGoldens(
    // A progress indicator never settles.
    settle: command.isBusy ? pumpNTimes(2) : onlyPumpAndSettle,
    'Switch: $description',
    fileName: 'switch_$fileName',
    devices: const [GoldenDevice.smallPhone],
    screen: () => Scaffold(
      body: ListView(
        children: [
          const ListTile(title: Text('Oświetlenie kotłowni')),
          SwitchCommandPanel(
            entityName: 'Oświetlenie kotłowni',
            current: current,
            decision: decision,
            command: command,
            fetchedAt: fetchedAt ?? goldenNow,
            now: goldenNow,
            onToggle: (_) {},
            onRefresh: () {},
          ),
        ],
      ),
    ),
  );

  panelGolden('idle', fileName: 'idle', command: const SwitchIdle());

  panelGolden(
    'heating relay, read-only',
    fileName: 'relay_read_only',
    command: const SwitchIdle(),
    decision: Locked(const [LockReason.heatingOrPumpRelay]),
    current: true,
  );

  panelGolden(
    'stale lock',
    fileName: 'stale_lock',
    command: const SwitchIdle(),
    decision: Locked(const [LockReason.staleData]),
    fetchedAt: goldenNow.subtract(const Duration(seconds: 40)),
  );

  panelGolden(
    'locked while suspended',
    fileName: 'suspended_lock',
    command: const SwitchIdle(),
    decision: Locked(const [LockReason.suspendedOnRequest]),
  );

  panelGolden(
    'sending',
    fileName: 'sending',
    command: const SwitchSending(requested: true),
  );

  panelGolden(
    'legacy: the device confirmed the command',
    fileName: 'legacy_confirmed',
    command: SwitchLegacyConfirmed(state: true, confirmedAt: requestedAt),
    current: true,
  );

  panelGolden(
    'GI Edge: waiting for a heartbeat',
    fileName: 'awaiting_heartbeat',
    command: SwitchAwaitingHeartbeat(
      requested: true,
      confirmedAt: requestedAt,
      dryRun: false,
    ),
  );

  panelGolden(
    'GI Edge: heartbeat observed',
    fileName: 'heartbeat_observed',
    command: SwitchHeartbeatObserved(
      requested: true,
      commanded: true,
      output: true,
      seenAt: heartbeatAt,
    ),
    current: true,
  );

  panelGolden(
    'GI Edge: recorded in dry-run',
    fileName: 'dry_run_recorded',
    command: SwitchDryRunRecorded(
      requested: true,
      commanded: true,
      output: false,
      seenAt: heartbeatAt,
    ),
  );

  panelGolden(
    'GI Edge: no heartbeat in time',
    fileName: 'timed_out',
    command: SwitchTimedOut(requested: true, confirmedAt: requestedAt),
  );

  panelGolden(
    'command not confirmed',
    fileName: 'failed_unconfirmed',
    command: const SwitchFailed(
      requested: true,
      failure: ApiFailure.server(
        statusCode: 502,
        errorCode: 'ESPHOME_COMMAND_UNCONFIRMED',
      ),
    ),
  );

  panelGolden(
    'device offline',
    fileName: 'failed_offline',
    command: const SwitchFailed(
      requested: false,
      failure: ApiFailure.server(statusCode: 503, errorCode: 'DEVICE_OFFLINE'),
    ),
    current: true,
  );

  void screenGolden(
    String description, {
    required String fileName,
    Duration? staleBy,
  }) {
    late FakeDeviceSource source;
    var clock = goldenNow;
    screenGoldens(
      'Switch screen: $description',
      fileName: 'switch_screen_$fileName',
      screen: () => const DeviceDetailScreen(deviceId: GoldenIds.boiler),
      prepare: (_) async {
        clock = goldenNow;
        source = FakeDeviceSource(roomList: fixtureRooms())
          ..deviceList = [goldenListed(GoldenIds.boiler)]
          ..details[GoldenIds.boiler] = switchDeviceDetail(
            transform: localJson,
          );
      },
      overrides: () => [
        deviceReadSourceProvider.overrideWithValue(source),
        deviceCommandSourceProvider.overrideWithValue(FakeCommandSource()),
        currentUserProvider.overrideWithValue(
          const CurrentUser(
            id: 'u1',
            email: 'owner@example.com',
            firstName: 'Ola',
            mustChangePassword: false,
            role: UserRole.owner,
          ),
        ),
        appForegroundProvider.overrideWithValue(AppForeground()),
        clockProvider.overrideWithValue(() => clock),
      ],
      act: (tester) async {
        // Every scenario scrolled to the end: the switches, then the
        // diagnostics.
        for (final element in find.byType(Scrollable).evaluate()) {
          final position =
              ((element as StatefulElement).state as ScrollableState).position;
          position.jumpTo(position.maxScrollExtent);
        }
        await tester.pump();
        if (staleBy != null) {
          source.detailGate = Completer<void>().future;
          clock = goldenNow.add(staleBy);
          await tester.pump(const Duration(seconds: 5));
          await tester.pump();
        }
      },
    );
  }

  screenGolden('OWNER controls', fileName: 'owner');
  screenGolden(
    'stale lock',
    fileName: 'stale',
    staleBy: const Duration(seconds: 11),
  );
}
