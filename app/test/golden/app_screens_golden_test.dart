@Tags(['golden'])
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/presentation/setup_required_screen.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/auth/application/change_password_controller.dart';
import 'package:gi_home/src/features/auth/presentation/change_password_screen.dart';
import 'package:gi_home/src/features/auth/presentation/session_restore_screen.dart';
import 'package:gi_home/src/features/experimental/presentation/experimental_features_screen.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';
import 'package:gi_home/src/features/settings/domain/session_expiry.dart';
import 'package:gi_home/src/features/settings/presentation/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/account_fixtures.dart';
import '../support/golden.dart';
import '../support/test_app.dart';

/// The session is still being restored on start.
class _Restoring extends AuthSessionNotifier {
  @override
  Future<AuthState> build() => Completer<AuthState>().future;
}

/// Restoring failed with [failure]; the session is kept for a retry.
class _RestoreFailed extends AuthSessionNotifier {
  new(this.failure);

  final ApiFailure failure;

  @override
  Future<AuthState> build() => Future<AuthState>.error(failure);
}

/// The new password was rejected.
class _RejectedPassword extends ChangePasswordController {
  @override
  AsyncValue<ChangePasswordResult?> build() => const AsyncError(
    ApiFailure.unauthorized(code: 'AUTH_INVALID_CREDENTIALS'),
    StackTrace.empty,
  );
}

/// Settings, the restore and set-up screens, the change-password form and
/// the hidden experimental screen at every size and text scale (M4
/// accessibility audit).
void main() {
  late SharedPreferencesWithCache prefs;

  Future<void> prepare(WidgetTester tester, {bool initialized = true}) async {
    prefs = (await tester.runAsync(
      () => inMemoryPreferences(
        profile: initialized
            ? testProfile
            : testProfile.copyWith(initializedAt: null),
      ),
    ))!;
  }

  screenGoldens(
    'Settings: owner signed in',
    fileName: 'settings_owner',
    screen: SettingsScreen.new,
    prepare: prepare,
    overrides: () => [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appInfoProvider.overrideWithValue(testAppInfo),
      currentUserProvider.overrideWithValue(testAccountUser),
      sessionExpiryProvider.overrideWithValue(
        SessionExpiry.of(DateTime(2026, 11, 20, 8), now: goldenNow),
      ),
      applianceRunningVersionProvider.overrideWith((ref) async => '1.4.2'),
      systemSettingsProvider.overrideWith((ref) async => null),
    ],
  );

  screenGoldens(
    'Session restore: connecting',
    fileName: 'session_restore_connecting',
    screen: SessionRestoreScreen.new,
    prepare: prepare,
    settle: (tester) => tester.pump(const Duration(milliseconds: 50)),
    overrides: () => [
      sharedPreferencesProvider.overrideWithValue(prefs),
      authSessionProvider.overrideWith(_Restoring.new),
    ],
  );

  screenGoldens(
    'Session restore: appliance unreachable',
    fileName: 'session_restore_unreachable',
    screen: SessionRestoreScreen.new,
    prepare: prepare,
    overrides: () => [
      sharedPreferencesProvider.overrideWithValue(prefs),
      clockProvider.overrideWithValue(() => goldenNow),
      authSessionProvider.overrideWith(
        () => _RestoreFailed(const ApiFailure.unreachable()),
      ),
    ],
  );

  screenGoldens(
    'Session restore: secure storage unavailable',
    fileName: 'session_restore_vault',
    screen: SessionRestoreScreen.new,
    prepare: prepare,
    overrides: () => [
      sharedPreferencesProvider.overrideWithValue(prefs),
      authSessionProvider.overrideWith(
        () => _RestoreFailed(const ApiFailure.vaultUnavailable()),
      ),
    ],
  );

  screenGoldens(
    'Change password: form',
    fileName: 'change_password_form',
    screen: ChangePasswordScreen.new,
  );

  screenGoldens(
    'Change password: rejected',
    fileName: 'change_password_error',
    screen: ChangePasswordScreen.new,
    overrides: () => [
      changePasswordControllerProvider.overrideWith(_RejectedPassword.new),
    ],
  );

  screenGoldens(
    'Setup required: dev flavor',
    fileName: 'setup_required_dev',
    screen: SetupRequiredScreen.new,
    prepare: (tester) => prepare(tester, initialized: false),
    overrides: () => [
      appConfigProvider.overrideWithValue(testConfig(AppFlavor.dev)),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  screenGoldens(
    'Setup required: prod flavor',
    fileName: 'setup_required_prod',
    screen: SetupRequiredScreen.new,
    prepare: (tester) => prepare(tester, initialized: false),
    overrides: () => [
      appConfigProvider.overrideWithValue(testConfig(AppFlavor.prod)),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  screenGoldens(
    'Experimental features',
    fileName: 'experimental_features',
    screen: ExperimentalFeaturesScreen.new,
    prepare: prepare,
    overrides: () => [
      appConfigProvider.overrideWithValue(testConfig(AppFlavor.dev)),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
}
