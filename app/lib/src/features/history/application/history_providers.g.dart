// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Entity history of the saved appliance; only read once signed in.

@ProviderFor(historySource)
final historySourceProvider = HistorySourceProvider._();

/// Entity history of the saved appliance; only read once signed in.

final class HistorySourceProvider
    extends $FunctionalProvider<HistorySource, HistorySource, HistorySource>
    with $Provider<HistorySource> {
  /// Entity history of the saved appliance; only read once signed in.
  HistorySourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historySourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historySourceHash();

  @$internal
  @override
  $ProviderElement<HistorySource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HistorySource create(Ref ref) {
    return historySource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistorySource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistorySource>(value),
    );
  }
}

String _$historySourceHash() => r'2fb399f4d026b4a5b7928adf0cc0dd067b2ce12a';

/// Where the chart line is downsampled; tests replace the isolate.

@ProviderFor(historyDownsampler)
final historyDownsamplerProvider = HistoryDownsamplerProvider._();

/// Where the chart line is downsampled; tests replace the isolate.

final class HistoryDownsamplerProvider
    extends
        $FunctionalProvider<
          HistoryDownsampler,
          HistoryDownsampler,
          HistoryDownsampler
        >
    with $Provider<HistoryDownsampler> {
  /// Where the chart line is downsampled; tests replace the isolate.
  HistoryDownsamplerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyDownsamplerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyDownsamplerHash();

  @$internal
  @override
  $ProviderElement<HistoryDownsampler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HistoryDownsampler create(Ref ref) {
    return historyDownsampler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryDownsampler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryDownsampler>(value),
    );
  }
}

String _$historyDownsamplerHash() =>
    r'919a6f521455d65f882df774c3fea3373df45a59';

/// Samples of entity [entityId] of device [deviceId] over the [window]
/// ending now; read again on pull-to-refresh.

@ProviderFor(entityHistory)
final entityHistoryProvider = EntityHistoryFamily._();

/// Samples of entity [entityId] of device [deviceId] over the [window]
/// ending now; read again on pull-to-refresh.

final class EntityHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<HistoryData>,
          HistoryData,
          FutureOr<HistoryData>
        >
    with $FutureModifier<HistoryData>, $FutureProvider<HistoryData> {
  /// Samples of entity [entityId] of device [deviceId] over the [window]
  /// ending now; read again on pull-to-refresh.
  EntityHistoryProvider._({
    required EntityHistoryFamily super.from,
    required (String, String, HistoryWindow) super.argument,
  }) : super(
         retry: null,
         name: r'entityHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$entityHistoryHash();

  @override
  String toString() {
    return r'entityHistoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HistoryData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HistoryData> create(Ref ref) {
    final argument = this.argument as (String, String, HistoryWindow);
    return entityHistory(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is EntityHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entityHistoryHash() => r'3ddd9beb9ebedab5abc255699427748efc98be12';

/// Samples of entity [entityId] of device [deviceId] over the [window]
/// ending now; read again on pull-to-refresh.

final class EntityHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HistoryData>,
          (String, String, HistoryWindow)
        > {
  EntityHistoryFamily._()
    : super(
        retry: null,
        name: r'entityHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Samples of entity [entityId] of device [deviceId] over the [window]
  /// ending now; read again on pull-to-refresh.

  EntityHistoryProvider call(
    String deviceId,
    String entityId,
    HistoryWindow window,
  ) => EntityHistoryProvider._(
    argument: (deviceId, entityId, window),
    from: this,
  );

  @override
  String toString() => r'entityHistoryProvider';
}

/// The chart line of [entityHistoryProvider], with at most [threshold]
/// change points (about one per logical pixel of the chart width, so at
/// most two points per pixel once expanded into steps).

@ProviderFor(historyChart)
final historyChartProvider = HistoryChartFamily._();

/// The chart line of [entityHistoryProvider], with at most [threshold]
/// change points (about one per logical pixel of the chart width, so at
/// most two points per pixel once expanded into steps).

final class HistoryChartProvider
    extends
        $FunctionalProvider<
          AsyncValue<HistoryChartSeries>,
          HistoryChartSeries,
          FutureOr<HistoryChartSeries>
        >
    with
        $FutureModifier<HistoryChartSeries>,
        $FutureProvider<HistoryChartSeries> {
  /// The chart line of [entityHistoryProvider], with at most [threshold]
  /// change points (about one per logical pixel of the chart width, so at
  /// most two points per pixel once expanded into steps).
  HistoryChartProvider._({
    required HistoryChartFamily super.from,
    required (String, String, HistoryWindow, int) super.argument,
  }) : super(
         retry: null,
         name: r'historyChartProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyChartHash();

  @override
  String toString() {
    return r'historyChartProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HistoryChartSeries> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HistoryChartSeries> create(Ref ref) {
    final argument = this.argument as (String, String, HistoryWindow, int);
    return historyChart(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
      argument.$4,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryChartProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyChartHash() => r'fe6b9bdc6576611282ec9942d970489e61279a26';

/// The chart line of [entityHistoryProvider], with at most [threshold]
/// change points (about one per logical pixel of the chart width, so at
/// most two points per pixel once expanded into steps).

final class HistoryChartFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HistoryChartSeries>,
          (String, String, HistoryWindow, int)
        > {
  HistoryChartFamily._()
    : super(
        retry: null,
        name: r'historyChartProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The chart line of [entityHistoryProvider], with at most [threshold]
  /// change points (about one per logical pixel of the chart width, so at
  /// most two points per pixel once expanded into steps).

  HistoryChartProvider call(
    String deviceId,
    String entityId,
    HistoryWindow window,
    int threshold,
  ) => HistoryChartProvider._(
    argument: (deviceId, entityId, window, threshold),
    from: this,
  );

  @override
  String toString() => r'historyChartProvider';
}

/// Entity [entityId] of device [deviceId] as the device details last read
/// it (name, unit, domain), or `null` while unknown.

@ProviderFor(historyEntity)
final historyEntityProvider = HistoryEntityFamily._();

/// Entity [entityId] of device [deviceId] as the device details last read
/// it (name, unit, domain), or `null` while unknown.

final class HistoryEntityProvider
    extends $FunctionalProvider<DeviceEntity?, DeviceEntity?, DeviceEntity?>
    with $Provider<DeviceEntity?> {
  /// Entity [entityId] of device [deviceId] as the device details last read
  /// it (name, unit, domain), or `null` while unknown.
  HistoryEntityProvider._({
    required HistoryEntityFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'historyEntityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyEntityHash();

  @override
  String toString() {
    return r'historyEntityProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<DeviceEntity?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceEntity? create(Ref ref) {
    final argument = this.argument as (String, String);
    return historyEntity(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceEntity?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryEntityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyEntityHash() => r'16c02e3073c38d576a00ff6dac66974112e7f715';

/// Entity [entityId] of device [deviceId] as the device details last read
/// it (name, unit, domain), or `null` while unknown.

final class HistoryEntityFamily extends $Family
    with $FunctionalFamilyOverride<DeviceEntity?, (String, String)> {
  HistoryEntityFamily._()
    : super(
        retry: null,
        name: r'historyEntityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Entity [entityId] of device [deviceId] as the device details last read
  /// it (name, unit, domain), or `null` while unknown.

  HistoryEntityProvider call(String deviceId, String entityId) =>
      HistoryEntityProvider._(argument: (deviceId, entityId), from: this);

  @override
  String toString() => r'historyEntityProvider';
}
