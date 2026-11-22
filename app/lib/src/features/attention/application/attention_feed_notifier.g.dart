// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attention_feed_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The "Uwaga" list and the badge count (plan §15), from the latest device
/// list and the signed-in user. It never polls by itself: the list is
/// refreshed by Home, device details or the "Uwaga" screen while one of
/// them is visible. Resolved entries are remembered in memory for 24 h and
/// forgotten with the user.

@ProviderFor(AttentionFeedNotifier)
final attentionFeedProvider = AttentionFeedNotifierProvider._();

/// The "Uwaga" list and the badge count (plan §15), from the latest device
/// list and the signed-in user. It never polls by itself: the list is
/// refreshed by Home, device details or the "Uwaga" screen while one of
/// them is visible. Resolved entries are remembered in memory for 24 h and
/// forgotten with the user.
final class AttentionFeedNotifierProvider
    extends $NotifierProvider<AttentionFeedNotifier, AttentionFeed> {
  /// The "Uwaga" list and the badge count (plan §15), from the latest device
  /// list and the signed-in user. It never polls by itself: the list is
  /// refreshed by Home, device details or the "Uwaga" screen while one of
  /// them is visible. Resolved entries are remembered in memory for 24 h and
  /// forgotten with the user.
  AttentionFeedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attentionFeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attentionFeedNotifierHash();

  @$internal
  @override
  AttentionFeedNotifier create() => AttentionFeedNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttentionFeed value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttentionFeed>(value),
    );
  }
}

String _$attentionFeedNotifierHash() =>
    r'871a535083be48db02a7ad77aff770db1dce4d43';

/// The "Uwaga" list and the badge count (plan §15), from the latest device
/// list and the signed-in user. It never polls by itself: the list is
/// refreshed by Home, device details or the "Uwaga" screen while one of
/// them is visible. Resolved entries are remembered in memory for 24 h and
/// forgotten with the user.

abstract class _$AttentionFeedNotifier extends $Notifier<AttentionFeed> {
  AttentionFeed build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AttentionFeed, AttentionFeed>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AttentionFeed, AttentionFeed>,
              AttentionFeed,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Number on the "Uwaga" tab: entries still reported.

@ProviderFor(attentionBadgeCount)
final attentionBadgeCountProvider = AttentionBadgeCountProvider._();

/// Number on the "Uwaga" tab: entries still reported.

final class AttentionBadgeCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Number on the "Uwaga" tab: entries still reported.
  AttentionBadgeCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attentionBadgeCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attentionBadgeCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return attentionBadgeCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$attentionBadgeCountHash() =>
    r'06d582cc1143025e0c9e24822260754a170fc733';
