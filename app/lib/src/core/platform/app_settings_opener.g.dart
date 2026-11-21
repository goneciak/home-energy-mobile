// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_opener.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appSettingsOpener)
final appSettingsOpenerProvider = AppSettingsOpenerProvider._();

final class AppSettingsOpenerProvider
    extends
        $FunctionalProvider<
          AppSettingsOpener,
          AppSettingsOpener,
          AppSettingsOpener
        >
    with $Provider<AppSettingsOpener> {
  AppSettingsOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsOpenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsOpenerHash();

  @$internal
  @override
  $ProviderElement<AppSettingsOpener> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppSettingsOpener create(Ref ref) {
    return appSettingsOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettingsOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettingsOpener>(value),
    );
  }
}

String _$appSettingsOpenerHash() => r'626751bbeebf790c72284e4906e52d2b11a48943';
