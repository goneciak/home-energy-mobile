// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_recovery.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Started by the app root and kept alive for the session.

@ProviderFor(networkRecovery)
final networkRecoveryProvider = NetworkRecoveryProvider._();

/// Started by the app root and kept alive for the session.

final class NetworkRecoveryProvider
    extends
        $FunctionalProvider<NetworkRecovery, NetworkRecovery, NetworkRecovery>
    with $Provider<NetworkRecovery> {
  /// Started by the app root and kept alive for the session.
  NetworkRecoveryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkRecoveryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkRecoveryHash();

  @$internal
  @override
  $ProviderElement<NetworkRecovery> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NetworkRecovery create(Ref ref) {
    return networkRecovery(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkRecovery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkRecovery>(value),
    );
  }
}

String _$networkRecoveryHash() => r'9c414185e82fed7d7031907f079f5e072febd0f4';
