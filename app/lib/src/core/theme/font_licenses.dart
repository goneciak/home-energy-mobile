import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:gi_home/src/core/theme/gi_tokens.dart';

/// SIL OFL 1.1 texts of the bundled fonts (plan §14), keyed by family. The
/// files are copied verbatim from the google/fonts repository.
const Map<String, String> fontLicenseAssets = {
  GiFonts.display: 'assets/fonts/OFL-Fraunces.txt',
  GiFonts.body: 'assets/fonts/OFL-Manrope.txt',
  GiFonts.mono: 'assets/fonts/OFL-JetBrainsMono.txt',
};

/// Adds the bundled fonts' licences to [LicenseRegistry], so they are listed
/// on the licences page next to the packages' ones. The texts are read
/// lazily, only when that page asks for them.
void registerFontLicenses([AssetBundle? bundle]) {
  LicenseRegistry.addLicense(() async* {
    final assets = bundle ?? rootBundle;
    for (final MapEntry(key: family, value: path)
        in fontLicenseAssets.entries) {
      yield LicenseEntryWithLineBreaks([family], await assets.loadString(path));
    }
  });
}
