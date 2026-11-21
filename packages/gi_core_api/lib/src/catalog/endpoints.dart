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
  ];
}
