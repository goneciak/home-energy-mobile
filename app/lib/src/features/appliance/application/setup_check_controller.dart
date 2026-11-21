import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_check_controller.g.dart';

/// "Check again" on the setup-required screen: asks the saved appliance
/// whether it has been set up and, if so, stores its fingerprint.
///
/// State holds the last answer: `true` set up, `false` still not set up,
/// `null` not checked yet.
@riverpod
class SetupCheckController extends _$SetupCheckController {
  @override
  AsyncValue<bool?> build() => const AsyncData(null);

  Future<void> check() async {
    final profile = ref.read(applianceProfileProvider);
    if (profile == null) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final probe = await ref
          .read(applianceProbeProvider)
          .probe(profile.baseUrl);
      if (probe.setup.initialized) {
        await ref
            .read(applianceProfileProvider.notifier)
            .applySetup(probe.setup);
      }
      return probe.setup.initialized;
    });
    if (ref.mounted) state = result;
  }
}
