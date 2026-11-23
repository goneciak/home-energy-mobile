import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The language last applied from the signed-in user's GI Core profile
/// (plan §13.2), so a cold start with a restored session shows it at once,
/// before `GET /users/me/profile` answers.
///
/// One key holds `{profileId, userId, languageCode}`: the preferences cache
/// needs a fixed allow-list, and v1 has a single profile. A value stored
/// for another profile or user reads as `null`. It belongs to the user
/// remembered on the appliance: a logout keeps it, so the login screen
/// stays in the user's language (plan §13.2); "Zmień użytkownika" and
/// forgetting the appliance remove it with the user.
///
/// Nothing here throws: a preference that cannot be read or written only
/// means the phone language is shown until the profile answers.
final class SessionLocaleStore {
  const new(this._prefs);

  static const key = 'session_locale.v1';

  /// Keys this store owns; part of the preferences cache allow-list.
  static const Set<String> keys = {key};

  final SharedPreferencesWithCache _prefs;

  /// The language code stored for [userId] on [profileId], or `null`.
  String? read({required String profileId, required String userId}) {
    try {
      final raw = _prefs.getString(key);
      if (raw == null) return null;
      if (jsonDecode(raw)
          case {
            'profileId': final String storedProfile,
            'userId': final String storedUser,
            'languageCode': final String languageCode,
          }
          when storedProfile == profileId && storedUser == userId) {
        return languageCode;
      }
    } on Object {
      // Malformed or unreadable: the phone language until the profile.
    }
    return null;
  }

  /// Stores [languageCode] for [userId] on [profileId]; `null` removes it
  /// (the profile has no supported language).
  Future<void> write({
    required String profileId,
    required String userId,
    required String? languageCode,
  }) async {
    if (languageCode == null) {
      await clear();
      return;
    }
    if (read(profileId: profileId, userId: userId) == languageCode) return;
    try {
      await _prefs.setString(
        key,
        jsonEncode({
          'profileId': profileId,
          'userId': userId,
          'languageCode': languageCode,
        }),
      );
    } on Object {
      // The next cold start shows the phone language first.
    }
  }

  Future<void> clear() async {
    try {
      if (_prefs.containsKey(key)) await _prefs.remove(key);
    } on Object {
      // Scoped to the user, so a leftover never reaches another one.
    }
  }
}
