import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Detects a fresh install (plan §7.1).
///
/// iOS keeps Keychain items after the app is deleted, while shared
/// preferences go with it. When the marker is missing on start, every
/// profile entry (`p/*`: refresh cookie `rt`, access token `at`) left in
/// secure storage by an earlier install is wiped, so a reinstall never
/// silently resumes an old session.
///
/// An existing appliance profile without the marker means preferences
/// survived (an update from a build without the marker), not a reinstall:
/// its entry belongs to that profile and is kept.
final class ReinstallMarker {
  const new(this._prefs, this._storage);

  static const key = 'install_marker.v1';

  /// Keys this marker owns; part of the preferences cache allow-list.
  static const Set<String> keys = {key};

  /// Prefix of every secure-storage key owned by a profile.
  static const profileKeyPrefix = 'p/';

  final SharedPreferencesWithCache _prefs;
  final FlutterSecureStorage _storage;

  /// Run once on start, before anything reads secure storage. Returns
  /// whether leftovers were wiped. Never throws: the marker is set even when
  /// wiping fails, so a session saved later is never mistaken for a
  /// leftover.
  Future<bool> check({required bool hasProfile}) async {
    if (_prefs.getBool(key) ?? false) return false;
    var wiped = false;
    if (!hasProfile) {
      wiped = await _wipeProfileEntries();
    }
    try {
      await _prefs.setBool(key, true);
    } on Object {
      // Checked again next start; a profile saved meanwhile is kept then.
    }
    return wiped;
  }

  Future<bool> _wipeProfileEntries() async {
    try {
      final entries = await _storage.readAll();
      final leftovers = [
        for (final key in entries.keys)
          if (key.startsWith(profileKeyPrefix)) key,
      ];
      for (final key in leftovers) {
        await _storage.delete(key: key);
      }
      return leftovers.isNotEmpty;
    } on Object {
      // Entries that cannot even be listed are unusable; every key the app
      // stores is a profile entry, so clearing the store loses nothing.
      try {
        await _storage.deleteAll();
        return true;
      } on Object {
        return false;
      }
    }
  }
}
