import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/platform/local_network_permission.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_candidate.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appliance_search.g.dart';

/// "Znajdź GI Home" on the connect screen (plan §9.2): one run of the
/// [ConnectionLadder] from the moment the screen opens, starting with the
/// saved profile's hosts. Invalidate it to search again.
///
/// With `FeatureFlags.androidLocalNetworkPermissionRequest` on, Android's
/// local network permission is asked for first (plan §9.4); a denial ends
/// the search with [LocalNetworkDeniedFailure].
@riverpod
Stream<ApplianceSearch> applianceSearch(Ref ref) async* {
  final ladder = ref.watch(connectionLadderProvider);
  yield ApplianceSearch.started;
  final askPermission = ref
      .read(featureFlagsProvider)
      .androidLocalNetworkPermissionRequest;
  if (askPermission) {
    try {
      await ref.read(localNetworkPermissionProvider).ensureGranted();
    } on LocalNetworkDeniedFailure catch (failure) {
      if (ref.mounted) {
        ref.read(diagnosticsServiceProvider).recordFailure(failure);
      }
      yield ApplianceSearch(done: true, failure: failure);
      return;
    }
  }
  if (!ref.mounted) return;
  final hosts = ref.read(applianceProfileProvider)?.knownHosts ?? const [];
  yield* ladder.search(rememberedHosts: hosts);
}
