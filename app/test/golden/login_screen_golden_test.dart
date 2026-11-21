@Tags(['golden'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/auth/application/login_controller.dart';
import 'package:gi_home/src/features/auth/presentation/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/golden.dart';
import '../support/test_app.dart';

/// Nobody is signed in.
class _SignedOut extends AuthSessionNotifier {
  @override
  Future<AuthState> build() async => const AuthState.unauthenticated();
}

/// The last submission was rejected with [failure].
class _FailedLogin extends LoginController {
  new(this.failure);

  final ApiFailure failure;

  @override
  AsyncValue<void> build() => AsyncError(failure, StackTrace.empty);
}

/// Logging in (plan §17.1): the empty form and a rejected password.
void main() {
  late SharedPreferencesWithCache prefs;

  void loginGoldens(
    String description, {
    required String fileName,
    String? lastUserEmail,
    ApiFailure? failure,
  }) => screenGoldens(
    description,
    fileName: fileName,
    screen: LoginScreen.new,
    prepare: (tester) async {
      prefs = (await tester.runAsync(
        () => inMemoryPreferences(
          profile: testProfile.copyWith(lastUserEmail: lastUserEmail),
        ),
      ))!;
    },
    overrides: () => [
      sharedPreferencesProvider.overrideWithValue(prefs),
      authSessionProvider.overrideWith(_SignedOut.new),
      if (failure != null)
        loginControllerProvider.overrideWith(() => _FailedLogin(failure)),
    ],
  );

  loginGoldens('Login: empty form', fileName: 'login_empty');

  loginGoldens(
    'Login: invalid credentials',
    fileName: 'login_error',
    lastUserEmail: 'owner@gihome.test',
    failure: const ApiFailure.unauthorized(code: 'AUTH_INVALID_CREDENTIALS'),
  );
}
