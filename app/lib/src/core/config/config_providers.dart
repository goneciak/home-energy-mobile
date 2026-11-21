import 'package:gi_home/src/core/config/app_config.dart';
import 'package:gi_home/src/core/config/app_flavor.dart';
import 'package:gi_home/src/core/config/feature_flag_overrides_store.dart';
import 'package:gi_home/src/core/config/feature_flags.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:gi_home/src/core/config/app_config.dart';
export 'package:gi_home/src/core/config/app_flavor.dart';
export 'package:gi_home/src/core/config/feature_flags.dart';

part 'config_providers.g.dart';

/// The build configuration. The bootstrap overrides it with the config of
/// the entrypoint's flavor; without that (tests) it is prod with every flag
/// off, so nothing meant for developers shows up by accident.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) =>
    AppConfig(flavor: AppFlavor.prod, flagDefaults: FeatureFlags.allOff);

@Riverpod(keepAlive: true)
AppFlavor appFlavor(Ref ref) => ref.watch(appConfigProvider).flavor;

@Riverpod(keepAlive: true)
FeatureFlagOverridesStore featureFlagOverridesStore(Ref ref) =>
    FeatureFlagOverridesStore(ref.watch(sharedPreferencesProvider));

/// The feature flags in effect (plan §19.6): the flavor defaults from the
/// config, with the overrides stored on the phone in dev and beta. Prod
/// never reads or writes overrides, and a flag that does not exist in the
/// flavor stays off.
///
/// The merge with the capability probe results (plan §16) comes with the
/// probes in M3; until then the flags alone decide.
@Riverpod(keepAlive: true)
class FeatureFlagsNotifier extends _$FeatureFlagsNotifier {
  @override
  FeatureFlags build() {
    final config = ref.watch(appConfigProvider);
    if (!config.flavor.allowsFlagOverrides) return config.flagDefaults;
    final overrides = ref.watch(featureFlagOverridesStoreProvider).read();
    return config.flagDefaults.merge(overrides).restrictTo(config.flavor);
  }

  AppConfig get _config => ref.read(appConfigProvider);
  FeatureFlagOverridesStore get _store =>
      ref.read(featureFlagOverridesStoreProvider);

  /// Whether [flag] can be changed on this phone.
  bool canOverride(FeatureFlag flag) =>
      _config.flavor.allowsFlagOverrides && flag.isAvailableIn(_config.flavor);

  /// Overrides [flag] with [value] and stores it; a value equal to the
  /// default drops the override. Does nothing where [canOverride] is false.
  Future<void> set(FeatureFlag flag, {required bool value}) async {
    if (!canOverride(flag)) return;
    final overrides = {..._store.read(), flag: value};
    if (value == _config.flagDefaults[flag]) overrides.remove(flag);
    await _store.write(overrides);
    state = state.merge({flag: value});
  }

  /// Drops every stored override.
  Future<void> resetToDefaults() async {
    if (!_config.flavor.allowsFlagOverrides) return;
    await _store.clear();
    state = _config.flagDefaults;
  }
}
