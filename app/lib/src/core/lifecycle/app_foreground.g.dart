// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_foreground.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appForeground)
final appForegroundProvider = AppForegroundProvider._();

final class AppForegroundProvider
    extends $FunctionalProvider<AppForeground, AppForeground, AppForeground>
    with $Provider<AppForeground> {
  AppForegroundProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appForegroundProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appForegroundHash();

  @$internal
  @override
  $ProviderElement<AppForeground> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppForeground create(Ref ref) {
    return appForeground(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppForeground value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppForeground>(value),
    );
  }
}

String _$appForegroundHash() => r'f099ef20698c691ea12fed970f6e76e7500480b6';
