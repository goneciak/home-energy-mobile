// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appliance_rebinder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kept alive: the session restore and the network recovery share it.

@ProviderFor(applianceRebinder)
final applianceRebinderProvider = ApplianceRebinderProvider._();

/// Kept alive: the session restore and the network recovery share it.

final class ApplianceRebinderProvider
    extends
        $FunctionalProvider<
          ApplianceRebinder,
          ApplianceRebinder,
          ApplianceRebinder
        >
    with $Provider<ApplianceRebinder> {
  /// Kept alive: the session restore and the network recovery share it.
  ApplianceRebinderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applianceRebinderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applianceRebinderHash();

  @$internal
  @override
  $ProviderElement<ApplianceRebinder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApplianceRebinder create(Ref ref) {
    return applianceRebinder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApplianceRebinder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApplianceRebinder>(value),
    );
  }
}

String _$applianceRebinderHash() => r'dc599773b344a0d123b48db95561f6f2833c0466';
