import 'dart:convert';

import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the single [ApplianceProfile] in shared preferences as JSON.
class ApplianceProfileStore {
  const new(this._prefs);

  static const profileKey = 'appliance_profile.v1';

  /// Keys this store owns; part of the preferences cache allow-list.
  static const Set<String> keys = {profileKey};

  final SharedPreferencesWithCache _prefs;

  /// The stored profile, or `null` when none is stored or it cannot be
  /// decoded (the user then simply connects again).
  ApplianceProfile? read() {
    final raw = _prefs.getString(profileKey);
    if (raw == null) return null;
    try {
      return ApplianceProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  Future<void> write(ApplianceProfile profile) =>
      _prefs.setString(profileKey, jsonEncode(profile.toJson()));

  Future<void> clear() => _prefs.remove(profileKey);
}
