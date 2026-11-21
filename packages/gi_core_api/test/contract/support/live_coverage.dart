import 'package:gi_core_api/gi_core_api.dart';

/// Catalog entries that legitimately have no live contract test, each with
/// the reason (plan §6.2, §17.2: "every entry has a fixture test and a live
/// contract test"). `test/catalog_coverage_test.dart` fails for an entry that
/// is neither covered by a `liveCoverage` list of a `*_contract_test.dart`
/// file nor listed here, and for a stale entry here that is covered after
/// all. `tools/gen_backend_contract.dart` prints the reasons in
/// `docs/backend-contract.md`.
///
/// The M2 entries below are decoded from recorded fixtures until their live
/// contract tests land; drop each exemption together with adding its test.
/// The M2 write endpoints are covered by `control_contract_test.dart`.
const liveCoverageExemptions = <Endpoint, String>{
  GiEndpoints.settingsSystem:
      'M2: live contract test not written yet; decoded from a recorded '
      'fixture.',
  GiEndpoints.applianceUpdatesStatus:
      'M2: live contract test not written yet; the contract stack has no '
      'Supervisor, so only the unconfigured status is reachable there.',
};
