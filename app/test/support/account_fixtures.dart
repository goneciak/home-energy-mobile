import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:gi_home/src/features/account/application/account_controllers.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// A placeholder recovery code: never a real one in tests or goldens.
const placeholderRecoveryCode = 'ABCD-EF01-2345-6789-ABCD-EF01-2345-6789';

const testAccountUser = CurrentUser(
  id: 'user-owner',
  email: 'owner@gihome.test',
  firstName: 'Dev',
  lastName: 'Owner',
  mustChangePassword: false,
  role: UserRole.owner,
);

final testAccountProfile = UserProfile(
  id: 'user-owner',
  email: 'owner@gihome.test',
  firstName: 'Dev',
  lastName: 'Owner',
  locale: 'pl-PL',
  role: UserRole.owner,
  enabled: true,
  mustChangePassword: false,
  createdAt: DateTime.utc(2026, 11, 2),
  updatedAt: DateTime.utc(2026, 11, 2),
);

/// This phone, a browser and a second phone; this phone first.
final testSessions = [
  AuthSessionInfo(
    id: '11111111-1111-4111-8111-111111111111',
    createdAt: DateTime(2026, 11, 17, 8),
    expiresAt: DateTime(2026, 12, 17, 8),
    lastUsedAt: DateTime(2026, 11, 18, 7, 40),
    userAgent: 'GIHome-Mobile/0.1.0 (android; Pixel 8)',
    ipAddress: '192.168.1.20',
    current: true,
  ),
  AuthSessionInfo(
    id: '22222222-2222-4222-8222-222222222222',
    createdAt: DateTime(2026, 11, 10, 19),
    expiresAt: DateTime(2026, 12, 10, 19),
    lastUsedAt: DateTime(2026, 11, 16, 21, 5),
    userAgent:
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/131.0 Safari/537.36',
    ipAddress: '192.168.1.31',
  ),
  AuthSessionInfo(
    id: '33333333-3333-4333-8333-333333333333',
    createdAt: DateTime(2026, 11, 2, 12),
    expiresAt: DateTime(2026, 12, 2, 12),
  ),
];

/// Records what the account controllers were asked to do, and how they
/// answer: [failure] makes every call fail.
class AccountScript {
  ApiFailure? failure;
  final profileUpdates = <ProfileUpdate>[];
  final revoked = <AuthSessionInfo>[];
  int logoutAllCalls = 0;
  int regenerateCalls = 0;
  final resets = <Map<String, Object?>>[];
}

Future<void> _tick() => Future<void>.delayed(Duration.zero);

class FakeProfileEditController extends ProfileEditController {
  new(this._script);

  final AccountScript _script;

  @override
  Future<bool> save(ProfileUpdate update) async {
    _script.profileUpdates.add(update);
    state = const AsyncLoading();
    await _tick();
    final failure = _script.failure;
    state = failure == null
        ? AsyncData(testAccountProfile)
        : AsyncError(failure, StackTrace.empty);
    return failure == null;
  }
}

class FakeSessionActionsController extends SessionActionsController {
  new(this._script);

  final AccountScript _script;

  Future<bool> _answer() async {
    state = const AsyncLoading();
    await _tick();
    final failure = _script.failure;
    state = failure == null
        ? const AsyncData(null)
        : AsyncError(failure, StackTrace.empty);
    return failure == null;
  }

  @override
  Future<bool> revoke(AuthSessionInfo session) {
    _script.revoked.add(session);
    return _answer();
  }

  @override
  Future<bool> logoutAll() {
    _script.logoutAllCalls++;
    return _answer();
  }
}

class FakeRecoveryCodeController extends RecoveryCodeController {
  new(this._script, {this.initial});

  final AccountScript _script;
  final RecoveryCodeResult? initial;

  @override
  AsyncValue<RecoveryCodeResult?> build() => AsyncData(initial);

  @override
  Future<void> regenerate() async {
    _script.regenerateCalls++;
    state = const AsyncLoading();
    await _tick();
    final failure = _script.failure;
    state = failure == null
        ? const AsyncData(
            RecoveryCodeResult(recoveryCode: placeholderRecoveryCode),
          )
        : AsyncError(failure, StackTrace.empty);
  }
}

class FakeRecoveryResetController extends RecoveryResetController {
  new(this._script);

  final AccountScript _script;

  @override
  Future<void> submit(RecoveryResetRequest request) async {
    _script.resets.add(request.toJson());
    state = const AsyncLoading();
    await _tick();
    final failure = _script.failure;
    state = failure == null
        ? const AsyncData(true)
        : AsyncError(failure, StackTrace.empty);
  }
}

/// Overrides of every account controller with the fakes above.
List<Override> fakeAccountControllers(
  AccountScript script, {
  RecoveryCodeResult? shownCode,
}) => [
  profileEditControllerProvider.overrideWith(
    () => FakeProfileEditController(script),
  ),
  sessionActionsControllerProvider.overrideWith(
    () => FakeSessionActionsController(script),
  ),
  recoveryCodeControllerProvider.overrideWith(
    () => FakeRecoveryCodeController(script, initial: shownCode),
  ),
  recoveryResetControllerProvider.overrideWith(
    () => FakeRecoveryResetController(script),
  ),
];

/// [screen] at `/start` of a Polish app with a router, so pushes and pops
/// work; every other app route shows its path.
Widget accountTestApp(
  Widget Function() screen, {
  List<Override> overrides = const [],
  Locale locale = const Locale('pl'),
}) {
  Widget stub(String path) => Scaffold(body: Center(child: Text(path)));
  final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => screen()),
      for (final path in [
        AppRoutes.login,
        AppRoutes.accountPassword,
        AppRoutes.accountSessions,
        AppRoutes.accountRecoveryCode,
      ])
        GoRoute(path: path, builder: (context, state) => stub(path)),
    ],
  );
  return ProviderScope(
    retry: (retryCount, error) => null,
    overrides: overrides,
    child: MaterialApp.router(
      theme: AppTheme.dark(),
      locale: locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}
