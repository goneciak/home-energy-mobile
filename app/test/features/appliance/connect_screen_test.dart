import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/platform/app_settings_opener.dart';
import 'package:gi_home/src/core/platform/local_network_permission.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/appliance/data/host_resolver.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';
import 'package:gi_home/src/features/appliance/presentation/connect_screen.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/accessibility.dart';
import '../../support/fake_core_adapter.dart';
import '../../support/fake_platform.dart';
import '../../support/test_app.dart';

/// A resolver whose every lookup waits for [release].
final class HeldHostResolver implements HostResolver {
  final _release = Completer<void>();

  void release() => _release.complete();

  @override
  Future<String?> resolve(String name) async {
    await _release.future;
    return null;
  }
}

/// `/setup/status` of a second appliance in the same house.
final Map<String, Object> boilerRoomSetup = {
  ...initializedSetup,
  'deviceName': 'Kotłownia',
  'initializedAt': '2026-03-01T08:00:00.000Z',
};

void main() {
  late FakeCoreAdapter core;
  late ProviderContainer container;
  late InMemoryTokenVault vault;
  late FakeSettingsOpener settings;
  late Directory reportRoot;

  /// `/setup/status` per host; others answer as the dev appliance.
  late Map<String, Map<String, Object?>> setupByHost;

  Future<void> pumpConnect(
    WidgetTester tester, {
    AppFlavor flavor = AppFlavor.prod,
    HostResolver resolver = const StaticHostResolver({}),
    ApplianceProfile? profile,
    Map<FeatureFlag, bool> flags = const {},
    LocalNetworkPermissionBackend? permission,
    bool settle = true,
  }) async {
    tester.view
      ..physicalSize = const Size(1200, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final prefs = await tester.runAsync(
      () => inMemoryPreferences(profile: profile),
    );
    await tester.pumpWidget(
      testScreen(
        const ConnectScreen(),
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(flavor, flagDefaults: flags),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs!),
          appInfoProvider.overrideWithValue(testAppInfo),
          coreHttpClientAdapterProvider.overrideWithValue(core),
          hostResolverProvider.overrideWithValue(resolver),
          tokenVaultProvider.overrideWith(
            (ref) => ref.watch(applianceProfileProvider) == null ? null : vault,
          ),
          appSettingsOpenerProvider.overrideWithValue(settings),
          reportDirectoryProvider.overrideWithValue(() async => reportRoot),
          if (permission != null)
            localNetworkPermissionProvider.overrideWithValue(
              LocalNetworkPermission(permission),
            ),
        ],
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
    container = ProviderScope.containerOf(
      tester.element(find.byType(ConnectScreen)),
    );
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  Future<void> probe(WidgetTester tester, String address) async {
    await tester.enterText(find.byType(TextFormField), address);
    await tapText(tester, 'Sprawdź');
  }

  Finder candidate(String host) =>
      find.byKey(ValueKey('connect-candidate-$host'));

  final cleartextNotice = find.textContaining(
    'Połączenie w sieci domowej nie jest szyfrowane',
  );

  setUp(() {
    reportRoot = Directory.systemTemp.createTempSync('gi-connect-');
    addTearDown(() => reportRoot.deleteSync(recursive: true));
    vault = InMemoryTokenVault();
    settings = FakeSettingsOpener();
    setupByHost = {};
    core = FakeCoreAdapter({
      ...mockCoreRoutes(),
      'GET /api/v1/setup/status': (request) =>
          jsonReply(setupByHost[request.uri.host] ?? initializedSetup),
    });
  });

  testWidgets('a found appliance is confirmed before it is saved', (
    tester,
  ) async {
    await pumpConnect(tester);

    await probe(tester, '10.0.2.2:3000');

    expect(find.text('Czy to Twój GI Home?'), findsOneWidget);
    expect(find.text('GI Home Dev · 10.0.2.2:3000'), findsOneWidget);
    expect(cleartextNotice, findsOneWidget);
    expect(container.read(applianceProfileProvider), isNull);
    expect(core.requestedRoutes, [
      'GET /api/v1/health/live',
      'GET /api/v1/setup/status',
    ]);
    expect(core.requests.first.uri.host, '10.0.2.2');

    await tester.tap(find.text('Tak, połącz'));
    await tester.pumpAndSettle();

    final profile = container.read(applianceProfileProvider)!;
    expect(profile.baseUrl, 'http://10.0.2.2:3000');
    expect(profile.hosts, ['http://10.0.2.2:3000']);
    expect(profile.label, 'GI Home Dev');
    expect(profile.initializedAt, DateTime.utc(2026, 11, 17, 22, 6, 20, 184));
    expect(profile.cleartextNoticeShown, isTrue);
  });

  testWidgets('"No" returns to the address form without saving', (
    tester,
  ) async {
    await pumpConnect(tester);
    await probe(tester, 'localhost:3000');

    await tester.tap(find.text('Nie, wpisz inny adres'));
    await tester.pumpAndSettle();

    expect(find.text('Czy to Twój GI Home?'), findsNothing);
    expect(find.text('localhost:3000'), findsOneWidget);
    expect(container.read(applianceProfileProvider), isNull);
  });

  testWidgets('an appliance that is not set up is flagged and saved '
      'without a fingerprint', (tester) async {
    setupByHost['192.168.1.20'] = uninitializedSetup;
    await pumpConnect(tester);

    await probe(tester, '192.168.1.20');

    expect(find.text('GI Home · 192.168.1.20'), findsOneWidget);
    expect(
      find.text('To urządzenie nie jest jeszcze skonfigurowane.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Tak, połącz'));
    await tester.pumpAndSettle();

    final profile = container.read(applianceProfileProvider)!;
    expect(profile.initializedAt, isNull);
    expect(profile.label, '192.168.1.20');
  });

  testWidgets('an unreachable address shows a friendly message', (
    tester,
  ) async {
    core.routes['GET /api/v1/health/live'] = refuseConnection;
    await pumpConnect(tester);

    await probe(tester, '192.168.1.99:3000');

    expect(
      find.text(
        'Nie można połączyć się z GI Home. Sprawdź, czy telefon jest w tej '
        'samej sieci Wi-Fi.',
      ),
      findsOneWidget,
    );
    expect(find.text('Czy to Twój GI Home?'), findsNothing);
    expect(find.text('Otwórz ustawienia'), findsNothing);
    expect(container.read(applianceProfileProvider), isNull);
  });

  testWidgets('another web server is not mistaken for GI Home', (tester) async {
    core.routes['GET /api/v1/health/live'] = (_) =>
        htmlReply('<html>router login</html>');
    await pumpConnect(tester);

    await probe(tester, '192.168.1.1');

    expect(
      find.text('Pod tym adresem odpowiada inne urządzenie, nie GI Home.'),
      findsOneWidget,
    );
  });

  testWidgets('cleartext outside the home network is refused without a '
      'request', (tester) async {
    await pumpConnect(tester);

    await probe(tester, 'http://example.com');

    expect(
      find.textContaining('dozwolone tylko w sieci domowej'),
      findsOneWidget,
    );
    expect(core.requests, isEmpty);
  });

  testWidgets('an unparsable address is reported', (tester) async {
    await pumpConnect(tester);

    await probe(tester, 'ftp://gi-home.local');

    expect(
      find.textContaining('To nie wygląda na poprawny adres'),
      findsOneWidget,
    );
    expect(core.requests, isEmpty);
  });

  group('Znajdź GI Home (plan §9.2)', () {
    testWidgets('lists every confirmed candidate and confirms the picked '
        'one', (tester) async {
      setupByHost['gi-home-2.local'] = boilerRoomSetup;
      await pumpConnect(
        tester,
        resolver: const StaticHostResolver({
          'gi-home.local',
          'gi-home-2.local',
        }),
      );

      expect(find.text('Szukam GI Home…'), findsNothing);
      expect(candidate('http://gi-home.local'), findsOneWidget);
      expect(candidate('http://gi-home-2.local'), findsOneWidget);
      expect(find.text('GI Home Dev'), findsOneWidget);
      expect(find.text('Kotłownia'), findsOneWidget);
      expect(find.text('gi-home-2.local'), findsOneWidget);
      expect(find.text('Szukaj ponownie'), findsOneWidget);

      await tester.tap(candidate('http://gi-home-2.local'));
      await tester.pumpAndSettle();

      expect(find.text('Czy to Twój GI Home?'), findsOneWidget);
      expect(find.text('Kotłownia · gi-home-2.local'), findsOneWidget);
      // Nothing more was sent: the ladder probed it already.
      expect(core.requests, hasLength(4));

      await tester.tap(find.text('Tak, połącz'));
      await tester.pumpAndSettle();

      final profile = container.read(applianceProfileProvider)!;
      expect(profile.baseUrl, 'http://gi-home-2.local');
      expect(profile.label, 'Kotłownia');
    });

    testWidgets('manual entry stays visible during and after the search', (
      tester,
    ) async {
      final resolver = HeldHostResolver();
      await pumpConnect(tester, resolver: resolver, settle: false);

      expect(find.text('Szukam GI Home…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Albo wpisz adres'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Sprawdź'), findsOneWidget);

      resolver.release();
      await tester.pumpAndSettle();

      expect(find.text('Szukam GI Home…'), findsNothing);
      expect(
        find.text(
          'Nie znaleziono GI Home w tej sieci. Wpisz jego adres poniżej.',
        ),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Sprawdź'), findsOneWidget);
    });

    testWidgets("the saved profile's hosts are tried first and marked", (
      tester,
    ) async {
      await pumpConnect(tester, profile: testProfile);

      expect(candidate('http://10.0.2.2:3000'), findsOneWidget);
      expect(find.text('10.0.2.2:3000 · Obecne urządzenie'), findsOneWidget);
    });

    testWidgets('another appliance replaces the profile only after the '
        'replacement confirmation, which wipes the old session', (
      tester,
    ) async {
      setupByHost['gi-home-2.local'] = boilerRoomSetup;
      await vault.write(
        RefreshCookie(
          name: 'gi_refresh_token',
          value: '11111111-1111-4111-8111-111111111111.${'B' * 43}',
          path: '/api/v1/auth/refresh',
          obtainedAt: DateTime.utc(2026, 11, 17),
          absoluteExpiry: DateTime.utc(2099),
        ),
      );
      await pumpConnect(
        tester,
        profile: testProfile,
        resolver: const StaticHostResolver({'gi-home-2.local'}),
      );
      // The stored session is restored, as on the restore screen.
      final session = container.listen(authSessionProvider, (_, _) {});
      addTearDown(session.close);
      await tester.pumpAndSettle();
      expect(session.read().value, isA<AuthAuthenticated>());

      await tester.tap(candidate('http://gi-home-2.local'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tak, połącz'));
      await tester.pumpAndSettle();

      expect(find.text('Zmienić urządzenie?'), findsOneWidget);
      expect(
        find.text(
          'Spowoduje wylogowanie i usunięcie danych GI Home „GI Home Dev” '
          'z tego telefonu.',
        ),
        findsOneWidget,
      );

      // Cancelling keeps everything.
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      expect(
        container.read(applianceProfileProvider)?.profileId,
        testProfile.profileId,
      );
      expect(await vault.read(), isA<VaultPresent>());

      await tester.tap(find.text('Tak, połącz'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Zmień urządzenie'));
      await tester.pumpAndSettle();

      final profile = container.read(applianceProfileProvider)!;
      expect(profile.profileId, isNot(testProfile.profileId));
      expect(profile.baseUrl, 'http://gi-home-2.local');
      expect(profile.label, 'Kotłownia');
      expect(profile.lastUserEmail, isNull);
      expect(core.requestedRoutes, contains('POST /api/v1/auth/logout'));
      expect(await vault.read(), isA<VaultAbsent>());
      expect(await vault.readAccessToken(), isNull);
    });

    testWidgets('the saved appliance on a new address keeps its profile', (
      tester,
    ) async {
      await pumpConnect(tester, profile: testProfile);

      await probe(tester, 'gi-home.local');
      await tester.tap(find.text('Tak, połącz'));
      await tester.pumpAndSettle();

      expect(find.text('Zmienić urządzenie?'), findsNothing);
      final profile = container.read(applianceProfileProvider)!;
      expect(profile.profileId, testProfile.profileId);
      expect(profile.baseUrl, 'http://gi-home.local');
      expect(profile.hosts, ['http://gi-home.local', 'http://10.0.2.2:3000']);
    });
  });

  group('cleartext notice (plan §9.4)', () {
    testWidgets('shows on the first confirmation of a profile only, and '
        'again for a replacing profile', (tester) async {
      setupByHost['192.168.1.30'] = boilerRoomSetup;
      await pumpConnect(tester);

      await probe(tester, '10.0.2.2:3000');
      expect(cleartextNotice, findsOneWidget);
      await tester.tap(find.text('Tak, połącz'));
      await tester.pumpAndSettle();
      expect(
        container.read(applianceProfileProvider)!.cleartextNoticeShown,
        isTrue,
      );

      // The same appliance confirmed again, on another address.
      await tester.tap(find.text('Nie, wpisz inny adres'));
      await tester.pumpAndSettle();
      await probe(tester, 'localhost:3000');
      expect(find.text('GI Home Dev · localhost:3000'), findsOneWidget);
      expect(cleartextNotice, findsNothing);
      await tester.tap(find.text('Tak, połącz'));
      await tester.pumpAndSettle();

      // Another appliance replaces the profile: the notice is due again.
      await tester.tap(find.text('Nie, wpisz inny adres'));
      await tester.pumpAndSettle();
      await probe(tester, '192.168.1.30');
      expect(find.text('Kotłownia · 192.168.1.30'), findsOneWidget);
      expect(cleartextNotice, findsOneWidget);
      await tester.tap(find.text('Tak, połącz'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Zmień urządzenie'));
      await tester.pumpAndSettle();

      final replaced = container.read(applianceProfileProvider)!;
      expect(replaced.label, 'Kotłownia');
      expect(replaced.cleartextNoticeShown, isTrue);
    });
  });

  group('local network access denied (plan §9.4)', () {
    testWidgets('a denied permission ends the search with a way to the '
        'settings', (tester) async {
      final permission = FakePermissionBackend(
        sdkInt: 34,
        answer: LocalNetworkPermissionStatus.permanentlyDenied,
      );
      await pumpConnect(
        tester,
        flavor: AppFlavor.dev,
        flags: {FeatureFlag.androidLocalNetworkPermissionRequest: true},
        permission: permission,
        resolver: const StaticHostResolver({'gi-home.local'}),
      );

      expect(permission.requests, 1);
      expect(
        find.text(
          'GI Home nie ma dostępu do sieci lokalnej. Zezwól na dostęp w '
          'Ustawieniach telefonu.',
        ),
        findsOneWidget,
      );
      expect(core.requests, isEmpty);
      // Manual entry stays.
      expect(find.byType(TextFormField), findsOneWidget);

      await tapText(tester, 'Otwórz ustawienia');

      expect(settings.opened, 1);
    });

    testWidgets('without the flag nothing is asked', (tester) async {
      final permission = FakePermissionBackend(
        sdkInt: 34,
        answer: LocalNetworkPermissionStatus.denied,
      );
      await pumpConnect(tester, flavor: AppFlavor.dev, permission: permission);

      expect(permission.requests, 0);
      expect(find.text('Otwórz ustawienia'), findsNothing);
    });

    testWidgets('a probe the system refused offers the settings', (
      tester,
    ) async {
      core.routes['GET /api/v1/health/live'] = (request) =>
          throw DioException.connectionError(
            requestOptions: request,
            reason: 'denied',
            error: SocketException(
              'Connection failed',
              osError: const OSError('Operation not permitted', 1),
              address: InternetAddress('192.168.1.20'),
            ),
          );
      await pumpConnect(tester);

      await probe(tester, '192.168.1.20');
      expect(
        find.textContaining('GI Home nie ma dostępu do sieci lokalnej'),
        findsOneWidget,
      );
      await tapText(tester, 'Otwórz ustawienia');

      expect(settings.opened, 1);
    });
  });

  group('dev presets (plan §9.6)', () {
    Finder preset(DevAddressPreset preset) =>
        find.byKey(ValueKey('connect-preset-${preset.name}'));
    String field(WidgetTester tester) =>
        tester.widget<TextField>(find.byType(TextField)).controller!.text;

    testWidgets('are listed in the dev flavor with their hints', (
      tester,
    ) async {
      await pumpConnect(tester, flavor: AppFlavor.dev);

      for (final label in [
        'Emulator Androida: 10.0.2.2:3000',
        'Symulator iOS: localhost:3000',
        'Android przez USB: localhost:3000',
        'Telefon w LAN: <IP-komputera>:3000',
        'Przez dev_lan_proxy: <IP-komputera>:8080',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(
        find.textContaining('adb reverse tcp:3000 tcp:3000'),
        findsOneWidget,
      );
      expect(find.textContaining('GI_CORE_BIND_ADDRESS=0.0.0.0'), findsOne);
    });

    for (final flavor in [AppFlavor.beta, AppFlavor.prod]) {
      testWidgets('are absent in ${flavor.name}', (tester) async {
        await pumpConnect(tester, flavor: flavor);

        expect(find.text('Podpowiedzi'), findsNothing);
        expect(find.byType(ActionChip), findsNothing);
        expect(find.textContaining('adb reverse'), findsNothing);
      });
    }

    testWidgets('fill the address for editing without probing it', (
      tester,
    ) async {
      await pumpConnect(tester, flavor: AppFlavor.dev);

      await tester.ensureVisible(preset(DevAddressPreset.iosSimulator));
      await tester.tap(preset(DevAddressPreset.iosSimulator));
      await tester.pumpAndSettle();

      expect(field(tester), 'localhost:3000');
      expect(core.requests, isEmpty);

      await tapText(tester, 'Sprawdź');

      expect(find.text('GI Home Dev · localhost:3000'), findsOneWidget);
    });

    testWidgets('LAN presets put the cursor where the IP goes', (tester) async {
      await pumpConnect(tester, flavor: AppFlavor.dev);

      for (final (lan, port) in [
        (DevAddressPreset.lanPhone, ':3000'),
        (DevAddressPreset.lanProxy, ':8080'),
      ]) {
        await tester.ensureVisible(preset(lan));
        await tester.tap(preset(lan));
        await tester.pumpAndSettle();

        final controller = tester
            .widget<TextField>(find.byType(TextField))
            .controller!;
        expect(controller.text, port);
        expect(controller.selection, const TextSelection.collapsed(offset: 0));
      }
      expect(core.requests, isEmpty);
    });
  });

  group('accessibility (plan §12.9)', () {
    testWidgets('the address form meets the guidelines', (tester) async {
      await pumpConnect(tester);

      await expectAccessibilityGuidelines(tester);
    });

    testWidgets('the candidate list meets the guidelines', (tester) async {
      setupByHost['gi-home-2.local'] = boilerRoomSetup;
      await pumpConnect(
        tester,
        profile: testProfile,
        resolver: const StaticHostResolver({
          'gi-home.local',
          'gi-home-2.local',
        }),
      );
      expect(candidate('http://gi-home-2.local'), findsOneWidget);

      await expectAccessibilityGuidelines(tester);
    });

    testWidgets('the confirmation meets the guidelines', (tester) async {
      await pumpConnect(tester);
      await probe(tester, '192.168.1.20');
      expect(find.text('Czy to Twój GI Home?'), findsOneWidget);

      await expectAccessibilityGuidelines(tester);
    });

    testWidgets('the dev presets meet the guidelines', (tester) async {
      await pumpConnect(tester, flavor: AppFlavor.dev);

      await expectAccessibilityGuidelines(tester);
    });
  });
}
