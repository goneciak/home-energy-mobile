// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_user_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Zmień użytkownika" (plan §7.8): a logout (server logout; refresh
/// cookie, access token, per-session preferences and diagnostics wiped)
/// that also forgets who was signed in, so the login screen opens with an
/// EMPTY email field, and drops every cache of the previous user (profile,
/// devices, rooms, heating cards), so nothing role-gated reaches the next
/// one.
///
/// It lives apart from [AuthSessionNotifier] because those caches depend
/// on the session: they can be invalidated from here, not from there. Kept
/// alive: the settings screen that starts it is gone once it logs out.

@ProviderFor(SwitchUserController)
final switchUserControllerProvider = SwitchUserControllerProvider._();

/// "Zmień użytkownika" (plan §7.8): a logout (server logout; refresh
/// cookie, access token, per-session preferences and diagnostics wiped)
/// that also forgets who was signed in, so the login screen opens with an
/// EMPTY email field, and drops every cache of the previous user (profile,
/// devices, rooms, heating cards), so nothing role-gated reaches the next
/// one.
///
/// It lives apart from [AuthSessionNotifier] because those caches depend
/// on the session: they can be invalidated from here, not from there. Kept
/// alive: the settings screen that starts it is gone once it logs out.
final class SwitchUserControllerProvider
    extends $NotifierProvider<SwitchUserController, AsyncValue<void>> {
  /// "Zmień użytkownika" (plan §7.8): a logout (server logout; refresh
  /// cookie, access token, per-session preferences and diagnostics wiped)
  /// that also forgets who was signed in, so the login screen opens with an
  /// EMPTY email field, and drops every cache of the previous user (profile,
  /// devices, rooms, heating cards), so nothing role-gated reaches the next
  /// one.
  ///
  /// It lives apart from [AuthSessionNotifier] because those caches depend
  /// on the session: they can be invalidated from here, not from there. Kept
  /// alive: the settings screen that starts it is gone once it logs out.
  SwitchUserControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'switchUserControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$switchUserControllerHash();

  @$internal
  @override
  SwitchUserController create() => SwitchUserController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$switchUserControllerHash() =>
    r'407ce022db76b9e430a4429436ecb0570d2f103c';

/// "Zmień użytkownika" (plan §7.8): a logout (server logout; refresh
/// cookie, access token, per-session preferences and diagnostics wiped)
/// that also forgets who was signed in, so the login screen opens with an
/// EMPTY email field, and drops every cache of the previous user (profile,
/// devices, rooms, heating cards), so nothing role-gated reaches the next
/// one.
///
/// It lives apart from [AuthSessionNotifier] because those caches depend
/// on the session: they can be invalidated from here, not from there. Kept
/// alive: the settings screen that starts it is gone once it logs out.

abstract class _$SwitchUserController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
