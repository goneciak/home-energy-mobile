import 'package:gi_core_api/src/catalog/endpoint.dart';
import 'package:gi_core_api/src/models/enums.dart';

const _public = <UserRole>{};
const Set<UserRole> _anyRole = {
  UserRole.owner,
  UserRole.admin,
  UserRole.user,
  UserRole.service,
};

/// Device control and appliance administration (`WRITE_ROLES` in
/// `devices.controller.ts`).
const Set<UserRole> _writeRoles = {UserRole.owner, UserRole.admin};

/// MVP endpoint catalog (plan §4.1, §6.2). Paths are relative to `/api/v1`.
abstract final class GiEndpoints {
  static const healthLive = Endpoint(
    id: 'HealthController_live',
    method: HttpMethod.get,
    path: '/health/live',
    roles: _public,
    timeout: TimeoutClass.read,
    milestone: Milestone.m1,
    feature: 'connect',
  );

  static const setupStatus = Endpoint(
    id: 'SetupController_getStatus',
    method: HttpMethod.get,
    path: '/setup/status',
    roles: _public,
    timeout: TimeoutClass.read,
    milestone: Milestone.m1,
    feature: 'connect',
    maxRetries: 2,
  );

  /// Rate limited to 5 attempts per minute per IP; never refreshes.
  static const authLogin = Endpoint(
    id: 'AuthController_login',
    method: HttpMethod.post,
    path: '/auth/login',
    roles: _public,
    timeout: TimeoutClass.write,
    milestone: Milestone.m1,
    feature: 'auth',
  );

  /// Cookie-only; owned exclusively by `AuthSessionManager`.
  static const authRefresh = Endpoint(
    id: 'AuthController_refresh',
    method: HttpMethod.post,
    path: '/auth/refresh',
    roles: _public,
    timeout: TimeoutClass.refresh,
    milestone: Milestone.m1,
    feature: 'session',
    refreshCookie: true,
  );

  static const authLogout = Endpoint(
    id: 'AuthController_logout',
    method: HttpMethod.post,
    path: '/auth/logout',
    roles: _anyRole,
    timeout: TimeoutClass.write,
    milestone: Milestone.m1,
    feature: 'settings',
  );

  static const authMe = Endpoint(
    id: 'AuthController_getMe',
    method: HttpMethod.get,
    path: '/auth/me',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m1,
    feature: 'session',
    maxRetries: 2,
  );

  static const usersMeProfile = Endpoint(
    id: 'UsersController_getProfile',
    method: HttpMethod.get,
    path: '/users/me/profile',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m1,
    feature: 'session',
    maxRetries: 2,
  );

  static const usersMeChangePassword = Endpoint(
    id: 'UsersController_changePassword',
    method: HttpMethod.post,
    path: '/users/me/change-password',
    roles: _anyRole,
    timeout: TimeoutClass.write,
    milestone: Milestone.m1,
    feature: 'password',
  );

  static const roomsList = Endpoint(
    id: 'RoomsController_list',
    method: HttpMethod.get,
    path: '/rooms',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m1,
    feature: 'home',
    maxRetries: 2,
  );

  /// Called with `?limit=100` (the server maximum).
  static const devicesList = Endpoint(
    id: 'DevicesController_list',
    method: HttpMethod.get,
    path: '/devices',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m1,
    feature: 'home',
    maxRetries: 2,
  );

  static const devicesDetail = Endpoint(
    id: 'DevicesController_get',
    method: HttpMethod.get,
    path: '/devices/{id}',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m1,
    feature: 'device',
    maxRetries: 2,
  );

  /// `GET /settings/system`: device name, locale and timezone.
  static const settingsSystem = Endpoint(
    id: 'SettingsController_getSystem',
    method: HttpMethod.get,
    path: '/settings/system',
    roles: {UserRole.owner, UserRole.admin, UserRole.service},
    timeout: TimeoutClass.read,
    milestone: Milestone.m2,
    feature: 'settings',
    maxRetries: 2,
  );

  /// `GET /appliance/updates/status`: last update check, the source of the
  /// best-effort running version (plan §16).
  static const applianceUpdatesStatus = Endpoint(
    id: 'ApplianceUpdateController_getStatus',
    method: HttpMethod.get,
    path: '/appliance/updates/status',
    roles: _writeRoles,
    timeout: TimeoutClass.read,
    milestone: Milestone.m2,
    feature: 'settings',
    maxRetries: 2,
  );

