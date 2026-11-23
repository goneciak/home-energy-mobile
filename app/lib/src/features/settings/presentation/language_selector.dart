import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';
import 'package:gi_home/src/features/settings/presentation/language_tile.dart';
import 'package:material_ui/material_ui.dart';

/// Compact language button for the screens before the login (connect,
/// login): "Język: Automatycznie" opens the same choice as
/// Settings > Language (Automatycznie / Polski / English) and applies it
/// through the same preference, so a tester whose phone speaks another
/// language can switch before signing in (plan §13.2).
class LanguageSelector extends ConsumerWidget {
  const new({super.key});

  static const ValueKey<String> selectorKey = ValueKey('language-selector');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final picked = ref.watch(languagePreferenceProvider);
    final label = l10n.languageSelectorLabel(
      LanguageTile.languageLabel(l10n, picked?.languageCode),
    );
    return Center(
      child: Semantics(
        button: true,
        excludeSemantics: true,
        label: label,
        onTap: () => unawaited(LanguageTile.chooseLanguage(context, ref)),
        child: TextButton.icon(
          key: selectorKey,
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () => unawaited(LanguageTile.chooseLanguage(context, ref)),
          icon: const Icon(Icons.translate),
          label: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
