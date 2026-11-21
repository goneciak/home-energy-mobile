import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/auth/data/vault_read_failures.dart';

/// Applies the "N = 3" rule of plan §7.1 on top of the platform vault.
///
/// A failing secure store ([VaultUnavailable]: Keystore damaged by an OS
/// update, Keychain locked before the first unlock) keeps the entry and the
/// profile, so the app can retry. Only after [maxConsecutiveFailures] failed
/// reads in a row (counted across restarts by [VaultReadFailures]) is the
/// entry wiped and reported as `VaultAbsent(wiped: true)`, which forces a
/// login with its own explanation. Any read that reaches the store
/// (present, absent or undecodable) resets the count.
final class CountingTokenVault implements TokenVault {
  new({
    required this._inner,
    required this._failures,
    this._onUnavailable,
    this.maxConsecutiveFailures = defaultMaxConsecutiveFailures,
  }) : assert(maxConsecutiveFailures > 0, 'at least one failure');

  /// N in plan §7.1.
  static const defaultMaxConsecutiveFailures = 3;

  final TokenVault _inner;
  final VaultReadFailures _failures;

  /// Called on every unavailable read (local diagnostics); must not throw.
  final void Function()? _onUnavailable;

  final int maxConsecutiveFailures;

  @override
  Future<VaultResult> read() async {
    final VaultResult result;
    try {
      result = await _inner.read();
    } on Object catch (error) {
      return await _unavailable(VaultUnavailable(error));
    }
    if (result is VaultUnavailable) return await _unavailable(result);
    await _failures.reset();
    return result;
  }

  @override
  Future<void> write(RefreshCookie cookie) async {
    await _inner.write(cookie);
    await _failures.reset();
  }

  @override
  Future<void> clear() async {
    await _inner.clear();
    await _failures.reset();
  }

  /// Not counted: an unreadable access token only costs a refresh, and the
  /// cookie read decides whether the store is failing.
  @override
  Future<PersistedAccessToken?> readAccessToken() async {
    try {
      return await _inner.readAccessToken();
    } on Object {
      return null;
    }
  }

  @override
  Future<void> writeAccessToken(PersistedAccessToken token) =>
      _inner.writeAccessToken(token);

  @override
  Future<void> clearAccessToken() => _inner.clearAccessToken();

  Future<VaultResult> _unavailable(VaultUnavailable result) async {
    try {
      _onUnavailable?.call();
    } on Object {
      // Diagnostics never change what the session manager sees.
    }
    final failures = await _failures.increment();
    if (failures < maxConsecutiveFailures) return result;
    try {
      await _inner.clear();
    } on Object {
      // A store this broken is overwritten by the next login, if it ever
      // works again; the session must not keep waiting for it.
    }
    await _failures.reset();
    return const VaultAbsent(wiped: true);
  }
}
