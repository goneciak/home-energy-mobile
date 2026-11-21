/// Acceptance test of plan §9.3: two Cores with different `initializedAt`
/// never get each other's refresh cookie.
///
/// Needs two initialized Cores: `GI_CORE_URL` (A, seeded: the USER account
/// logs in) and `GI_CORE_URL_B` (B, only probed). Skipped without
/// `GI_CORE_URL_B`. B is never logged in to; one login on A.
///
/// A session made on A is handed to a client pointed at B (same vault, A's
/// fingerprint), the way a stored profile would meet another appliance at the
/// remembered address. The client must stop at the fingerprint check: an
/// intercepting adapter shows that B never received A's cookie or token, and
/// A afterwards accepts the untouched cookie (the server-side outcome).
@Tags(['contract'])
library;

import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/contract_env.dart';

/// Catalog entries this file exercises live (plan §6.2, §19.1). Read by
/// `test/catalog_coverage_test.dart` and scanned by
/// `tools/gen_backend_contract.dart`.
const liveCoverage = <Endpoint>[
  GiEndpoints.healthLive,
  GiEndpoints.setupStatus,
  GiEndpoints.authLogin,
  GiEndpoints.authRefresh,
];

Future<void> main() async {
  final urlA = ContractEnv.coreUrl;
  final urlB = ContractEnv.coreUrlB;
  final probeA = await ContractEnv.probe(urlA);
  final probeB = urlB == null ? null : await ContractEnv.probe(urlB);

  Object skip() {
    if (urlB == null) return 'GI_CORE_URL_B is not set';
    final reason =
        ContractEnv.skipReason(urlA, probeA) ??
        (probeB == null ? 'GI Core B is not reachable at $urlB' : null);
    if (reason != null) return reason;
    if (!probeB!.setup.initialized) return 'GI Core B is not initialized';
    return false;
  }

  group('appliance fingerprint (§9.3)', skip: skip(), () {
    test("a session of A pointed at B never sends A's cookie or token to B; "
        'A still accepts the cookie', () async {
      final initializedA = probeA!.setup.initializedAt!;
      final initializedB = probeB!.setup.initializedAt!;
      expect(
        initializedB.isAtSameMomentAs(initializedA),
        isFalse,
        reason: 'the two Cores must differ in initializedAt',
      );

      // A session on A (the seeded USER: no data is changed).
      final vault = InMemoryTokenVault();
      final onA = strictClient(
        address: probeA.address,
        vault: vault,
        expectedInitializedAt: initializedA,
      );
      addTearDown(onA.close);
      final account = ContractEnv.seededAccount('USER');
      await respectingLoginLimit(
        () => onA.login(email: account.email, password: account.password),
      );
      final cookieA = vault.cookie!;

      // The same stored session meets B.
      final recorder = RecordingAdapter();
      final atB = strictClient(
        address: probeB.address,
        vault: vault,
        expectedInitializedAt: initializedA,
        httpClientAdapter: recorder,
      );
      addTearDown(atB.close);

      await expectLater(
        atB.restoreSession(),
        throwsA(isA<DifferentApplianceFailure>()),
      );
      await expectLater(
        atB.session.ensureFresh(force: true),
        throwsA(isA<DifferentApplianceFailure>()),
      );
      await expectLater(atB.me(), throwsA(isA<ApiFailure>()));

      // What reached B: only fingerprint checks, never credentials.
      expect(recorder.requests, isNotEmpty);
      for (final request in recorder.requests) {
        final route = '${request.method} ${request.uri}';
        expect(request.uri.host, probeB.address.apiBaseUrl.host);
        expect(request.uri.port, probeB.address.apiBaseUrl.port);
        expect(headerOf(request, 'cookie'), isNull, reason: route);
        expect(headerOf(request, 'authorization'), isNull, reason: route);
        expect(request.uri.path, isNot(endsWith('/auth/refresh')));
      }
      expect(
        recorder.requests.map((r) => r.uri.path),
        contains(endsWith('/setup/status')),
      );
      // The cookie is kept for the app to decide (§9.3), not wiped.
      expect(vault.cookie, cookieA);

      // Server side: A rotates the cookie it issued, so nobody used it.
      final token = await onA.session.ensureFresh(force: true);
      expect(token, isNotEmpty);
      expect(vault.cookie!.generation, cookieA.generation + 1);
      expect((await onA.me()).email, account.email);
      expect((await onA.logout()).serverSessionEnded, isTrue);
    });
  });
}
