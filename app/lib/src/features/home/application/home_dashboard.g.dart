// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dashboard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeDashboard)
final homeDashboardProvider = HomeDashboardProvider._();

final class HomeDashboardProvider
    extends $FunctionalProvider<HomeDashboard, HomeDashboard, HomeDashboard>
    with $Provider<HomeDashboard> {
  HomeDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeDashboardHash();

  @$internal
  @override
  $ProviderElement<HomeDashboard> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeDashboard create(Ref ref) {
    return homeDashboard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeDashboard value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeDashboard>(value),
    );
  }
}

String _$homeDashboardHash() => r'5ad81dd02adf42f9b1c1be2ca1800d3c807d4498';
