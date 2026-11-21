@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart' show onlyPumpAndSettle, pumpNTimes;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/domain/heating_command_state.dart';
import 'package:gi_home/src/features/devices/presentation/device_detail_screen.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/heating_control_panel.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/strategy_editor_sheet.dart';
import 'package:material_ui/material_ui.dart';

import '../support/fake_device_source.dart';
import '../support/fixtures.dart';
import '../support/golden.dart';
import '../support/heating_fixtures.dart';
import '../support/switch_fixtures.dart';
import 'golden_devices.dart';

/// Heating controls (plan §12.1, §12.5, G2): the details screen of an
/// OWNER with hold-to-suspend or resume, the resume consequence sheet, the
/// strategy editor and every suspend/resume outcome.
void main() {
  final heartbeatAt = goldenNow.subtract(const Duration(seconds: 5));

  List<Override> ownerOverrides(FakeDeviceSource source) => [
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
    clockProvider.overrideWithValue(() => goldenNow),
  ];

  void screenGolden(
    String description, {
    required String fileName,
    bool suspended = false,
  }) {
    late FakeDeviceSource source;
    screenGoldens(
      'Heating control screen: $description',
      fileName: 'heating_control_screen_$fileName',
      screen: () => const DeviceDetailScreen(deviceId: GoldenIds.boiler),
      prepare: (_) async {
        source = FakeDeviceSource(roomList: fixtureRooms())
          ..deviceList = [goldenListed(GoldenIds.boiler)]
          ..details[GoldenIds.boiler] = heatingDetail(
            heatingSuspended: suspended,
            transform: localJson,
          );
      },
      overrides: () => ownerOverrides(source),
    );
  }

  screenGolden('OWNER, heating on', fileName: 'owner');
  screenGolden('OWNER, suspended', fileName: 'suspended', suspended: true);

  final suspendedDetail = Fetched(
    heatingDetail(heatingSuspended: true, transform: localJson),
    goldenNow.subtract(const Duration(seconds: 3)),
  );

  screenGoldens(
    'Resume sheet',
    fileName: 'heating_resume_sheet',
    devices: const [GoldenDevice.smallPhone, GoldenDevice.largePhone],
    screen: () => Scaffold(
      body: ResumeSheet(detail: suspendedDetail, now: goldenNow),
    ),
  );

  screenGoldens(
    'Strategy editor',
    fileName: 'heating_strategy_editor',
    devices: const [GoldenDevice.smallPhone, GoldenDevice.largePhone],
    screen: () => Scaffold(
      body: StrategyEditorSheet(
        detail: Fetched(
          heatingDetail(heatingSuspended: true, safeMax: 60),
          goldenNow,
        ),
      ),
    ),
  );

  void outcomeGolden(String fileName, SuspensionState state) => screenGoldens(
    // A progress indicator never settles.
    settle: state.isBusy ? pumpNTimes(2) : onlyPumpAndSettle,
    'Suspension outcome: $fileName',
    fileName: 'heating_outcome_$fileName',
    devices: const [GoldenDevice.smallPhone],
    screen: () => Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SuspensionOutcome(
          state: state,
          now: goldenNow,
          onRefresh: () {},
        ),
      ),
    ),
  );

  outcomeGolden(
    'awaiting_heartbeat',
    const SuspendApplied(relays: RelayReport.awaitingHeartbeat),
  );
  outcomeGolden(
    'outputs_off',
    SuspendApplied(relays: RelayReport.outputsOff, heartbeatAt: heartbeatAt),
  );
  outcomeGolden(
    'output_on',
    SuspendApplied(relays: RelayReport.outputOn, heartbeatAt: heartbeatAt),
  );
  outcomeGolden(
    'legacy',
    const SuspendApplied(relays: RelayReport.notApplicable),
  );
  outcomeGolden(
    'no_heartbeat',
    const SuspendApplied(relays: RelayReport.noHeartbeat),
  );
  outcomeGolden('resume_pending', const ResumeApplied(strategyRestored: false));
}
