// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_language.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(requestLanguage)
final requestLanguageProvider = RequestLanguageProvider._();

final class RequestLanguageProvider
    extends
        $FunctionalProvider<RequestLanguage, RequestLanguage, RequestLanguage>
    with $Provider<RequestLanguage> {
  RequestLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestLanguageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestLanguageHash();

  @$internal
  @override
  $ProviderElement<RequestLanguage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RequestLanguage create(Ref ref) {
    return requestLanguage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestLanguage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestLanguage>(value),
    );
  }
}

String _$requestLanguageHash() => r'cb5115c68029dc55cc7ec1c38d72768a807bc1c3';