  /// `PUT /devices/:id/entities/:entityId/state` with `{"state": bool}`
  /// (plan §12.2). Not idempotent from the user's point of view: never
  /// retried, never queued.
  static const setSwitchState = Endpoint(
    id: 'DeviceEspHomeSyncController_setSwitchState',
    method: HttpMethod.put,
    path: '/devices/{id}/entities/{entityId}/state',
    roles: _writeRoles,
    timeout: TimeoutClass.write,
    milestone: Milestone.m2,
    feature: 'device',
  );

  /// `PATCH /devices/:id`; the app only sends `{"heatingSuspended": bool}`
  /// (plan §12.1).
  static const updateDevice = Endpoint(
    id: 'DevicesController_update',
    method: HttpMethod.patch,
    path: '/devices/{id}',
    roles: _writeRoles,
    timeout: TimeoutClass.write,
    milestone: Milestone.m2,
    feature: 'device',
  );

  /// `PATCH /devices/:id/control-strategy` (plan §12.5).
  static const updateControlStrategy = Endpoint(
    id: 'DevicesController_updateControlStrategy',
    method: HttpMethod.patch,
    path: '/devices/{id}/control-strategy',
    roles: _writeRoles,
    timeout: TimeoutClass.write,
    milestone: Milestone.m2,
    feature: 'device',
  );

  /// `GET /devices/:deviceId/schedules`: plain array, oldest first. Also a
  /// cheap feature probe (plan §16).
  static const schedulesList = Endpoint(
    id: 'HeatingScheduleController_list',
    method: HttpMethod.get,
    path: '/devices/{id}/schedules',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m3,
    feature: 'schedules',
    maxRetries: 2,
  );

  /// `POST /devices/:deviceId/schedules`: 201 with the new row.
  static const scheduleCreate = Endpoint(
    id: 'HeatingScheduleController_create',
    method: HttpMethod.post,
    path: '/devices/{id}/schedules',
    roles: _writeRoles,
    timeout: TimeoutClass.write,
    milestone: Milestone.m3,
    feature: 'schedules',
  );

  /// `PATCH /devices/:deviceId/schedules/:scheduleId`: 200 with the row.
  static const scheduleUpdate = Endpoint(
    id: 'HeatingScheduleController_update',
    method: HttpMethod.patch,
    path: '/devices/{id}/schedules/{scheduleId}',
    roles: _writeRoles,
    timeout: TimeoutClass.write,
    milestone: Milestone.m3,
    feature: 'schedules',
  );

  /// `DELETE /devices/:deviceId/schedules/:scheduleId`: 204, empty body.
  static const scheduleRemove = Endpoint(
    id: 'HeatingScheduleController_remove',
    method: HttpMethod.delete,
    path: '/devices/{id}/schedules/{scheduleId}',
    roles: _writeRoles,
    timeout: TimeoutClass.write,
    milestone: Milestone.m3,
    feature: 'schedules',
  );

  /// `GET /weather/current`. 503 `HTTP_503` means "no data yet", not an
  /// outage, so it is not retried. Never probe weather by status code.
  static const weatherCurrent = Endpoint(
    id: 'EnvironmentController_current',
    method: HttpMethod.get,
    path: '/weather/current',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m3,
    feature: 'weather',
  );

  /// `GET /weather/hourly` (at most 72 rows). 503 = no data.
  static const weatherHourly = Endpoint(
    id: 'EnvironmentController_hourly',
    method: HttpMethod.get,
    path: '/weather/hourly',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m3,
    feature: 'weather',
  );

  /// `GET /weather/daily`. 503 = no data.
  static const weatherDaily = Endpoint(
    id: 'EnvironmentController_daily',
    method: HttpMethod.get,
    path: '/weather/daily',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m3,
    feature: 'weather',
  );

  /// `GET /solar/current`. 400 `HTTP_400` = no house coordinates.
  static const solarCurrent = Endpoint(
    id: 'EnvironmentController_solarCurrent',
    method: HttpMethod.get,
    path: '/solar/current',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m3,
    feature: 'weather',
    maxRetries: 2,
  );

