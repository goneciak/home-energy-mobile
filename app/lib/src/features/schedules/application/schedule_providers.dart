import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_detail_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/schedules/data/schedule_source.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_mutation_state.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'schedule_providers.g.dart';

/// Heating schedule endpoints of the saved appliance; only read once
/// signed in, i.e. when a client exists.
@Riverpod(keepAlive: true)
ScheduleSource scheduleSource(Ref ref) {
  final client = ref.watch(giCoreClientProvider);
  if (client == null) return const _Detached();
  return GiCoreScheduleSource(client);
}

/// Whether the signed-in user may create, change and delete schedules,
/// from the endpoint catalog (OWNER, ADMIN); USER and SERVICE only read.
@riverpod
bool canEditSchedules(Ref ref) {
  final role = ref.watch(currentUserProvider.select((user) => user?.role));
  return role != null &&
      GiEndpoints.scheduleCreate.allows(role) &&
      GiEndpoints.scheduleUpdate.allows(role) &&
      GiEndpoints.scheduleRemove.allows(role);
}

/// The clock schedule times are shown and edited in (plan §13.4, D8): the
/// home zone from `/settings/system` when the role may read it, otherwise
/// the phone's zone as a label only. Converting edits needs the
/// `scheduleClockConversion` flag and the home zone.
@riverpod
ScheduleClock scheduleClock(Ref ref) {
  final convert = ref.watch(
    featureFlagsProvider.select((flags) => flags.scheduleClockConversion),
  );
  final settings = ref.watch(systemSettingsProvider);
  final home = switch (settings.value?.timezone) {
    final name? => IanaScheduleZone.tryParse(name),
    null => null,
  };
  return ScheduleClock(
    zone: home ?? const PhoneScheduleZone(),
    convert: convert && home != null,
  );
}

/// The heating schedules of device [deviceId], oldest first (the order GI
/// Core applies them in). Loaded when the schedule list opens; reloaded
/// on pull-to-refresh and after every change.
@riverpod
class Schedules extends _$Schedules {
  @override
  Future<List<HeatingSchedule>> build(String deviceId) =>
      ref.watch(scheduleSourceProvider).schedules(deviceId);

  /// Loads the list again, keeping the current one on screen meanwhile.
  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } on Object {
      // Shown by the error state of the list.
    }
  }
}

/// Creates, changes and deletes the schedules of device [deviceId]. Each
/// save reloads the list and the device, whose effective strategy GI Core
/// reconciles right away. Nothing is retried automatically.
@riverpod
class ScheduleMutation extends _$ScheduleMutation {
  @override
  ScheduleMutationState build(String deviceId) => const ScheduleMutationIdle();

  Future<void> create(HeatingScheduleInput input) => _run(
    () => ref.read(scheduleSourceProvider).createSchedule(deviceId, input),
  );

  Future<void> update(String scheduleId, HeatingSchedulePatch patch) => _run(
    () => ref
        .read(scheduleSourceProvider)
        .updateSchedule(deviceId, scheduleId, patch),
  );

  Future<void> delete(String scheduleId) => _run(
    () => ref.read(scheduleSourceProvider).deleteSchedule(deviceId, scheduleId),
    deleted: true,
  );

  /// Forgets the outcome.
  void reset() {
    if (!state.isBusy) state = const ScheduleMutationIdle();
  }

  Future<void> _run(
    Future<Object?> Function() call, {
    bool deleted = false,
  }) async {
    if (state.isBusy) return;
    state = const ScheduleMutationSaving();
    try {
      await call();
      if (!ref.mounted) return;
      state = ScheduleMutationSaved(deleted: deleted);
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return;
      state = failure.code == GiErrorCodes.heatingScheduleNotFound
          ? const ScheduleMutationGone()
          : ScheduleMutationFailed(failure);
    }
    await _reload();
  }

  Future<void> _reload() async {
    if (!ref.mounted) return;
    final schedules = schedulesProvider(deviceId);
    if (ref.read(schedules.exists)) {
      await ref.read(schedules.notifier).refresh();
    }
    if (!ref.mounted) return;
    if (ref.read(deviceDetailProvider(deviceId).exists)) {
      await ref.read(deviceDetailProvider(deviceId).notifier).refresh();
      return;
    }
    try {
      await ref.read(devicesRepositoryProvider).fetchDevice(deviceId);
    } on ApiFailure {
      // Shown by the next poll of the device screen.
    }
  }
}

/// The source while there is no client (see `device_repositories.dart`).
final class _Detached implements ScheduleSource {
  const new();

  @override
  Object? noSuchMethod(Invocation invocation) =>
      Future<Never>.error(StateError('No appliance profile'));
}
