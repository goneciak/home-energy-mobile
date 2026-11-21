import 'package:dio/dio.dart';

import 'package:gi_core_api/src/auth/auth_session_manager.dart';
import 'package:gi_core_api/src/auth/auth_state.dart';
import 'package:gi_core_api/src/auth/monotonic_clock.dart';
import 'package:gi_core_api/src/auth/token_vault.dart';
import 'package:gi_core_api/src/catalog/endpoint.dart';
import 'package:gi_core_api/src/catalog/endpoints.dart';
import 'package:gi_core_api/src/converters/json_converters.dart';
import 'package:gi_core_api/src/failures/api_failure.dart';
import 'package:gi_core_api/src/failures/failure_mapping.dart';
import 'package:gi_core_api/src/failures/failure_observer.dart';
import 'package:gi_core_api/src/http/client_info.dart';
import 'package:gi_core_api/src/http/concurrency_limiter.dart';
import 'package:gi_core_api/src/http/dio_factory.dart';
import 'package:gi_core_api/src/http/interceptors.dart';
import 'package:gi_core_api/src/http/response_decoding.dart';
import 'package:gi_core_api/src/models/auth_models.dart';
import 'package:gi_core_api/src/models/device_commands.dart';
import 'package:gi_core_api/src/models/device_detail.dart';
import 'package:gi_core_api/src/models/device_list_item.dart';
import 'package:gi_core_api/src/models/enums.dart';
import 'package:gi_core_api/src/models/room.dart';
import 'package:gi_core_api/src/models/system_models.dart';
import 'package:gi_core_api/src/models/user_models.dart';
import 'package:gi_core_api/src/probe/appliance_address.dart';

/// Delay before automatic retry number [attempt] (0-based).
typedef RetryBackoff = Duration Function(int attempt);

/// Typed client for the MVP subset of the GI Core API (`/api/v1`).
///
/// Every method throws [ApiFailure] and nothing else. Idempotent reads are
/// retried up to their catalog limit after transient failures; writes never
/// are, apart from the single replay after a 401 refresh.
///
/// At most [ConcurrencyLimiter.perApplianceRequests] requests of one client
/// (session calls included) are on the wire at once (plan §11); the rest
/// queue in arrival order.
final class GiCoreClient {
  new _(
    this._dio,
    this._sessionDio,
    this.session,
    this.requestLimiter,
    this._backoff,
    this._onFailure,
    this._decodeMode,
  );

  /// Wires the session manager (own raw Dio) and the API Dio (with auth
  /// interceptor) for [address]. [onFailure] sees every [ApiFailure] a
  /// public call throws (local diagnostics).
  ///
  /// [expectedInitializedAt] and [expectedDeviceName] are the fingerprint of
  /// the stored session; [onApplianceRenamed] hears about a new device name
  /// (see [AuthSessionManager.new]).
  ///
  /// [requestLimiter] caps the requests in flight to the appliance (default:
  /// a new limiter of [ConcurrencyLimiter.perApplianceRequests]); share one
  /// only between clients of the same appliance. [localNetworkDenied]
  /// recognises a denied local-network permission. [decodeMode] defaults to
  /// [DecodeMode.tolerant]; contract tests pass [DecodeMode.strict] or
  /// [DecodeMode.fromEnvironment].
  ///
  /// [httpClientAdapter], [clock], [now] and [retryBackoff] exist for tests.
  factory create({
    required ApplianceAddress address,
    required TokenVault vault,
    required ClientInfo clientInfo,
    String Function()? acceptLanguage,
    HttpLogSink? log,
    DateTime? expectedInitializedAt,
    String? expectedDeviceName,
    ApplianceRenamed? onApplianceRenamed,
    Future<void> Function()? waitUntilForeground,
    ApiFailureObserver? onFailure,
    ConcurrencyLimiter? requestLimiter,
    LocalNetworkDeniedDetector localNetworkDenied =
        defaultLocalNetworkDeniedDetector,
    DecodeMode decodeMode = DecodeMode.tolerant,
    HttpClientAdapter? httpClientAdapter,
    MonotonicClock? clock,
    DateTime Function()? now,
    RetryBackoff? retryBackoff,
  }) {
    final limiter =
        requestLimiter ??
        ConcurrencyLimiter(ConcurrencyLimiter.perApplianceRequests);
    Dio build({AuthInterceptor? auth}) => createCoreDio(
      apiBaseUrl: address.apiBaseUrl,
      clientInfo: clientInfo,
      acceptLanguage: acceptLanguage,
      auth: auth,
      log: log,
      httpClientAdapter: httpClientAdapter,
      limiter: limiter,
      localNetworkDenied: localNetworkDenied,
    );
    final sessionDio = build();
    final session = AuthSessionManager(
      dio: sessionDio,
      vault: vault,
      clock: clock,
      now: now,
      expectedInitializedAt: expectedInitializedAt,
      expectedDeviceName: expectedDeviceName,
      onApplianceRenamed: onApplianceRenamed,
      waitUntilForeground: waitUntilForeground,
      decodeMode: decodeMode,
    );
    return GiCoreClient._(
      build(auth: AuthInterceptor(session)),
      sessionDio,
      session,
      limiter,
      retryBackoff ?? _defaultBackoff,
      onFailure,
      decodeMode,
    );
  }

