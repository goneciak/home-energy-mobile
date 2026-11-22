// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Environment endpoints of the saved appliance; only read once signed in,
/// i.e. when a client exists.

@ProviderFor(environmentSource)
final environmentSourceProvider = EnvironmentSourceProvider._();

/// Environment endpoints of the saved appliance; only read once signed in,
/// i.e. when a client exists.

final class EnvironmentSourceProvider
    extends
        $FunctionalProvider<
          EnvironmentSource,
          EnvironmentSource,
          EnvironmentSource
        >
    with $Provider<EnvironmentSource> {
  /// Environment endpoints of the saved appliance; only read once signed in,
  /// i.e. when a client exists.
  EnvironmentSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'environmentSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$environmentSourceHash();

  @$internal
  @override
  $ProviderElement<EnvironmentSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EnvironmentSource create(Ref ref) {
    return environmentSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnvironmentSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnvironmentSource>(value),
    );
  }
}

String _$environmentSourceHash() => r'baa89a6482a8e0b29a273a1be5c6f0cc3c86ac4e';

/// The zone weather hours and sun times are shown in: the home zone from
/// `/settings/system` when the role may read it, otherwise the phone's.

@ProviderFor(houseZone)
final houseZoneProvider = HouseZoneProvider._();

/// The zone weather hours and sun times are shown in: the home zone from
/// `/settings/system` when the role may read it, otherwise the phone's.

final class HouseZoneProvider
    extends $FunctionalProvider<ScheduleZone, ScheduleZone, ScheduleZone>
    with $Provider<ScheduleZone> {
  /// The zone weather hours and sun times are shown in: the home zone from
  /// `/settings/system` when the role may read it, otherwise the phone's.
  HouseZoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'houseZoneProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$houseZoneHash();

  @$internal
  @override
  $ProviderElement<ScheduleZone> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScheduleZone create(Ref ref) {
    return houseZone(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleZone value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleZone>(value),
    );
  }
}

String _$houseZoneHash() => r'531fdf83b897fc7fee6c802a2080500e99145156';

/// `GET /weather/current`, loaded when the weather screen opens and again
/// on pull-to-refresh.

@ProviderFor(weatherCurrent)
final weatherCurrentProvider = WeatherCurrentProvider._();

/// `GET /weather/current`, loaded when the weather screen opens and again
/// on pull-to-refresh.

final class WeatherCurrentProvider
    extends
        $FunctionalProvider<
          AsyncValue<EnvironmentResult<WeatherEnvelope<CurrentWeather>>>,
          EnvironmentResult<WeatherEnvelope<CurrentWeather>>,
          FutureOr<EnvironmentResult<WeatherEnvelope<CurrentWeather>>>
        >
    with
        $FutureModifier<EnvironmentResult<WeatherEnvelope<CurrentWeather>>>,
        $FutureProvider<EnvironmentResult<WeatherEnvelope<CurrentWeather>>> {
  /// `GET /weather/current`, loaded when the weather screen opens and again
  /// on pull-to-refresh.
  WeatherCurrentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherCurrentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherCurrentHash();

  @$internal
  @override
  $FutureProviderElement<EnvironmentResult<WeatherEnvelope<CurrentWeather>>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<EnvironmentResult<WeatherEnvelope<CurrentWeather>>> create(Ref ref) {
    return weatherCurrent(ref);
  }
}

String _$weatherCurrentHash() => r'e785fe0d705605702c26b5851761f63afbba075e';

/// `GET /weather/hourly` (at most 72 hours, UTC).

@ProviderFor(weatherHourly)
final weatherHourlyProvider = WeatherHourlyProvider._();

/// `GET /weather/hourly` (at most 72 hours, UTC).

final class WeatherHourlyProvider
    extends
        $FunctionalProvider<
          AsyncValue<EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>>,
          EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>,
          FutureOr<EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>>
        >
    with
        $FutureModifier<
          EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>
        >,
        $FutureProvider<
          EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>
        > {
  /// `GET /weather/hourly` (at most 72 hours, UTC).
  WeatherHourlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherHourlyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherHourlyHash();

  @$internal
  @override
  $FutureProviderElement<
    EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>> create(
    Ref ref,
  ) {
    return weatherHourly(ref);
  }
}

