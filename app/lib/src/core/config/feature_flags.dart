import 'package:flutter/foundation.dart';
import 'package:gi_home/src/core/config/app_flavor.dart';

/// A feature that can be switched on per flavor (plan §19.6).
///
/// The default of each flag comes from its [define] in `config/<flavor>.json`
/// (`--dart-define-from-file`); without the define it is off. In dev and beta
/// the hidden "Funkcje eksperymentalne" screen overrides it on the phone; in
/// prod only the default counts.
enum FeatureFlag {
  /// GI Core is replaced by the in-process mock (`MockCoreAdapter`), for
  /// working without a backend. Dev flavor only: in beta and prod it is
  /// always off, whatever the config or a stored override says.
  mockCore('FF_MOCK_CORE', devOnly: true),

  /// "Edytuj w czasie domu": schedule times are edited in the home time
  /// zone (`/settings/system`) and converted to the GI Core clock, instead
  /// of only being labelled with the Core clock (plan §13.4, D8: opt-in
  /// conversion). The phone's zone is only the label fallback for a USER,
  /// never a conversion target.
  scheduleClockConversion('FF_SCHEDULE_CLOCK_CONVERSION'),

  /// Switch control is enabled per integration type of the device rather
  /// than for every writable switch (plan §19.6). Not D10: that decision is
  /// the v1.1 background checks, which get their own flag.
  switchControlByIntegration('FF_SWITCH_CONTROL_BY_INTEGRATION'),

  /// The app asks for Android's local network permission
  /// (`NEARBY_WIFI_DEVICES`) at runtime before it connects (plan §9.4),
  /// ready for when the target API enforces local network protection.
  androidLocalNetworkPermissionRequest(
    'FF_ANDROID_LOCAL_NETWORK_PERMISSION_REQUEST',
  );

  new(this.define, {this.devOnly = false});

  /// Name of the compile-time define holding the flavor default.
  final String define;

  /// Whether the flag exists only in the dev flavor.
  final bool devOnly;

  /// Whether the flag can be on in [flavor] at all.
  bool isAvailableIn(AppFlavor flavor) => !devOnly || flavor == AppFlavor.dev;
}

/// The value of every [FeatureFlag]: immutable, compared by value.
///
/// Screens and use cases read the typed getters. The M3 merge with the
/// capability probe results (plan §16) is not part of this object yet.
@immutable
final class FeatureFlags {
  /// [values] for the flags it names; the others are off.
  new([Map<FeatureFlag, bool> values = const {}])
    : _values = Map.unmodifiable({
        for (final flag in FeatureFlag.values) flag: values[flag] ?? false,
      });

  /// Every flag off.
  static final FeatureFlags allOff = FeatureFlags();

  final Map<FeatureFlag, bool> _values;

  bool operator [](FeatureFlag flag) => _values[flag]!;

  bool get mockCore => this[FeatureFlag.mockCore];
  bool get scheduleClockConversion => this[FeatureFlag.scheduleClockConversion];
  bool get switchControlByIntegration =>
      this[FeatureFlag.switchControlByIntegration];
  bool get androidLocalNetworkPermissionRequest =>
      this[FeatureFlag.androidLocalNetworkPermissionRequest];

  /// Every flag with its value, in declaration order.
  Map<FeatureFlag, bool> asMap() => _values;

  /// These flags with [overrides] applied.
  FeatureFlags merge(Map<FeatureFlag, bool> overrides) =>
      FeatureFlags({..._values, ...overrides});

  /// These flags with the ones unavailable in [flavor] switched off.
  FeatureFlags restrictTo(AppFlavor flavor) => FeatureFlags({
    for (final MapEntry(key: flag, :value) in _values.entries)
      flag: value && flag.isAvailableIn(flavor),
  });

  @override
  bool operator ==(Object other) =>
      other is FeatureFlags && mapEquals(other._values, _values);

  @override
  int get hashCode => Object.hashAll(_values.values);

  @override
  String toString() {
    final on = [
      for (final MapEntry(:key, :value) in _values.entries)
        if (value) key.name,
    ];
    return 'FeatureFlags(${on.join(', ')})';
  }
}
