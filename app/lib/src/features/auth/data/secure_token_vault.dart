import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gi_core_api/gi_core_api.dart';

/// [TokenVault] backed by the Keychain / Android Keystore through
/// `flutter_secure_storage`, one pair of entries per appliance profile (plan
/// §7.1): the refresh cookie under `p/<profileId>/rt` and the access token
/// with its wall-clock expiry under `p/<profileId>/at` (D3).
class SecureTokenVault implements TokenVault {
  new({required this._storage, required String profileId})
    : key = keyFor(profileId),
      accessTokenKey = accessTokenKeyFor(profileId);

  final FlutterSecureStorage _storage;

  /// Storage key of the refresh cookie.
  final String key;

  /// Storage key of the access token.
  final String accessTokenKey;

  static String keyFor(String profileId) => 'p/$profileId/rt';

  static String accessTokenKeyFor(String profileId) => 'p/$profileId/at';

  /// Never throws. A platform failure (Keystore/Keychain error, device not
  /// unlocked since boot) is [VaultUnavailable] and the entry is kept. An
  /// entry that cannot be decoded is unusable: it is removed and reported as
  /// `VaultAbsent(wiped: true)`, which forces a login with an explanation.
  @override
  Future<VaultResult> read() async {
    final String? raw;
    try {
      raw = await _storage.read(key: key);
    } on Object catch (error) {
      return VaultUnavailable(error);
    }
    if (raw == null) return const VaultAbsent();
    try {
      return VaultPresent(
        RefreshCookie.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    } on Object {
      try {
        await _storage.delete(key: key);
      } on Object {
        // The corrupt entry is overwritten by the next login anyway.
      }
      return const VaultAbsent(wiped: true);
    }
  }

  @override
  Future<void> write(RefreshCookie cookie) async {
    await _storage.write(key: key, value: jsonEncode(cookie.toJson()));
  }

  /// Removes the cookie first: without it the access token is never used.
  @override
  Future<void> clear() async {
    await _storage.delete(key: key);
    await _storage.delete(key: accessTokenKey);
  }

  /// Never throws. A platform failure only means no token (the session
  /// refreshes with the cookie, which is left alone); an entry that cannot
  /// be decoded is removed.
  @override
  Future<PersistedAccessToken?> readAccessToken() async {
    final String? raw;
    try {
      raw = await _storage.read(key: accessTokenKey);
    } on Object {
      return null;
    }
    if (raw == null) return null;
    PersistedAccessToken? token;
    try {
      token = PersistedAccessToken.tryFromJson(jsonDecode(raw));
    } on FormatException {
      token = null;
    }
    if (token == null) {
      try {
        await _storage.delete(key: accessTokenKey);
      } on Object {
        // Overwritten by the next login or refresh.
      }
    }
    return token;
  }

  @override
  Future<void> writeAccessToken(PersistedAccessToken token) async {
    await _storage.write(
      key: accessTokenKey,
      value: jsonEncode(token.toJson()),
    );
  }

  @override
  Future<void> clearAccessToken() async {
    await _storage.delete(key: accessTokenKey);
  }
}