String _$weatherHourlyHash() => r'6724b12688daaacddb922ade1a5dd990fac84f73';

/// `GET /weather/daily` (UTC days).

@ProviderFor(weatherDaily)
final weatherDailyProvider = WeatherDailyProvider._();

/// `GET /weather/daily` (UTC days).

final class WeatherDailyProvider
    extends
        $FunctionalProvider<
          AsyncValue<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>>,
          EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>,
          FutureOr<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>>
        >
    with
        $FutureModifier<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>>,
        $FutureProvider<
          EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>
        > {
  /// `GET /weather/daily` (UTC days).
  WeatherDailyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherDailyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherDailyHash();

  @$internal
  @override
  $FutureProviderElement<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>> create(
    Ref ref,
  ) {
    return weatherDaily(ref);
  }
}

String _$weatherDailyHash() => r'0ee51e0135036b8224a973e5fe1c52f752e00123';

/// `GET /solar/current`.

@ProviderFor(solarStatus)
final solarStatusProvider = SolarStatusProvider._();

/// `GET /solar/current`.

final class SolarStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<EnvironmentResult<SolarStatus>>,
          EnvironmentResult<SolarStatus>,
          FutureOr<EnvironmentResult<SolarStatus>>
        >
    with
        $FutureModifier<EnvironmentResult<SolarStatus>>,
        $FutureProvider<EnvironmentResult<SolarStatus>> {
  /// `GET /solar/current`.
  SolarStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'solarStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$solarStatusHash();

  @$internal
  @override
  $FutureProviderElement<EnvironmentResult<SolarStatus>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EnvironmentResult<SolarStatus>> create(Ref ref) {
    return solarStatus(ref);
  }
}

String _$solarStatusHash() => r'e9d6ea4f8f500908ce088d19dba681f46ae116e6';

/// `GET /pv/forecast`.

@ProviderFor(pvForecast)
final pvForecastProvider = PvForecastProvider._();

/// `GET /pv/forecast`.

final class PvForecastProvider
    extends
        $FunctionalProvider<
          AsyncValue<EnvironmentResult<PvForecast>>,
          EnvironmentResult<PvForecast>,
          FutureOr<EnvironmentResult<PvForecast>>
        >
    with
        $FutureModifier<EnvironmentResult<PvForecast>>,
        $FutureProvider<EnvironmentResult<PvForecast>> {
  /// `GET /pv/forecast`.
  PvForecastProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pvForecastProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pvForecastHash();

  @$internal
  @override
  $FutureProviderElement<EnvironmentResult<PvForecast>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EnvironmentResult<PvForecast>> create(Ref ref) {
    return pvForecast(ref);
  }
}

String _$pvForecastHash() => r'b05b533d50180dd0ebf4f825e23036e8bb067040';

/// `GET /devices/:id/pv-heating-plan` of device [deviceId].

@ProviderFor(pvHeatingPlan)
final pvHeatingPlanProvider = PvHeatingPlanFamily._();

/// `GET /devices/:id/pv-heating-plan` of device [deviceId].

final class PvHeatingPlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<PvHeatingPlan>,
          PvHeatingPlan,
          FutureOr<PvHeatingPlan>
        >
    with $FutureModifier<PvHeatingPlan>, $FutureProvider<PvHeatingPlan> {
  /// `GET /devices/:id/pv-heating-plan` of device [deviceId].
  PvHeatingPlanProvider._({
    required PvHeatingPlanFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pvHeatingPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pvHeatingPlanHash();

  @override
  String toString() {
    return r'pvHeatingPlanProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PvHeatingPlan> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PvHeatingPlan> create(Ref ref) {
    final argument = this.argument as String;
    return pvHeatingPlan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PvHeatingPlanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pvHeatingPlanHash() => r'312c4ba0bb4d61090774d3caeb652ca8f6e5c2c1';

/// `GET /devices/:id/pv-heating-plan` of device [deviceId].

final class PvHeatingPlanFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PvHeatingPlan>, String> {
  PvHeatingPlanFamily._()
    : super(
        retry: null,
        name: r'pvHeatingPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// `GET /devices/:id/pv-heating-plan` of device [deviceId].

  PvHeatingPlanProvider call(String deviceId) =>
      PvHeatingPlanProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'pvHeatingPlanProvider';
}
