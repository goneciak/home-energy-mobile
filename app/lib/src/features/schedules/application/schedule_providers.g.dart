// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Heating schedule endpoints of the saved appliance; only read once
/// signed in, i.e. when a client exists.

@ProviderFor(scheduleSource)
final scheduleSourceProvider = ScheduleSourceProvider._();

/// Heating schedule endpoints of the saved appliance; only read once
/// signed in, i.e. when a client exists.

final class ScheduleSourceProvider
    extends $FunctionalProvider<ScheduleSource, ScheduleSource, ScheduleSource>
    with $Provider<ScheduleSource> {
  /// Heating schedule endpoints of the saved appliance; only read once
  /// signed in, i.e. when a client exists.
  ScheduleSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleSourceHash();

  @$internal
  @override
  $ProviderElement<ScheduleSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScheduleSource create(Ref ref) {
    return scheduleSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleSource>(value),
    );
  }
}

String _$scheduleSourceHash() => r'b2eb65f8604d1819b02de7a4f32fae6599b9fef7';

/// Whether the signed-in user may create, change and delete schedules,
/// from the endpoint catalog (OWNER, ADMIN); USER and SERVICE only read.

@ProviderFor(canEditSchedules)
final canEditSchedulesProvider = CanEditSchedulesProvider._();

/// Whether the signed-in user may create, change and delete schedules,
/// from the endpoint catalog (OWNER, ADMIN); USER and SERVICE only read.

final class CanEditSchedulesProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the signed-in user may create, change and delete schedules,
  /// from the endpoint catalog (OWNER, ADMIN); USER and SERVICE only read.
  CanEditSchedulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canEditSchedulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canEditSchedulesHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canEditSchedules(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canEditSchedulesHash() => r'73c59c019a0e113b6f57088d161c908098e2f285';

/// The clock schedule times are shown and edited in (plan §13.4, D8): the
/// home zone from `/settings/system` when the role may read it, otherwise
/// the phone's zone as a label only. Converting edits needs the
/// `scheduleClockConversion` flag and the home zone.

@ProviderFor(scheduleClock)
final scheduleClockProvider = ScheduleClockProvider._();

/// The clock schedule times are shown and edited in (plan §13.4, D8): the
/// home zone from `/settings/system` when the role may read it, otherwise
/// the phone's zone as a label only. Converting edits needs the
/// `scheduleClockConversion` flag and the home zone.

final class ScheduleClockProvider
    extends $FunctionalProvider<ScheduleClock, ScheduleClock, ScheduleClock>
    with $Provider<ScheduleClock> {
  /// The clock schedule times are shown and edited in (plan §13.4, D8): the
  /// home zone from `/settings/system` when the role may read it, otherwise
  /// the phone's zone as a label only. Converting edits needs the
  /// `scheduleClockConversion` flag and the home zone.
  ScheduleClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleClockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleClockHash();

  @$internal
  @override
  $ProviderElement<ScheduleClock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScheduleClock create(Ref ref) {
    return scheduleClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleClock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleClock>(value),
    );
  }
}

String _$scheduleClockHash() => r'ce08ed054ddd3f5aaae0f6c498ba77ff534eecb5';

/// The heating schedules of device [deviceId], oldest first (the order GI
/// Core applies them in). Loaded when the schedule list opens; reloaded
/// on pull-to-refresh and after every change.

@ProviderFor(Schedules)
final schedulesProvider = SchedulesFamily._();

