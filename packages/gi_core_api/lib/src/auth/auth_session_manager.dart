import 'dart:async';

import 'package:dio/dio.dart';
import 'package:gi_core_api/src/auth/auth_state.dart';
import 'package:gi_core_api/src/auth/monotonic_clock.dart';
import 'package:gi_core_api/src/auth/refresh_cookie.dart';
import 'package:gi_core_api/src/auth/token_vault.dart';
import 'package:gi_core_api/src/catalog/endpoint.dart';
import 'package:gi_core_api/src/catalog/endpoints.dart';
import 'package:gi_core_api/src/converters/json_converters.dart';
import 'package:gi_core_api/src/failures/api_error_envelope.dart';
import 'package:gi_core_api/src/failures/api_failure.dart';
import 'package:gi_core_api/src/failures/failure_mapping.dart';
import 'package:gi_core_api/src/http/dio_factory.dart';
import 'package:gi_core_api/src/http/interceptors.dart';
import 'package:gi_core_api/src/http/response_decoding.dart';
import 'package:gi_core_api/src/models/auth_models.dart';
import 'package:gi_core_api/src/models/system_models.dart';
import 'package:synchronized/synchronized.dart';

/// Told the appliance's new `deviceName` after a rename (plan §9.3).
typedef ApplianceRenamed = void Function(String deviceName);

/// The single owner of the GI Core session (plan §7.4).
///
/// * It is the only code that reads or sends the refresh cookie, using its
///   own [Dio] without the auth interceptor and without a CancelToken.
/// * [ensureFresh] is single-flight: concurrent callers share one refresh,
///   and a lock serialises refresh, login and logout.
/// * Write-ahead: a rotated cookie is persisted before the new access token
///   becomes visible to anyone.
/// * A refresh whose outcome is unknown is never repeated blindly: the next
///   attempt waits for a successful `GET /health/live` first.
/// * Nothing refreshes on a timer; refreshes happen only on demand.
/// * The access token is persisted with its wall-clock expiry (plan §7.1,
///   D3): a cold start while it is still valid for more than
///   [persistedTokenMargin] uses it without a refresh. It is removed with
///   the session (logout, loss) and whenever the appliance turns out to be
///   another one or reset, and it is never logged.
final class AuthSessionManager implements AccessTokenSource {
  /// `dio` must come from `createCoreDio` without an auth interceptor.
  ///
  /// `expectedInitializedAt` and `expectedDeviceName` are the appliance
  /// fingerprint of the stored session (plan §9.3). When
  /// `expectedInitializedAt` is set, `GET /setup/status` is checked before
  /// a refresh (at most once a minute) and the cookie is only sent when it
  /// reports the same `initializedAt`:
  ///
  /// * a different `initializedAt` → [ApiFailure.differentAppliance];
  /// * `initialized: false` → [ApiFailure.applianceReset];
  /// * the same `initializedAt` under another `deviceName` is a rename: the
  ///   refresh goes ahead and `onApplianceRenamed` receives the new name
  ///   (also readable as [applianceDeviceName]).
  ///
  /// `waitUntilForeground` lets the app hold refreshes while it is in the
  /// background. `decodeMode` applies to every body this manager decodes.
  new({
    required this._dio,
    required this._vault,
    MonotonicClock? clock,
    DateTime Function()? now,
    this._expectedInitializedAt,
    String? expectedDeviceName,
    this._onApplianceRenamed,
    this._waitUntilForeground,
    this._decodeMode = DecodeMode.tolerant,
    this._refreshMargin = const Duration(seconds: 60),
  }) : _clock = clock ?? StopwatchClock(),
       _now = now ?? _utcNow,
       _deviceName = expectedDeviceName;

  static const _applianceCheckTtl = Duration(seconds: 60);

  /// A persisted access token is used on cold start only while it stays
  /// valid for longer than this by the wall clock.
  static const persistedTokenMargin = Duration(seconds: 30);

  final Dio _dio;
  final TokenVault _vault;
  final MonotonicClock _clock;
  final DateTime Function() _now;
  final DateTime? _expectedInitializedAt;
  final ApplianceRenamed? _onApplianceRenamed;
  final Future<void> Function()? _waitUntilForeground;
  final DecodeMode _decodeMode;
  final Duration _refreshMargin;

  final _lock = Lock();
  final _states = StreamController<AuthState>.broadcast();
  Future<String>? _inFlight;
  _AccessToken? _access;
  RefreshCookie? _cookie;
  bool _ambiguous = false;
  bool _loggingOut = false;
  Duration? _applianceCheckedAt;
  String? _deviceName;
  AuthState _state = const AuthState.unknown();

