import 'package:shared_preferences/shared_preferences.dart';

/// The language picked in "Ustawienia → Język" on this phone: `pl`, `en`,
/// or nothing ("Automatycznie": the GI Core profile, else the phone; plan
/// §13.2).
///
/// A phone preference, not part of the session: it outlives logout and
/// "Zmień użytkownika", like the system language would. GI Core is not
/// told (`PATCH /users/me/profile {locale}` is v1.0).
///
/// Nothing here throws: a preference that cannot be read or written only
/// means the automatic language.
final class LanguagePreferenceStore {
  const new(this._prefs);

  static const key = 'app_language.v1';

  /// Keys this store owns; part of the preferences cache allow-list.
  static const Set<String> keys = {key};

  final SharedPreferencesWithCache _prefs;

  /// The stored language code, or `null` for the automatic language.
  String? read() {
    try {
      return _prefs.getString(key);
    } on Object {
      return null;
    }
  }

  /// Stores [languageCode]; `null` returns to the automatic language.
  Future<void> write(String? languageCode) async {
    try {
      if (languageCode == null) {
        if (_prefs.containsKey(key)) await _prefs.remove(key);
      } else {
        await _prefs.setString(key, languageCode);
      }
    } on Object {
      // Applied for this run; the next cold start is automatic.
    }
  }
}
