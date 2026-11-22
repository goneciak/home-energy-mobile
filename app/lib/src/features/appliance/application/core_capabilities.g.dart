// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_capabilities.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Counts the GI Core version changes seen in `GET /appliance/updates/status`
/// (plan §16 pt 1) on the current client; each change re-runs the
/// capability probes. Learning the version the first time is no change.

@ProviderFor(CoreVersionChanges)
final coreVersionChangesProvider = CoreVersionChangesProvider._();

/// Counts the GI Core version changes seen in `GET /appliance/updates/status`
/// (plan §16 pt 1) on the current client; each change re-runs the
/// capability probes. Learning the version the first time is no change.
final class CoreVersionChangesProvider
    extends $NotifierProvider<CoreVersionChanges, int> {
  /// Counts the GI Core version changes seen in `GET /appliance/updates/status`
  /// (plan §16 pt 1) on the current client; each change re-runs the
  /// capability probes. Learning the version the first time is no change.
  CoreVersionChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coreVersionChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coreVersionChangesHash();

  @$internal
  @override
  CoreVersionChanges create() => CoreVersionChanges();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$coreVersionChangesHash() =>
    r'31266c9a23b39bdb40c88da283405a2fe6036ee8';

/// Counts the GI Core version changes seen in `GET /appliance/updates/status`
/// (plan §16 pt 1) on the current client; each change re-runs the
/// capability probes. Learning the version the first time is no change.

abstract class _$CoreVersionChanges extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Feature probing (plan §16 pt 2): which optional GI Core features this
/// appliance has, probed once per client (that is per Core instance and
/// connection) and signed-in user, and again when the Core version changes.
///
/// Until the probes finish, and for a probe that ended without a verdict,
/// every feature stays visible: only a proven `HTTP_404` hides one.

@ProviderFor(coreCapabilities)
final coreCapabilitiesProvider = CoreCapabilitiesProvider._();

/// Feature probing (plan §16 pt 2): which optional GI Core features this
/// appliance has, probed once per client (that is per Core instance and
/// connection) and signed-in user, and again when the Core version changes.
///
/// Until the probes finish, and for a probe that ended without a verdict,
/// every feature stays visible: only a proven `HTTP_404` hides one.

final class CoreCapabilitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<CoreCapabilities>,
          CoreCapabilities,
          FutureOr<CoreCapabilities>
        >
    with $FutureModifier<CoreCapabilities>, $FutureProvider<CoreCapabilities> {
  /// Feature probing (plan §16 pt 2): which optional GI Core features this
  /// appliance has, probed once per client (that is per Core instance and
  /// connection) and signed-in user, and again when the Core version changes.
  ///
  /// Until the probes finish, and for a probe that ended without a verdict,
  /// every feature stays visible: only a proven `HTTP_404` hides one.
  CoreCapabilitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coreCapabilitiesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coreCapabilitiesHash();

  @$internal
  @override
  $FutureProviderElement<CoreCapabilities> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CoreCapabilities> create(Ref ref) {
    return coreCapabilities(ref);
  }
}

String _$coreCapabilitiesHash() => r'0cedde751fe445e4f8fd188d822be4e2bb944557';

/// Whether the UI shows [capability] (see [coreCapabilities]).

@ProviderFor(coreCapabilityAvailable)
final coreCapabilityAvailableProvider = CoreCapabilityAvailableFamily._();

/// Whether the UI shows [capability] (see [coreCapabilities]).

final class CoreCapabilityAvailableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the UI shows [capability] (see [coreCapabilities]).
  CoreCapabilityAvailableProvider._({
    required CoreCapabilityAvailableFamily super.from,
    required CoreCapability super.argument,
  }) : super(
         retry: null,
         name: r'coreCapabilityAvailableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coreCapabilityAvailableHash();

  @override
  String toString() {
    return r'coreCapabilityAvailableProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as CoreCapability;
    return coreCapabilityAvailable(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CoreCapabilityAvailableProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coreCapabilityAvailableHash() =>
    r'348eccbc9522229b1f69cf6e9a2d31cf36a6aa66';

/// Whether the UI shows [capability] (see [coreCapabilities]).

final class CoreCapabilityAvailableFamily extends $Family
    with $FunctionalFamilyOverride<bool, CoreCapability> {
  CoreCapabilityAvailableFamily._()
    : super(
        retry: null,
        name: r'coreCapabilityAvailableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the UI shows [capability] (see [coreCapabilities]).

  CoreCapabilityAvailableProvider call(CoreCapability capability) =>
      CoreCapabilityAvailableProvider._(argument: capability, from: this);

  @override
  String toString() => r'coreCapabilityAvailableProvider';
}
