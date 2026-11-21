import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_password_controller.g.dart';

/// Forced password change (plan §4.1). The server ends every other session
/// of the user and keeps this one.
@riverpod
class ChangePasswordController extends _$ChangePasswordController {
  @override
  AsyncValue<ChangePasswordResult?> build() => const AsyncData(null);

  Future<void> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    final client = ref.read(giCoreClientProvider);
    if (client == null) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => client.changePassword(
        ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      ),
    );
    if (!ref.mounted) return;
    state = result;
  }

  /// Leaves the screen: the router follows `mustChangePassword == false`.
  void finish() => ref.read(authSessionProvider.notifier).markPasswordChanged();
}
