import 'package:gi_core_api/src/catalog/endpoint.dart';
import 'package:gi_core_api/src/models/enums.dart';

const _public = <UserRole>{};
const Set<UserRole> _anyRole = {
  UserRole.owner,
  UserRole.admin,
  UserRole.user,
  UserRole.service,
};

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
  ];
}