  AuthState get state => _state;

  /// The appliance's `deviceName` as last seen by the fingerprint check (or
  /// the expected one until then).
  String? get applianceDeviceName => _deviceName;

  /// State changes; the current value is [state].
  Stream<AuthState> get states => _states.stream;

  /// When the 30-day session ends and the user must log in again.
  DateTime? get sessionExpiresAt => _cookie?.absoluteExpiry;

  /// Whether the last refresh had an unknown outcome; the next one waits
  /// for `GET /health/live` to succeed.
  bool get isRefreshAmbiguous => _ambiguous;

  /// Resolves the stored session on cold start. Absent cookie →
  /// unauthenticated; an unreadable cookie the vault wiped →
  /// [AuthState.sessionLost] with [SessionLostReason.vaultWiped]; a session
  /// the server (or the cookie's expiry) ended →
  /// [AuthState.sessionLost] with its reason. Outcomes that are not known
  /// (unreachable, vault unavailable, different or reset appliance) throw and
  /// leave the state [AuthState.unknown] with the cookie kept, so the app can
  /// retry or decide.
  ///
  /// A persisted access token still valid for more than
  /// [persistedTokenMargin] (wall clock) is used instead of a refresh, after
  /// the appliance fingerprint check; one the server rejects is refreshed
  /// once, like any other 401.
  Future<AuthState> restore() async {
    if (_cookie == null) {
      switch (await _readVault()) {
        case VaultAbsent(wiped: true):
          // The unusable entry is already gone; the login screen says why.
          _setState(const AuthState.sessionLost(SessionLostReason.vaultWiped));
          return _state;
        case VaultAbsent():
          _setState(const AuthState.unauthenticated());
          return _state;
        case VaultUnavailable():
          throw const ApiFailure.vaultUnavailable();
        case VaultPresent(:final cookie):
          _cookie = cookie;
      }
    }
    try {
      if (_access == null) await _lock.synchronized(_adoptPersistedAccess);
      final token = await ensureFresh();
      final user = await _fetchMeOnRestore(token);
      _setState(AuthState.authenticated(user));
    } on SessionLostFailure {
      // Definitive: the cookie is wiped and the state carries the reason.
      if (_state is! AuthSessionLost) rethrow;
    }
    return _state;
  }

  /// `POST /auth/login` with exactly `{email, password}`. On success the
  /// refresh cookie is persisted before the session becomes authenticated.
  Future<CurrentUser> login({
    required String email,
    required String password,
  }) => _lock.synchronized(() async {
    const endpoint = GiEndpoints.authLogin;
    final response = await _send(
      endpoint,
      data: LoginRequest(email: email, password: password).toJson(),
    );
    final body = decodeResponse(
      endpoint,
      response,
      (json) => LoginResponse.fromJson(asJsonObject(json)),
      mode: _decodeMode,
      encode: (body) => body.toJson(),
    );
    final selection = RefreshCookieCodec.select(
      _setCookies(response),
      now: _now(),
    );
    if (selection is! RefreshCookieFound) {
      throw const ApiFailure.refreshCookieMissing();
    }
    await _persist(selection.cookie);
    _ambiguous = false;
    await _useAccessToken(body.accessToken, body.expiresIn);
    _setState(AuthState.authenticated(body.user));
    return body.user;
  });

  /// Ends the session: refreshes if needed, calls `POST /auth/logout` and
  /// ALWAYS wipes local credentials, even when the server is unreachable.
  /// An access token the server rejects as expired or invalid (it may have
  /// aged while the device slept) is refreshed once and the logout resent.
  Future<LogoutResult> logout() async {
    _loggingOut = true;
    var serverSessionEnded = false;
    try {
      final token = await ensureFresh();
      try {
        await _send(GiEndpoints.authLogout, headers: _bearer(token));
      } on UnauthorizedFailure catch (failure) {
        switch (failure.code) {
          case 'AUTH_ACCESS_TOKEN_EXPIRED' || 'AUTH_ACCESS_TOKEN_INVALID':
            final fresh = await ensureFresh(force: true, rejectedToken: token);
            await _send(GiEndpoints.authLogout, headers: _bearer(fresh));
          case 'AUTH_SESSION_REVOKED':
            break; // Already ended on the server.
          default:
            rethrow;
        }
      }
      serverSessionEnded = true;
    } on ApiFailure {
      // The local wipe below is what matters; the caller is told the server
      // session may still be alive.
    } finally {
      await _lock.synchronized(_wipeLocal);
      _loggingOut = false;
      _setState(const AuthState.unauthenticated());
    }
    return LogoutResult(serverSessionEnded: serverSessionEnded);
  }

