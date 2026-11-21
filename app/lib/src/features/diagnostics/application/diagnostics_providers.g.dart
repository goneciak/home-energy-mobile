// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's diagnostics. `main` overrides it with the instance its error
/// handlers write to; the default keeps everything in memory (tests).

@ProviderFor(diagnosticsService)
final diagnosticsServiceProvider = DiagnosticsServiceProvider._();

/// The app's diagnostics. `main` overrides it with the instance its error
/// handlers write to; the default keeps everything in memory (tests).

final class DiagnosticsServiceProvider
    extends
        $FunctionalProvider<
          DiagnosticsService,
          DiagnosticsService,
          DiagnosticsService
        >
    with $Provider<DiagnosticsService> {
  /// The app's diagnostics. `main` overrides it with the instance its error
  /// handlers write to; the default keeps everything in memory (tests).
  DiagnosticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diagnosticsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diagnosticsServiceHash();

  @$internal
  @override
  $ProviderElement<DiagnosticsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiagnosticsService create(Ref ref) {
    return diagnosticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiagnosticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiagnosticsService>(value),
    );
  }
}

String _$diagnosticsServiceHash() =>
    r'1442c1d23d0248325ad1a9a3b95f228bf093712b';

/// Started on the first line of `main`; `null` when cold start is not
/// measured (tests).

@ProviderFor(coldStartStopwatch)
final coldStartStopwatchProvider = ColdStartStopwatchProvider._();

/// Started on the first line of `main`; `null` when cold start is not
/// measured (tests).

final class ColdStartStopwatchProvider
    extends $FunctionalProvider<Stopwatch?, Stopwatch?, Stopwatch?>
    with $Provider<Stopwatch?> {
  /// Started on the first line of `main`; `null` when cold start is not
  /// measured (tests).
  ColdStartStopwatchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coldStartStopwatchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coldStartStopwatchHash();

  @$internal
  @override
  $ProviderElement<Stopwatch?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Stopwatch? create(Ref ref) {
    return coldStartStopwatch(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Stopwatch? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Stopwatch?>(value),
    );
  }
}

String _$coldStartStopwatchHash() =>
    r'27eddef417f941bcc7ac3d679d352563d3346cb0';

/// Measures this start up to the Home condition (plan §1.1 G1).

@ProviderFor(coldStartMeter)
final coldStartMeterProvider = ColdStartMeterProvider._();

/// Measures this start up to the Home condition (plan §1.1 G1).

final class ColdStartMeterProvider
    extends $FunctionalProvider<ColdStartMeter, ColdStartMeter, ColdStartMeter>
    with $Provider<ColdStartMeter> {
  /// Measures this start up to the Home condition (plan §1.1 G1).
  ColdStartMeterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coldStartMeterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coldStartMeterHash();

  @$internal
  @override
  $ProviderElement<ColdStartMeter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ColdStartMeter create(Ref ref) {
    return coldStartMeter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ColdStartMeter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ColdStartMeter>(value),
    );
  }
}

String _$coldStartMeterHash() => r'fa3cc0daf87bc6bf7ffb5ea54fab55c1b3f321fb';

/// Build, device and appliance facts for the diagnostic report.

@ProviderFor(reportEnvironment)
final reportEnvironmentProvider = ReportEnvironmentProvider._();

/// Build, device and appliance facts for the diagnostic report.

final class ReportEnvironmentProvider
    extends
        $FunctionalProvider<
          ReportEnvironment,
          ReportEnvironment,
          ReportEnvironment
        >
    with $Provider<ReportEnvironment> {
  /// Build, device and appliance facts for the diagnostic report.
  ReportEnvironmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportEnvironmentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportEnvironmentHash();

  @$internal
  @override
  $ProviderElement<ReportEnvironment> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReportEnvironment create(Ref ref) {
    return reportEnvironment(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportEnvironment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportEnvironment>(value),
    );
  }
}

String _$reportEnvironmentHash() => r'8bf6337eb31a1348e53c1560dde4d4826fcd6219';

@ProviderFor(shareLauncher)
final shareLauncherProvider = ShareLauncherProvider._();

final class ShareLauncherProvider
    extends $FunctionalProvider<ShareLauncher, ShareLauncher, ShareLauncher>
    with $Provider<ShareLauncher> {
  ShareLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareLauncherHash();

  @$internal
  @override
  $ProviderElement<ShareLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareLauncher create(Ref ref) {
    return shareLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareLauncher>(value),
    );
  }
}

String _$shareLauncherHash() => r'640b46fd5b2a75e541bb4653a3703b5d86785ca3';

/// Where a report file is written before it is shared; overridden in tests.

@ProviderFor(reportDirectory)
final reportDirectoryProvider = ReportDirectoryProvider._();

/// Where a report file is written before it is shared; overridden in tests.

final class ReportDirectoryProvider
    extends
        $FunctionalProvider<
          Future<Directory> Function(),
          Future<Directory> Function(),
          Future<Directory> Function()
        >
    with $Provider<Future<Directory> Function()> {
  /// Where a report file is written before it is shared; overridden in tests.
  ReportDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportDirectoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportDirectoryHash();

  @$internal
  @override
  $ProviderElement<Future<Directory> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<Directory> Function() create(Ref ref) {
    return reportDirectory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<Directory> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<Directory> Function()>(value),
    );
  }
}

String _$reportDirectoryHash() => r'7fca17582710f93021168943d91cbe5408dc9296';
