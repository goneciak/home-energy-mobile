import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.g.dart';

/// Submission state of the login form; errors are `ApiFailure`s.
@riverpod
class LoginController extends _$LoginController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns whether the login succeeded.
  Future<bool> submit({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(authSessionProvider.notifier)
          .login(email: email.trim(), password: password),
    );
    if (ref.mounted) state = result;
    return !result.hasError;
  }
}
