// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Connect screen flow (plan §9.2): probe an address or pick a candidate
/// the connection ladder found, show the appliance for confirmation, and
/// only then save it. No credentials are sent here.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` probing, `AsyncData(probe)`
/// awaiting confirmation, `AsyncError` with a [FormatException] (bad
/// address) or an [ApiFailure].

@ProviderFor(ConnectController)
final connectControllerProvider = ConnectControllerProvider._();

/// Connect screen flow (plan §9.2): probe an address or pick a candidate
/// the connection ladder found, show the appliance for confirmation, and
/// only then save it. No credentials are sent here.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` probing, `AsyncData(probe)`
/// awaiting confirmation, `AsyncError` with a [FormatException] (bad
/// address) or an [ApiFailure].
final class ConnectControllerProvider
    extends $NotifierProvider<ConnectController, AsyncValue<ProbeResult?>> {
  /// Connect screen flow (plan §9.2): probe an address or pick a candidate
  /// the connection ladder found, show the appliance for confirmation, and
  /// only then save it. No credentials are sent here.
  ///
  /// State: `AsyncData(null)` idle, `AsyncLoading` probing, `AsyncData(probe)`
  /// awaiting confirmation, `AsyncError` with a [FormatException] (bad
  /// address) or an [ApiFailure].
  ConnectControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectControllerHash();

  @$internal
  @override
  ConnectController create() => ConnectController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ProbeResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ProbeResult?>>(value),
    );
  }
}

String _$connectControllerHash() => r'59cee3385cde3b0771879212e8bfaf4d076c3739';

/// Connect screen flow (plan §9.2): probe an address or pick a candidate
/// the connection ladder found, show the appliance for confirmation, and
/// only then save it. No credentials are sent here.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` probing, `AsyncData(probe)`
/// awaiting confirmation, `AsyncError` with a [FormatException] (bad
/// address) or an [ApiFailure].

abstract class _$ConnectController extends $Notifier<AsyncValue<ProbeResult?>> {
  AsyncValue<ProbeResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ProbeResult?>, AsyncValue<ProbeResult?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ProbeResult?>, AsyncValue<ProbeResult?>>,
              AsyncValue<ProbeResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
