// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_change_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(networkChangeSource)
final networkChangeSourceProvider = NetworkChangeSourceProvider._();

final class NetworkChangeSourceProvider
    extends
        $FunctionalProvider<
          NetworkChangeSource,
          NetworkChangeSource,
          NetworkChangeSource
        >
    with $Provider<NetworkChangeSource> {
  NetworkChangeSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkChangeSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkChangeSourceHash();

  @$internal
  @override
  $ProviderElement<NetworkChangeSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NetworkChangeSource create(Ref ref) {
    return networkChangeSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkChangeSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkChangeSource>(value),
    );
  }
}

String _$networkChangeSourceHash() =>
    r'282dc4d0fae452611a3113847d407cf8f4d35b39';