  /// `GET /pv/forecast`. 400 = no coordinates or no PV; 500 = Open-Meteo
  /// failed (no data). Not retried: a 5xx here is an upstream failure.
  static const pvForecast = Endpoint(
    id: 'EnvironmentController_pvForecast',
    method: HttpMethod.get,
    path: '/pv/forecast',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m3,
    feature: 'weather',
  );

  /// `GET /devices/:id/pv-heating-plan`; never fails for a missing PV setup.
  static const pvHeatingPlan = Endpoint(
    id: 'PvHeatingController_getPlan',
    method: HttpMethod.get,
    path: '/devices/{id}/pv-heating-plan',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m3,
    feature: 'device',
    maxRetries: 2,
  );

  /// `GET /devices/:deviceId/entities/:entityId/history?from=&to=&limit=`.
  static const entityHistory = Endpoint(
    id: 'HistoryController_getEntityHistory',
    method: HttpMethod.get,
    path: '/devices/{id}/entities/{entityId}/history',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m3,
    feature: 'history',
    maxRetries: 2,
  );

  /// `GET /auth/sessions`: the user's live sessions, newest first; `current`
  /// marks this phone. Also a cheap feature probe (plan §16).
  static const authSessionsList = Endpoint(
    id: 'AuthController_listSessions',
    method: HttpMethod.get,
    path: '/auth/sessions',
    roles: _anyRole,
    timeout: TimeoutClass.read,
    milestone: Milestone.m3,
    feature: 'sessions',
    maxRetries: 2,
  );

  /// `DELETE /auth/sessions/:sessionId`: 204, idempotent. Revoking the
  /// current session ends it locally too.
  static const authSessionRevoke = Endpoint(
    id: 'AuthController_revokeSession',
    method: HttpMethod.delete,
    path: '/auth/sessions/{sessionId}',
    roles: _anyRole,
    timeout: TimeoutClass.write,
    milestone: Milestone.m3,
    feature: 'sessions',
  );

  /// `POST /auth/logout-all`: 204; revokes every session of the user,
  /// including this one, so the client logs out locally.
  static const authLogoutAll = Endpoint(
    id: 'AuthController_logoutAll',
    method: HttpMethod.post,
    path: '/auth/logout-all',
    roles: _anyRole,
    timeout: TimeoutClass.write,
    milestone: Milestone.m3,
    feature: 'sessions',
  );

  /// `POST /auth/recovery/regenerate`: 200 `{recoveryCode}`, shown once;
  /// the previous code stops working.
  static const authRecoveryRegenerate = Endpoint(
    id: 'AuthController_regenerateRecoveryCode',
    method: HttpMethod.post,
    path: '/auth/recovery/regenerate',
    roles: _anyRole,
    timeout: TimeoutClass.write,
    milestone: Milestone.m3,
    feature: 'recovery',
  );

  /// `POST /auth/recovery/reset` (public): 204; revokes every session of the
  /// user. Throttled to 5 requests per 15 minutes (429 `HTTP_429`).
  static const authRecoveryReset = Endpoint(
    id: 'AuthController_recoveryReset',
    method: HttpMethod.post,
    path: '/auth/recovery/reset',
    roles: _public,
    timeout: TimeoutClass.write,
    milestone: Milestone.m3,
    feature: 'recovery',
  );

  /// `PATCH /users/me/profile`: 200 with the profile (plan §13.2).
  static const usersMeProfileUpdate = Endpoint(
    id: 'UsersController_updateProfile',
    method: HttpMethod.patch,
    path: '/users/me/profile',
    roles: _anyRole,
    timeout: TimeoutClass.write,
    milestone: Milestone.m3,
    feature: 'settings',
  );

  static const all = <Endpoint>[
    healthLive,
    setupStatus,
    authLogin,
    authRefresh,
    authLogout,
    authMe,
    usersMeProfile,
    usersMeChangePassword,
    roomsList,
    devicesList,
    devicesDetail,
    settingsSystem,
    applianceUpdatesStatus,
    setSwitchState,
    updateDevice,
    updateControlStrategy,
    schedulesList,
    scheduleCreate,
    scheduleUpdate,
    scheduleRemove,
    weatherCurrent,
    weatherHourly,
    weatherDaily,
    solarCurrent,
    pvForecast,
    pvHeatingPlan,
    entityHistory,
    authSessionsList,
    authSessionRevoke,
    authLogoutAll,
    authRecoveryRegenerate,
    authRecoveryReset,
    usersMeProfileUpdate,
  ];
}
