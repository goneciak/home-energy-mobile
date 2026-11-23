import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/appliance_rebinder.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:gi_home/src/features/appliance/data/host_resolver.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';

import '../../support/fake_core_adapter.dart';

final _fingerprint = DateTime.utc(2026, 11, 17, 22, 6, 20, 184);

ApplianceProfile _profile(String id) => ApplianceProfile(
  profileId: id,
  label: 'GI Home',
  baseUrl: 'http://192.168.1.20',
  hosts: ['http://192.168.1.20'],
  deviceName: 'GI Home',
  initializedAt: _fingerprint,
);

final class _Profile extends ApplianceProfileNotifier {
  new(this.initial);

  final ApplianceProfile initial;
  final rebound = <String>[];

  @override
  ApplianceProfile? build() => initial;

  @override
  Future<void> rebind(String origin) async => rebound.add(origin);

  // A test hook, not a property.
  // ignore: use_setters_to_change_properties
  void swapTo(ApplianceProfile profile) => state = profile;
}

/// Answers `gi-home.local` after running [beforeAnswer], like a search that
/// takes seconds.
final class _SlowResolver implements HostResolver {
  new(this.beforeAnswer);

  final void Function() beforeAnswer;

  @override
  Future<String?> resolve(String name) async {
    beforeAnswer();
    return name == 'gi-home.local' ? 'gi-home.local' : null;
  }
}

void main() {
  Future<(bool, List<String>)> run({required String? replacedBy}) async {
    final core = MockCoreAdapter({
      'GET /api/v1/health/live': (request) {
        if (request.uri.host == '192.168.1.20') refuseConnection(request);
        return jsonReply({'status': 'ok'});
      },
      'GET /api/v1/setup/status': (_) => jsonReply(initializedSetup),
    });
    final notifier = _Profile(_profile('0123456789abcdef0123456789abcdef'));
    final ladder = ConnectionLadder(
      probe: ApplianceProbe(
        clientInfo: const ClientInfo(appVersion: '0.1.0', platform: 'test'),
        httpClientAdapter: core,
      ),
      resolver: _SlowResolver(() {
        if (replacedBy != null) {
          notifier.swapTo(_profile(replacedBy));
        }
      }),
    );
    final container = ProviderContainer(
      overrides: [
        applianceProfileProvider.overrideWith(() => notifier),
        connectionLadderProvider.overrideWithValue(ladder),
      ],
    );
    addTearDown(container.dispose);
    final rebound = await container
        .read(applianceRebinderProvider)
        .rebindIfMoved();
    return (rebound, notifier.rebound);
  }

  test('follows the appliance to its new address', () async {
    final (rebound, origins) = await run(replacedBy: null);

    expect(rebound, isTrue);
    expect(origins, ['http://gi-home.local']);
  });

  test('a profile replaced during the search is left alone', () async {
    final (rebound, origins) = await run(
      replacedBy: 'fedcba9876543210fedcba9876543210',
    );

    expect(rebound, isFalse);
    expect(origins, isEmpty);
  });
}
