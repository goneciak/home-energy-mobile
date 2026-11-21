// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_network_permission.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localNetworkPermission)
final localNetworkPermissionProvider = LocalNetworkPermissionProvider._();

final class LocalNetworkPermissionProvider
    extends
        $FunctionalProvider<
          LocalNetworkPermission,
          LocalNetworkPermission,
          LocalNetworkPermission
        >
    with $Provider<LocalNetworkPermission> {
  LocalNetworkPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localNetworkPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localNetworkPermissionHash();

  @$internal
  @override
  $ProviderElement<LocalNetworkPermission> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalNetworkPermission create(Ref ref) {
    return localNetworkPermission(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalNetworkPermission value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalNetworkPermission>(value),
    );
  }
}

String _$localNetworkPermissionHash() =>
    r'e47599169fb401bf097baf9f03c210b34c3be30a';
