import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/data/appliance_profile_store.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';
import 'package:gi_home/src/features/demo/application/demo_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appliance_profile_notifier.g.dart';

@Riverpod(keepAlive: true)
ApplianceProfileStore applianceProfileStore(Ref ref) =>
    ApplianceProfileStore(ref.watch(sharedPreferencesProvider));

/// The saved appliance profile; `null` until the user connects.
///
/// In demo mode it is the demo appliance's profile, held in memory: changes
/// are never stored, and the saved profile is left as it was.
@Riverpod(keepAlive: true)
class ApplianceProfileNotifier extends _$ApplianceProfileNotifier {
  @override
  ApplianceProfile? build() {
    final demo = ref.watch(demoModeProvider);
    if (demo != null) return demo.profile;
    return ref.watch(applianceProfileStoreProvider).read();
  }

  bool get _inDemo => ref.read(demoModeProvider) != null;

  ApplianceProfileStore get _store => ref.read(applianceProfileStoreProvider);

  /// Saves the appliance confirmed on the connect screen.
  /// [cleartextNoticeShown]: the confirmation showed the one-time
  /// "not encrypted" notice (plan §9.4).
  ///
  /// The profile's own appliance ([ApplianceProfile.matches]) keeps the
  /// profile, its id and so its stored session; the confirmed address
  /// becomes the active one. Any other appliance gets a new profile: use
  /// `AuthSessionNotifier.replaceAppliance` when a profile exists, which
  /// wipes the old appliance's session first.
  Future<void> connect(ProbeResult probe, {bool cleartextNoticeShown = false}) {
    final current = state;
    if (current != null && current.matches(probe)) {
      return _save(
        current
            .movedTo(probe.address.origin.toString())
            .withSetup(probe.setup)
            .copyWith(
              cleartextNoticeShown:
                  current.cleartextNoticeShown || cleartextNoticeShown,
            ),
      );
    }
    return _save(
      ApplianceProfile.fromProbe(
        probe,
        cleartextNoticeShown: cleartextNoticeShown,
      ),
    );
  }

  /// The saved appliance answers on [origin] now (plan §9.3: found with the
  /// same fingerprint under its `.local` name): the profile follows it
  /// silently and keeps its session.
  Future<void> rebind(String origin) async {
    final profile = state;
    if (profile == null || profile.baseUrl == origin) return;
    await _save(profile.movedTo(origin));
  }

  /// Stores the fingerprint after the appliance has been set up.
  Future<void> applySetup(SetupStatus setup) async {
    final profile = state;
    if (profile == null) return;
    await _save(profile.withSetup(setup));
  }

  /// Follows a rename of the appliance reported by the session's fingerprint
  /// check (plan §9.3).
  Future<void> applyRename(String deviceName) async {
    final profile = state;
    if (profile == null) return;
    final renamed = profile.renamedTo(deviceName);
    if (renamed == profile) return;
    await _save(renamed);
  }

  /// Marks the appliance as reset (it reports `initialized: false`), which
  /// routes to the setup-required screen. Use `forgetResetAppliance`, which
  /// also wipes the session cookie the reset made worthless.
  Future<void> markReset() async {
    final profile = state;
    if (profile == null || !profile.isInitialized) return;
    await _save(profile.asReset());
  }

  /// After a login: pre-fills the next login with [email] and records the
  /// user (plan §7.1).
  Future<void> rememberUser({
    required String email,
    required String userId,
  }) async {
    final profile = state;
    if (profile == null) return;
    final next = profile.copyWith(lastUserEmail: email, lastUserId: userId);
    if (next != profile) await _save(next);
  }

  /// Records the signed-in user after `GET /auth/me` or a restore.
  Future<void> rememberUserId(String userId) async {
    final profile = state;
    if (profile == null || profile.lastUserId == userId) return;
    await _save(profile.copyWith(lastUserId: userId));
  }

  /// "Zmień użytkownika" (plan §7.8): unlike a logout, the next login starts
  /// with an empty email field and no user is remembered.
  Future<void> forgetUser() async {
    final profile = state;
    if (profile == null) return;
    final next = profile.copyWith(lastUserEmail: null, lastUserId: null);
    if (next != profile) await _save(next);
  }

  /// Puts [profile] in place of the saved one. Use
  /// `AuthSessionNotifier.replaceAppliance`, which wipes the old session.
  Future<void> replaceWith(ApplianceProfile profile) => _save(profile);

  /// Removes the profile from this phone. Use
  /// `AuthSessionNotifier.forgetAppliance`, which also ends and wipes the
  /// stored session: the token vault depends on this provider, so it cannot
  /// be reached from here.
  /// In demo mode it ends the demo instead.
  Future<void> forget() async {
    if (_inDemo) {
      ref.read(demoModeProvider.notifier).exit();
      return;
    }
    await _store.clear();
    state = null;
  }

  /// The state changes at once, so updates made while an earlier write is
  /// still in flight (login and the session stream both record the user)
  /// build on each other instead of overwriting.
  Future<void> _save(ApplianceProfile profile) async {
    state = profile;
    if (!_inDemo) await _store.write(profile);
  }
}
