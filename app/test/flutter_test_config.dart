import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Golden test setup (alchemist, plan §17.1), picked up by `flutter test`
/// for every test under `test/`.
///
/// - CI goldens (`goldens/ci/`, committed) are platform-agnostic: text is
///   painted as blocks and shadows are off, so they compare equal on every
///   host. They run everywhere.
/// - Platform goldens (`goldens/<os>/`, gitignored) render real text in the
///   bundled fonts (alchemist loads the families from the font manifest) as
///   a readable preview. They are written only by a local
///   `flutter test --update-goldens --tags golden` and never run on CI
///   (the `CI` variable is set there).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final onCi = Platform.environment.containsKey('CI');
  const tokens = GiTokens.dark;
  await AlchemistConfig.runWithConfig<FutureOr<void>>(
    config: AlchemistConfig(
      theme: AppTheme.dark(),
      goldenTestTheme: GoldenTestTheme(
        backgroundColor: tokens.background,
        borderColor: tokens.surfaceRaised,
        padding: const EdgeInsets.all(8),
        nameTextStyle: TextStyle(fontSize: 16, color: tokens.text),
      ),
      platformGoldensConfig: PlatformGoldensConfig(
        enabled: !onCi && autoUpdateGoldenFiles,
      ),
    ),
    run: testMain,
  );
}
