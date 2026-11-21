import 'dart:io';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'contract/appliance_fingerprint_contract_test.dart' as fingerprint;
import 'contract/auth_flow_contract_test.dart' as auth_flow;
import 'contract/core_quirks_contract_test.dart' as core_quirks;
import 'contract/devices_contract_test.dart' as devices;
import 'contract/session_rotation_contract_test.dart' as session_rotation;
import 'contract/support/live_coverage.dart';
import 'support/fixtures.dart';

/// The `liveCoverage` list of every live contract test file. A new
/// `test/contract/*_contract_test.dart` must declare one and be added here.
final Map<String, List<Endpoint>> liveCoverageByFile = {
  'appliance_fingerprint_contract_test.dart': fingerprint.liveCoverage,
  'auth_flow_contract_test.dart': auth_flow.liveCoverage,
  'core_quirks_contract_test.dart': core_quirks.liveCoverage,
  'devices_contract_test.dart': devices.liveCoverage,
  'session_rotation_contract_test.dart': session_rotation.liveCoverage,
};

/// A fixture read in a unit test: `fixtureObject('<EndpointId>/...')`,
/// `fixtureJson(...)` or `fixtureText(...)` (test/support/fixtures.dart).
final _fixtureUse = RegExp(r"fixture(?:Object|Json|Text)\(\s*'(\w+)/");

/// Catalog coverage rule (plan §6.2, §17.2, §19.1 pt 1): every
/// [GiEndpoints.all] entry has a recorded fixture, a unit test that decodes
/// it and a live contract test (or an explained exemption).
void main() {
  final ids = [for (final endpoint in GiEndpoints.all) endpoint.id];

  test('catalog ids are unique', () {
    expect(ids.toSet(), hasLength(ids.length));
  });

  group('fixtures', () {
    for (final endpoint in GiEndpoints.all) {
      test('${endpoint.id} has a recorded fixture', () {
        final dir = Directory('$fixturesDir/${endpoint.id}');
        final files = dir.existsSync()
            ? dir.listSync().whereType<File>().toList()
            : const <File>[];

        expect(files, isNotEmpty, reason: 'no file under ${dir.path}');
      });
    }
  });

  group('fixture-based decode tests', () {
    final uses = <String, Set<String>>{};
    for (final file in _unitTestFiles()) {
      for (final match in _fixtureUse.allMatches(file.readAsStringSync())) {
        (uses[match[1]!] ??= {}).add(file.uri.pathSegments.last);
      }
    }

    for (final endpoint in GiEndpoints.all) {
      test('${endpoint.id} is decoded from a fixture in a unit test', () {
        expect(
          uses[endpoint.id],
          isNotEmpty,
          reason:
              'no test outside test/contract reads a fixture of '
              '${endpoint.id}',
        );
      });
    }
  });

  group('live contract tests', () {
    final covered = <String, Set<String>>{};
    for (final MapEntry(key: file, value: endpoints)
        in liveCoverageByFile.entries) {
      for (final endpoint in endpoints) {
        (covered[endpoint.id] ??= {}).add(file);
      }
    }
    final exempt = {
      for (final MapEntry(:key, :value) in liveCoverageExemptions.entries)
        key.id: value,
    };

    test(
      'every contract test file declares liveCoverage and is registered',
      () {
        final files = Directory('test/contract')
            .listSync()
            .whereType<File>()
            .map((f) => f.uri.pathSegments.last)
            .where((name) => name.endsWith('_contract_test.dart'))
            .toSet();

        expect(files, liveCoverageByFile.keys.toSet());
        for (final name in files) {
          final source = File('test/contract/$name').readAsStringSync();
          expect(
            source,
            contains('const liveCoverage = <Endpoint>['),
            reason: '$name has no liveCoverage list',
          );
        }
      },
    );

    test('liveCoverage only names catalog entries', () {
      for (final endpoints in liveCoverageByFile.values) {
        for (final endpoint in endpoints) {
          expect(ids, contains(endpoint.id));
        }
      }
    });

    for (final endpoint in GiEndpoints.all) {
      test('${endpoint.id} has a live contract test or an exemption', () {
        final reason = exempt[endpoint.id];
        if (reason == null) {
          expect(
            covered[endpoint.id],
            isNotEmpty,
            reason:
                'no liveCoverage list names ${endpoint.id}; add a live test '
                'or an entry with a reason to liveCoverageExemptions',
          );
        } else {
          expect(reason.trim(), isNotEmpty);
          expect(
            covered[endpoint.id],
            isNull,
            reason: '${endpoint.id} is covered; drop its stale exemption',
          );
        }
      });
    }
  });
}

/// Unit test sources: everything under test/ except the live contract tests.
Iterable<File> _unitTestFiles() =>
    Directory('test')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_test.dart'))
        .where((f) => !f.uri.pathSegments.contains('contract'));
