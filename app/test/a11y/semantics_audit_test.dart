import 'dart:async';

import 'package:alchemist/alchemist.dart' show pumpNTimes;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/account/application/account_controllers.dart';
import 'package:gi_home/src/features/account/application/account_providers.dart';
import 'package:gi_home/src/features/account/presentation/account_screen.dart';
import 'package:gi_home/src/features/account/presentation/sessions_screen.dart';
import 'package:gi_home/src/features/appliance/application/appliance_search.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_candidate.dart';
import 'package:gi_home/src/features/appliance/presentation/connect_screen.dart';
import 'package:gi_home/src/features/attention/presentation/attention_screen.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/auth/application/login_controller.dart';
import 'package:gi_home/src/features/auth/presentation/login_screen.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:gi_home/src/features/devices/domain/switch_command_state.dart';
import 'package:gi_home/src/features/devices/presentation/device_detail_screen.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/switch_command_panel.dart';
import 'package:gi_home/src/features/environment/application/environment_providers.dart';
import 'package:gi_home/src/features/history/presentation/history_screen.dart';
import 'package:gi_home/src/features/home/presentation/home_screen.dart';
import 'package:gi_home/src/features/schedules/application/schedule_providers.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:gi_home/src/features/schedules/presentation/schedules_screen.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';
import 'package:gi_home/src/features/settings/presentation/settings_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../golden/golden_devices.dart';
import '../support/account_fixtures.dart';
import '../support/environment_fixtures.dart';
import '../support/fake_device_source.dart';
import '../support/fixtures.dart';
import '../support/golden.dart';
import '../support/history_fixtures.dart';
import '../support/schedule_fixtures.dart';
import '../support/semantics.dart';
import '../support/test_app.dart';

