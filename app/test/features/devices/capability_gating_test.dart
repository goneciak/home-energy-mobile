import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/core_capabilities.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/presentation/device_detail_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fake_device_source.dart';
import '../../support/heating_fixtures.dart';
import '../../support/test_app.dart';

const _deviceId = '60d5a6b9-e974-45b0-b3ee-43e264d1ec85';

/// Device details gated on the capability probes (plan §16 pt 2).
void main() {
  final now = DateTime.utc(2026, 11, 18, 7, 41);

  Future<void> pumpDetail(
    WidgetTester tester,
    CoreCapabilities capabilities,
  ) async {
    tester.view
      ..physicalSize = const Size(1200, 12000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testScreen(
        const DeviceDetailScreen(deviceId: _deviceId),
        overrides: [
          deviceReadSourceProvider.overrideWithValue(
            FakeDeviceSource(details: {_deviceId: heatingDetail()}),
          ),
          currentUserProvider.overrideWithValue(
            const CurrentUser(
              id: 'u1',
              email: 'owner@example.com',
              firstName: 'Ola',
              mustChangePassword: false,
              role: UserRole.owner,
            ),
          ),
          coreCapabilitiesProvider.overrideWithValue(AsyncData(capabilities)),
          appForegroundProvider.overrideWithValue(AppForeground()),
          clockProvider.overrideWithValue(() => now),
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

  const schedules = ValueKey('device-schedules');
  const nightHistory = ValueKey('device-night-history');
  const pvPlan = ValueKey('device-pv-plan');

  testWidgets('unprobed or present: every entry is offered', (tester) async {
    await pumpDetail(tester, CoreCapabilities.unprobed);
    expect(find.byKey(schedules), findsOneWidget);
    expect(find.byKey(nightHistory), findsOneWidget);
    expect(find.byKey(pvPlan), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('routes this Core lacks are not offered', (tester) async {
    await pumpDetail(
      tester,
      CoreCapabilities(const {
        CoreCapability.schedules: CapabilityStatus.absent,
        CoreCapability.history: CapabilityStatus.absent,
        CoreCapability.pvPlan: CapabilityStatus.absent,
        CoreCapability.sessions: CapabilityStatus.present,
      }),
    );
    expect(find.byKey(schedules), findsNothing);
    expect(find.byKey(nightHistory), findsNothing);
    expect(find.byKey(pvPlan), findsNothing);
    await unmount(tester);
  });
}
