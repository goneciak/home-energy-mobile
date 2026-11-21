@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/home/presentation/home_screen.dart';

import '../support/fake_device_source.dart';
import '../support/fixtures.dart';
import '../support/golden.dart';
import 'golden_devices.dart';

/// "Dom" (plan §17.1, G3): healthy, with attention items, empty, and
/// offline with outdated data.
void main() {
  late FakeDeviceSource source;
  late DateTime clock;

  setUp(() {
    clock = goldenNow;
    source = FakeDeviceSource(roomList: fixtureRooms());
  });

  void homeGoldens(
    String description, {
    required String fileName,
    required void Function() data,
    Future<void> Function(WidgetTester tester)? act,
  }) => screenGoldens(
    description,
    fileName: fileName,
    screen: HomeScreen.new,
    prepare: (_) async => data(),
    overrides: () => [
      deviceReadSourceProvider.overrideWithValue(source),
      currentUserProvider.overrideWithValue(null),
      appForegroundProvider.overrideWithValue(AppForeground()),
      clockProvider.overrideWithValue(() => clock),
    ],
    act: act,
  );

  void healthyHome() {
    source
      ..deviceList = [
        goldenListed(GoldenIds.boiler),
        goldenListed(GoldenIds.lamp, seenAgo: const Duration(minutes: 1)),
        goldenListed(GoldenIds.sensor, seenAgo: const Duration(minutes: 2)),
      ]
      ..details[GoldenIds.boiler] = goldenBoilerDetail({'diagnostics': null});
  }

  homeGoldens(
    'Home: everything fine',
    fileName: 'home_healthy',
    data: healthyHome,
  );

  homeGoldens(
    'Home: heating faults, a suspended heating and an offline device',
    fileName: 'home_attention',
    data: () {
      const heatingFlags = {
        'heatingSuspended': true,
        'dryRun': true,
        'activeFaultCount': 2,
      };
      source
        ..deviceList = [
          goldenListed(
            GoldenIds.boiler,
            seenAgo: const Duration(minutes: 5),
            overrides: heatingFlags,
          ),
          goldenListed(
            GoldenIds.lamp,
            connectivity: 'OFFLINE',
            seenAgo: const Duration(hours: 3),
          ),
          goldenListed(
            GoldenIds.sensor,
            connectivity: 'STALE',
            seenAgo: const Duration(minutes: 20),
          ),
        ]
        ..details[GoldenIds.boiler] = goldenBoilerDetail({
          'heatingSuspended': true,
          'dryRun': true,
          'diagnostics': null,
        });
    },
  );

  homeGoldens(
    'Home: no devices yet',
    fileName: 'home_empty',
    data: () => source.deviceList = [],
  );

  homeGoldens(
    'Home: GI Home unreachable, data older than 2 minutes',
    fileName: 'home_offline_stale',
    data: healthyHome,
    act: (tester) async {
      source
        ..devicesFailure = const ApiFailure.unreachable()
        ..roomsFailure = const ApiFailure.unreachable()
        ..detailFailure = const ApiFailure.unreachable();
      clock = goldenNow.add(const Duration(minutes: 3));
      // The next 30 s poll of the list and the heating card fails.
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
    },
  );
}