  final Dio _dio;
  final Dio _sessionDio;
  final RetryBackoff _backoff;
  final ApiFailureObserver? _onFailure;
  final DecodeMode _decodeMode;
  Future<void>? _userReload;

  /// Session owner; expose [AuthSessionManager.states] to the UI.
  final AuthSessionManager session;

  /// The per-appliance cap shared by every request of this client.
  final ConcurrencyLimiter requestLimiter;

  Future<HealthLive> healthLive() => _call(
    GiEndpoints.healthLive,
    (json) => HealthLive.fromJson(asJsonObject(json)),
    (health) => health.toJson(),
  );

  Future<SetupStatus> setupStatus() => _call(
    GiEndpoints.setupStatus,
    (json) => SetupStatus.fromJson(asJsonObject(json)),
    (status) => status.toJson(),
  );

  /// See [AuthSessionManager.restore].
  Future<AuthState> restoreSession() =>
      observeFailures(_onFailure, session.restore);

  /// See [AuthSessionManager.login].
  Future<CurrentUser> login({
    required String email,
    required String password,
  }) => observeFailures(
    _onFailure,
    () => session.login(email: email, password: password),
  );

  /// See [AuthSessionManager.logout].
  Future<LogoutResult> logout() => session.logout();

  /// `GET /auth/me`; also refreshes the user held by the session state.
  Future<CurrentUser> me() async {
    final user = await _call(
      GiEndpoints.authMe,
      (json) => CurrentUser.fromJson(asJsonObject(json)),
      (user) => user.toJson(),
    );
    session.updateUser(user);
    return user;
  }

  Future<UserProfile> profile() => _call(
    GiEndpoints.usersMeProfile,
    (json) => UserProfile.fromJson(asJsonObject(json)),
    (profile) => profile.toJson(),
  );

  Future<ChangePasswordResult> changePassword(ChangePasswordRequest request) =>
      _call(
        GiEndpoints.usersMeChangePassword,
        (json) => ChangePasswordResult.fromJson(asJsonObject(json)),
        (result) => result.toJson(),
        data: request.toJson(),
      );

  Future<List<Room>> rooms() => _call(
    GiEndpoints.roomsList,
    (json) => [
      for (final room in asJsonList(json)) Room.fromJson(asJsonObject(room)),
    ],
    (rooms) => [for (final room in rooms) room.toJson()],
  );

  /// `GET /devices?page=&limit=`; [limit] is capped at 100 by the server.
  Future<ListPage<DeviceListItem>> devices({int page = 1, int limit = 100}) =>
      _call(
        GiEndpoints.devicesList,
        (json) => ListPage.fromJson(
          asJsonObject(json),
          (item) => DeviceListItem.fromJson(asJsonObject(item)),
        ),
        (list) => list.toJson((item) => item.toJson()),
        query: {'page': page, 'limit': limit},
      );

  Future<DeviceDetail> device(String id) => _call(
    GiEndpoints.devicesDetail,
    (json) => DeviceDetail.fromJson(asJsonObject(json)),
    (device) => device.toJson(),
    pathParams: {'id': id},
  );

  /// `GET /settings/system` (OWNER, ADMIN, SERVICE).
  Future<SystemSettings> systemSettings() => _call(
    GiEndpoints.settingsSystem,
    (json) => SystemSettings.fromJson(asJsonObject(json)),
    (settings) => settings.toJson(),
  );

  /// `GET /appliance/updates/status` (OWNER, ADMIN).
  Future<ApplianceUpdateStatus> applianceUpdateStatus() => _call(
    GiEndpoints.applianceUpdatesStatus,
    (json) => ApplianceUpdateStatus.fromJson(asJsonObject(json)),
    (status) => status.toJson(),
  );

  /// `PUT /devices/:deviceId/entities/:entityId/state` with exactly
  /// `{"state": state}` (OWNER, ADMIN; plan §12.2).
  ///
  /// The returned [SwitchCommandResult.state] is NOT the new state of the
  /// switch: a GI Edge device in dry-run returns its OLD value, a GI Edge
  /// device otherwise echoes the request before the controller acted, and
  /// the response never states the communication mode or the outcome. The
  /// caller must re-read the device and confirm the command its own way.
  ///
  /// Never retried automatically (only the single replay after a 401
  /// refresh): repeating a switch command is the user's decision.
  Future<SwitchCommandResult> setSwitchState(
    String deviceId,
    String entityId, {
    required bool state,
  }) => _call(
    GiEndpoints.setSwitchState,
    (json) => SwitchCommandResult.fromJson(asJsonObject(json)),
    (result) => result.toJson(),
    pathParams: {'id': deviceId, 'entityId': entityId},
    data: {'state': state},
  );

