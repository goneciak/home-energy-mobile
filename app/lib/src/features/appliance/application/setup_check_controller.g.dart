// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_check_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Check again" on the setup-required screen: asks the saved appliance
/// whether it has been set up and, if so, stores its fingerprint.
///
/// State holds the last answer: `true` set up, `false` still not set up,
/// `null` not checked yet.

@ProviderFor(SetupCheckController)
final setupCheckControllerProvider = SetupCheckControllerProvider._();

/// "Check again" on the setup-required screen: asks the saved appliance
/// whether it has been set up and, if so, stores its fingerprint.
///
/// State holds the last answer: `true` set up, `false` still not set up,
/// `null` not checked yet.
final class SetupCheckControllerProvider
    extends $NotifierProvider<SetupCheckController, AsyncValue<bool?>> {
  /// "Check again" on the setup-required screen: asks the saved appliance
  /// whether it has been set up and, if so, stores its fingerprint.
  ///
  /// State holds the last answer: `true` set up, `false` still not set up,
  /// `null` not checked yet.
  SetupCheckControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setupCheckControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setupCheckControllerHash();

  @$internal
  @override
  SetupCheckController create() => SetupCheckController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<bool?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<bool?>>(value),
    );
  }
}

String _$setupCheckControllerHash() =>
    r'229e6501dec77be21363887b1de5fe2791e03747';

/// "Check again" on the setup-required screen: asks the saved appliance
/// whether it has been set up and, if so, stores its fingerprint.
///
/// State holds the last answer: `true` set up, `false` still not set up,
/// `null` not checked yet.

abstract class _$SetupCheckController extends $Notifier<AsyncValue<bool?>> {
  AsyncValue<bool?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool?>, AsyncValue<bool?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool?>, AsyncValue<bool?>>,
              AsyncValue<bool?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
