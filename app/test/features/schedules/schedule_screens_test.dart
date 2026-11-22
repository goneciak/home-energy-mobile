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

import '../../support/schedule_fixtures.dart';
import '../../support/test_app.dart';

/// Monday 2026-11-23, 06:30 UTC (07:30 in Warsaw).
final now = DateTime.utc(2026, 11, 23, 6, 30);
final IanaScheduleZone warsaw = IanaScheduleZone.tryParse('Europe/Warsaw')!;

CurrentUser user(UserRole role) => CurrentUser(
  id: 'u1',
  email: 'owner@example.com',
  firstName: 'Ola',
  mustChangePassword: false,
  role: role,
);

void main() {
  late FakeScheduleSource source;

  setUp(() {
    source = FakeScheduleSource({
      'd1': [
        scheduleRow('morning', name: 'Rano'),
        scheduleRow(
          'evening',
          name: 'Wieczór',
          start: '22:00',
          end: '06:00',
          createdMinute: 1,
          enabled: false,
        ),
      ],
    });
  });

  List<Override> overrides(UserRole role, {bool convert = false}) => [
    scheduleSourceProvider.overrideWithValue(source),
    currentUserProvider.overrideWithValue(user(role)),
    scheduleClockProvider.overrideWithValue(
      ScheduleClock(zone: warsaw, convert: convert),
    ),
    clockProvider.overrideWithValue(() => now),
  ];

  group('SchedulesScreen', () {
    testWidgets('OWNER sees the schedules, the active one and "Dodaj"', (
      tester,
    ) async {
      await tester.pumpWidget(
        testScreen(
          const SchedulesScreen(deviceId: 'd1'),
          overrides: overrides(UserRole.owner),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rano'), findsOneWidget);
      expect(find.text('Wieczór'), findsOneWidget);
      expect(find.text('Aktywny teraz'), findsOneWidget);
      expect(find.text('Wyłączony'), findsOneWidget);
      expect(find.byKey(const ValueKey('schedule-add')), findsOneWidget);
      expect(find.byKey(const ValueKey('schedules-view-only')), findsNothing);
      expect(
        find.textContaining('Dziś 06:00 UTC to 07:00 czasu domu'),
        findsOneWidget,
      );
    });

    testWidgets('USER reads only', (tester) async {
      await tester.pumpWidget(
        testScreen(
          const SchedulesScreen(deviceId: 'd1'),
          overrides: overrides(UserRole.user),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Zmiany ogrzewania może wprowadzić właściciel.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('schedule-add')), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('empty list', (tester) async {
      source.rows['d1'] = [];
      await tester.pumpWidget(
        testScreen(
          const SchedulesScreen(deviceId: 'd1'),
          overrides: overrides(UserRole.owner),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Brak harmonogramów'), findsOneWidget);
    });
  });

  group('ScheduleEditorForm', () {
    HeatingScheduleInput? saved;

    Future<void> pumpForm(
      WidgetTester tester, {
      HeatingSchedule? initial,
      ScheduleClock? clock,
    }) async {
      saved = null;
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        testScreen(
          Scaffold(
            body: ScheduleEditorForm(
              initial: initial,
              others: source.rows['d1']!,
              clock: clock ?? ScheduleClock(zone: warsaw),
              now: now,
              onSave: (input) => saved = input,
              onDelete: initial == null ? null : () async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> save(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('schedule-save')));
      await tester.pumpAndSettle();
    }

    testWidgets('shows every validation error and sends nothing', (
      tester,
    ) async {
      await pumpForm(tester);
      for (final day in [1, 2, 3, 4, 5]) {
        await tester.tap(find.byKey(ValueKey('schedule-day-$day')));
      }
      await tester.enterText(
        find.byKey(const ValueKey('schedule-target')),
        '150',
      );
      await tester.enterText(
        find.byKey(const ValueKey('schedule-hysteresis')),
        '0,5',
      );
      await save(tester);
      expect(find.text('Podaj nazwę, najwyżej 120 znaków.'), findsOneWidget);
      expect(find.text('Wybierz co najmniej jeden dzień.'), findsOneWidget);
      expect(find.text('Podaj wartość od 0 do 100 °C.'), findsOneWidget);
      expect(find.text('Podaj wartość od 1 do 20 °C.'), findsOneWidget);
      expect(saved, isNull);
    });

    testWidgets('warns about an overlap and saves the GI Core clock', (
      tester,
    ) async {
      await pumpForm(tester);
      await tester.enterText(find.byKey(const ValueKey('schedule-name')), 'X');
      await tester.pumpAndSettle();
      expect(find.textContaining('Nakłada się na: Rano'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('schedule-target')),
        '47,5',
      );
      await save(tester);
      expect(saved?.name, 'X');
      expect(saved?.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(saved?.startTime, '06:00');
      expect(saved?.endTime, '08:00');
      expect(saved?.targetTemperatureCelsius, 47.5);
    });

    testWidgets('converts home time when the clock converts', (tester) async {
      await pumpForm(tester, clock: ScheduleClock(zone: warsaw, convert: true));
      await tester.enterText(find.byKey(const ValueKey('schedule-name')), 'X');
      await save(tester);
      // 06:00-08:00 home time in November = 05:00-07:00 UTC.
      expect(saved?.startTime, '05:00');
      expect(saved?.endTime, '07:00');
    });

    testWidgets('edit: wraps past midnight, delete asks first', (tester) async {
      await pumpForm(tester, initial: source.rows['d1']![1]);
      expect(
        find.text('Okno kończy się następnego dnia o 06:00.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('schedule-delete')));
      await tester.pumpAndSettle();
      expect(find.text('Usunąć harmonogram?'), findsOneWidget);
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      expect(find.text('Usunąć harmonogram?'), findsNothing);
    });
  });
}
