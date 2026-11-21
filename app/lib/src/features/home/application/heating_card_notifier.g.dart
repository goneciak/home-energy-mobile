// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heating_card_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared by every heating card, so Home never has more than
/// [heatingCardMaxConcurrency] `GET /devices/:id` requests in flight.

@ProviderFor(heatingCardLimiter)
final heatingCardLimiterProvider = HeatingCardLimiterProvider._();

/// Shared by every heating card, so Home never has more than
/// [heatingCardMaxConcurrency] `GET /devices/:id` requests in flight.

final class HeatingCardLimiterProvider
    extends
        $FunctionalProvider<
          ConcurrencyLimiter,
          ConcurrencyLimiter,
          ConcurrencyLimiter
        >
    with $Provider<ConcurrencyLimiter> {
  /// Shared by every heating card, so Home never has more than
  /// [heatingCardMaxConcurrency] `GET /devices/:id` requests in flight.
  HeatingCardLimiterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heatingCardLimiterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heatingCardLimiterHash();

  @$internal
  @override
  $ProviderElement<ConcurrencyLimiter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConcurrencyLimiter create(Ref ref) {
    return heatingCardLimiter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConcurrencyLimiter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConcurrencyLimiter>(value),
    );
  }
}

String _$heatingCardLimiterHash() =>
    r'183a28e030d20259affa315e98171fad8447c09a';

/// `GET /devices/:id` of one heating device shown as a card on Home, polled
/// every 15 s while the card is on screen and the app is in the foreground
/// (plan §4.1, §11). Only the card widget watches it, and Home builds its
/// rows lazily, so a card scrolled out of view (or never scrolled to) sends
/// no requests. Only heating devices recognised from the list get a card,
/// so Home never asks for details of other devices.
///
/// Every state is also published to [heatingCardResultsProvider], which the
/// Home condition reads without keeping the card alive.
///
/// A failure keeps the last good details next to the error (the Home
/// condition then reports limited data, plan §11.1) and backs off like
/// every poller; a tick is skipped while a request, or its wait for a free
/// slot, is still running. A card that comes back into view with details
/// younger than the polling interval waits for the next tick instead of
/// asking again, so scrolling back and forth does not add requests.

@ProviderFor(HeatingCardNotifier)
final heatingCardProvider = HeatingCardNotifierFamily._();