  /// Replaces the user in an authenticated state (after `GET /auth/me`).
  void updateUser(CurrentUser user) {
    if (_state is AuthAuthenticated) _setState(AuthState.authenticated(user));
  }

  @override
  Future<String> accessToken() => ensureFresh();

  @override
  Future<String> ensureFresh({bool force = false, String? rejectedToken}) {
    final current = _access;
    if (current != null && !_needsRefresh(current, force, rejectedToken)) {
      return Future.value(current.value);
    }
    return _inFlight ??= _lock
        .synchronized(() => _refreshLocked(force, rejectedToken))
        .whenComplete(() => _inFlight = null);
  }

  @override
  Future<bool> invalidate(SessionLostReason reason, {String? rejectedToken}) =>
      _lock.synchronized(() async {
        // A late answer to a request sent before the session ended must
        // neither re-announce the end nor replace the reason shown.
        if (_hasEnded) return false;
        final current = _access;
        if (rejectedToken != null &&
            current != null &&
            current.value != rejectedToken) {
          return false;
        }
        await _lose(reason);
        return true;
      });

  Future<void> dispose() => _states.close();

  bool _needsRefresh(_AccessToken token, bool force, String? rejectedToken) {
    if (force) return rejectedToken == null || rejectedToken == token.value;
    final margin = token.ttl < _refreshMargin * 2
        ? token.ttl ~/ 2
        : _refreshMargin;
    return token.remaining(_clock.elapsed, _now()) < margin;
  }

  /// The session ended (logout or loss) and no credentials are held.
  bool get _hasEnded =>
      _access == null &&
      _cookie == null &&
      (_state is AuthUnauthenticated || _state is AuthSessionLost);

  /// Makes a token from the server the current one and persists it with its
  /// wall-clock expiry (D3). A store that fails only costs a refresh on the
  /// next cold start; an older token left behind is removed, so it is never
  /// preferred over a refresh.
  Future<void> _useAccessToken(String value, int expiresInSeconds) async {
    final wallNow = _now();
    final ttl = Duration(seconds: expiresInSeconds);
    _access = _AccessToken(
      value,
      ttl: ttl,
      obtainedAt: _clock.elapsed,
      obtainedAtWall: wallNow,
    );
    try {
      await _vault.writeAccessToken(
        PersistedAccessToken(token: value, expiresAt: wallNow.add(ttl)),
      );
    } on Object {
      await _clearPersistedAccess();
    }
  }

  /// Cold start: takes over the persisted access token when it is still
  /// valid for more than [persistedTokenMargin] by the wall clock. While
  /// running, the token is then checked on both clocks like any other.
  /// The token only goes to the appliance it was issued by, so the
  /// fingerprint is checked first. Runs under the lock.
  Future<void> _adoptPersistedAccess() async {
    final cookie = _cookie;
    if (_access != null || cookie == null || cookie.isExpiredAt(_now())) {
      return;
    }
    final PersistedAccessToken? stored;
    try {
      stored = await _vault.readAccessToken();
    } on Object {
      return; // Unreadable: refresh with the cookie instead.
    }
    if (stored == null) return;
    final remaining = stored.expiresAt.difference(_now());
    if (remaining <= persistedTokenMargin) return;
    await _checkAppliance();
    _access = _AccessToken(
      stored.token,
      ttl: remaining,
      obtainedAt: _clock.elapsed,
      obtainedAtWall: _now(),
    );
  }

  /// `GET /auth/me` while restoring. With a persisted token the server may
  /// have ended the session meanwhile, or rejected the token: an ended
  /// session is lost like on any request, and any other 401 is refreshed
  /// once and retried, as the auth interceptor does.
  Future<CurrentUser> _fetchMeOnRestore(String token) async {
    try {
      return await _fetchMe(token);
    } on ApiFailure catch (failure) {
      final reason = switch (failure) {
        UnauthorizedFailure(code: 'AUTH_SESSION_REVOKED') =>
          SessionLostReason.sessionRevoked,
        ForbiddenFailure(code: 'USER_DISABLED') =>
          SessionLostReason.userDisabled,
        _ => null,
      };
      if (reason != null) {
        await invalidate(reason, rejectedToken: token);
        throw ApiFailure.sessionLost(reason: reason);
      }
      if (failure is! UnauthorizedFailure) rethrow;
      final fresh = await ensureFresh(force: true, rejectedToken: token);
      return await _fetchMe(fresh);
    }
  }

  Future<void> _forgetAccess() async {
    _access = null;
    await _clearPersistedAccess();
  }

