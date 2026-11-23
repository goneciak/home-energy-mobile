import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/presentation/device_detail_screen.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fake_device_source.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

/// What a real GI Edge controller produces, as Core serves it: sensors that
/// stop updating without becoming unavailable, and diagnostics entities
/// nobody assigned a role to.
void main() {
  final now = DateTime.utc(2026, 11, 18, 7, 41);

  Map<String, Object?> entity(
    String id,
    String name,
    String source, {
    String domain = 'sensor',
    Object? value,
    String? unit,
    String lastSeenAt = '2026-11-18T07:40:30.000Z',
    Map<String, String>? role,
  }) => {
    'id': id,
    'displayName': name,
    'sourceName': source,
    'domain': domain,
    'deviceClass': null,
    'value': value,
    'unit': unit,
    'readable': true,
    'writable': false,
    'availability': true,
    'lastSeenAt': lastSeenAt,
    'assignedFunction': null,
    'assignedRole': role,
    'enabled': true,
  };

  Future<void> pump(
    WidgetTester tester,
    List<Map<String, Object?>> entities,
  ) async {
    final detail = DeviceDetail.fromJson({
      ...entityRichDetailJson(),
      'entities': entities,
      'status': 'needs_configuration',
    });
    tester.view
      ..physicalSize = const Size(1200, 12000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testScreen(
        DeviceDetailScreen(deviceId: detail.id),
        overrides: [
          deviceReadSourceProvider.overrideWithValue(
            FakeDeviceSource(
              deviceList: fixtureDevices(),
              roomList: fixtureRooms(),
              details: {detail.id: detail},
            ),
          ),
          currentUserProvider.overrideWithValue(null),
          appForegroundProvider.overrideWithValue(AppForeground()),
          clockProvider.overrideWithValue(() => now),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a sensor silent for 30 minutes says so, not its old value', (
    tester,
  ) async {
    await pump(tester, [
      entity(
        'supply',
        'Temperatura zasilania',
        'temperature_1',
        value: 45.5,
        unit: '°C',
        lastSeenAt: '2026-11-18T07:10:00.000Z',
        role: {'code': 'SUPPLY', 'name': 'Zasilanie'},
      ),
      entity(
        'return',
        'Temperatura powrotu',
        'temperature_2',
        value: 41.123456,
        unit: '°C',
        role: {'code': 'RETURN', 'name': 'Powrót'},
      ),
    ]);

    final supply = find.byKey(const ValueKey('entity-supply'));
    expect(
      find.descendant(of: supply, matching: find.text('Brak świeżych danych')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: supply, matching: find.text('45,5 °C')),
      findsNothing,
    );
    expect(
      find.descendant(of: supply, matching: find.textContaining('31 min')),
      findsOneWidget,
    );
    // A fresh reading with six decimals shows one.
    expect(find.text('41,1 °C'), findsOneWidget);
  });

  testWidgets('unassigned diagnostics entities hide under a collapsed header', (
    tester,
  ) async {
    await pump(tester, [
      entity(
        'supply',
        'Temperatura zasilania',
        'temperature_1',
        value: 45.5,
        unit: '°C',
        role: {'code': 'SUPPLY', 'name': 'Zasilanie'},
      ),
      entity('up', 'device_uptime', 'device_uptime', value: 1234, unit: 's'),
      entity('heap', 'diagnostics.freeHeap', 'diagnostics.freeHeap', value: 99),
    ]);

    expect(find.byKey(const ValueKey('entity-supply')), findsOneWidget);
    expect(find.byKey(const ValueKey('entity-up')), findsNothing);
    expect(find.byKey(const ValueKey('entity-heap')), findsNothing);

    await tester.tap(find.text('Dane techniczne urządzenia'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('entity-up')), findsOneWidget);
    expect(find.byKey(const ValueKey('entity-heap')), findsOneWidget);
  });

  testWidgets('needs_configuration is a neutral hint', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      testScreen(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    final look = productStatusLook(
      context.l10n,
      ProductStatus.needsConfiguration,
      benign: true,
    );
    expect(look.tone, StatusTone.neutral);
    expect(
      productStatusLook(context.l10n, ProductStatus.needsConfiguration).tone,
      StatusTone.warning,
    );
  });
}
