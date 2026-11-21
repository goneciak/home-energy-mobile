// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_report_sharer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(diagnosticReportSharer)
final diagnosticReportSharerProvider = DiagnosticReportSharerProvider._();

final class DiagnosticReportSharerProvider
    extends
        $FunctionalProvider<
          DiagnosticReportSharer,
          DiagnosticReportSharer,
          DiagnosticReportSharer
        >
    with $Provider<DiagnosticReportSharer> {
  DiagnosticReportSharerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diagnosticReportSharerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diagnosticReportSharerHash();

  @$internal
  @override
  $ProviderElement<DiagnosticReportSharer> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiagnosticReportSharer create(Ref ref) {
    return diagnosticReportSharer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiagnosticReportSharer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiagnosticReportSharer>(value),
    );
  }
}

String _$diagnosticReportSharerHash() =>
    r'93ae2e59f8ec420c9a2f44d4fdd466cae8aaffc0';
