import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:alchemist/alchemist.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

import 'support/quiet_connectivity.dart';

/// Golden test setup (alchemist, plan §17.1), picked up by `flutter test`
/// for every test under `test/`.
///
/// - CI goldens (`goldens/ci/`, committed) are rendered on Linux, the CI
///   platform: text is painted as blocks and shadows are off, so only
///   sub-pixel anti-aliasing (the rounded ends of chips) differs between
///   hosts. They run everywhere: strictly on Linux, with a small tolerance
///   ([_crossPlatformTolerance]) on other systems.
/// - Platform goldens (`goldens/<os>/`, gitignored) render real text in the
///   bundled fonts (alchemist loads the families from the font manifest) as
///   a readable preview. They are written only by a local
///   `flutter test --update-goldens --tags golden` and never run on CI
///   (the `CI` variable is set there).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // No platform channel in widget tests: the app listens for network changes.
  ConnectivityPlatform.instance = QuietConnectivity();
  if (!Platform.isLinux) {
    final current = goldenFileComparator;
    if (current is LocalFileComparator) {
      goldenFileComparator = _TolerantComparator(current.basedir);
    }
  }
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

/// The share of pixels that may differ when a golden recorded on Linux is
/// compared on another system (the largest difference seen is 0.17%).
const _crossPlatformTolerance = 0.003;

/// A [LocalFileComparator] that accepts anti-aliasing noise.
class _TolerantComparator extends LocalFileComparator {
  new(Uri basedir) : super(basedir.resolve('golden_test.dart'));

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _crossPlatformTolerance) {
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
