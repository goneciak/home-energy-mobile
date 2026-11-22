import 'package:flutter/foundation.dart';
import 'package:gi_home/src/core/config/app_flavor.dart';
import 'package:gi_home/src/core/config/feature_flags.dart';

/// Build configuration: the flavor, the feature flag defaults and the store
/// links compiled in from `config/<flavor>.json` with
/// `--dart-define-from-file` (plan §19.2). The files hold no secrets;
/// nothing here is one.
@immutable
final class AppConfig {
  const new({
    required this.flavor,
    required this.flagDefaults,
    this.defines = const {},
    this.androidStoreUrl,
    this.iosStoreUrl,
  });

  /// The configuration compiled into this build, for the [entrypoint]
  /// flavor. Throws like `parse` when the defines do not fit it.
  factory fromEnvironment(AppFlavor entrypoint) =>
      AppConfig.parse(entrypoint, compiledDefines);

  /// Reads [defines] (name → value, an empty value meaning "not set") for
  /// the flavor of the [entrypoint].
  ///
  /// A present `FLAVOR` must name that flavor: a dev config built into the
  /// prod entrypoint (or the reverse) throws a [StateError]. A flag define
  /// is `true` or `false`; an absent one leaves the flag off. Flags that do
  /// not exist in the flavor stay off. A store link ([androidStoreUrlDefine],
  /// [iosStoreUrlDefine]) is empty or an `https` URL. Anything else throws a
  /// [FormatException].
  factory parse(AppFlavor entrypoint, Map<String, String> defines) {
    final named = defines[flavorDefine] ?? '';
    if (named.isNotEmpty) {
      final flavor = AppFlavor.tryParse(named);
      if (flavor == null) {
        throw FormatException('Unknown $flavorDefine', named);
      }
      if (flavor != entrypoint) {
        throw StateError(
          'The ${entrypoint.name} entrypoint was built with '
          '$flavorDefine=$named: pass config/${entrypoint.name}.json.',
        );
      }
    }
    return AppConfig(
      flavor: entrypoint,
      flagDefaults: FeatureFlags({
        for (final flag in FeatureFlag.values)
          flag: _parseBool(flag.define, defines[flag.define] ?? ''),
      }).restrictTo(entrypoint),
      defines: Map.unmodifiable({
        for (final MapEntry(:key, :value) in defines.entries)
          if (value.isNotEmpty) key: value,
      }),
      androidStoreUrl: _parseStoreUrl(
        androidStoreUrlDefine,
        defines[androidStoreUrlDefine] ?? '',
      ),
      iosStoreUrl: _parseStoreUrl(
        iosStoreUrlDefine,
        defines[iosStoreUrlDefine] ?? '',
      ),
    );
  }

  /// The define naming the flavor the build was configured for.
  static const flavorDefine = 'FLAVOR';

  /// Google Play listing of this build, for "Zaktualizuj aplikację" (plan
  /// §16 point 4); empty until the app is published.
  static const androidStoreUrlDefine = 'STORE_URL_ANDROID';

  /// App Store listing of this build; empty until the app is published.
  static const iosStoreUrlDefine = 'STORE_URL_IOS';

  /// Every define the app reads, as compiled into this build (empty when
  /// not set). The keys are [flavorDefine] and each [FeatureFlag.define].
  static const Map<String, String> compiledDefines = {
    flavorDefine: String.fromEnvironment(flavorDefine),
    'FF_MOCK_CORE': String.fromEnvironment('FF_MOCK_CORE'),
    'FF_SCHEDULE_CLOCK_CONVERSION': String.fromEnvironment(
      'FF_SCHEDULE_CLOCK_CONVERSION',
    ),
    'FF_SWITCH_CONTROL_BY_INTEGRATION': String.fromEnvironment(
      'FF_SWITCH_CONTROL_BY_INTEGRATION',
    ),
    'FF_ANDROID_LOCAL_NETWORK_PERMISSION_REQUEST': String.fromEnvironment(
      'FF_ANDROID_LOCAL_NETWORK_PERMISSION_REQUEST',
    ),
    'FF_CONDITIONAL_GET': String.fromEnvironment('FF_CONDITIONAL_GET'),
    androidStoreUrlDefine: String.fromEnvironment(androidStoreUrlDefine),
    iosStoreUrlDefine: String.fromEnvironment(iosStoreUrlDefine),
  };

  final AppFlavor flavor;

  /// Flag values before any override made on the phone.
  final FeatureFlags flagDefaults;

  /// The defines that were set, as shown on the experimental screen.
  final Map<String, String> defines;

  /// Store listings for the "Zaktualizuj aplikację" banner; `null` when not
  /// configured, and the banner then shows its text only.
  final Uri? androidStoreUrl;
  final Uri? iosStoreUrl;

  /// The store listing for [platform], if configured.
  Uri? storeUrlFor(TargetPlatform platform) => switch (platform) {
    TargetPlatform.android => androidStoreUrl,
    TargetPlatform.iOS => iosStoreUrl,
    _ => null,
  };

  static Uri? _parseStoreUrl(String name, String value) {
    if (value.isEmpty) return null;
    final url = Uri.tryParse(value);
    if (url == null || url.scheme != 'https' || url.host.isEmpty) {
      throw FormatException('$name must be an https URL', value);
    }
    return url;
  }

  static bool _parseBool(String name, String value) => switch (value) {
    '' || 'false' => false,
    'true' => true,
    _ => throw FormatException('$name must be true or false', value),
  };

  @override
  bool operator ==(Object other) =>
      other is AppConfig &&
      other.flavor == flavor &&
      other.flagDefaults == flagDefaults &&
      mapEquals(other.defines, defines) &&
      other.androidStoreUrl == androidStoreUrl &&
      other.iosStoreUrl == iosStoreUrl;

  @override
  int get hashCode => Object.hash(
    flavor,
    flagDefaults,
    Object.hashAllUnordered(defines.entries.map((e) => (e.key, e.value))),
    androidStoreUrl,
    iosStoreUrl,
  );

  @override
  String toString() => 'AppConfig(${flavor.name}, $flagDefaults)';
}
