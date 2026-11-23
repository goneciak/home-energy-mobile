import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/localized_snack_bar.dart';
import 'package:gi_home/src/core/widgets/section_header.dart';
import 'package:material_ui/material_ui.dart';

/// Hidden "Funkcje eksperymentalne" screen (plan §19.2, §19.6), in dev and
/// beta only: reached by tapping the app version in Settings
/// [ExperimentalFeaturesScreen.versionTapsToOpen] times. Lists every
/// feature flag with a switch, resets them, and shows the build config.
class ExperimentalFeaturesScreen extends ConsumerWidget {
  const new({super.key});

  /// Taps on the app version in Settings that open this screen.
  static const versionTapsToOpen = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final config = ref.watch(appConfigProvider);
    final flags = ref.watch(featureFlagsProvider);
    final notifier = ref.read(featureFlagsProvider.notifier);
    final muted = textTheme.bodySmall?.copyWith(color: tokens.textMuted);

    Future<void> reset() async {
      await notifier.resetToDefaults();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(localizedSnackBar((l10n) => l10n.experimentalResetDone));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.experimentalTitle)),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: tokens.gap / 2),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(l10n.experimentalIntro, style: textTheme.bodyMedium),
          ),
          SectionHeader(l10n.experimentalFlagsSection),
          for (final flag in FeatureFlag.values)
            SwitchListTile(
              key: ValueKey('flag-${flag.name}'),
              title: Text(_flagTitle(l10n, flag)),
              subtitle: Text(
                [
                  _flagDescription(l10n, flag),
                  if (!flag.isAvailableIn(config.flavor))
                    l10n.experimentalDevOnly
                  else if (flags[flag] != config.flagDefaults[flag])
                    l10n.experimentalChanged,
                ].join('\n'),
              ),
              value: flags[flag],
              onChanged: notifier.canOverride(flag)
                  ? (value) => unawaited(notifier.set(flag, value: value))
                  : null,
            ),
          ListTile(
            key: const ValueKey('experimental-reset'),
            leading: const Icon(Icons.restart_alt),
            title: Text(l10n.experimentalReset),
            onTap: reset,
          ),
          SectionHeader(l10n.experimentalConfigSection),
          ListTile(
            title: Text(l10n.experimentalFlavor),
            subtitle: Text(config.flavor.name, style: GiFonts.monospace()),
          ),
          if (config.defines.isEmpty)
            ListTile(subtitle: Text(l10n.experimentalNoDefines, style: muted))
          else
            for (final MapEntry(:key, :value) in config.defines.entries)
              ListTile(
                dense: true,
                title: Text(key, style: GiFonts.monospace()),
                trailing: Text(value, style: GiFonts.monospace()),
              ),
        ],
      ),
    );
  }

  static String _flagTitle(AppLocalizations l10n, FeatureFlag flag) =>
      switch (flag) {
        FeatureFlag.mockCore => l10n.flagMockCoreTitle,
        FeatureFlag.scheduleClockConversion =>
          l10n.flagScheduleClockConversionTitle,
        FeatureFlag.switchControlByIntegration =>
          l10n.flagSwitchControlByIntegrationTitle,
        FeatureFlag.androidLocalNetworkPermissionRequest =>
          l10n.flagAndroidLocalNetworkPermissionRequestTitle,
        FeatureFlag.conditionalGet => l10n.flagConditionalGetTitle,
        FeatureFlag.mdnsFallback => l10n.flagMdnsFallbackTitle,
      };

  static String _flagDescription(AppLocalizations l10n, FeatureFlag flag) =>
      switch (flag) {
        FeatureFlag.mockCore => l10n.flagMockCoreDescription,
        FeatureFlag.scheduleClockConversion =>
          l10n.flagScheduleClockConversionDescription,
        FeatureFlag.switchControlByIntegration =>
          l10n.flagSwitchControlByIntegrationDescription,
        FeatureFlag.androidLocalNetworkPermissionRequest =>
          l10n.flagAndroidLocalNetworkPermissionRequestDescription,
        FeatureFlag.conditionalGet => l10n.flagConditionalGetDescription,
        FeatureFlag.mdnsFallback => l10n.flagMdnsFallbackDescription,
      };
}
