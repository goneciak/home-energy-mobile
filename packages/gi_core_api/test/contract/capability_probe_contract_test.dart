/// Live contract of the GI Core compatibility checks (plan §16): the
/// best-effort running version for OWNER/ADMIN, the 403 a USER would get
/// (so the app never asks), and the feature probes for every role.
///
/// The contract stack has no Supervisor (`GI_APPLIANCE_OWNER` unset), so the
/// update status is the unconfigured one and the version is unknown. Three
/// logins: the owner and the seeded ADMIN and USER.
@Tags(['contract'])
library;

import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/contract_env.dart';

/// Catalog entries this file exercises live (plan §6.2, §19.1). Read by
/// `test/catalog_coverage_test.dart` and scanned by
/// `tools/gen_backend_contract.dart`.
const liveCoverage = <Endpoint>[
  GiEndpoints.authLogin,
  GiEndpoints.applianceUpdatesStatus,
];

Future<void> main() async {
  final base = ContractEnv.coreUrl;
  final probe = await ContractEnv.probe(base);
  final skip = ContractEnv.skipReason(base, probe) ?? false;

  group('compatibility checks', skip: skip, () {
    final clients = <UserRole, GiCoreClient>{};
    String? notSeeded;

    setUpAll(() async {
      final accounts = {
        UserRole.owner: ContractEnv.owner(),
        UserRole.admin: ContractEnv.seededAccount('ADMIN'),
        UserRole.user: ContractEnv.seededAccount('USER'),
      };
      for (final MapEntry(key: role, value: account) in accounts.entries) {
        if (account == null) {
          notSeeded = 'no owner credentials (tools/backend/dev.env)';
          return;
        }
        final client = strictClient(
          address: probe!.address,
          vault: InMemoryTokenVault(),
          expectedInitializedAt: probe.setup.initializedAt,
        );
        clients[role] = client;
        try {
          final user = await respectingLoginLimit(
            () =>
                client.login(email: account.email, password: account.password),
          );
          expect(user.role, role);
        } on UnauthorizedFailure {
          notSeeded = 'no seeded ${role.name} at $base';
          return;
        }
      }
    });

    tearDownAll(() async {
      for (final client in clients.values) {
        await client.close();
      }
    });

    void seededTest(String description, Future<void> Function() body) =>
        test(description, () async {
          if (notSeeded case final reason?) {
            markTestSkipped(reason);
            return;
          }
          await body();
        });

    for (final role in [UserRole.owner, UserRole.admin]) {
      seededTest('${role.name}: update status without a Supervisor is '
          'unconfigured, so the running version is unknown', () async {
        final status = await clients[role]!.applianceUpdateStatus();
        expect(status.configured, isFalse);
        expect(status.lastCheck, isNull);
        expect(status.runningVersion(), isNull);
      });
    }

    seededTest('USER may not read the update status: 403 HTTP_403', () async {
      expect(GiEndpoints.applianceUpdatesStatus.allows(UserRole.user), isFalse);
      await expectLater(
        clients[UserRole.user]!.applianceUpdateStatus(),
        throwsA(
          isA<ForbiddenFailure>().having((f) => f.code, 'code', 'HTTP_403'),
        ),
      );
    });

    for (final role in [UserRole.owner, UserRole.admin, UserRole.user]) {
      seededTest('${role.name}: every optional feature probes as present '
          '(domain 404s, not HTTP_404)', () async {
        final caps = await CapabilityProbe(clients[role]!).probe(role);
        for (final capability in CoreCapability.values) {
          expect(
            caps[capability],
            CapabilityStatus.present,
            reason: capability.name,
          );
        }
      });
    }
  });
}
