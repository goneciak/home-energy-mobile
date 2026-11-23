import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';
import 'package:material_ui/material_ui.dart';

/// "Język": Automatycznie, Polski or English. The choice applies at once and
/// is remembered on this phone ([LanguagePreference]).
class LanguageTile extends ConsumerWidget {
  const new({super.key});

  static const ValueKey<String> tileKey = ValueKey('settings-language');

  /// Key of the dialog option for [languageCode]; `null` is "Automatycznie".
  static ValueKey<String> optionKey(String? languageCode) =>
      ValueKey('settings-language-${languageCode ?? 'auto'}');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final picked = ref.watch(languagePreferenceProvider);
    return ListTile(
      key: tileKey,
      leading: const Icon(Icons.translate),
      title: Text(l10n.settingsLanguage),
      subtitle: Text(languageLabel(l10n, picked?.languageCode)),
      onTap: () => unawaited(chooseLanguage(context, ref)),
    );
  }

  /// Name of [code] as the dialog and the selectors show it; `null` is
  /// "Automatycznie".
  static String languageLabel(AppLocalizations l10n, String? code) =>
      switch (code) {
        null => l10n.settingsLanguageAutomatic,
        'en' => l10n.settingsLanguageEnglish,
        _ => l10n.settingsLanguagePolish,
      };

  /// Asks which language to use and applies the answer
  /// ([LanguagePreference.select]); shared with `LanguageSelector`.
  static Future<void> chooseLanguage(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final current = ref.read(languagePreferenceProvider)?.languageCode;
    final codes = [
      null,
      for (final locale in AppLocalizations.supportedLocales)
        locale.languageCode,
    ];
    final chosen = await showDialog<(String?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsLanguageDialogTitle),
        children: [
          RadioGroup<String?>(
            groupValue: current,
            onChanged: (code) => Navigator.of(context).pop((code,)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final code in codes)
                  RadioListTile<String?>(
                    key: optionKey(code),
                    value: code,
                    title: Text(languageLabel(l10n, code)),
                    subtitle: code == null
                        ? Text(l10n.settingsLanguageAutomaticSubtitle)
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen == null) return;
    final (code,) = chosen;
    await ref
        .read(languagePreferenceProvider.notifier)
        .select(code == null ? null : Locale(code));
  }
}
