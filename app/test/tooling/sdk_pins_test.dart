import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The SDK and the riverpod_lint plugin are pinned outside pubspec.yaml, so
/// pub cannot keep them consistent. These checks fail when one side of a pin
/// moves without the other.
void main() {
  // `flutter test` runs from app/; a Windows checkout may have CRLF.
  String read(String path) =>
      File(path).readAsStringSync().replaceAll('\r\n', '\n');

  /// Resolved version of [package] in the workspace lock file.
  String locked(String package) {
    final match = RegExp(
      '^  $package:\\n(?:    .*\\n)*?    version: "([^"]+)"',
      multiLine: true,
    ).firstMatch(read('../pubspec.lock'));
    if (match == null) fail('$package is not in pubspec.lock');
    return match.group(1)!;
  }

  test('riverpod_lint plugin matches the resolved riverpod', () {
    // riverpod_lint depends on one exact riverpod (its pubspec.yaml). Bump
    // the plugin in app/analysis_options.yaml together with riverpod and
    // add the pair here.
    const riverpodFor = {'3.2.0': '3.5.0'};

    final plugin = RegExp(
      r'^plugins:\n  riverpod_lint: (\S+)$',
      multiLine: true,
    ).firstMatch(read('analysis_options.yaml'))?.group(1);

    expect(plugin, isNotNull, reason: 'riverpod_lint plugin is not enabled');
    expect(riverpodFor, contains(plugin), reason: 'unknown riverpod_lint');
    expect(locked('riverpod'), riverpodFor[plugin]);
  });

  test('the FVM pin is what CI and VS Code use', () {
    final fvmrc = jsonDecode(read('../.fvmrc')) as Map<String, Object?>;
    final settings =
        jsonDecode(read('../.vscode/settings.json')) as Map<String, Object?>;

    expect(fvmrc['flutter'], isA<String>());
    // Every workflow installs Flutter through this composite action.
    expect(
      read('../.github/actions/setup-flutter/action.yml'),
      contains('flutter-version-file: .fvmrc'),
    );
    expect(
      read('../.github/workflows/ci.yml'),
      contains('uses: ./.github/actions/setup-flutter'),
    );
    // Codemagic cannot read .fvmrc: its pin must be the same version.
    expect(
      read('../codemagic.yaml'),
      contains('&flutter_version ${fvmrc['flutter']}'),
    );
    expect(settings['dart.flutterSdkPath'], '.fvm/flutter_sdk');
  });
}
