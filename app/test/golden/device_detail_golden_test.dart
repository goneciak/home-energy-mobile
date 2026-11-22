@Tags(['golden'])
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/presentation/device_detail_screen.dart';
import 'package:gi_home/src/features/environment/application/environment_providers.dart';

import '../support/environment_fixtures.dart';
import '../support/fake_device_source.dart';
import '../support/fixtures.dart';
import '../support/golden.dart';
import 'golden_devices.dart';

/// Read-only device details (plan §17.1): normal, heating suspended,
/// dry-run, device offline, and stale data.
void main() {
  late FakeDeviceSource source;
  late DateTime clock;

  setUp(() {
    clock = goldenNow;
    source = FakeDeviceSource(roomList: fixtureRooms());
  });

  void detailGoldens(
    String description, {
    required String fileName,
    Map<String, Object?> device = const {},
    String connectivity = 'ONLINE',
    Duration seenAgo = const Duration(seconds: 30),
    Future<void> Function(WidgetTester tester)? act,
  }) => screenGoldens(
    description,
    fileName: fileName,
    screen: () => const DeviceDetailScreen(deviceId: GoldenIds.boiler),
    prepare: (_) async {
      final lastSeenAt = goldenNow.subtract(seenAgo).toIso8601String();
      source
        ..deviceList = [
          goldenListed(
            GoldenIds.boiler,
            connectivity: connectivity,
            seenAgo: seenAgo,
            overrides: device,
          ),
        ]
        ..details[GoldenIds.boiler] = goldenBoilerDetail({
          'connectivityState': connectivity,
          'status': connectivity.toLowerCase(),
          'lastSeenAt': lastSeenAt,
          ...device,
        });
    },
    overrides: () => [
      deviceReadSourceProvider.overrideWithValue(source),
      environmentSourceProvider.overrideWithValue(FakeEnvironmentSource()),
      currentUserProvider.overrideWithValue(null),
      appForegroundProvider.overrideWithValue(AppForeground()),
      clockProvider.overrideWithValue(() => clock),
    ],
    act: act,
  );

  detailGoldens('Details: normal', fileName: 'detail_normal');

  detailGoldens(
    'Details: heating suspended',
    fileName: 'detail_suspended',
    device: {'heatingSuspended': true},
  );

  detailGoldens(
    'Details: dry-run',
    fileName: 'detail_dry_run',
    device: {'dryRun': true},
  );

  detailGoldens(
    'Details: device offline',
    fileName: 'detail_offline',
    connectivity: 'OFFLINE',
    seenAgo: const Duration(hours: 3),
  );

  detailGoldens(
    'Details: no answer for more than 10 s',
    fileName: 'detail_stale',
    act: (tester) async {
      // The next 5 s poll is still in flight 11 s after the data arrived.
      source.detailGate = Completer<void>().future;
      clock = goldenNow.add(const Duration(seconds: 11));
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
    },
  );
}
