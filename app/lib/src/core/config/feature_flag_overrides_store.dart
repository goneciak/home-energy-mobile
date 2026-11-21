import 'dart:convert';

import 'package:gi_home/src/core/config/feature_flags.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature flag overrides made on the phone, from the hidden
/// "Funkcje eksperymentalne" screen (dev and beta, plan §19.6). Stored as
/// a JSON object of flag name → value; only flags that differ from the
/// flavor default are kept.
class FeatureFlagOverridesStore {
  const new(this._prefs);

  static const overridesKey = 'feature_flag_overrides.v1';

  /// Keys this store owns; part of the preferences cache allow-list.
  static const Set<String> keys = {overridesKey};

  final SharedPreferencesWithCache _prefs;

  /// The stored overrides. Unknown flag names (from another app version) and
  /// a value that cannot be decoded are ignored.
  Map<FeatureFlag, bool> read() {
    final raw = _prefs.getString(overridesKey);
    if (raw == null) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const {};
      final byName = FeatureFlag.values.asNameMap();
      return {
        for (final MapEntry(:key, :value) in decoded.entries)
          if (byName[key] case final flag? when value is bool) flag: value,
      };
    } on FormatException {
      return const {};
    }
  }

  /// Replaces the stored overrides; none removes the entry.
  Future<void> write(Map<FeatureFlag, bool> overrides) => overrides.isEmpty
      ? clear()
      : _prefs.setString(
          overridesKey,
          jsonEncode({
            for (final MapEntry(:key, :value) in overrides.entries)
              key.name: value,
          }),
        );

  Future<void> clear() => _prefs.remove(overridesKey);
}
