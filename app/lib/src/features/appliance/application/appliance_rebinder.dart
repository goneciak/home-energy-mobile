import 'package:gi_home/src/core/polling/polling_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appliance_rebinder.g.dart';

/// Finds the saved appliance again when it moved to another address.
///
/// Used by the session restore (the saved address did not answer) and by the
/// network recovery (the phone changed network). It only ever sends reads:
/// the appliance is looked for under its `.local` names, and a candidate
/// replaces the stored address only when its fingerprint is the saved
/// appliance's (plan §9.3). An `https` profile is never rebound (no
/// cleartext downgrade), see [ConnectionLadder.findMoved].
final class ApplianceRebinder {
  new(this._ref);

  final Ref _ref;
  Future<bool>? _inFlight;

  /// Whether a search is running.
  bool get isRunning => _inFlight != null;

  /// Looks for the appliance and follows it to its new address. Returns
  /// whether the profile was rebound. Best effort: any failure means "not
  /// found". A search already running is joined. [stillWanted] is asked
  /// before the profile changes; `false` drops the result (the caller's
  /// own work was superseded meanwhile).
  Future<bool> rebindIfMoved({bool Function()? stillWanted}) =>
      _inFlight ??= _run(stillWanted).whenComplete(() => _inFlight = null);

  Future<bool> _run(bool Function()? stillWanted) async {
    final profile = _ref.read(applianceProfileProvider);
    if (profile == null) return false;
    try {
      final moved = await _ref
          .read(connectionLadderProvider)
          .findMoved(profile);
      if (moved == null || !_ref.mounted) return false;
      if (stillWanted != null && !stillWanted()) return false;
      // The search takes seconds: the profile may have been forgotten or
      // replaced by another appliance meanwhile, and must not follow this
      // one's address.
      final current = _ref.read(applianceProfileProvider);
      if (current == null ||
          current.profileId != profile.profileId ||
          current.initializedAt != profile.initializedAt) {
        return false;
      }
      await _ref.read(applianceProfileProvider.notifier).rebind(moved.host);
      // A new address starts with a clean slate.
      _ref.read(applianceReachabilityProvider).reset();
      return true;
    } on Object {
      return false;
    }
  }
}

/// Kept alive: the session restore and the network recovery share it.
@Riverpod(keepAlive: true)
ApplianceRebinder applianceRebinder(Ref ref) => ApplianceRebinder(ref);
