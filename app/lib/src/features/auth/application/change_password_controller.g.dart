// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Forced password change (plan §4.1). The server ends every other session
/// of the user and keeps this one.

@ProviderFor(ChangePasswordController)
final changePasswordControllerProvider = ChangePasswordControllerProvider._();

/// Forced password change (plan §4.1). The server ends every other session
/// of the user and keeps this one.
final class ChangePasswordControllerProvider
    extends
        $NotifierProvider<
          ChangePasswordController,
          AsyncValue<ChangePasswordResult?>
        > {
  /// Forced password change (plan §4.1). The server ends every other session
  /// of the user and keeps this one.
  ChangePasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordControllerHash();

  @$internal
  @override
  ChangePasswordController create() => ChangePasswordController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ChangePasswordResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ChangePasswordResult?>>(
        value,
      ),
    );
  }
}

String _$changePasswordControllerHash() =>
    r'45d2f91bbc3f99e7bfa51d55a74090182f478afd';

/// Forced password change (plan §4.1). The server ends every other session
/// of the user and keeps this one.

abstract class _$ChangePasswordController
    extends $Notifier<AsyncValue<ChangePasswordResult?>> {
  AsyncValue<ChangePasswordResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ChangePasswordResult?>,
              AsyncValue<ChangePasswordResult?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ChangePasswordResult?>,
                AsyncValue<ChangePasswordResult?>
              >,
              AsyncValue<ChangePasswordResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
