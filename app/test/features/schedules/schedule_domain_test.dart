import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/schedules/domain/api_weekday.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_window.dart';

ScheduleTimes times(List<int> days, String start, String end) => ScheduleTimes(
  days: days,
  startMinutes: HeatingScheduleRules.minutesOf(start)!,
  endMinutes: HeatingScheduleRules.minutesOf(end)!,
);

int minute(String hhmm) => HeatingScheduleRules.minutesOf(hhmm)!;

HeatingSchedule schedule(
  String id, {
  required List<int> days,
  required String start,
  required String end,
  bool enabled = true,
  int createdMinute = 0,
}) => HeatingSchedule(
  id: id,
  deviceId: 'd1',
  name: id,
  daysOfWeek: days,
  startTime: start,
  endTime: end,
  targetTemperatureCelsius: 50,
  hysteresisCelsius: 3,
  enabled: enabled,
  createdAt: DateTime.utc(2026, 11).add(Duration(minutes: createdMinute)),
  updatedAt: DateTime.utc(2026, 11),
);

void main() {
  group('ApiWeekday', () {
    // 2026-11-23 is a Monday.
    const table = {
      DateTime.monday: 1,
      DateTime.tuesday: 2,
      DateTime.wednesday: 3,
      DateTime.thursday: 4,
      DateTime.friday: 5,
      DateTime.saturday: 6,
      DateTime.sunday: 0,
    };
    for (final MapEntry(key: dart, value: core) in table.entries) {
      test('Dart weekday $dart ↔ GI Core day $core', () {
        expect(ApiWeekday.fromDart(dart), core);
        expect(ApiWeekday.toDart(core), dart);
        final date = DateTime.utc(2026, 11, 22 + dart);
        expect(date.weekday, dart);
        expect(ApiWeekday.of(date), core);
      });
    }

    test('rejects values outside the ranges', () {
      expect(() => ApiWeekday.fromDart(0), throwsRangeError);
      expect(() => ApiWeekday.fromDart(8), throwsRangeError);
      expect(() => ApiWeekday.toDart(-1), throwsRangeError);
      expect(() => ApiWeekday.toDart(7), throwsRangeError);
    });

    test('shift wraps both ways', () {
      expect(ApiWeekday.shift(0, -1), 6);
      expect(ApiWeekday.shift(6, 1), 0);
      expect(ApiWeekday.shift(3, 0), 3);
    });
  });

  group('ScheduleTimes.matches mirrors windowMatches', () {
    test('start minute inclusive, end minute exclusive', () {
      final window = times([1], '06:00', '08:00');
      expect(window.matches(1, minute('05:59')), isFalse);
      expect(window.matches(1, minute('06:00')), isTrue);
      expect(window.matches(1, minute('07:59')), isTrue);
      expect(window.matches(1, minute('08:00')), isFalse);
      expect(window.matches(2, minute('07:00')), isFalse);
    });

    test('start == end is the whole of each listed day', () {
      final window = times([3], '07:00', '07:00');
      expect(window.isWholeDay, isTrue);
      expect(window.matches(3, 0), isTrue);
      expect(window.matches(3, minute('23:59')), isTrue);
      expect(window.matches(4, 0), isFalse);
      expect(window.matches(2, minute('23:59')), isFalse);
    });

    test('22:00-00:00 matches 22:00..23:59 of the start day only', () {
      final window = times([2], '22:00', '00:00');
      expect(window.wrapsMidnight, isTrue);
      expect(window.matches(2, minute('21:59')), isFalse);
      expect(window.matches(2, minute('22:00')), isTrue);
      expect(window.matches(2, minute('23:59')), isTrue);
      // The "yesterday" branch never fires: no minute is < 0.
      expect(window.matches(3, 0), isFalse);
      expect(window.matches(3, minute('00:01')), isFalse);
    });

    test('Saturday 22:00 - Sunday 06:00 with days [6]', () {
      final window = times([6], '22:00', '06:00');
      expect(window.matches(6, minute('22:00')), isTrue);
      expect(window.matches(0, minute('05:59')), isTrue);
      expect(window.matches(0, minute('06:00')), isFalse);
      expect(window.matches(0, minute('22:00')), isFalse);
      expect(window.matches(6, minute('05:59')), isFalse);
    });
  });

  group('ActiveSchedule', () {
    // Monday 2026-11-23, 07:30 UTC.
    final now = DateTime.utc(2026, 11, 23, 7, 30);

    test('the first enabled match by createdAt wins', () {
      final later = schedule(
        'later',
        days: [1],
        start: '07:00',
        end: '09:00',
        createdMinute: 5,
      );
      final earlier = schedule(
        'earlier',
        days: [1],
        start: '06:00',
        end: '08:00',
        createdMinute: 1,
      );
      final disabled = schedule(
        'disabled',
        days: [1],
        start: '00:00',
        end: '00:00',
        enabled: false,
      );
      expect(ActiveSchedule.of([later, disabled, earlier], now)?.id, 'earlier');
      expect(ActiveSchedule.of([later], now)?.id, 'later');
      expect(ActiveSchedule.of([disabled], now), isNull);
      expect(ActiveSchedule.of([later], DateTime.utc(2026, 11, 23, 9)), isNull);
    });
  });

  group('overlap', () {
    test('windows on the same day that share a minute', () {
      expect(
        times([1], '06:00', '08:00').overlaps(times([1], '07:59', '09:00')),
        isTrue,
      );
      expect(
        times([1], '06:00', '08:00').overlaps(times([1], '08:00', '09:00')),
        isFalse,
      );
      expect(
        times([1], '06:00', '08:00').overlaps(times([2], '06:00', '08:00')),
        isFalse,
      );
    });

    test('a wrap reaches into the next day, Saturday into Sunday', () {
      final night = times([6], '22:00', '06:00');
      expect(night.overlaps(times([0], '05:00', '07:00')), isTrue);
      expect(night.overlaps(times([0], '06:00', '07:00')), isFalse);
      expect(night.overlaps(times([6], '05:00', '06:00')), isFalse);
    });

    test('a whole day overlaps everything on that day', () {
      expect(
        times([4], '10:00', '10:00').overlaps(times([4], '23:59', '00:00')),
        isTrue,
      );
      expect(
        times([4], '10:00', '10:00').overlaps(times([5], '00:00', '01:00')),
        isFalse,
      );
    });

    test('overlapping skips the edited schedule and disabled ones', () {
      final edited = times([1], '06:00', '08:00');
      final others = [
        schedule('same', days: [1], start: '06:00', end: '08:00'),
        schedule('hit', days: [1], start: '07:00', end: '07:30'),
        schedule(
          'off',
          days: [1],
          start: '07:00',
          end: '07:30',
          enabled: false,
        ),
        schedule('miss', days: [1], start: '08:00', end: '09:00'),
      ];
      expect(
        ActiveSchedule.overlapping(
          edited,
          others,
          exceptId: 'same',
        ).map((s) => s.id),
        ['hit'],
      );
    });
  });

  group('ScheduleClock', () {
    final warsaw = IanaScheduleZone.tryParse('Europe/Warsaw')!;
    const converting = true;
    final clock = ScheduleClock(zone: warsaw, convert: converting);

    test('unknown zones are not parsed', () {
      expect(IanaScheduleZone.tryParse('Mars/Olympus'), isNull);
    });

    test('without conversion the GI Core clock is edited as is', () {
      final window = times([1], '06:00', '08:00');
      final now = DateTime.utc(2026, 11, 23, 12);
      expect(ScheduleClock(zone: warsaw).toCore(window, now: now), window);
      expect(ScheduleClock.coreOnly.toEditing(window, now: now), window);
      // The phone's zone is never a conversion target.
      expect(
        const ScheduleClock(
          zone: PhoneScheduleZone(),
          convert: converting,
        ).convertsEdits,
        isFalse,
      );
    });

    test('winter: home 07:00-09:00 is GI Core 06:00-08:00', () {
      final now = DateTime.utc(2026, 11, 23, 12);
      final core = clock.toCore(times([1], '07:00', '09:00'), now: now);
      expect(core, times([1], '06:00', '08:00'));
      expect(clock.toEditing(core, now: now), times([1], '07:00', '09:00'));
      expect(clock.zoneMinutesOf(minute('06:00'), now: now), minute('07:00'));
    });

    test('summer: home 07:00 is GI Core 05:00', () {
      final now = DateTime.utc(2026, 7, 6, 12);
      expect(
        clock.toCore(times([1], '07:00', '09:00'), now: now),
        times([1], '05:00', '07:00'),
      );
    });

    test('a start after home midnight moves the days back', () {
      final now = DateTime.utc(2026, 11, 23, 12);
      // Monday and Sunday 00:30-02:00 at home = Sunday and Saturday
      // 23:30-01:00 on the GI Core clock (a wrap, anchored on its start).
      final core = clock.toCore(times([1, 0], '00:30', '02:00'), now: now);
      expect(core, times([0, 6], '23:30', '01:00'));
      expect(core.wrapsMidnight, isTrue);
      expect(clock.toEditing(core, now: now), times([1, 0], '00:30', '02:00'));
    });

    test('a GI Core start late in the day moves the days forward', () {
      final now = DateTime.utc(2026, 7, 6, 12);
      // Saturday 23:00 UTC = Sunday 01:00 summer time.
      expect(
        clock.toEditing(times([6], '23:00', '23:30'), now: now),
        times([0], '01:00', '01:30'),
      );
    });

    group('DST in Europe/Warsaw', () {
      test('2026-03-29: 02:30 does not exist, read as 03:30 CEST', () {
        final now = DateTime.utc(2026, 3, 29, 10);
        final instant = ScheduleClock.resolveWallTime(
          warsaw,
          DateTime.utc(2026, 3, 29, 2, 30),
        );
        expect(instant, DateTime.utc(2026, 3, 29, 1, 30));
        expect(
          clock.toCore(times([0], '02:30', '04:00'), now: now),
          times([0], '01:30', '03:00'),
        );
      });

      test('2026-10-25: 02:30 occurs twice, the first (CEST) wins', () {
        final now = DateTime.utc(2026, 10, 25, 10);
        final instant = ScheduleClock.resolveWallTime(
          warsaw,
          DateTime.utc(2026, 10, 25, 2, 30),
        );
        expect(instant, DateTime.utc(2026, 10, 25, 0, 30));
        expect(
          clock.toCore(times([0], '02:30', '03:00'), now: now),
          times([0], '00:30', '01:00'),
        );
      });

      test('the day of the change: 00:30 crosses midnight either way', () {
        // Before the spring change (CET) and on the autumn day (CEST at
        // 00:30): Sunday 00:30 at home is Saturday on the GI Core clock.
        expect(
          clock.toCore(
            times([0], '00:30', '01:00'),
            now: DateTime.utc(2026, 3, 29, 10),
          ),
          times([6], '23:30', '00:00'),
        );
        expect(
          clock.toCore(
            times([0], '00:30', '01:00'),
            now: DateTime.utc(2026, 10, 25, 10),
          ),
          times([6], '22:30', '23:00'),
        );
      });

      test('a change ahead is reported', () {
        expect(clock.offsetChangesSoon(DateTime.utc(2026, 10, 20)), isTrue);
        expect(clock.offsetChangesSoon(DateTime.utc(2026, 11, 23)), isFalse);
        expect(
          ScheduleClock.coreOnly.offsetChangesSoon(DateTime.utc(2026)),
          isFalse,
        );
      });
    });
  });
}