/// What a screen reader gets on every main screen (M4 accessibility
/// audit): every control has a name, headings come in reading order, and
/// a state that appears without a user action (offline, stale, an error)
/// sits in a live region.
void main() {
  late FakeDeviceSource source;
  late DateTime clock;
  late SharedPreferencesWithCache prefs;

  setUp(() {
    clock = goldenNow;
    source = FakeDeviceSource(roomList: fixtureRooms());
  });

  Future<void> preparePrefs(WidgetTester tester) async {
    prefs = (await tester.runAsync(
      () => inMemoryPreferences(profile: testProfile),
    ))!;
  }

  void healthyDevices() {
    source
      ..deviceList = [
        goldenListed(GoldenIds.boiler),
        goldenListed(GoldenIds.lamp, seenAgo: const Duration(minutes: 1)),
        goldenListed(GoldenIds.sensor, seenAgo: const Duration(minutes: 2)),
      ]
      ..details[GoldenIds.boiler] = goldenBoilerDetail({'diagnostics': null});
  }

  List<Override> deviceOverrides({CurrentUser? user}) => [
    deviceReadSourceProvider.overrideWithValue(source),
    environmentSourceProvider.overrideWithValue(FakeEnvironmentSource()),
    currentUserProvider.overrideWithValue(user),
    appForegroundProvider.overrideWithValue(AppForeground()),
    clockProvider.overrideWithValue(() => clock),
  ];

  const retry = 'Spróbuj ponownie';
  const offline = 'Nie można połączyć się z GI Home';

  group('Home', () {
    auditedScreen(
      'names its devices, groups them under room headings and announces '
      'that everything is fine',
      screen: HomeScreen.new,
      prepare: (_) async => healthyDevices(),
      overrides: deviceOverrides,
      verify: (semantics, _) {
        semantics
          ..expectControlsNamed()
          ..expectControl('Sterownik kotłowni')
          ..expectHeadingsInOrder(['Kotłownia', 'Salon', 'Bez pokoju'])
          ..expectLiveRegion('Wszystko w porządku');
      },
    );

    auditedScreen(
      'announces that GI Home became unreachable',
      screen: HomeScreen.new,
      prepare: (_) async => healthyDevices(),
      overrides: deviceOverrides,
      act: (tester) async {
        source
          ..devicesFailure = const ApiFailure.unreachable()
          ..roomsFailure = const ApiFailure.unreachable()
          ..detailFailure = const ApiFailure.unreachable();
        clock = goldenNow.add(const Duration(minutes: 3));
        await tester.pump(const Duration(seconds: 30));
        await tester.pumpAndSettle();
      },
      verify: (semantics, _) {
        semantics
          ..expectControlsNamed()
          ..expectLiveRegion('Brak połączenia z GI Home');
      },
    );

    auditedScreen(
      'announces a failed first load and offers a retry',
      screen: HomeScreen.new,
      prepare: (_) async =>
          source.devicesFailure = const ApiFailure.unreachable(),
      overrides: deviceOverrides,
      verify: (semantics, _) {
        semantics
          ..expectControl(retry)
          ..expectLiveRegion(offline);
      },
    );
  });

  group('Device details', () {
    void detail(
      String description, {
      required void Function(ScreenSemantics semantics) verify,
      String connectivity = 'ONLINE',
      Duration seenAgo = const Duration(seconds: 30),
      Map<String, Object?> device = const {},
      Future<void> Function(WidgetTester tester)? act,
    }) => auditedScreen(
      description,
      screen: () => const DeviceDetailScreen(deviceId: GoldenIds.boiler),
      prepare: (_) async {
        source
          ..deviceList = [
            goldenListed(
              GoldenIds.boiler,
              connectivity: connectivity,
              seenAgo: seenAgo,
              overrides: device,
            ),
          ]
          ..details[GoldenIds.boiler] = goldenBoilerDetail({
            'connectivityState': connectivity,
            'status': connectivity.toLowerCase(),
            'lastSeenAt': goldenNow.subtract(seenAgo).toIso8601String(),
            ...device,
          });
      },
      overrides: deviceOverrides,
      act: act,
      verify: (semantics, _) => verify(semantics..expectControlsNamed()),
    );

    detail(
      'has named controls and section headings',
      verify: (semantics) => expect(semantics.headings, isNotEmpty),
    );

    detail(
      'announces that GI Home became unreachable',
      act: (tester) async {
        source.detailFailure = const ApiFailure.unreachable();
        clock = goldenNow.add(const Duration(minutes: 3));
        await tester.pump(const Duration(seconds: 30));
        await tester.pumpAndSettle();
      },
      verify: (semantics) =>
          semantics.expectLiveRegion('Brak połączenia z GI Home'),
    );

    detail(
      'announces a suspended heating',
      device: const {'heatingSuspended': true},
      verify: (semantics) =>
          semantics.expectLiveRegion('Ogrzewanie jest wstrzymane'),
    );
  });

  group('Schedules', () {
    final clockZone = ScheduleClock(
      zone: IanaScheduleZone.tryParse('Europe/Warsaw'),
    );
    final now = DateTime.utc(2026, 11, 23, 6, 30);

    List<Override> overrides(FakeScheduleSource schedules) => [
      scheduleSourceProvider.overrideWithValue(schedules),
      currentUserProvider.overrideWithValue(testAccountUser),
      scheduleClockProvider.overrideWithValue(clockZone),
      clockProvider.overrideWithValue(() => now),
    ];

    auditedScreen(
      'names the schedules and the add button',
      screen: () => const SchedulesScreen(deviceId: 'd1'),
      overrides: () => overrides(
        FakeScheduleSource({
          'd1': [scheduleRow('morning', name: 'Rano')],
        }),
      ),
      verify: (semantics, _) {
        semantics
          ..expectControlsNamed()
          ..expectControl('Rano')
          ..expectControl('Dodaj harmonogram');
      },
    );

    late FakeScheduleSource failing;
    auditedScreen(
      'announces when a reload failed and the old list is shown',
      screen: () => const SchedulesScreen(deviceId: 'd1'),
      overrides: () => overrides(
        failing = FakeScheduleSource({
          'd1': [scheduleRow('morning', name: 'Rano')],
        }),
      ),
      act: (tester) async {
        failing.listFailure = const ApiFailure.unreachable();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(SchedulesScreen)),
        );
        await container.read(schedulesProvider('d1').notifier).refresh();
        await tester.pumpAndSettle();
      },
      verify: (semantics, _) {
        semantics
          ..expectControl('Rano')
          ..expectLiveRegion('Brak połączenia z GI Home');
      },
    );

    auditedScreen(
      'announces a failed first load and offers a retry',
      screen: () => const SchedulesScreen(deviceId: 'd1'),
      overrides: () => overrides(
        FakeScheduleSource()..listFailure = const ApiFailure.unreachable(),
      ),
      verify: (semantics, _) {
        semantics
          ..expectControl(retry)
          ..expectLiveRegion(offline);
      },
    );
  });

  group('History', () {
    auditedScreen(
      'names the window and table controls',
      screen: () => const HistoryScreen(
        deviceId: historyDeviceId,
        entityId: supplyEntityId,
      ),
      overrides: () => historyOverrides(
        FakeHistorySource(series: {supplyEntityId: temperatureSamples()}),
      ),
      verify: (semantics, _) => semantics.expectControlsNamed(),
    );

    auditedScreen(
      'announces that the history could not be loaded',
      screen: () => const HistoryScreen(
        deviceId: historyDeviceId,
        entityId: supplyEntityId,
      ),
      overrides: () => historyOverrides(
        FakeHistorySource(error: const ApiFailure.unreachable()),
      ),
      verify: (semantics, _) {
        semantics
          ..expectControl(retry)
          ..expectLiveRegion(offline);
      },
    );
  });

  group('Attention', () {
    List<Override> overrides() => [...deviceOverrides(user: testAccountUser)];

    auditedScreen(
      'announces that the list could not be loaded and offers a retry',
      screen: AttentionScreen.new,
      prepare: (_) async =>
          source.devicesFailure = const ApiFailure.unreachable(),
      overrides: overrides,
      verify: (semantics, _) {
        semantics
          ..expectControl(retry)
          ..expectLiveRegion(offline);
      },
    );

    auditedScreen(
      'has named controls and a heading for each weight',
      screen: AttentionScreen.new,
      prepare: (_) async {
        source.deviceList = [
          goldenListed(
            GoldenIds.lamp,
            connectivity: 'OFFLINE',
            seenAgo: const Duration(minutes: 40),
          ),
          goldenListed(GoldenIds.boiler, overrides: {'currentState': 'FAULT'}),
        ];
      },
      overrides: overrides,
      verify: (semantics, _) {
        semantics.expectControlsNamed();
        expect(semantics.headings, isNotEmpty);
      },
    );
  });

  group('Settings', () {
    auditedScreen(
      'names every row and groups them under headings',
      screen: SettingsScreen.new,
      prepare: preparePrefs,
      overrides: () => [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appInfoProvider.overrideWithValue(testAppInfo),
        currentUserProvider.overrideWithValue(testAccountUser),
        applianceRunningVersionProvider.overrideWith((ref) async => '1.4.2'),
        systemSettingsProvider.overrideWith((ref) async => null),
      ],
      verify: (semantics, _) {
        semantics
          ..expectControlsNamed()
          ..expectControl('Wyloguj');
        expect(semantics.headings, isNotEmpty);
      },
    );
  });

  group('Account', () {
    final script = AccountScript();

    auditedScreen(
      'names the profile fields and the save button',
      screen: AccountScreen.new,
      overrides: () => [
        currentUserProvider.overrideWithValue(testAccountUser),
        userProfileProvider.overrideWith((ref) async => testAccountProfile),
        ...fakeAccountControllers(script),
      ],
      verify: (semantics, _) {
        semantics.expectControlsNamed();
        expect(semantics.headings, isNotEmpty);
      },
    );

    auditedScreen(
      'announces that the sessions could not be loaded',
      screen: SessionsScreen.new,
      overrides: () => [
        authSessionsProvider.overrideWith(
          (ref) => Future<List<AuthSessionInfo>>.error(
            const ApiFailure.unreachable(),
          ),
        ),
        ...fakeAccountControllers(script),
      ],
      verify: (semantics, _) {
        semantics
          ..expectControl(retry)
          ..expectLiveRegion(offline);
      },
    );
  });

  group('Login', () {
    auditedScreen(
      'names the form fields and the submit button',
      screen: LoginScreen.new,
      prepare: preparePrefs,
      overrides: () => [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authSessionProvider.overrideWith(_SignedOut.new),
      ],
      verify: (semantics, _) => semantics.expectControlsNamed(),
    );

    auditedScreen(
      'announces a rejected password',
      screen: LoginScreen.new,
      prepare: preparePrefs,
      overrides: () => [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authSessionProvider.overrideWith(_SignedOut.new),
        loginControllerProvider.overrideWith(_RejectedLogin.new),
      ],
      verify: (semantics, _) =>
          semantics.expectLiveRegion('Nieprawidłowy e-mail lub hasło'),
    );
  });

  group('Command progress', () {
    void panel(
      String description, {
      required SwitchCommandState command,
      required Pattern announces,
    }) => auditedScreen(
      description,
      // A progress indicator never settles.
      settle: pumpNTimes(2),
      screen: () => Scaffold(
        body: ListView(
          children: [
            SwitchCommandPanel(
              entityName: 'Oświetlenie kotłowni',
              current: false,
              decision: const Allowed(),
              command: command,
              fetchedAt: goldenNow,
              now: goldenNow,
              onToggle: (_) {},
              onRefresh: () {},
            ),
          ],
        ),
      ),
      verify: (semantics, _) {
        semantics
          ..expectControlsNamed(requireAny: false)
          ..expectLiveRegion(announces);
      },
    );

    panel(
      'announces that the command is being sent',
      command: const SwitchSending(requested: true),
      announces: RegExp('.'),
    );

    panel(
      'announces that it waits for the controller to report',
      command: SwitchAwaitingHeartbeat(
        requested: true,
        confirmedAt: goldenNow,
        dryRun: false,
      ),
      announces: 'czeka na raport sterownika',
    );

    panel(
      'announces that the controller did not answer in time',
      command: SwitchTimedOut(requested: true, confirmedAt: goldenNow),
      announces: 'stan jest nieznany',
    );
  });

  group('Connect', () {
    auditedScreen(
      'names the manual entry controls',
      screen: ConnectScreen.new,
      prepare: preparePrefs,
      overrides: () => [
        sharedPreferencesProvider.overrideWithValue(prefs),
        applianceSearchProvider.overrideWith(
          (ref) => Stream.value(const ApplianceSearch(done: true)),
        ),
      ],
      verify: (semantics, _) => semantics.expectControlsNamed(),
    );
  });
}

/// Nobody is signed in.
class _SignedOut extends AuthSessionNotifier {
  @override
  Future<AuthState> build() async => const AuthState.unauthenticated();
}

/// The last submission was rejected.
class _RejectedLogin extends LoginController {
  @override
  AsyncValue<void> build() => const AsyncError(
    ApiFailure.unauthorized(code: 'AUTH_INVALID_CREDENTIALS'),
    StackTrace.empty,
  );
}
