@Tags(['golden'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/schedules/application/schedule_providers.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:gi_home/src/features/schedules/presentation/schedule_editor_screen.dart';
import 'package:gi_home/src/features/schedules/presentation/schedules_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../support/golden.dart';
import '../support/schedule_fixtures.dart';

/// Heating schedules (plan §20 M3): the list filled, empty and read-only
/// for a USER, and the editor with its validation errors. The app has one
/// (dark) theme (D11), so there is no light variant.
void main() {
  // Monday 2026-11-23, 06:30 UTC: "Rano" (06:00-08:00) is active.
  final now = DateTime.utc(2026, 11, 23, 6, 30);
  final clock = ScheduleClock(zone: IanaScheduleZone.tryParse('Europe/Warsaw'));

  List<HeatingSchedule> filled() => [
    scheduleRow('morning', name: 'Rano'),
    scheduleRow(
      'weekend',
      name: 'Weekend cały dzień',
      days: [6, 0],
      start: '00:00',
      end: '00:00',
      target: 50.5,
      createdMinute: 1,
    ),
    scheduleRow(
      'night',
      name: 'Noc',
      days: [6],
      start: '22:00',
      end: '06:00',
      target: 45,
      hysteresis: 5,
      enabled: false,
      createdMinute: 2,
    ),
  ];

  List<Override> overrides(
    FakeScheduleSource source, {
    UserRole role = UserRole.owner,
  }) => [
    scheduleSourceProvider.overrideWithValue(source),
    currentUserProvider.overrideWithValue(
      CurrentUser(
        id: 'u1',
        email: 'owner@example.com',
        firstName: 'Ola',
        mustChangePassword: false,
        role: role,
      ),
    ),
    scheduleClockProvider.overrideWithValue(clock),
    clockProvider.overrideWithValue(() => now),
  ];

  screenGoldens(
    'Schedules: OWNER, filled',
    fileName: 'schedules_owner',
    screen: () => const SchedulesScreen(deviceId: 'd1'),
    overrides: () => overrides(FakeScheduleSource({'d1': filled()})),
  );

  // Every scenario holds its own source: the last one set below fails.
  final sources = <FakeScheduleSource>[];
  screenGoldens(
    'Schedules: GI Home unreachable, the last list stays',
    fileName: 'schedules_offline',
    devices: const [GoldenDevice.smallPhone, GoldenDevice.largePhone],
    screen: () => const SchedulesScreen(deviceId: 'd1'),
    overrides: () {
      final source = FakeScheduleSource({'d1': filled()});
      sources.add(source);
      return overrides(source);
    },
    act: (tester) async {
      for (final source in sources) {
        source.listFailure = const ApiFailure.unreachable();
      }
      for (final element in find.byType(SchedulesScreen).evaluate()) {
        await ProviderScope.containerOf(element)
            .read(schedulesProvider('d1').notifier)
            .refresh();
      }
      await tester.pumpAndSettle();
    },
  );

  screenGoldens(
    'Schedules: empty',
    fileName: 'schedules_empty',
    devices: const [GoldenDevice.smallPhone, GoldenDevice.largePhone],
    screen: () => const SchedulesScreen(deviceId: 'd1'),
    overrides: () => overrides(FakeScheduleSource({'d1': []})),
  );

  screenGoldens(
    'Schedules: USER, read-only',
    fileName: 'schedules_user',
    devices: const [GoldenDevice.smallPhone, GoldenDevice.largePhone],
    screen: () => const SchedulesScreen(deviceId: 'd1'),
    overrides: () =>
        overrides(FakeScheduleSource({'d1': filled()}), role: UserRole.user),
  );

  screenGoldens(
    'Schedule editor: validation errors',
    fileName: 'schedule_editor_errors',
    devices: const [GoldenDevice.smallPhone, GoldenDevice.largePhone],
    screen: () => Scaffold(
      body: ScheduleEditorForm(
        others: filled(),
        clock: clock,
        now: now,
        onSave: (_) {},
      ),
    ),
    act: (tester) async {
      // Every scenario (language × text scale) holds its own form; some
      // sit outside the test view, so the callbacks are called directly.
      for (final day in [1, 2, 3, 4, 5]) {
        for (final chip in tester.widgetList<FilterChip>(
          find.byKey(ValueKey('schedule-day-$day')),
        )) {
          chip.onSelected!(false);
        }
      }
      final targets = find.byKey(const ValueKey('schedule-target'));
      for (var i = 0; i < targets.evaluate().length; i++) {
        await tester.enterText(targets.at(i), '150');
      }
      // The lists build lazily: scroll each to its end so "Zapisz" exists,
      // save, and go back to the top, where the errors start.
      final scrollables = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .toList();
      for (final scrollable in scrollables) {
        scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      }
      await tester.pump();
      for (final button in tester.widgetList<FilledButton>(
        find.byKey(const ValueKey('schedule-save')),
      )) {
        button.onPressed!();
      }
      await tester.pump();
      for (final scrollable in scrollables) {
        scrollable.position.jumpTo(0);
      }
      await tester.pumpAndSettle();
    },
  );

  screenGoldens(
    'Schedule editor: edit with warnings',
    fileName: 'schedule_editor_warnings',
    devices: const [GoldenDevice.smallPhone, GoldenDevice.largePhone],
    screen: () => Scaffold(
      body: ScheduleEditorForm(
        initial: filled()[2].copyWith(enabled: true),
        others: filled(),
        clock: clock,
        now: now,
        onSave: (_) {},
        onDelete: () async {},
      ),
    ),
  );
}
