// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_mode.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in tests, which read the asset from disk.

@ProviderFor(demoFixturesLoader)
final demoFixturesLoaderProvider = DemoFixturesLoaderProvider._();

/// Overridden in tests, which read the asset from disk.

final class DemoFixturesLoaderProvider
    extends
        $FunctionalProvider<
          DemoFixturesLoader,
          DemoFixturesLoader,
          DemoFixturesLoader
        >
    with $Provider<DemoFixturesLoader> {
  /// Overridden in tests, which read the asset from disk.
  DemoFixturesLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'demoFixturesLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$demoFixturesLoaderHash();

  @$internal
  @override
  $ProviderElement<DemoFixturesLoader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DemoFixturesLoader create(Ref ref) {
    return demoFixturesLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoFixturesLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoFixturesLoader>(value),
    );
  }
}

String _$demoFixturesLoaderHash() =>
    r'babccfa7902ac0a936dde7060617e7fc4cac931c';

/// Demo mode (plan §19.5): entered with the visible "Wypróbuj wersję
/// demonstracyjną" button on the connect screen, left with "Zakończ demo"
/// on the permanent DEMO banner. `null` outside demo mode.
///
/// While it is on, the GI Core transport, the appliance profile and the
/// token vault are the demo ones: the saved profile, its stored session and
/// the real appliance are never read or written. Leaving drops all demo
/// state; routing then follows the saved profile again (the connect screen
/// when there is none).

@ProviderFor(DemoMode)
final demoModeProvider = DemoModeProvider._();

/// Demo mode (plan §19.5): entered with the visible "Wypróbuj wersję
/// demonstracyjną" button on the connect screen, left with "Zakończ demo"
/// on the permanent DEMO banner. `null` outside demo mode.
///
/// While it is on, the GI Core transport, the appliance profile and the
/// token vault are the demo ones: the saved profile, its stored session and
/// the real appliance are never read or written. Leaving drops all demo
/// state; routing then follows the saved profile again (the connect screen
/// when there is none).
final class DemoModeProvider extends $NotifierProvider<DemoMode, DemoSession?> {
  /// Demo mode (plan §19.5): entered with the visible "Wypróbuj wersję
  /// demonstracyjną" button on the connect screen, left with "Zakończ demo"
  /// on the permanent DEMO banner. `null` outside demo mode.
  ///
  /// While it is on, the GI Core transport, the appliance profile and the
  /// token vault are the demo ones: the saved profile, its stored session and
  /// the real appliance are never read or written. Leaving drops all demo
  /// state; routing then follows the saved profile again (the connect screen
  /// when there is none).
  DemoModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'demoModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$demoModeHash();

  @$internal
  @override
  DemoMode create() => DemoMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoSession?>(value),
    );
  }
}

String _$demoModeHash() => r'a9147fa881a8df259dbe830e0ac231131c83eacf';

/// Demo mode (plan §19.5): entered with the visible "Wypróbuj wersję
/// demonstracyjną" button on the connect screen, left with "Zakończ demo"
/// on the permanent DEMO banner. `null` outside demo mode.
///
/// While it is on, the GI Core transport, the appliance profile and the
/// token vault are the demo ones: the saved profile, its stored session and
/// the real appliance are never read or written. Leaving drops all demo
/// state; routing then follows the saved profile again (the connect screen
/// when there is none).

abstract class _$DemoMode extends $Notifier<DemoSession?> {
  DemoSession? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DemoSession?, DemoSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DemoSession?, DemoSession?>,
              DemoSession?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether demo mode is on.

@ProviderFor(isDemo)
final isDemoProvider = IsDemoProvider._();

/// Whether demo mode is on.

final class IsDemoProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether demo mode is on.
  IsDemoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isDemoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isDemoHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isDemo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isDemoHash() => r'27a851e6ecb718cd35cb35baa5d3b871fea186fd';
