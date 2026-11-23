import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/request_language.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/account/data/session_locale_store.dart';
import 'package:gi_home/src/features/account/domain/app_locale.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/demo/application/demo_mode.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_providers.g.dart';

@Riverpod(keepAlive: true)
SessionLocaleStore sessionLocaleStore(Ref ref) =>
    SessionLocaleStore(ref.watch(sharedPreferencesProvider));

/// `GET /users/me/profile` of the signed-in user (plan §4.1, §13.2), or
/// `null` while signed out. Loaded after login and session restore (when
/// the user appears) and again on every return to the foreground (plan
/// §7.6, §11), next to the session notifier's `GET /auth/me`. Another
/// user, or none, drops it, so nothing of one user reaches the next.
///
/// On success the language it names is remembered for the next cold start
/// ([SessionLocaleStore]). A failure is only an error here: the app keeps
/// its language and the session goes on.
@Riverpod(keepAlive: true)
Future<UserProfile?> userProfile(Ref ref) async {
  final userId = ref.watch(currentUserProvider.select((user) => user?.id));
  final profileId = ref.watch(
    applianceProfileProvider.select((profile) => profile?.profileId),
  );
  final client = ref.watch(giCoreClientProvider);
  if (userId == null || profileId == null || client == null) return null;
  _reloadOnResume(ref);
  final profile = await client.profile();
  // The demo user's language is not remembered (plan §19.5).
  if (ref.mounted && profile.id == userId && !ref.read(isDemoProvider)) {
    await ref
        .read(sessionLocaleStoreProvider)
        .write(
          profileId: profileId,
          userId: userId,
          languageCode: supportedAppLocale(profile.locale)?.languageCode,
        );
  }
  return profile;
}

/// The language the app shows (plan §13.2), fed to `MaterialApp.locale`;
/// `null` means the phone language.
///
/// * A language picked in Settings ([languagePreferenceProvider]) wins
///   over everything below, signed in or not.
/// * Signed out with a remembered last user on this appliance (after a
///   logout, or on the login screen of a restart): the language last
///   applied for that user, so the login screen matches the user's
///   language.
/// * Signed out without one (first connect, after "Zmień użytkownika"):
///   the phone language.
/// * Signed in: the language of the user's GI Core profile, or the phone
///   language when the profile has none the app supports.
/// * Until the profile has answered (cold start, a failed profile call):
///   the language last applied for this user on this appliance, so a
///   restored session does not start in the phone language.
@Riverpod(keepAlive: true)
Locale? appLocale(Ref ref) {
  final picked = ref.watch(languagePreferenceProvider);
  if (picked != null) return picked;
  final (:profileId, :lastUserId) = ref.watch(
    applianceProfileProvider.select(
      (p) => (profileId: p?.profileId, lastUserId: p?.lastUserId),
    ),
  );
  if (profileId == null) return null;
  final userId = switch (ref.watch(authSessionProvider)) {
    AsyncData(value: AuthAuthenticated(:final user)) => user.id,
    // Signed out, restoring, or restoring failed: the last user of this
    // appliance, if the app remembers one.
    _ => lastUserId,
  };
  if (userId == null) return null;
  if (ref.watch(userProfileProvider) case AsyncData(:final value?)
      when value.id == userId) {
    return supportedAppLocale(value.locale);
  }
  final stored = ref
      .watch(sessionLocaleStoreProvider)
      .read(profileId: profileId, userId: userId);
  return stored == null ? null : supportedAppLocale(stored);
}

/// [requestLanguageProvider], kept on the language the app shows
/// ([appLocaleProvider]), so `Accept-Language` follows the signed-in user's
/// profile (plan §13.2). A listener instead of a watch from the client: the
/// app language depends on the session, and the session on the client.
/// `GiHomeApp` keeps it running from its first frame.
@Riverpod(keepAlive: true)
RequestLanguage syncedRequestLanguage(Ref ref) {
  final language = ref.watch(requestLanguageProvider);
  ref.listen(
    appLocaleProvider,
    (_, locale) => language.appLocale = locale,
    fireImmediately: true,
  );
  return language;
}

/// Reloads the provider of [ref] on every return to the foreground.
void _reloadOnResume(Ref ref) {
  final foreground = ref.watch(appForegroundProvider);
  var wasForeground = foreground.value;
  void onChange() {
    final resumed = foreground.value && !wasForeground;
    wasForeground = foreground.value;
    if (resumed && ref.mounted) ref.invalidateSelf();
  }

  foreground.addListener(onChange);
  ref.onDispose(() => foreground.removeListener(onChange));
}
