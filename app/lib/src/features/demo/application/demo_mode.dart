import 'package:flutter/services.dart' show rootBundle;
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/account/domain/app_locale.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';
import 'package:gi_home/src/features/demo/data/demo_core.dart';
import 'package:gi_home/src/features/demo/data/demo_http_client_adapter.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'demo_mode.g.dart';

/// Reads the bundled demo fixtures (`demo_core.json`).
typedef DemoFixturesLoader = Future<String> Function();

/// The asset with the demo appliance's fixtures.
const demoFixturesAsset = 'assets/demo_fixtures/demo_core.json';

/// Overridden in tests, which read the asset from disk.
@Riverpod(keepAlive: true)
DemoFixturesLoader demoFixturesLoader(Ref ref) =>
    () => rootBundle.loadString(demoFixturesAsset);

/// One run of demo mode: the in-memory appliance, its transport, profile
/// and session. Nothing of it is written to preferences or secure storage.
@immutable
final class DemoSession {
  const new({
    required this.core,
    required this.adapter,
    required this.profile,
    required this.vault,
  });

  final DemoCore core;
  final DemoHttpClientAdapter adapter;

  /// Held in memory in place of the saved profile.
  final ApplianceProfile profile;

  /// The demo session's refresh cookie, in memory only.
  final TokenVault vault;
}

/// Demo mode (plan §19.5): entered with the visible "Wypróbuj wersję
/// demonstracyjną" button on the connect screen, left with "Zakończ demo"
/// on the permanent DEMO banner. `null` outside demo mode.
///
/// While it is on, the GI Core transport, the appliance profile and the
/// token vault are the demo ones: the saved profile, its stored session and
/// the real appliance are never read or written. Leaving drops all demo
/// state; routing then follows the saved profile again (the connect screen
/// when there is none).
@Riverpod(keepAlive: true)
class DemoMode extends _$DemoMode {
  @override
  DemoSession? build() => null;

  /// Starts a fresh demo, signed in as the demo owner.
  Future<void> enter() async {
    final json = await ref.read(demoFixturesLoaderProvider)();
    final clock = ref.read(clockProvider);
    final core = DemoCore.fromJsonString(json, now: clock);
    final now = clock().toUtc();
    final setup = core.setup;
    if (!ref.mounted) return;
    state = DemoSession(
      core: core,
      adapter: DemoHttpClientAdapter(
        core,
        latency: const Duration(milliseconds: 250),
        // What the app shows in demo mode: the language picked in Settings,
        // else the demo user's profile language.
        languageCode: () =>
            ref.read(languagePreferenceProvider)?.languageCode ??
            supportedAppLocale(core.profileLocale)?.languageCode ??
            'pl',
      ),
      profile: ApplianceProfile(
        profileId: demoProfileId,
        label: setup['deviceName']! as String,
        baseUrl: demoBaseUrl,
        hosts: const [demoBaseUrl],
        deviceName: setup['deviceName'] as String?,
        initializedAt: DateTime.parse(setup['initializedAt']! as String),
        lastUserEmail: core.user['email'] as String?,
        lastUserId: core.user['id'] as String?,
      ),
      // A stored session, so the app restores it like a returning user.
      vault: InMemoryTokenVault(
        RefreshCookie(
          name: 'gi_refresh_token',
          value: '00000000-0000-4000-8000-000000000000.${'D' * 43}',
          path: '/api/v1/auth/refresh',
          obtainedAt: now,
          absoluteExpiry: now.add(const Duration(days: 30)),
        ),
      ),
    );
  }

  /// Ends demo mode and wipes its state.
  void exit() => state = null;
}

/// Profile id of the demo appliance; never a real profile's (those are 32
/// hex digits).
const demoProfileId = 'demo';

/// Address of the demo appliance. `.invalid` never resolves, and the demo
/// transport answers every request in process anyway.
const demoBaseUrl = 'https://demo.gi-home.invalid';

/// Whether demo mode is on.
@Riverpod(keepAlive: true)
bool isDemo(Ref ref) => ref.watch(demoModeProvider) != null;
