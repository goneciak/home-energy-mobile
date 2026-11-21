// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stale_app_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether to show "Zaktualizuj aplikację" (plan §16 point 4): GI Core kept
/// sending responses this version cannot read (`StaleAppPolicy`). The user
/// may [dismiss] it for the rest of the app session.

@ProviderFor(StaleAppNotifier)
final staleAppProvider = StaleAppNotifierProvider._();

/// Whether to show "Zaktualizuj aplikację" (plan §16 point 4): GI Core kept
/// sending responses this version cannot read (`StaleAppPolicy`). The user
/// may [dismiss] it for the rest of the app session.
final class StaleAppNotifierProvider
    extends $NotifierProvider<StaleAppNotifier, bool> {
  /// Whether to show "Zaktualizuj aplikację" (plan §16 point 4): GI Core kept
  /// sending responses this version cannot read (`StaleAppPolicy`). The user
  /// may [dismiss] it for the rest of the app session.
  StaleAppNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'staleAppProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$staleAppNotifierHash();

  @$internal
  @override
  StaleAppNotifier create() => StaleAppNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$staleAppNotifierHash() => r'e1c28ad921bff54e57cfe60a81953682521df47e';

/// Whether to show "Zaktualizuj aplikację" (plan §16 point 4): GI Core kept
/// sending responses this version cannot read (`StaleAppPolicy`). The user
/// may [dismiss] it for the rest of the app session.

abstract class _$StaleAppNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