  /// `PATCH /devices/:deviceId` with ONLY `{"heatingSuspended": suspended}`
  /// (OWNER, ADMIN; plan §12.1). Returns the list-item shape
  /// (`DeviceResponseDto`: UPPERCASE status, `currentState`,
  /// `activeFaultCount`), not the details shape.
  ///
  /// The server turns the relays off and rewrites the effective strategy
  /// asynchronously after answering; confirm by re-reading the device.
  /// Never retried automatically.
  Future<DeviceListItem> setHeatingSuspended(
    String deviceId, {
    required bool suspended,
  }) => _call(
    GiEndpoints.updateDevice,
    (json) => DeviceListItem.fromJson(asJsonObject(json)),
    (device) => device.toJson(),
    pathParams: {'id': deviceId},
    data: {'heatingSuspended': suspended},
  );

  /// `PATCH /devices/:deviceId/control-strategy` (OWNER, ADMIN; plan
  /// §12.5). All three fields are sent; [targetTemperatureCelsius] must be
  /// within 0–100, [hysteresisCelsius] within 1–20 and [mode] a known mode,
  /// otherwise an [ArgumentError] is thrown before anything is sent.
  /// Never retried automatically.
  Future<ControlStrategyUpdateResult> updateControlStrategy(
    String deviceId, {
    required double targetTemperatureCelsius,
    required double hysteresisCelsius,
    required ControlStrategyMode mode,
  }) {
    _checkRange(targetTemperatureCelsius, 0, 100, 'targetTemperatureCelsius');
    _checkRange(hysteresisCelsius, 1, 20, 'hysteresisCelsius');
    if (mode == ControlStrategyMode.unknown) {
      throw ArgumentError.value(mode, 'mode', 'must be AUTO, OFF or MANUAL');
    }
    return _call(
      GiEndpoints.updateControlStrategy,
      (json) => ControlStrategyUpdateResult.fromJson(asJsonObject(json)),
      (result) => result.toJson(),
      pathParams: {'id': deviceId},
      data: {
        'targetTemperatureCelsius': targetTemperatureCelsius,
        'hysteresisCelsius': hysteresisCelsius,
        'mode': mode.name.toUpperCase(),
      },
    );
  }

  static void _checkRange(double value, int min, int max, String name) {
    if (!value.isFinite || value < min || value > max) {
      throw RangeError.range(value, min, max, name);
    }
  }

  /// Closes both HTTP clients and the session state stream.
  Future<void> close() async {
    _dio.close(force: true);
    _sessionDio.close(force: true);
    await session.dispose();
  }

  /// [encode] turns the decoded value back into JSON for
  /// [DecodeMode.strict].
  Future<T> _call<T>(
    Endpoint endpoint,
    T Function(Object? json) decode,
    Object? Function(T value) encode, {
    Map<String, String> pathParams = const {},
    Map<String, Object?>? query,
    Object? data,
  }) => observeFailures(
    _onFailure,
    () => _send(endpoint, decode, encode, pathParams, query, data),
  );

  Future<T> _send<T>(
    Endpoint endpoint,
    T Function(Object? json) decode,
    Object? Function(T value) encode,
    Map<String, String> pathParams,
    Map<String, Object?>? query,
    Object? data,
  ) async {
    for (var attempt = 0; ; attempt++) {
      try {
        final response = await sendEndpoint(
          _dio,
          endpoint,
          pathParams: pathParams,
          query: query,
          data: data,
        );
        return decodeResponse<T>(
          endpoint,
          response,
          decode,
          mode: _decodeMode,
          encode: encode,
        );
      } on DioException catch (e) {
        final failure = mapDioException(e);
        if (failure case ForbiddenFailure(code: 'HTTP_403')
            when endpoint != GiEndpoints.authMe) {
          _reloadUser();
        }
        final fromSession =
            e.requestOptions.extra[sessionFailureExtraKey] == true;
        if (fromSession ||
            !failure.isTransient ||
            attempt >= endpoint.maxRetries) {
          throw failure;
        }
        await Future<void>.delayed(_backoff(attempt));
      }
    }
  }

  /// RBAC denied a call: the role may have changed on the server, so the
  /// user is reloaded once (plan §8.2); concurrent denials share the reload
  /// and its failure only means the cached user stays.
  void _reloadUser() {
    _userReload ??= me()
        .then<void>((_) {}, onError: (Object _) {})
        .whenComplete(() => _userReload = null);
  }

  static Duration _defaultBackoff(int attempt) =>
      Duration(milliseconds: 500 * (attempt * 2 + 1));
}
