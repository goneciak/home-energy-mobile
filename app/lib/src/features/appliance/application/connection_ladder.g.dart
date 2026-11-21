// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_ladder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves the `.local` names of step 2. The dev flavor's mock Core
/// answers on any host, so there only `gi-home.local` "resolves", which
/// shows the found appliance without a network.

@ProviderFor(hostResolver)
final hostResolverProvider = HostResolverProvider._();

/// Resolves the `.local` names of step 2. The dev flavor's mock Core
/// answers on any host, so there only `gi-home.local` "resolves", which
/// shows the found appliance without a network.

final class HostResolverProvider
    extends $FunctionalProvider<HostResolver, HostResolver, HostResolver>
    with $Provider<HostResolver> {
  /// Resolves the `.local` names of step 2. The dev flavor's mock Core
  /// answers on any host, so there only `gi-home.local` "resolves", which
  /// shows the found appliance without a network.
  HostResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostResolverHash();

  @$internal
  @override
  $ProviderElement<HostResolver> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HostResolver create(Ref ref) {
    return hostResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostResolver>(value),
    );
  }
}

String _$hostResolverHash() => r'45fac2ada53737c8294e0f53f543f582079ff503';

/// Kept alive: the session restore uses it to rebind (plan §9.3).

@ProviderFor(connectionLadder)
final connectionLadderProvider = ConnectionLadderProvider._();

/// Kept alive: the session restore uses it to rebind (plan §9.3).

final class ConnectionLadderProvider
    extends
        $FunctionalProvider<
          ConnectionLadder,
          ConnectionLadder,
          ConnectionLadder
        >
    with $Provider<ConnectionLadder> {
  /// Kept alive: the session restore uses it to rebind (plan §9.3).
  ConnectionLadderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionLadderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionLadderHash();

  @$internal
  @override
  $ProviderElement<ConnectionLadder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConnectionLadder create(Ref ref) {
    return connectionLadder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionLadder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionLadder>(value),
    );
  }
}

String _$connectionLadderHash() => r'bba341c9b65e2cbecc5e5c2c49949bf725c2f37a';
