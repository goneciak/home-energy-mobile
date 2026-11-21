import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_candidate.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connect_controller.g.dart';

/// Connect screen flow (plan §9.2): probe an address or pick a candidate
/// the connection ladder found, show the appliance for confirmation, and
/// only then save it. No credentials are sent here.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` probing, `AsyncData(probe)`
/// awaiting confirmation, `AsyncError` with a [FormatException] (bad
/// address) or an [ApiFailure].
@riverpod
class ConnectController extends _$ConnectController {
  @override
  AsyncValue<ProbeResult?> build() => const AsyncData(null);

  Future<void> probe(String rawAddress) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(applianceProbeProvider).probe(rawAddress),
    );
    if (ref.mounted) state = result;
  }

  /// A candidate from "Znajdź GI Home" goes to the same confirmation as a
  /// typed address; the ladder has probed it already.
  void pick(ApplianceCandidate candidate) => state = AsyncData(candidate.probe);

  /// Back to address entry ("No, enter another address").
  void reset() => state = const AsyncData(null);

  /// Whether confirming [probe] replaces the saved profile with another
  /// appliance (D1 = A, plan §9.2): the user must agree first, since it logs
  /// out and wipes the saved appliance's data.
  bool replacesProfile(ProbeResult probe) {
    final profile = ref.read(applianceProfileProvider);
    return profile != null && !profile.matches(probe);
  }

  /// Whether the confirmation of [probe] shows the one-time "not encrypted"
  /// notice (plan §9.4): an `http://` address, and the profile it is saved
  /// in has not shown it yet. A replaced profile starts over.
  bool showsCleartextNotice(ProbeResult probe) {
    if (!probe.address.isCleartext) return false;
    final profile = ref.read(applianceProfileProvider);
    return profile == null ||
        !profile.matches(probe) ||
        !profile.cleartextNoticeShown;
  }

  /// Saves the confirmed appliance; the router then moves on. Another
  /// appliance than the saved one replaces it ([replacesProfile]; the
  /// screen asks first) and the old session is wiped.
  Future<void> confirm() async {
    final probe = state.value;
    if (probe == null) return;
    final noticeShown = showsCleartextNotice(probe);
    if (replacesProfile(probe)) {
      await ref
          .read(authSessionProvider.notifier)
          .replaceAppliance(probe, cleartextNoticeShown: noticeShown);
    } else {
      await ref
          .read(applianceProfileProvider.notifier)
          .connect(probe, cleartextNoticeShown: noticeShown);
    }
  }
}
