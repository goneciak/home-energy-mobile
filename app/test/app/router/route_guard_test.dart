import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';

RouteGuardState guard({
  bool hasProfile = true,
  bool initialized = true,
  SessionPhase session = SessionPhase.signedIn,
  bool mustChangePassword = false,
}) => RouteGuardState(
  hasProfile: hasProfile,
  applianceInitialized: initialized,
  session: session,
  mustChangePassword: mustChangePassword,
);

const List<String> allLocations = [
  AppRoutes.connect,
  AppRoutes.setupRequired,
  AppRoutes.restore,
  AppRoutes.login,
  AppRoutes.changePassword,
  AppRoutes.recover,
  AppRoutes.home,
  AppRoutes.settings,
];

/// Follows redirects from [location] and fails on a loop.
String settle(RouteGuardState state, String location) {
  final seen = <String>{location};
  var current = location;
  while (true) {
    final next = resolveRedirect(state, current);
    if (next == null) return current;
    expect(seen.add(next), isTrue, reason: 'redirect loop via $next');
    current = next;
  }
}

void main() {
  group('resolveRedirect', () {
    test('no profile → connect, whatever else is true', () {
      final state = guard(hasProfile: false, initialized: false);
      expect(resolveRedirect(state, AppRoutes.home), AppRoutes.connect);
      expect(resolveRedirect(state, AppRoutes.login), AppRoutes.connect);
      expect(resolveRedirect(state, AppRoutes.connect), isNull);
    });

    test('password recovery stays open only while signed out', () {
      expect(
        resolveRedirect(
          guard(session: SessionPhase.signedOut),
          AppRoutes.recover,
        ),
        isNull,
      );
      expect(resolveRedirect(guard(), AppRoutes.recover), AppRoutes.home);
      expect(
        resolveRedirect(
          guard(session: SessionPhase.restoring),
          AppRoutes.recover,
        ),
        AppRoutes.restore,
      );
      expect(
        resolveRedirect(guard(initialized: false), AppRoutes.recover),
        AppRoutes.setupRequired,
      );
    });

    test('appliance not set up → setup required, before the session', () {
      final state = guard(initialized: false, session: SessionPhase.signedOut);
      expect(resolveRedirect(state, AppRoutes.home), AppRoutes.setupRequired);
      expect(resolveRedirect(state, AppRoutes.login), AppRoutes.setupRequired);
      expect(resolveRedirect(state, AppRoutes.setupRequired), isNull);
    });

    test('restoring or failed restore → restore screen', () {
      for (final phase in [
        SessionPhase.restoring,
        SessionPhase.restoreFailed,
      ]) {
        final state = guard(session: phase);
        expect(resolveRedirect(state, AppRoutes.home), AppRoutes.restore);
        expect(resolveRedirect(state, AppRoutes.restore), isNull);
      }
    });

    test('"Znajdź GI Home" stays open in every phase while a profile '
        'exists', () {
      for (final phase in SessionPhase.values) {
        for (final initialized in [true, false]) {
          expect(
            resolveRedirect(
              guard(session: phase, initialized: initialized),
              AppRoutes.findAppliance,
            ),
            isNull,
            reason: '$phase, initialized: $initialized',
          );
        }
      }
      expect(
        resolveRedirect(guard(hasProfile: false), AppRoutes.findAppliance),
        AppRoutes.connect,
      );
    });

    test('signed out → login', () {
      final state = guard(session: SessionPhase.signedOut);
      expect(resolveRedirect(state, AppRoutes.home), AppRoutes.login);
      expect(resolveRedirect(state, AppRoutes.connect), AppRoutes.login);
      expect(resolveRedirect(state, AppRoutes.login), isNull);
    });

    test('mustChangePassword → change password, shell unreachable', () {
      final state = guard(mustChangePassword: true);
      expect(resolveRedirect(state, AppRoutes.home), AppRoutes.changePassword);
      expect(
        resolveRedirect(state, AppRoutes.settings),
        '${AppRoutes.changePassword}?from=%2Fsettings',
      );
      expect(resolveRedirect(state, AppRoutes.changePassword), isNull);
    });

    test('signed in: gates go home, shell tabs stay', () {
      final state = guard();
      for (final gate in AppRoutes.gates) {
        expect(resolveRedirect(state, gate), AppRoutes.home);
      }
      expect(resolveRedirect(state, AppRoutes.home), isNull);
      expect(resolveRedirect(state, AppRoutes.settings), isNull);
    });

    test('a stopped shell location is reopened after the gates', () {
      final device = AppRoutes.device('341584fe-d238');
      final atRestore = resolveRedirect(
        guard(session: SessionPhase.restoring),
        device,
      )!;
      expect(atRestore, '/restore?from=${Uri.encodeQueryComponent(device)}');

      // It survives restore → login → change password …
      final atLogin = resolveRedirect(
        guard(session: SessionPhase.signedOut),
        atRestore,
      )!;
      expect(Uri.parse(atLogin).path, AppRoutes.login);
      final atChange = resolveRedirect(
        guard(mustChangePassword: true),
        atLogin,
      )!;
      expect(Uri.parse(atChange).path, AppRoutes.changePassword);
      expect(
        resolveRedirect(guard(mustChangePassword: true), atChange),
        isNull,
      );

      // … and is opened once signed in.
      expect(resolveRedirect(guard(), atChange), device);
      expect(
        resolveRedirect(
          guard(session: SessionPhase.signedOut),
          AppRoutes.settings,
        ),
        '/login?from=%2Fsettings',
      );
    });

    test('only shell paths are reopened; Home needs no parameter', () {
      for (final from in [
        'https://example.com/home',
        '//example.com/home',
        AppRoutes.connect,
        '/unknown',
      ]) {
        final login = '/login?from=${Uri.encodeQueryComponent(from)}';
        expect(resolveRedirect(guard(), login), AppRoutes.home, reason: from);
      }
      expect(
        resolveRedirect(guard(session: SessionPhase.restoring), AppRoutes.home),
        AppRoutes.restore,
      );
    });

    test('never loops for any state and starting location', () {
      for (final hasProfile in [true, false]) {
        for (final initialized in [true, false]) {
          for (final session in SessionPhase.values) {
            for (final mustChange in [true, false]) {
              final state = guard(
                hasProfile: hasProfile,
                initialized: initialized,
                session: session,
                mustChangePassword: mustChange,
              );
              for (final location in [
                ...allLocations,
                AppRoutes.device('d1'),
                '/login?from=%2Fsettings',
              ]) {
                final target = settle(state, location);
                expect(resolveRedirect(state, target), isNull);
              }
            }
          }
        }
      }
    });
  });

  group('SessionPhase.of', () {
    const user = CurrentUser(
      id: 'u1',
      email: 'owner@gihome.test',
      firstName: 'Dev',
      mustChangePassword: false,
    );

    test('maps the session notifier state', () {
      expect(
        SessionPhase.of(const AsyncLoading<AuthState>()),
        SessionPhase.restoring,
      );
      expect(
        SessionPhase.of(
          const AsyncError<AuthState>(
            ApiFailure.unreachable(),
            StackTrace.empty,
          ),
        ),
        SessionPhase.restoreFailed,
      );
      expect(
        SessionPhase.of(const AsyncData(AuthState.unauthenticated())),
        SessionPhase.signedOut,
      );
      expect(
        SessionPhase.of(
          const AsyncData(
            AuthState.sessionLost(SessionLostReason.sessionRevoked),
          ),
        ),
        SessionPhase.signedOut,
      );
      expect(
        SessionPhase.of(const AsyncData(AuthState.authenticated(user))),
        SessionPhase.signedIn,
      );
      expect(
        SessionPhase.of(const AsyncData(AuthState.unknown())),
        SessionPhase.restoring,
      );
    });
  });
}
