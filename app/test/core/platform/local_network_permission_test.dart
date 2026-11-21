import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/platform/local_network_permission.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_search.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:gi_home/src/features/appliance/data/host_resolver.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_candidate.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';

import '../../support/fake_core_adapter.dart';
import '../../support/fake_platform.dart';
import '../../support/test_app.dart';

void main() {
  // The probes read the app language.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalNetworkPermission', () {
    test('does nothing on iOS (no API level)', () async {
      final backend = FakePermissionBackend(sdkInt: null, answer: .denied);

      await LocalNetworkPermission(backend).ensureGranted();

      expect(backend.requests, 0);
    });

    test('does nothing below Android 13 (API 33)', () async {
      final backend = FakePermissionBackend(sdkInt: 32, answer: .denied);

      await LocalNetworkPermission(backend).ensureGranted();

      expect(backend.requests, 0);
    });

    test('asks for NEARBY_WIFI_DEVICES on Android 13+', () async {
      final backend = FakePermissionBackend(sdkInt: 33);

      await LocalNetworkPermission(backend).ensureGranted();

      expect(backend.requests, 1);
    });

    for (final answer in [
      LocalNetworkPermissionStatus.denied,
      LocalNetworkPermissionStatus.permanentlyDenied,
    ]) {
      test('${answer.name} is LocalNetworkDenied', () async {
        final backend = FakePermissionBackend(sdkInt: 36, answer: answer);

        await expectLater(
          LocalNetworkPermission(backend).ensureGranted(),
          throwsA(
            isA<LocalNetworkDeniedFailure>().having(
              (f) => f.reason,
              'reason',
              contains(answer.name),
            ),
          ),
        );
      });
    }

    test('a platform error does not block the search', () async {
      final backend = FakePermissionBackend(
        sdkInt: 34,
        error: PlatformException(code: 'busy'),
      );

      await LocalNetworkPermission(backend).ensureGranted();

      expect(backend.requests, 1);
    });

    test('channel answers are parsed', () {
      expect(
        LocalNetworkPermissionStatus.tryParse('permanentlyDenied'),
        LocalNetworkPermissionStatus.permanentlyDenied,
      );
      expect(LocalNetworkPermissionStatus.tryParse('weird'), isNull);
    });
  });

  group('the search asks first only with the flag on', () {
    Future<(ProviderContainer, FakePermissionBackend)> start({
      required bool flag,
      LocalNetworkPermissionStatus answer = .denied,
    }) async {
      final backend = FakePermissionBackend(sdkInt: 34, answer: answer);
      final prefs = await inMemoryPreferences();
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(
              AppFlavor.dev,
              flagDefaults: {
                FeatureFlag.androidLocalNetworkPermissionRequest: flag,
              },
            ),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs),
          appInfoProvider.overrideWithValue(testAppInfo),
          coreHttpClientAdapterProvider.overrideWithValue(
            FakeCoreAdapter(healthyApplianceRoutes()),
          ),
          hostResolverProvider.overrideWithValue(
            const StaticHostResolver({'gi-home.local'}),
          ),
          localNetworkPermissionProvider.overrideWithValue(
            LocalNetworkPermission(backend),
          ),
        ],
      );
      addTearDown(container.dispose);
      return (container, backend);
    }

    Future<ApplianceSearch> finished(ProviderContainer container) async {
      final subscription = container.listen(applianceSearchProvider, (_, _) {});
      addTearDown(subscription.close);
      while (true) {
        final search = await container.read(applianceSearchProvider.future);
        if (search.done) return search;
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('flag off: never asks, searches', () async {
      final (container, backend) = await start(flag: false);

      final search = await finished(container);

      expect(backend.requests, 0);
      expect(search.candidates.single.host, 'http://gi-home.local');
    });

    test('flag on and granted: searches', () async {
      final (container, backend) = await start(flag: true, answer: .granted);

      final search = await finished(container);

      expect(backend.requests, 1);
      expect(search.candidates, hasLength(1));
    });

    test('flag on and denied: LocalNetworkDenied, counted, no probe', () async {
      final (container, backend) = await start(flag: true);

      final search = await finished(container);

      expect(backend.requests, 1);
      expect(search.candidates, isEmpty);
      expect(search.failure, isA<LocalNetworkDeniedFailure>());
      final adapter =
          container.read(coreHttpClientAdapterProvider)! as FakeCoreAdapter;
      expect(adapter.requests, isEmpty);
      expect(
        container.read(diagnosticsServiceProvider).counters.localNetworkDenied,
        1,
      );
    });
  });
}