/// The heating schedules of device [deviceId], oldest first (the order GI
/// Core applies them in). Loaded when the schedule list opens; reloaded
/// on pull-to-refresh and after every change.
final class SchedulesProvider
    extends $AsyncNotifierProvider<Schedules, List<HeatingSchedule>> {
  /// The heating schedules of device [deviceId], oldest first (the order GI
  /// Core applies them in). Loaded when the schedule list opens; reloaded
  /// on pull-to-refresh and after every change.
  SchedulesProvider._({
    required SchedulesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'schedulesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$schedulesHash();

  @override
  String toString() {
    return r'schedulesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Schedules create() => Schedules();

  @override
  bool operator ==(Object other) {
    return other is SchedulesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$schedulesHash() => r'f24dde7347f1f04a1317cb79a9899bf313ae9337';

/// The heating schedules of device [deviceId], oldest first (the order GI
/// Core applies them in). Loaded when the schedule list opens; reloaded
/// on pull-to-refresh and after every change.

final class SchedulesFamily extends $Family
    with
        $ClassFamilyOverride<
          Schedules,
          AsyncValue<List<HeatingSchedule>>,
          List<HeatingSchedule>,
          FutureOr<List<HeatingSchedule>>,
          String
        > {
  SchedulesFamily._()
    : super(
        retry: null,
        name: r'schedulesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The heating schedules of device [deviceId], oldest first (the order GI
  /// Core applies them in). Loaded when the schedule list opens; reloaded
  /// on pull-to-refresh and after every change.

  SchedulesProvider call(String deviceId) =>
      SchedulesProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'schedulesProvider';
}

/// The heating schedules of device [deviceId], oldest first (the order GI
/// Core applies them in). Loaded when the schedule list opens; reloaded
/// on pull-to-refresh and after every change.

abstract class _$Schedules extends $AsyncNotifier<List<HeatingSchedule>> {
  late final _$args = ref.$arg as String;
  String get deviceId => _$args;

  FutureOr<List<HeatingSchedule>> build(String deviceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<HeatingSchedule>>, List<HeatingSchedule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<HeatingSchedule>>,
                List<HeatingSchedule>
              >,
              AsyncValue<List<HeatingSchedule>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Creates, changes and deletes the schedules of device [deviceId]. Each
/// save reloads the list and the device, whose effective strategy GI Core
/// reconciles right away. Nothing is retried automatically.

@ProviderFor(ScheduleMutation)
final scheduleMutationProvider = ScheduleMutationFamily._();

/// Creates, changes and deletes the schedules of device [deviceId]. Each
/// save reloads the list and the device, whose effective strategy GI Core
/// reconciles right away. Nothing is retried automatically.
final class ScheduleMutationProvider
    extends $NotifierProvider<ScheduleMutation, ScheduleMutationState> {
  /// Creates, changes and deletes the schedules of device [deviceId]. Each
  /// save reloads the list and the device, whose effective strategy GI Core
  /// reconciles right away. Nothing is retried automatically.
  ScheduleMutationProvider._({
    required ScheduleMutationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'scheduleMutationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scheduleMutationHash();

  @override
  String toString() {
    return r'scheduleMutationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ScheduleMutation create() => ScheduleMutation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleMutationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleMutationState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduleMutationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scheduleMutationHash() => r'a8697b81f4f4b7fdcd3dc3da348b8f8016ccd5be';

/// Creates, changes and deletes the schedules of device [deviceId]. Each
/// save reloads the list and the device, whose effective strategy GI Core
/// reconciles right away. Nothing is retried automatically.

final class ScheduleMutationFamily extends $Family
    with
        $ClassFamilyOverride<
          ScheduleMutation,
          ScheduleMutationState,
          ScheduleMutationState,
          ScheduleMutationState,
          String
        > {
  ScheduleMutationFamily._()
    : super(
        retry: null,
        name: r'scheduleMutationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Creates, changes and deletes the schedules of device [deviceId]. Each
  /// save reloads the list and the device, whose effective strategy GI Core
  /// reconciles right away. Nothing is retried automatically.

  ScheduleMutationProvider call(String deviceId) =>
      ScheduleMutationProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'scheduleMutationProvider';
}

/// Creates, changes and deletes the schedules of device [deviceId]. Each
/// save reloads the list and the device, whose effective strategy GI Core
/// reconciles right away. Nothing is retried automatically.

abstract class _$ScheduleMutation extends $Notifier<ScheduleMutationState> {
  late final _$args = ref.$arg as String;
  String get deviceId => _$args;

  ScheduleMutationState build(String deviceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ScheduleMutationState, ScheduleMutationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScheduleMutationState, ScheduleMutationState>,
              ScheduleMutationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
