// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Inputs of the redirect, derived from the profile and the session.

@ProviderFor(routeGuardState)
final routeGuardStateProvider = RouteGuardStateProvider._();

/// Inputs of the redirect, derived from the profile and the session.

final class RouteGuardStateProvider
    extends
        $FunctionalProvider<RouteGuardState, RouteGuardState, RouteGuardState>
    with $Provider<RouteGuardState> {
  /// Inputs of the redirect, derived from the profile and the session.
  RouteGuardStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeGuardStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeGuardStateHash();

  @$internal
  @override
  $ProviderElement<RouteGuardState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RouteGuardState create(Ref ref) {
    return routeGuardState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteGuardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteGuardState>(value),
    );
  }
}

String _$routeGuardStateHash() => r'1d0d989c5bfb5de5ff004fefa3e05da4cffe67db';

/// The app router. It is created once; guard changes re-run the redirect
/// through the router's `refreshListenable` instead of rebuilding it.

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// The app router. It is created once; guard changes re-run the redirect
/// through the router's `refreshListenable` instead of rebuilding it.

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app router. It is created once; guard changes re-run the redirect
  /// through the router's `refreshListenable` instead of rebuilding it.
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'5473e509c4f140f3f089562f500019a7a7c85d08';
