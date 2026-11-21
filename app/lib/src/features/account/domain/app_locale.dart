import 'package:flutter/widgets.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';

/// The app language for a GI Core `locale` such as `pl-PL` or `en_US` (plan
/// §13.2), or `null` when it is missing or not one the app supports: the
/// app then follows the phone language.
Locale? supportedAppLocale(String? tag) {
  final language = tag?.trim().split(RegExp('[-_]')).first.toLowerCase();
  if (language == null || language.isEmpty) return null;
  for (final locale in AppLocalizations.supportedLocales) {
    if (locale.languageCode == language) return Locale(locale.languageCode);
  }
  return null;
}
