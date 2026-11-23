import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/account/application/account_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/home/application/heating_card_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'switch_user_controller.g.dart';

/// "Zmień użytkownika" (plan §7.8): a logout (server logout; refresh
/// cookie, access token, per-session preferences and diagnostics wiped)
/// that also forgets who was signed in, so the login screen opens with an
/// EMPTY email field, and drops every cache of the previous user (profile,
/// devices, rooms, heating cards), so nothing role-gated reaches the next
/// one.
///
/// It lives apart from [AuthSessionNotifier] because those caches depend
/// on the session: they can be invalidated from here, not from there. Kept
/// alive: the settings screen that starts it is gone once it logs out.
@Riverpod(keepAlive: true)
class SwitchUserController extends _$SwitchUserController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<LogoutResult> switchUser() async {
    state = const AsyncLoading();
    // Before the logout: the login screen it routes to reads the email.
    await ref.read(applianceProfileProvider.notifier).forgetUser();
    // Nobody is remembered, so neither is their language: the login screen
    // is in the phone language.
    await ref.read(sessionLocaleStoreProvider).clear();
    final result = await ref.read(authSessionProvider.notifier).logout();
    ref
      ..invalidate(userProfileProvider)
      ..invalidate(devicesRepositoryProvider)
      ..invalidate(roomsRepositoryProvider)
      ..invalidate(heatingCardResultsProvider);
    if (ref.mounted) state = const AsyncData(null);
    return result;
  }
}
