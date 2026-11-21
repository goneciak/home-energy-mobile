import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Consecutive failed reads of a profile's secure-storage entry, kept in
/// shared preferences so the count survives app restarts (plan §7.1).
///
/// One key holds `{profileId, count}`: the preferences cache needs a fixed
/// allow-list, and v1 has a single profile. A count stored for another
/// profile id reads as zero.
///
/// Nothing here throws: a preference that cannot be written only means the
/// count is kept in memory for this run.
final class VaultReadFailures {
  new(this._prefs, {required this.profileId});

  static const key = 'vault_read_failures.v1';

  /// Keys this store owns; part of the preferences cache allow-list.
  static const Set<String> keys = {key};

  final SharedPreferencesWithCache _prefs;
  final String profileId;
  int? _count;

  /// Failures in a row since the last successful read.
  int get count => _count ??= _load();

  /// Counts one more failure and returns the new total.
  Future<int> increment() async {
    final next = count + 1;
    _count = next;
    try {
      await _prefs.setString(
        key,
        jsonEncode({'profileId': profileId, 'count': next}),
      );
    } on Object {
      // Kept in memory; the next run starts from the last stored value.
    }
    return next;
  }

  /// Forgets the failures (a successful read, write or clear).
  Future<void> reset() async {
    if (count == 0) return;
    _count = 0;
    try {
      await _prefs.remove(key);
    } on Object {
      // A stale count of another run only shortens the next failure streak.
    }
  }

  int _load() {
    try {
      final raw = _prefs.getString(key);
      if (raw == null) return 0;
      if (jsonDecode(raw)
          case {'profileId': final String id, 'count': final int stored}
          when id == profileId && stored > 0) {
        return stored;
      }
    } on Object {
      // Malformed or unreadable: start counting again.
    }
    return 0;
  }
}
