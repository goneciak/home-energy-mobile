import 'package:flutter/foundation.dart';
import 'package:gi_home/src/app/router/app_shell.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/presentation/connect_screen.dart';
import 'package:gi_home/src/features/appliance/presentation/setup_required_screen.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/auth/presentation/change_password_screen.dart';
import 'package:gi_home/src/features/auth/presentation/login_screen.dart';
import 'package:gi_home/src/features/auth/presentation/session_restore_screen.dart';
import 'package:gi_home/src/features/devices/presentation/device_detail_screen.dart';
import 'package:gi_home/src/features/experimental/presentation/experimental_features_screen.dart';
import 'package:gi_home/src/features/home/presentation/home_screen.dart';
import 'package:gi_home/src/features/settings/presentation/settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Inputs of the redirect, derived from the profile and the session.
@Riverpod(keepAlive: true)
RouteGuardState routeGuardState(Ref ref) {
  final profile = ref.watch(applianceProfileProvider);
  final auth = ref.watch(authSessionProvider);
  return RouteGuardState(
    hasProfile: profile != null,
    applianceInitialized: profile?.isInitialized ?? false,
    session: SessionPhase.of(auth),
    mustChangePassword:
        ref.watch(currentUserProvider)?.mustChangePassword ?? false,
  );
}

/// The app router. It is created once; guard changes re-run the redirect
/// through the router's `refreshListenable` instead of rebuilding it.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final guardChanged = ValueNotifier(ref.read(routeGuardStateProvider));
  ref.listen(routeGuardStateProvider, (_, next) => guardChanged.value = next);
  // The flavor is fixed for the life of the app.
  final flavor = ref.read(appFlavorProvider);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: guardChanged,
    redirect: (context, state) =>
        resolveRedirect(guardChanged.value, state.uri.toString()),
    routes: [
      GoRoute(
        path: AppRoutes.connect,
        builder: (context, state) => const ConnectScreen(),
      ),
      GoRoute(
        path: AppRoutes.findAppliance,
        // Confirming leaves for Home; the guards then pick the gate.
        builder: (context, state) =>
            ConnectScreen(onConnected: (context) => context.go(AppRoutes.home)),
      ),
      GoRoute(
        path: AppRoutes.setupRequired,
        builder: (context, state) => const SetupRequiredScreen(),
      ),
      GoRoute(
        path: AppRoutes.restore,
        builder: (context, state) => const SessionRestoreScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'devices/:id',
                    builder: (context, state) => DeviceDetailScreen(
                      deviceId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'experimental',
                    // Prod has no experimental features, not even by link.
                    redirect: (context, state) =>
                        flavor.allowsFlagOverrides ? null : AppRoutes.settings,
                    builder: (context, state) =>
                        const ExperimentalFeaturesScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    guardChanged.dispose();
  });
  return router;
}
