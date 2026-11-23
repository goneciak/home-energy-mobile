@Tags(['golden'])
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/account/application/account_controllers.dart';
import 'package:gi_home/src/features/account/application/account_providers.dart';
import 'package:gi_home/src/features/account/presentation/account_screen.dart';
import 'package:gi_home/src/features/account/presentation/recovery_code_screen.dart';
import 'package:gi_home/src/features/account/presentation/recovery_reset_screen.dart';
import 'package:gi_home/src/features/account/presentation/sessions_screen.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';

import '../support/account_fixtures.dart';
import '../support/golden.dart';

/// Account screens (plan §17.1, §20 M3.5): the profile, the session list,
/// a recovery code on display (a placeholder, never a real code) and the
/// recovery reset form.
void main() {
  final script = AccountScript();

  screenGoldens(
    'Account: profile',
    fileName: 'account_profile',
    screen: AccountScreen.new,
    overrides: () => [
      currentUserProvider.overrideWithValue(testAccountUser),
      userProfileProvider.overrideWith((ref) async => testAccountProfile),
      ...fakeAccountControllers(script),
    ],
  );

  screenGoldens(
    'Account: sessions',
    fileName: 'account_sessions',
    screen: SessionsScreen.new,
    overrides: () => [
      authSessionsProvider.overrideWith((ref) async => testSessions),
      ...fakeAccountControllers(script),
    ],
  );

  screenGoldens(
    'Account: recovery code shown once',
    fileName: 'account_recovery_code',
    screen: RecoveryCodeScreen.new,
    overrides: () => fakeAccountControllers(
      script,
      shownCode: const RecoveryCodeResult(
        recoveryCode: placeholderRecoveryCode,
      ),
    ),
  );

  screenGoldens(
    'Account: recovery reset form',
    fileName: 'account_recovery_reset',
    screen: RecoveryResetScreen.new,
    overrides: () => fakeAccountControllers(script),
  );

  screenGoldens(
    'Account: sessions unreachable',
    fileName: 'account_sessions_error',
    screen: SessionsScreen.new,
    overrides: () => [
      authSessionsProvider.overrideWith(
        (ref) =>
            Future<List<AuthSessionInfo>>.error(const ApiFailure.unreachable()),
      ),
      ...fakeAccountControllers(script),
    ],
  );

  screenGoldens(
    'Account: sessions loading',
    fileName: 'account_sessions_loading',
    screen: SessionsScreen.new,
    settle: (tester) => tester.pump(const Duration(milliseconds: 50)),
    overrides: () => [
      authSessionsProvider.overrideWith(
        (ref) => Completer<List<AuthSessionInfo>>().future,
      ),
      ...fakeAccountControllers(script),
    ],
  );
}
