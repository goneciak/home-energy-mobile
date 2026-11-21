@Tags(['golden'])
library;

import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_search.dart';
import 'package:gi_home/src/features/appliance/application/connect_controller.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_candidate.dart';
import 'package:gi_home/src/features/appliance/presentation/connect_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixtures.dart';
import '../support/golden.dart';
import '../support/test_app.dart';

/// What an appliance at [address] answers to the probe.
ProbeResult _probe(String address, {String? deviceName}) => ProbeResult(
  address: ApplianceAddress.parse(address),
  health: HealthLive.fromJson(fixtureObject('HealthController_live/ok.json')),
  setup: SetupStatus.fromJson({
    ...fixtureObject('SetupController_getStatus/initialized.json'),
    'deviceName': ?deviceName,
  }),
);

/// The confirmation of [probe] is showing.
class _Confirming extends ConnectController {
  new(this.confirmed);

  final ProbeResult confirmed;

  @override
  AsyncValue<ProbeResult?> build() => AsyncData(confirmed);
}

/// "Znajdź GI Home" (plan §17.1, §9.2): the search with candidates found,
/// manual entry after an empty search, and the confirmation card.
void main() {
  late SharedPreferencesWithCache prefs;

  void connectGoldens(
    String description, {
    required String fileName,
    required ApplianceSearch search,
    ProbeResult? confirming,
    PumpAction settle = onlyPumpAndSettle,
  }) => screenGoldens(
    description,
    fileName: fileName,
    screen: ConnectScreen.new,
    prepare: (tester) async {
      prefs = (await tester.runAsync(inMemoryPreferences))!;
    },
    overrides: () => [
      sharedPreferencesProvider.overrideWithValue(prefs),
      applianceSearchProvider.overrideWith((ref) => Stream.value(search)),
      if (confirming != null)
        connectControllerProvider.overrideWith(() => _Confirming(confirming)),
    ],
    settle: settle,
  );

  connectGoldens(
    'Connect: still searching, two appliances found',
    fileName: 'connect_searching',
    search: ApplianceSearch(
      candidates: [
        ApplianceCandidate(
          probe: _probe('gi-home.local'),
          source: CandidateSource.localName,
          rank: 0,
        ),
        ApplianceCandidate(
          probe: _probe('gi-home-2.local', deviceName: 'Kotłownia'),
          source: CandidateSource.localName,
          rank: 1,
        ),
      ],
    ),
    // The progress bar never settles: freeze it at a fixed frame.
    settle: (tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    },
  );

  connectGoldens(
    'Connect: nothing found, enter the address',
    fileName: 'connect_manual',
    search: const ApplianceSearch(done: true),
  );

  connectGoldens(
    'Connect: is this your GI Home?',
    fileName: 'connect_confirm',
    search: const ApplianceSearch(done: true),
    confirming: _probe('192.168.1.20'),
  );
}