  Future<void> _clearPersistedAccess() async {
    try {
      await _vault.clearAccessToken();
    } on Object {
      // Left behind, it is rejected on use and then refreshed.
    }
  }

  Future<String> _refreshLocked(bool force, String? rejectedToken) async {
    final current = _access;
    if (current != null && !_needsRefresh(current, force, rejectedToken)) {
      return current.value;
    }
    if (_hasEnded) {
      // Nothing to refresh with: fail without a request and keep the reason
      // the user is already shown.
      throw ApiFailure.sessionLost(
        reason: switch (_state) {
          AuthSessionLost(:final reason) => reason,
          _ => SessionLostReason.noToken,
        },
      );
    }
    await _waitUntilForeground?.call();
    if (_ambiguous) await _confirmReachable();
    await _checkAppliance();
    final cookie = await _loadCookie();

    const endpoint = GiEndpoints.authRefresh;
    final Response<Object?> response;
    try {
      response = await sendEndpoint(
        _dio,
        endpoint,
        headers: {'cookie': cookie.cookieHeader},
      );
    } on DioException catch (e) {
      throw await _refreshFailure(e);
    }

    if (response.data is! Map) {
      // A 200 that is not JSON (captive portal, proxy page): the server may
      // or may not have rotated the cookie.
      _ambiguous = true;
      throw ApiFailure.unexpectedResponse(
        statusCode: response.statusCode,
        contentType: response.headers.value(Headers.contentTypeHeader),
      );
    }
    final selection = RefreshCookieCodec.select(
      _setCookies(response),
      now: _now(),
      generation: cookie.generation + 1,
    );
    if (selection is! RefreshCookieFound) {
      // Replaying the old cookie would only be reported as reuse.
      await _lose(SessionLostReason.protocol);
      throw const ApiFailure.sessionLost(reason: SessionLostReason.protocol);
    }
    await _persist(selection.cookie); // WRITE-AHEAD
    _ambiguous = false;
    final body = decodeResponse(
      endpoint,
      response,
      (json) => RefreshResponse.fromJson(asJsonObject(json)),
      mode: _decodeMode,
      encode: (body) => body.toJson(),
    );
    await _useAccessToken(body.accessToken, body.expiresIn);
    return body.accessToken;
  }

  /// Classifies a failed refresh. The cookie is wiped only when the server
  /// definitively rejected it.
  Future<ApiFailure> _refreshFailure(DioException e) async {
    final failure = mapDioException(e);
    final response = e.response;
    if (e.type == DioExceptionType.badResponse && response != null) {
      final status = response.statusCode ?? 0;
      final envelope = ApiErrorEnvelope.tryParse(response.data);
      if (envelope == null || status >= 500) {
        _ambiguous = true;
        return failure;
      }
      final reason = switch ((status, envelope.code)) {
        (401, 'AUTH_REFRESH_TOKEN_INVALID') =>
          SessionLostReason.refreshTokenInvalid,
        (401, 'AUTH_REFRESH_TOKEN_REUSED') =>
          SessionLostReason.refreshTokenReused,
        (401, 'AUTH_SESSION_REVOKED') => SessionLostReason.sessionRevoked,
        (403, 'USER_DISABLED') => SessionLostReason.userDisabled,
        (401, _) => SessionLostReason.refreshRejected,
        _ => null,
      };
      if (reason == null) return failure;
      await _lose(reason);
      return ApiFailure.sessionLost(reason: reason);
    }
    // Not sent (unreachable, TLS, policy): the cookie is still valid.
    if (failure is! UnreachableFailure &&
        failure is! TlsUntrustedFailure &&
        failure is! InsecureTransportFailure) {
      _ambiguous = true;
    }
    return failure;
  }

