import 'dart:io';

import 'package:gi_tools/spec_diff.dart' show findRepoRoot;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// The ban's step name, split so that the ban itself does not match this
/// file.
final String _todoGate = ['No TODO', '(backend)'].join();

/// Static checks of the CI and release configuration (plan §19.1, §19.4,
/// G5): every file parses, every workflow carries the repository gates, the
/// local actions and scripts it uses exist, third-party actions are pinned
/// to a commit,
/// contract stacks are always torn down, and no credential is written into
/// the files. GitHub itself is not available locally, so this is the
/// pre-flight check of the YAML.
void main() {
  final root = findRepoRoot(from: Directory.current);
  String path(String relative) => '${root.path}/$relative';

  final workflowFiles =
      Directory(path('.github/workflows'))
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.yml') || f.path.endsWith('.yaml'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  String name(File f) => f.uri.pathSegments.last;

  YamlMap load(String relative) =>
      loadYaml(File(path(relative)).readAsStringSync()) as YamlMap;

  Map<String, YamlMap> workflows() => {
    for (final f in workflowFiles)
      name(f): loadYaml(f.readAsStringSync()) as YamlMap,
  };

  Iterable<YamlMap> steps(YamlMap workflow) sync* {
    for (final job in (workflow['jobs'] as YamlMap).values.cast<YamlMap>()) {
      yield* (job['steps'] as YamlList? ?? YamlList()).cast<YamlMap>();
    }
  }

  test('the expected workflows exist', () {
    expect(workflowFiles.map(name), [
      'build.yml',
      'ci.yml',
      'contract.yml',
      'e2e.yml',
    ]);
  });

  test('every CI and release YAML file parses', () {
    for (final f in [
      ...workflowFiles.map((f) => f.path),
      path('.github/actions/setup-flutter/action.yml'),
      path('.github/actions/repo-gates/action.yml'),
      path('codemagic.yaml'),
    ]) {
      expect(
        () => loadYaml(File(f).readAsStringSync()),
        returnsNormally,
        reason: f,
      );
    }
    for (final entry in workflows().entries) {
      expect(entry.value['on'], isNotNull, reason: '${entry.key}: no `on`');
      expect(entry.value['jobs'], isA<YamlMap>(), reason: entry.key);
    }
  });

  test('the repo gates action runs Format and the TODO ban', () {
    final action = load('.github/actions/repo-gates/action.yml');
    final names = [
      for (final step in (action['runs'] as YamlMap)['steps'] as YamlList)
        (step as YamlMap)['name'],
    ];
    expect(names, containsAll(<String>['Format', _todoGate]));
    final format = ((action['runs'] as YamlMap)['steps'] as YamlList)
        .cast<YamlMap>()
        .firstWhere((s) => s['name'] == 'Format');
    expect(
      format['run'],
      contains(
        'dart format --output=none --set-exit-if-changed app packages tools',
      ),
    );
  });

  test('every workflow carries the repo gates (plan G5)', () {
    for (final MapEntry(:key, :value) in workflows().entries) {
      final uses = steps(value).map((s) => s['uses']).whereType<String>();
      expect(
        uses,
        contains('./.github/actions/repo-gates'),
        reason: '$key must run the Format and $_todoGate gates',
      );
    }
  });

  test('ci.yml has the codegen, coverage and golden gates', () {
    final ci = workflows()['ci.yml']!;
    final runs = steps(ci).map((s) => '${s['run'] ?? ''}').join('\n');
    expect(runs, contains('tools/ci/check-generated.sh'));
    expect(runs, contains('dart run tools/check_coverage.dart'));
    expect(runs, contains('flutter test --tags golden'));
    expect(runs, contains('flutter test -x golden --branch-coverage'));
    expect(runs, contains('dart test -x contract --coverage-path'));
    expect((ci['on'] as YamlMap).containsKey('workflow_call'), isTrue);
  });

  test('local actions, reusable workflows and scripts exist', () {
    for (final MapEntry(:key, :value) in workflows().entries) {
      final jobs = (value['jobs'] as YamlMap).values.cast<YamlMap>();
      final uses = [
        ...steps(value).map((s) => s['uses']),
        ...jobs.map((j) => j['uses']),
      ].whereType<String>().where((u) => u.startsWith('./'));
      for (final u in uses) {
        final target = u.endsWith('.yml') ? u : '$u/action.yml';
        expect(File(path(target)).existsSync(), isTrue, reason: '$key: $u');
      }
      final runs = steps(value).map((s) => '${s['run'] ?? ''}').join('\n');
      for (final m in RegExp(r'tools/[\w./-]+\.(?:sh|dart)').allMatches(runs)) {
        expect(
          File(path(m[0]!)).existsSync(),
          isTrue,
          reason: '$key runs ${m[0]}',
        );
      }
    }
  });

  test('third-party actions are pinned to a commit SHA', () {
    // Raw lines, not YAML: the version comment after the SHA is checked too.
    final files = [
      ...workflowFiles,
      for (final dir in Directory(path('.github/actions')).listSync())
        if (dir is Directory) File('${dir.path}/action.yml'),
    ];
    final usesLine = RegExp(r'^\s*(?:-\s*)?uses:\s*(\S+)(.*)$');
    final pinned = RegExp(r'^[\w.-]+/[\w./-]+@[0-9a-f]{40}$');
    final versionComment = RegExp(r'^\s+# v\d+\.\d+\.\d+$');
    final thirdParty = <String>[];
    for (final file in files) {
      for (final line in file.readAsLinesSync()) {
        final m = usesLine.firstMatch(line);
        if (m == null) continue;
        final uses = m[1]!;
        if (uses.startsWith('./')) continue;
        if (uses.startsWith('actions/')) {
          // GitHub's own actions: a major version is enough.
          expect(uses, matches(RegExp(r'^actions/[\w.-]+@v\d+')), reason: line);
          continue;
        }
        thirdParty.add(uses);
        // A tag can be moved to other code; a commit cannot. The release
        // job signs with the upload key after these actions ran.
        expect(uses, matches(pinned), reason: '${name(file)}: $line');
        expect(m[2], matches(versionComment), reason: '${name(file)}: $line');
      }
    }
    expect(
      thirdParty.map((u) => u.split('@').first).toSet(),
      containsAll(<String>[
        'subosito/flutter-action',
        'reactivecircus/android-emulator-runner',
      ]),
    );
  });

  test('a job that starts a contract stack always removes it', () {
    for (final MapEntry(:key, :value) in workflows().entries) {
      for (final job in (value['jobs'] as YamlMap).values.cast<YamlMap>()) {
        final jobSteps = (job['steps'] as YamlList? ?? YamlList())
            .cast<YamlMap>();
        final starts = jobSteps.any(
          (s) =>
              '${s['run'] ?? ''}'.contains('dev-up.sh --contract') &&
              !'${s['run']}'.contains('--down'),
        );
        if (!starts) continue;
        final down = jobSteps.where(
          (s) => '${s['run'] ?? ''}'.contains('--down'),
        );
        expect(down, isNotEmpty, reason: '$key: no --down step');
        expect(down.first['if'], 'always()', reason: '$key: --down not always');
      }
    }
  });

  test('every secret is documented in docs/development.md', () {
    final readme = File(path('docs/development.md')).readAsStringSync();
    final used = <String>{};
    for (final f in workflowFiles) {
      used.addAll(
        RegExp(r'secrets\.(\w+)')
            .allMatches(f.readAsStringSync())
            .map((m) => m[1]!),
      );
    }
    expect(used, isNotEmpty);
    for (final secret in used) {
      expect(
        readme,
        contains(secret),
        reason: 'docs/development.md lists $secret',
      );
    }
  });

  test('no credential is written into the CI and release files', () {
    final files = [
      ...workflowFiles,
      File(path('codemagic.yaml')),
      File(path('fastlane/Fastfile')),
      File(path('fastlane/Appfile')),
      File(path('app/android/app/build.gradle.kts')),
    ];
    final leaks = [
      RegExp('-----BEGIN [A-Z ]*PRIVATE KEY-----'),
      RegExp('"private_key"'),
      // A literal value assigned to a password/key/token-like name.
      RegExp(
        r'''(PASSWORD|_KEY|TOKEN|SECRET)\w*\s*[:=]\s*["']?[A-Za-z0-9+/]{16,}''',
      ),
      RegExp('ghp_[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_-]{20,}'),
    ];
    for (final f in files) {
      final text = f.readAsStringSync();
      for (final leak in leaks) {
        expect(
          leak.hasMatch(text),
          isFalse,
          reason: '${f.path}: ${leak.firstMatch(text)?[0]}',
        );
      }
    }
    for (final ignored in ['key.properties', '*.jks']) {
      expect(
        File(path('.gitignore')).readAsLinesSync(),
        contains(ignored),
        reason: '.gitignore must list $ignored',
      );
    }
  });

  test('codemagic.yaml has the two internal workflows on env groups', () {
    final workflows = load('codemagic.yaml')['workflows'] as YamlMap;
    expect(
      workflows.keys,
      containsAll(<String>['ios-testflight-internal', 'android-play-internal']),
    );
    for (final w in workflows.values.cast<YamlMap>()) {
      final environment = w['environment'] as YamlMap;
      expect(environment['flutter'], '3.50.0', reason: 'same SDK as .fvmrc');
      expect(environment['groups'], isA<YamlList>());
      expect(environment.containsKey('vars'), isFalse, reason: 'groups only');
    }
    expect(
      File(path('.fvmrc')).readAsStringSync(),
      contains('"3.50.0"'),
      reason: 'codemagic.yaml pins the .fvmrc version',
    );
  });

  test('fastlane has the internal_ios and internal_android lanes', () {
    final fastfile = File(path('fastlane/Fastfile')).readAsStringSync();
    expect(fastfile, contains('lane :internal_ios'));
    expect(fastfile, contains('lane :internal_android'));
  });
}
