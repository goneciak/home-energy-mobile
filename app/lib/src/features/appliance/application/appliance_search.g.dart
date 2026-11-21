// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appliance_search.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Znajdź GI Home" on the connect screen (plan §9.2): one run of the
/// [ConnectionLadder] from the moment the screen opens, starting with the
/// saved profile's hosts. Invalidate it to search again.
///
/// With `FeatureFlags.androidLocalNetworkPermissionRequest` on, Android's
/// local network permission is asked for first (plan §9.4); a denial ends
/// the search with [LocalNetworkDeniedFailure].

@ProviderFor(applianceSearch)
final applianceSearchProvider = ApplianceSearchProvider._();

/// "Znajdź GI Home" on the connect screen (plan §9.2): one run of the
/// [ConnectionLadder] from the moment the screen opens, starting with the
/// saved profile's hosts. Invalidate it to search again.
///
/// With `FeatureFlags.androidLocalNetworkPermissionRequest` on, Android's
/// local network permission is asked for first (plan §9.4); a denial ends
/// the search with [LocalNetworkDeniedFailure].

final class ApplianceSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<ApplianceSearch>,
          ApplianceSearch,
          Stream<ApplianceSearch>
        >
    with $FutureModifier<ApplianceSearch>, $StreamProvider<ApplianceSearch> {
  /// "Znajdź GI Home" on the connect screen (plan §9.2): one run of the
  /// [ConnectionLadder] from the moment the screen opens, starting with the
  /// saved profile's hosts. Invalidate it to search again.
  ///
  /// With `FeatureFlags.androidLocalNetworkPermissionRequest` on, Android's
  /// local network permission is asked for first (plan §9.4); a denial ends
  /// the search with [LocalNetworkDeniedFailure].
  ApplianceSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applianceSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applianceSearchHash();

  @$internal
  @override
  $StreamProviderElement<ApplianceSearch> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ApplianceSearch> create(Ref ref) {
    return applianceSearch(ref);
  }
}

String _$applianceSearchHash() => r'a1d23475a8716aafa355f9c343f69ab815284db9';
