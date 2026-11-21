// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rooms_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `GET /rooms`, loaded when a screen that shows rooms opens and on
/// pull-to-refresh; rooms rarely change, so they are not polled (plan §11).

@ProviderFor(RoomsNotifier)
final roomsProvider = RoomsNotifierProvider._();

/// `GET /rooms`, loaded when a screen that shows rooms opens and on
/// pull-to-refresh; rooms rarely change, so they are not polled (plan §11).
final class RoomsNotifierProvider
    extends $NotifierProvider<RoomsNotifier, PolledData<List<Room>>> {
  /// `GET /rooms`, loaded when a screen that shows rooms opens and on
  /// pull-to-refresh; rooms rarely change, so they are not polled (plan §11).
  RoomsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomsNotifierHash();

  @$internal
  @override
  RoomsNotifier create() => RoomsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PolledData<List<Room>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PolledData<List<Room>>>(value),
    );
  }
}

String _$roomsNotifierHash() => r'4da6c9376f1a087877929b81373d388d57d034a2';

/// `GET /rooms`, loaded when a screen that shows rooms opens and on
/// pull-to-refresh; rooms rarely change, so they are not polled (plan §11).

abstract class _$RoomsNotifier extends $Notifier<PolledData<List<Room>>> {
  PolledData<List<Room>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PolledData<List<Room>>, PolledData<List<Room>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PolledData<List<Room>>, PolledData<List<Room>>>,
              PolledData<List<Room>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
