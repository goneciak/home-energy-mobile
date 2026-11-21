import 'package:gi_core_api/gi_core_api.dart' show AuthSessionManager;

import 'package:gi_core_api/src/auth/auth_session_manager.dart'
    show AuthSessionManager;

import 'package:gi_core_api/src/auth/refresh_cookie.dart';
import 'package:gi_core_api/src/failures/api_failure.dart'
    show SessionLostReason;
import 'package:meta/meta.dart';

/// Outcome of reading the vault (plan §7.1).
sealed class VaultResult {
  const new();
}

final class VaultPresent extends VaultResult {
  const new(this.cookie);
  final RefreshCookie cookie;
}

/// No usable cookie is stored.
final class VaultAbsent extends VaultResult {
  const new({this.wiped = false});

  /// The entry existed but was unusable and has been removed: it could not
  /// be decoded, or the store failed on several reads in a row (plan §7.1).
  /// The user is told why they must log in again
  /// ([SessionLostReason.vaultWiped]); a plain absence is a normal sign-in.
  final bool wiped;
}

/// The platform store failed (Keystore/Keychain error, device locked before
/// first unlock). Credentials must NOT be wiped because of a single failure;
/// the app gives up only after several in a row and then reports
/// `VaultAbsent(wiped: true)`.
final class VaultUnavailable extends VaultResult {
  const new(this.error);
  final Object error;
}

/// An access token persisted with its wall-clock expiry (plan §7.1, D3), so
/// a cold start within its lifetime needs no refresh. [toString] never
/// prints [token].
@immutable
final class PersistedAccessToken {
  new({required this.token, required DateTime expiresAt})
    : expiresAt = expiresAt.toUtc();

  /// Decodes [toJson] output; `null` when [json] is not a valid record.
  static PersistedAccessToken? tryFromJson(Object? json) {
    if (json
        case {'token': final String token, 'expiresAt': final String expiresAt}
        when token.isNotEmpty) {
      final at = DateTime.tryParse(expiresAt);
      if (at != null) return PersistedAccessToken(token: token, expiresAt: at);
    }
    return null;
  }

  final String token;

  /// When the server stops accepting [token], by the wall clock (UTC).
  final DateTime expiresAt;

  Map<String, Object?> toJson() => {
    'token': token,
    'expiresAt': expiresAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is PersistedAccessToken &&
      other.token == token &&
      other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash(token, expiresAt);

  @override
  String toString() =>
      'PersistedAccessToken(token: <redacted>, expiresAt: $expiresAt)';
}

/// Secure storage for the refresh cookie and the current access token (plan
/// §7.1). The app implements it with `flutter_secure_storage`;
/// [AuthSessionManager] is its only user.
abstract interface class TokenVault {
  /// Never throws: platform errors are reported as [VaultUnavailable].
  Future<VaultResult> read();

  /// Persists [cookie]; throws when the platform store fails.
  Future<void> write(RefreshCookie cookie);

  /// Removes the cookie AND the access token; throws when the platform
  /// store fails.
  Future<void> clear();

  /// The persisted access token, or `null` when there is none or it cannot
  /// be read. Never throws, and a failure here never touches the cookie:
  /// without a token the session simply refreshes.
  Future<PersistedAccessToken?> readAccessToken();

  /// Persists [token] in place of the previous one; throws when the
  /// platform store fails.
  Future<void> writeAccessToken(PersistedAccessToken token);

  /// Removes only the access token; throws when the platform store fails.
  Future<void> clearAccessToken();
}

/// In-memory [TokenVault] for tests and tools, with failure injection.
class InMemoryTokenVault implements TokenVault {
  new([this._cookie, this._accessToken]);

  RefreshCookie? _cookie;
  PersistedAccessToken? _accessToken;

  /// When set, [read] reports [VaultUnavailable] with this error.
  Object? readError;

  /// When set, [readAccessToken] fails like an unavailable store: it reports
  /// no token and keeps both entries.
  Object? accessReadError;

  /// When set, every write and clear throws this error.
  Exception? writeError;

  /// Every successful write, in order.
  final List<RefreshCookie> writes = [];

  /// Every successful access token write, in order.
  final List<PersistedAccessToken> accessWrites = [];

  RefreshCookie? get cookie => _cookie;

  PersistedAccessToken? get accessToken => _accessToken;

  @override
  Future<VaultResult> read() async {
    final error = readError;
    if (error != null) return VaultUnavailable(error);
    final cookie = _cookie;
    return cookie == null ? const VaultAbsent() : VaultPresent(cookie);
  }

  @override
  Future<void> write(RefreshCookie cookie) async {
    final error = writeError;
    if (error != null) throw error;
    _cookie = cookie;
    writes.add(cookie);
  }

  @override
  Future<void> clear() async {
    final error = writeError;
    if (error != null) throw error;
    _cookie = null;
    _accessToken = null;
  }

  @override
  Future<PersistedAccessToken?> readAccessToken() async =>
      accessReadError == null ? _accessToken : null;

  @override
  Future<void> writeAccessToken(PersistedAccessToken token) async {
    final error = writeError;
    if (error != null) throw error;
    _accessToken = token;
    accessWrites.add(token);
  }

  @override
  Future<void> clearAccessToken() async {
    final error = writeError;
    if (error != null) throw error;
    _accessToken = null;
  }
}
