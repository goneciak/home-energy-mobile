import 'package:flutter/widgets.dart';

import 'package:gi_home/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;

export '../../../l10n/app_localizations.dart';

/// The app's strings plus the Material, Cupertino and widgets strings of
/// `material_ui`. The generated `AppLocalizations.localizationsDelegates`
/// still lists flutter_localizations' delegates for the deprecated
/// `package:flutter/material.dart`, which `material_ui` widgets do not read:
/// with it, their built-in strings (tooltips, pickers) fall back to English.
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The phone language when the app supports it, Polish otherwise: the app
/// language while no signed-in user's profile names one (plan §13.2).
/// Requests send the effective app language instead (`RequestLanguage` in
/// `request_language.dart`), which falls back to this.
String appLanguageCode() {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return AppLocalizations.supportedLocales.any((l) => l.languageCode == code)
      ? code
      : 'pl';
}