  Future<void> _confirmReachable() async {
    try {
      await sendEndpoint(
        _dio,
        GiEndpoints.healthLive,
        timeout: TimeoutClass.probe,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> _checkAppliance() async {
    final expected = _expectedInitializedAt;
    if (expected == null) return;
    final checkedAt = _applianceCheckedAt;
    if (checkedAt != null && _clock.elapsed - checkedAt < _applianceCheckTtl) {
      return;
    }
    const endpoint = GiEndpoints.setupStatus;
    final status = decodeResponse(
      endpoint,
      await _send(endpoint),
      (json) => SetupStatus.fromJson(asJsonObject(json)),
      mode: _decodeMode,
      encode: (status) => status.toJson(),
    );
    // The known appliance answers but is no longer set up: it was reset.
    // Either way the access token must never reach it; the cookie is kept
    // for the app to decide.
    if (!status.initialized) {
      await _forgetAccess();
      throw const ApiFailure.applianceReset();
    }
    final initializedAt = status.initializedAt;
    if (initializedAt == null || !initializedAt.isAtSameMomentAs(expected)) {
      await _forgetAccess();
      throw const ApiFailure.differentAppliance();
    }
    _applianceCheckedAt = _clock.elapsed;
    final name = status.deviceName?.trim();
    // A missing name is not a rename: the label keeps the last one.
    if (name != null && name.isNotEmpty && name != _deviceName) {
      _deviceName = name;
      try {
        _onApplianceRenamed?.call(name);
      } on Object {
        // The profile label is cosmetic; it must not fail the refresh.
      }
    }
  }

  Future<RefreshCookie> _loadCookie() async {
    var cookie = _cookie;
    if (cookie == null) {
      switch (await _readVault()) {
        case VaultAbsent(:final wiped):
          final reason = wiped
              ? SessionLostReason.vaultWiped
              : SessionLostReason.noToken;
          await _lose(reason);
          throw ApiFailure.sessionLost(reason: reason);
        case VaultUnavailable():
          throw const ApiFailure.vaultUnavailable();
        case VaultPresent(cookie: final stored):
          cookie = _cookie = stored;
      }
    }
    if (cookie.isExpiredAt(_now())) {
      await _lose(SessionLostReason.expired);
      throw const ApiFailure.sessionLost(reason: SessionLostReason.expired);
    }
    return cookie;
  }

  /// [TokenVault.read] must not throw; a faulty implementation is treated
  /// as unavailable rather than as a missing session.
  Future<VaultResult> _readVault() async {
    try {
      return await _vault.read();
    } on Object catch (error) {
      return VaultUnavailable(error);
    }
  }

  Future<CurrentUser> _fetchMe(String token) async {
    const endpoint = GiEndpoints.authMe;
    return decodeResponse<CurrentUser>(
      endpoint,
      await _send(endpoint, headers: _bearer(token)),
      (json) => CurrentUser.fromJson(asJsonObject(json)),
      mode: _decodeMode,
      encode: (user) => user.toJson(),
    );
  }

  Future<Response<Object?>> _send(
    Endpoint endpoint, {
    Object? data,
    Map<String, Object?>? headers,
  }) async {
    try {
      return await sendEndpoint(_dio, endpoint, data: data, headers: headers);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Persists [cookie]. If the store fails, the session continues from
  /// memory and the stale cookie is removed, because replaying it on the next
  /// cold start would be detected as reuse and revoke the session.
  Future<void> _persist(RefreshCookie cookie) async {
    _cookie = cookie;
    try {
      await _vault.write(cookie);
    } on Object {
      try {
        await _vault.clear();
      } on Object {
        // Nothing more can be done; the next refresh still uses memory.
      }
    }
  }

  Future<void> _lose(SessionLostReason reason) async {
    await _wipeLocal();
    if (!_loggingOut) _setState(AuthState.sessionLost(reason));
  }

  Future<void> _wipeLocal() async {
    _access = null;
    _cookie = null;
    _ambiguous = false;
    _applianceCheckedAt = null;
    try {
      await _vault.clear(); // The cookie and the access token.
    } on Object {
      // The server-side session is already gone or going; a leftover cookie
      // is rejected on its next use. The token goes on its own if it can.
      await _clearPersistedAccess();
    }
  }

  void _setState(AuthState next) {
    if (next == _state) return;
    _state = next;
    if (!_states.isClosed) _states.add(next);
  }

  static Map<String, Object?> _bearer(String token) => {
    'authorization': 'Bearer $token',
  };

  static List<String> _setCookies(Response<Object?> response) =>
      response.headers['set-cookie'] ?? const [];

  static DateTime _utcNow() => DateTime.now().toUtc();
}

/// An access token and when it was obtained on both clocks.
///
/// The monotonic clock ignores wall-clock jumps but may stop while the
/// device is suspended (CLOCK_MONOTONIC on Android, mach_absolute_time on
/// iOS); the wall clock keeps counting through sleep. The shorter of the two
/// remaining times wins, so sleep never makes an expired token look valid
/// and a wall-clock jump only causes an early refresh.
final class _AccessToken {
  new(
    this.value, {
    required this.ttl,
    required this.obtainedAt,
    required this.obtainedAtWall,
  });

  final String value;
  final Duration ttl;
  final Duration obtainedAt;
  final DateTime obtainedAtWall;

  Duration remaining(Duration monotonicNow, DateTime wallNow) {
    final byMonotonic = ttl - (monotonicNow - obtainedAt);
    final byWall = ttl - wallNow.difference(obtainedAtWall);
    return byMonotonic < byWall ? byMonotonic : byWall;
  }
}
