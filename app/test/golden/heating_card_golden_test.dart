@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/home/presentation/widgets/heating_card.dart';
import 'package:material_ui/material_ui.dart';

import '../support/golden.dart';
import 'golden_devices.dart';

/// The heating card's control settings (plan §12.5, M2 item 3): default
/// only, schedule active, suspended (effective mode OFF ignored), PV boost
/// with and without configuration, dry-run, stale data, a latched fault,
/// no strategies, and the USER view.
void main() {
  const owner = HeatingPermission(
    canSwitch: true,
    canSuspend: true,
    canEditStrategy: true,
  );

  Map<String, Object?> strategy(num target, num hysteresis, String mode) => {
    'targetTemperatureCelsius': target,
    'hysteresisCelsius': hysteresis,
    'mode': mode,
  };

  final base = strategy(55, 4, 'AUTO');

  void cardGolden(
    String description, {
    required String fileName,
    Map<String, Object?> detail = const {},
    Map<String, Object?> listed = const {},
    HeatingPermission permission = owner,
    Duration fetchedAgo = Duration.zero,
    VoidCallback? onResume,
  }) => screenGoldens(
    'Heating card: $description',
    fileName: 'heating_card_$fileName',
    devices: const [GoldenDevice.smallPhone],
    screen: () => Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HeatingCard(
            device: goldenListed(GoldenIds.boiler, overrides: listed),
            listFetchedAt: goldenNow,
            detail: PolledData(
              data: Fetched(
                goldenBoilerDetail({
                  'controlStrategy': base,
                  'baseControlStrategy': base,
                  'pvBoostActive': false,
                  ...detail,
                }),
                goldenNow.subtract(fetchedAgo),
              ),
            ),
            roomName: 'Kotłownia',
            now: goldenNow,
            onTap: () {},
            permission: permission,
            onResume: onResume,
          ),
        ],
      ),
    ),
  );

  cardGolden('default only', fileName: 'base_only');

  cardGolden(
    'schedule active',
    fileName: 'schedule_active',
    detail: {'controlStrategy': strategy(21, 0.5, 'AUTO')},
  );

  cardGolden(
    'suspended, mode OFF ignored',
    fileName: 'suspended',
    detail: {
      'heatingSuspended': true,
      'controlStrategy': strategy(21, 0.5, 'OFF'),
    },
    listed: {'heatingSuspended': true},
    onResume: () {},
  );

  cardGolden(
    'PV boost with configuration',
    fileName: 'pv_boost',
    detail: {
      'pvBoostActive': true,
      'pvHeatingConfig': {'mode': 'HYBRID', 'safeMaxTemperatureCelsius': 75},
    },
  );

  cardGolden(
    'PV boost without configuration',
    fileName: 'pv_boost_no_config',
    detail: {'pvBoostActive': true, 'pvHeatingConfig': null},
  );

  cardGolden(
    'dry-run',
    fileName: 'dry_run',
    detail: {'dryRun': true},
    listed: {'dryRun': true},
  );

  cardGolden(
    'stale details',
    fileName: 'stale',
    fetchedAgo: const Duration(minutes: 2),
    listed: {'connectivityState': 'STALE'},
  );

  cardGolden(
    'latched fault',
    fileName: 'fault',
    listed: {'currentState': 'FAULT', 'activeFaultCount': 1},
  );

  cardGolden(
    'no strategies',
    fileName: 'no_strategy',
    detail: {'controlStrategy': null, 'baseControlStrategy': null},
  );

  cardGolden(
    'USER view, suspended',
    fileName: 'user_suspended',
    permission: HeatingCard.viewOnly,
    detail: {'heatingSuspended': true},
    listed: {'heatingSuspended': true},
  );
}