/// `GET /devices/:id` of one heating device shown as a card on Home, polled
/// every 15 s while the card is on screen and the app is in the foreground
/// (plan §4.1, §11). Only the card widget watches it, and Home builds its
/// rows lazily, so a card scrolled out of view (or never scrolled to) sends
/// no requests. Only heating devices recognised from the list get a card,
/// so Home never asks for details of other devices.
///
/// Every state is also published to [heatingCardResultsProvider], which the
/// Home condition reads without keeping the card alive.
///
/// A failure keeps the last good details next to the error (the Home
/// condition then reports limited data, plan §11.1) and backs off like
/// every poller; a tick is skipped while a request, or its wait for a free
/// slot, is still running. A card that comes back into view with details
/// younger than the polling interval waits for the next tick instead of
/// asking again, so scrolling back and forth does not add requests.
final class HeatingCardNotifierProvider
    extends $NotifierProvider<HeatingCardNotifier, PolledData<DeviceDetail>> {
  /// `GET /devices/:id` of one heating device shown as a card on Home, polled
  /// every 15 s while the card is on screen and the app is in the foreground
  /// (plan §4.1, §11). Only the card widget watches it, and Home builds its
  /// rows lazily, so a card scrolled out of view (or never scrolled to) sends
  /// no requests. Only heating devices recognised from the list get a card,
  /// so Home never asks for details of other devices.
  ///
  /// Every state is also published to [heatingCardResultsProvider], which the
  /// Home condition reads without keeping the card alive.
  ///
  /// A failure keeps the last good details next to the error (the Home
  /// condition then reports limited data, plan §11.1) and backs off like
  /// every poller; a tick is skipped while a request, or its wait for a free
  /// slot, is still running. A card that comes back into view with details
  /// younger than the polling interval waits for the next tick instead of
  /// asking again, so scrolling back and forth does not add requests.
  HeatingCardNotifierProvider._({
    required HeatingCardNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'heatingCardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$heatingCardNotifierHash();

  @override
  String toString() {
    return r'heatingCardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HeatingCardNotifier create() => HeatingCardNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PolledData<DeviceDetail> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PolledData<DeviceDetail>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HeatingCardNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$heatingCardNotifierHash() =>
    r'8718afc8b90fdb9a7ce0e7cec64abe971b0d279c';

/// `GET /devices/:id` of one heating device shown as a card on Home, polled
/// every 15 s while the card is on screen and the app is in the foreground
/// (plan §4.1, §11). Only the card widget watches it, and Home builds its
/// rows lazily, so a card scrolled out of view (or never scrolled to) sends
/// no requests. Only heating devices recognised from the list get a card,
/// so Home never asks for details of other devices.
///
/// Every state is also published to [heatingCardResultsProvider], which the
/// Home condition reads without keeping the card alive.
///
/// A failure keeps the last good details next to the error (the Home
/// condition then reports limited data, plan §11.1) and backs off like
/// every poller; a tick is skipped while a request, or its wait for a free
/// slot, is still running. A card that comes back into view with details
/// younger than the polling interval waits for the next tick instead of
/// asking again, so scrolling back and forth does not add requests.

final class HeatingCardNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          HeatingCardNotifier,
          PolledData<DeviceDetail>,
          PolledData<DeviceDetail>,
          PolledData<DeviceDetail>,
          String
        > {
  HeatingCardNotifierFamily._()
    : super(
        retry: null,
        name: r'heatingCardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// `GET /devices/:id` of one heating device shown as a card on Home, polled
  /// every 15 s while the card is on screen and the app is in the foreground
  /// (plan §4.1, §11). Only the card widget watches it, and Home builds its
  /// rows lazily, so a card scrolled out of view (or never scrolled to) sends
  /// no requests. Only heating devices recognised from the list get a card,
  /// so Home never asks for details of other devices.
  ///
  /// Every state is also published to [heatingCardResultsProvider], which the
  /// Home condition reads without keeping the card alive.
  ///
  /// A failure keeps the last good details next to the error (the Home
  /// condition then reports limited data, plan §11.1) and backs off like
  /// every poller; a tick is skipped while a request, or its wait for a free
  /// slot, is still running. A card that comes back into view with details
  /// younger than the polling interval waits for the next tick instead of
  /// asking again, so scrolling back and forth does not add requests.

  HeatingCardNotifierProvider call(String deviceId) =>
      HeatingCardNotifierProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'heatingCardProvider';
}

/// `GET /devices/:id` of one heating device shown as a card on Home, polled
/// every 15 s while the card is on screen and the app is in the foreground
/// (plan §4.1, §11). Only the card widget watches it, and Home builds its
/// rows lazily, so a card scrolled out of view (or never scrolled to) sends
/// no requests. Only heating devices recognised from the list get a card,
/// so Home never asks for details of other devices.
///
/// Every state is also published to [heatingCardResultsProvider], which the
/// Home condition reads without keeping the card alive.
///
/// A failure keeps the last good details next to the error (the Home
/// condition then reports limited data, plan §11.1) and backs off like
/// every poller; a tick is skipped while a request, or its wait for a free
/// slot, is still running. A card that comes back into view with details
/// younger than the polling interval waits for the next tick instead of
/// asking again, so scrolling back and forth does not add requests.

abstract class _$HeatingCardNotifier
    extends $Notifier<PolledData<DeviceDetail>> {
  late final _$args = ref.$arg as String;
  String get deviceId => _$args;

  PolledData<DeviceDetail> build(String deviceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PolledData<DeviceDetail>, PolledData<DeviceDetail>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PolledData<DeviceDetail>, PolledData<DeviceDetail>>,
              PolledData<DeviceDetail>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The latest state of every heating card built in this session, by device
/// id. Home's condition is computed from it (plan §11.1) instead of from
/// the cards themselves, so it never keeps an off-screen card polling; a
/// card out of view keeps counting with its last result. Forgotten with a
/// new appliance or user (plan §8.3).

@ProviderFor(HeatingCardResults)
final heatingCardResultsProvider = HeatingCardResultsProvider._();

/// The latest state of every heating card built in this session, by device
/// id. Home's condition is computed from it (plan §11.1) instead of from
/// the cards themselves, so it never keeps an off-screen card polling; a
/// card out of view keeps counting with its last result. Forgotten with a
/// new appliance or user (plan §8.3).
final class HeatingCardResultsProvider
    extends
        $NotifierProvider<
          HeatingCardResults,
          Map<String, PolledData<DeviceDetail>>
        > {
  /// The latest state of every heating card built in this session, by device
  /// id. Home's condition is computed from it (plan §11.1) instead of from
  /// the cards themselves, so it never keeps an off-screen card polling; a
  /// card out of view keeps counting with its last result. Forgotten with a
  /// new appliance or user (plan §8.3).
  HeatingCardResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heatingCardResultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heatingCardResultsHash();

  @$internal
  @override
  HeatingCardResults create() => HeatingCardResults();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, PolledData<DeviceDetail>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String, PolledData<DeviceDetail>>>(value),
    );
  }
}

String _$heatingCardResultsHash() =>
    r'9e5084b55b3fe5171a65f70b7f119fee4c046acc';

/// The latest state of every heating card built in this session, by device
/// id. Home's condition is computed from it (plan §11.1) instead of from
/// the cards themselves, so it never keeps an off-screen card polling; a
/// card out of view keeps counting with its last result. Forgotten with a
/// new appliance or user (plan §8.3).

abstract class _$HeatingCardResults
    extends $Notifier<Map<String, PolledData<DeviceDetail>>> {
  Map<String, PolledData<DeviceDetail>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, PolledData<DeviceDetail>>,
              Map<String, PolledData<DeviceDetail>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, PolledData<DeviceDetail>>,
                Map<String, PolledData<DeviceDetail>>
              >,
              Map<String, PolledData<DeviceDetail>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
