import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:gi_core_api/gi_core_api.dart'
    show CapabilityStatus, CoreCapabilities, CoreCapability;

part 'core_capabilities.g.dart';

/// Counts the GI Core version changes seen in `GET /appliance/updates/status`
/// (plan §16 pt 1) on the current client; each change re-runs the
/// capability probes. Learning the version the first time is no change.
@Riverpod(keepAlive: true)
class CoreVersionChanges extends _$CoreVersionChanges {
  String? _version;

  @override
  int build() {
    // A new client is a new connection: the version is unknown again.
    ref.watch(giCoreClientProvider);
    _version = null;
    return 0;
  }

  /// Records [version]; `null` (unknown) keeps the last known one.
  void note(String? version) {
    if (version == null || version == _version) return;
    final known = _version != null;
    _version = version;
    if (known) state++;
  }
}

/// Feature probing (plan §16 pt 2): which optional GI Core features this
/// appliance has, probed once per client (that is per Core instance and
/// connection) and signed-in user, and again when the Core version changes.
///
/// Until the probes finish, and for a probe that ended without a verdict,
/// every feature stays visible: only a proven `HTTP_404` hides one.
@Riverpod(keepAlive: true)
Future<CoreCapabilities> coreCapabilities(Ref ref) async {
  final client = ref.watch(giCoreClientProvider);
  final role = ref.watch(currentUserProvider.select((user) => user?.role));
  ref.watch(coreVersionChangesProvider);
  if (client == null || role == null) return CoreCapabilities.unprobed;
  return await CapabilityProbe(client).probe(role);
}

/// Whether the UI shows [capability] (see [coreCapabilities]).
@riverpod
bool coreCapabilityAvailable(Ref ref, CoreCapability capability) =>
    ref.watch(coreCapabilitiesProvider).value?.isAvailable(capability) ?? true;
