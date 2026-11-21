import 'dart:io';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_tools/backend_contract.dart';
import 'package:test/test.dart';

void main() {
  final root = findRepoRoot(from: Directory.current);

  test('docs/backend-contract.md is up to date with the catalog', () {
    final committed = File('${root.path}/docs/backend-contract.md');
    final expected = renderBackendContract(ContractSources.read(root));

    expect(
      committed.existsSync() &&
          normalizeNewlines(committed.readAsStringSync()) == expected,
      isTrue,
      reason:
          'docs/backend-contract.md is stale; regenerate it with '
          'dart run tools/gen_backend_contract.dart',
    );
  });

  test('every catalog entry is in the table, with fixtures and live tests', () {
    final sources = ContractSources.read(root);
    final text = renderBackendContract(sources);

    for (final endpoint in GiEndpoints.all) {
      expect(text, contains('| `${endpoint.id}` | ${endpoint.method.verb} |'));
      expect(sources.fixtureFiles[endpoint.id], isNotEmpty);
    }
    expect(text, isNot(contains('**brak**')));
  });

  group('source scanners', () {
    test('catalog field names map to ids', () {
      const source = '''
  static const healthLive = Endpoint(
    id: 'HealthController_live',
    method: HttpMethod.get,
  );
  static const devicesDetail = Endpoint(id: 'DevicesController_get');
''';

      expect(parseCatalogFieldNames(source), {
        'healthLive': 'HealthController_live',
        'devicesDetail': 'DevicesController_get',
      });
    });

    test('the liveCoverage registry of a contract test is read', () {
      const source = '''
const liveCoverage = <Endpoint>[
  GiEndpoints.authLogin,
  // GiEndpoints.commentedOut is still a reference; keep lists plain.
  GiEndpoints.devicesList,
];
void main() => GiEndpoints.roomsList;
''';

      expect(parseLiveCoverage(source), [
        'authLogin',
        'commentedOut',
        'devicesList',
      ]);
      expect(parseLiveCoverage('void main() {}'), isEmpty);
    });

    test('exemptions keep their reasons, adjacent literals joined', () {
      const source = r'''
const liveCoverageExemptions = <Endpoint, String>{
  GiEndpoints.authLogout:
      'Ends the only session; '
      "covered by the owner\'s flow",
  GiEndpoints.roomsList: 'Needs a seeded room.',
};
''';

      expect(parseLiveCoverageExemptions(source), {
        'authLogout': "Ends the only session; covered by the owner's flow",
        'roomsList': 'Needs a seeded room.',
      });
    });

    test('exempt entries are listed with their reason', () {
      final sources = ContractSources.read(root);
      final text = renderBackendContract(
        ContractSources(
          backendRef: sources.backendRef,
          endpoints: sources.endpoints,
          fieldNames: sources.fieldNames,
          fixtureFiles: sources.fixtureFiles,
          liveTests: const {},
          exemptions: {GiEndpoints.authLogout.id: 'A test reason.'},
        ),
      );

      expect(text, contains('- `AuthController_logout`: A test reason.'));
      expect(text, contains('zwolniony (niżej)'));
      expect(text, contains('**brak**'));
    });
  });
}
