import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/environment/data/environment_source.dart';
import 'package:gi_home/src/features/schedules/application/schedule_providers.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'environment_providers.g.dart';

/// Environment endpoints of the saved appliance; only read once signed in,
/// i.e. when a client exists.
@Riverpod(keepAlive: true)
EnvironmentSource environmentSource(Ref ref) {
  final client = ref.watch(giCoreClientProvider);
  if (client == null) return const _Detached();
  return GiCoreEnvironmentSource(client);
}

/// The zone weather hours and sun times are shown in: the home zone from
/// `/settings/system` when the role may read it, otherwise the phone's.
@riverpod
ScheduleZone houseZone(Ref ref) =>
    ref.watch(scheduleClockProvider.select((clock) => clock.zone)) ??
    const PhoneScheduleZone();

/// `GET /weather/current`, loaded when the weather screen opens and again
/// on pull-to-refresh.
@riverpod
Future<EnvironmentResult<WeatherEnvelope<CurrentWeather>>> weatherCurrent(
  Ref ref,
) => ref.watch(environmentSourceProvider).weatherCurrent();

/// `GET /weather/hourly` (at most 72 hours, UTC).
@riverpod
Future<EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>> weatherHourly(
  Ref ref,
) => ref.watch(environmentSourceProvider).weatherHourly();

/// `GET /weather/daily` (UTC days).
@riverpod
Future<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>> weatherDaily(
  Ref ref,
) => ref.watch(environmentSourceProvider).weatherDaily();

/// `GET /solar/current`.
@riverpod
Future<EnvironmentResult<SolarStatus>> solarStatus(Ref ref) =>
    ref.watch(environmentSourceProvider).solarCurrent();

/// `GET /pv/forecast`.
@riverpod
Future<EnvironmentResult<PvForecast>> pvForecast(Ref ref) =>
    ref.watch(environmentSourceProvider).pvForecast();

/// `GET /devices/:id/pv-heating-plan` of device [deviceId].
@riverpod
Future<PvHeatingPlan> pvHeatingPlan(Ref ref, String deviceId) =>
    ref.watch(environmentSourceProvider).pvHeatingPlan(deviceId);

/// The source while there is no client (see `device_repositories.dart`).
final class _Detached implements EnvironmentSource {
  const new();

  @override
  Object? noSuchMethod(Invocation invocation) =>
      Future<Never>.error(StateError('No appliance profile'));
}
