import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/schedules/application/schedule_providers.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_mutation_state.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';

import '../../support/fake_device_source.dart';
import '../../support/heating_fixtures.dart';
import '../../support/schedule_fixtures.dart';

const deviceId = 'd1';

CurrentUser user(UserRole role) => CurrentUser(
  id: 'u1',
  email: 'owner@example.com',
  firstName: 'Ola',
  mustChangePassword: false,
  role: role,
);

void main() {
  late FakeScheduleSource schedules;
  late FakeDeviceSource devices;

  setUp(() {
    schedules = FakeScheduleSource({
      deviceId: [scheduleRow('a')],
    });
    devices = FakeDeviceSource()..details[deviceId] = heatingDetail();
  });

  ProviderContainer container({
    UserRole role = UserRole.owner,
    bool convert = false,
    String? timezone,
  }) {
    final c = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        scheduleSourceProvider.overrideWithValue(schedules),
        deviceReadSourceProvider.overrideWithValue(devices),
        currentUserProvider.overrideWithValue(user(role)),
        systemSettingsProvider.overrideWith(
          (ref) async => timezone == null
              ? null
              : SystemSettings(locale: 'pl-PL', timezone: timezone),
        ),
        featureFlagsProvider.overrideWithValue(
          FeatureFlags({FeatureFlag.scheduleClockConversion: convert}),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('OWNER and ADMIN edit, USER and SERVICE only read', () {
    expect(container().read(canEditSchedulesProvider), isTrue);
    expect(
      container(role: UserRole.admin).read(canEditSchedulesProvider),
      isTrue,
    );
    expect(
      container(role: UserRole.user).read(canEditSchedulesProvider),
      isFalse,
    );
    expect(
      container(role: UserRole.service).read(canEditSchedulesProvider),
      isFalse,
    );
  });

  group('scheduleClock', () {
    Future<ScheduleClock> clockOf(ProviderContainer c) async {
      c.listen(scheduleClockProvider, (_, _) {});
      await c.read(systemSettingsProvider.future);
      final clock = c.read(scheduleClockProvider);
      return clock;
    }

    test('converts only with the flag and a known home zone', () async {
      final on = await clockOf(
        container(convert: true, timezone: 'Europe/Warsaw'),
      );
      expect(on.convertsEdits, isTrue);
      expect(on.zone?.name, 'Europe/Warsaw');

      final off = await clockOf(container(timezone: 'Europe/Warsaw'));
      expect(off.convertsEdits, isFalse);
      expect(off.zone, isA<IanaScheduleZone>());
    });

    test('without the home zone the phone zone is a label only', () async {
      final clock = await clockOf(container(convert: true));
      expect(clock.convertsEdits, isFalse);
      expect(clock.zone, isA<PhoneScheduleZone>());
    });
  });

  test('a create reloads the list and the device', () async {
    final c = container();
    c.listen(schedulesProvider(deviceId), (_, _) {});
    await c.read(schedulesProvider(deviceId).future);
    final mutation = c.read(scheduleMutationProvider(deviceId).notifier);
    await mutation.create(
      const HeatingScheduleInput(
        name: 'Rano',
        daysOfWeek: [1],
        startTime: '06:00',
        endTime: '08:00',
        targetTemperatureCelsius: 50,
        hysteresisCelsius: 3,
      ),
    );
    expect(
      c.read(scheduleMutationProvider(deviceId)),
      isA<ScheduleMutationSaved>(),
    );
    expect(schedules.calls, ['list:d1', 'create:d1', 'list:d1']);
    expect(devices.calls, contains('device:d1'));
    expect(c.read(schedulesProvider(deviceId)).requireValue, hasLength(2));
  });

  test('HEATING_SCHEDULE_NOT_FOUND reloads the list', () async {
    final c = container();
    c.listen(schedulesProvider(deviceId), (_, _) {});
    await c.read(schedulesProvider(deviceId).future);
    schedules
      ..writeFailure = const ApiFailure.notFound(
        code: GiErrorCodes.heatingScheduleNotFound,
      )
      ..rows[deviceId] = [];
    await c.read(scheduleMutationProvider(deviceId).notifier).delete('a');
    expect(
      c.read(scheduleMutationProvider(deviceId)),
      isA<ScheduleMutationGone>(),
    );
    expect(schedules.calls.last, 'list:d1');
    expect(c.read(schedulesProvider(deviceId)).requireValue, isEmpty);
  });

  test('another failure is kept for the editor', () async {
    final c = container();
    schedules.writeFailure = const ApiFailure.forbidden(code: 'HTTP_403');
    await c
        .read(scheduleMutationProvider(deviceId).notifier)
        .update('a', const HeatingSchedulePatch(enabled: false));
    final state = c.read(scheduleMutationProvider(deviceId));
    expect(state, isA<ScheduleMutationFailed>());
    expect((state as ScheduleMutationFailed).failure.code, 'HTTP_403');
  });
}
