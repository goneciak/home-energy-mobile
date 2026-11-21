import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:gi_home/src/features/appliance/data/host_resolver.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_candidate.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';

import '../../support/fake_core_adapter.dart';

/// Answers `.local` names from a table: a host, `null` (not found), or a
/// function that may throw or never complete.
final class FakeHostResolver implements HostResolver {
  new([this.answers = const {}]);

  final Map<String, Future<String?> Function()> answers;
  final asked = <String>[];

  @override
  Future<String?> resolve(String name) async {
    asked.add(name);
    final answer = answers[name];
    return answer == null ? null : await answer();
  }
}

Future<String?> Function() resolvesTo(String host) =>
    () async => host;

/// `/setup/status` of another appliance: a different fingerprint.
Map<String, Object> otherSetup(String name, DateTime initializedAt) => {
  ...initializedSetup,
  'deviceName': name,
  'initializedAt': initializedAt.toIso8601String(),
};

final devFingerprint = DateTime.utc(2026, 11, 17, 22, 6, 20, 184);

ApplianceProfile savedProfile({String baseUrl = 'http://192.168.1.20'}) =>
    ApplianceProfile(
      profileId: '0123456789abcdef0123456789abcdef',
      label: 'GI Home Dev',
      baseUrl: baseUrl,
      hosts: [baseUrl],
      deviceName: 'GI Home Dev',
      initializedAt: devFingerprint,
    );

void main() {
  late MockCoreAdapter core;

  /// `/setup/status` per host; hosts not listed answer as the dev appliance.
  late Map<String, Map<String, Object?>> setupByHost;

  /// Hosts whose `/health/live` refuses the connection.
  late Set<String> downHosts;

  ConnectionLadder ladder(HostResolver resolver) => ConnectionLadder(
    probe: ApplianceProbe(
      clientInfo: const ClientInfo(appVersion: '0.1.0', platform: 'test'),
      httpClientAdapter: core,
    ),
    resolver: resolver,
  );

  setUp(() {
    setupByHost = {};
    downHosts = {};
    core = MockCoreAdapter({
      'GET /api/v1/health/live': (request) {
        if (downHosts.contains(request.uri.host)) refuseConnection(request);
        return jsonReply({'status': 'ok'});
      },
      'GET /api/v1/setup/status': (request) =>
          jsonReply(setupByHost[request.uri.host] ?? initializedSetup),
    });
  });

  List<String> hosts(ApplianceSearch search) => [
    for (final c in search.candidates) c.host,
  ];

  group('step 1: remembered hosts', () {
    test('a remembered host that answers is confirmed', () async {
      final updates = await ladder(FakeHostResolver())
          .search(rememberedHosts: ['http://192.168.1.20'])
          .toList();

      final last = updates.last;
      expect(last.done, isTrue);
      expect(last.failure, isNull);
      final candidate = last.candidates.single;
      expect(candidate.host, 'http://192.168.1.20');
      expect(candidate.source, CandidateSource.remembered);
      expect(candidate.deviceName, 'GI Home Dev');
      expect(candidate.initialized, isTrue);
      expect(candidate.fingerprint, devFingerprint);
      expect(core.requestedRoutes, [
        'GET /api/v1/health/live',
        'GET /api/v1/setup/status',
      ]);
    });

    test('a remembered host gets 1.5 s for /health/live', () {
      fakeAsync((async) {
        final hanging = Completer<ResponseBody>();
        core.routes['GET /api/v1/health/live'] = (request) =>
            request.uri.host == '192.168.1.20'
            ? hanging.future
            : jsonReply({'status': 'ok'});
        final updates = <ApplianceSearch>[];
        ladder(FakeHostResolver({'gi-home.local': resolvesTo('gi-home.local')}))
            .search(rememberedHosts: ['http://192.168.1.20'])
            .listen(updates.add);

        async.elapse(const Duration(milliseconds: 1499));
        expect(updates.where((u) => u.done), isEmpty);
        expect(hosts(updates.last), ['http://gi-home.local']);

        async.elapse(const Duration(milliseconds: 2));
        expect(updates.last.done, isTrue);
        expect(hosts(updates.last), ['http://gi-home.local']);
      });
    });

    test('a remembered host that no longer parses is skipped', () async {
      final last = await ladder(FakeHostResolver())
          .search(rememberedHosts: ['ftp://nope', 'http://192.168.1.20'])
          .last;

      expect(hosts(last), ['http://192.168.1.20']);
    });
  });

  group('step 2: .local names', () {
    test('every resolved name is probed as http://<name>, in order', () async {
      final resolver = FakeHostResolver({
        'gi-home.local': resolvesTo('gi-home.local'),
        'gi-home-2.local': resolvesTo('gi-home-2.local'),
        'gi-home-3.local': resolvesTo('gi-home-3.local'),
      });
      setupByHost['gi-home-2.local'] = otherSetup(
        'Kotłownia',
        DateTime.utc(2026, 1, 2),
      );
      setupByHost['gi-home-3.local'] = uninitializedSetup;

      final updates = await ladder(resolver).search().toList();

      expect(resolver.asked, ConnectionLadder.defaultLocalNames);
      final last = updates.last;
      expect(last.done, isTrue);
      expect(hosts(last), [
        'http://gi-home.local',
        'http://gi-home-2.local',
        'http://gi-home-3.local',
      ]);
      expect(
        [for (final c in last.candidates) c.deviceName],
        ['GI Home Dev', 'Kotłownia', null],
      );
      expect(last.candidates[2].initialized, isFalse);
      expect(last.candidates[2].fingerprint, isNull);
      expect(last.candidates.map((c) => c.source).toSet(), {
        CandidateSource.localName,
      });
      // The list grows one candidate at a time before the final state.
      expect([for (final u in updates) u.candidates.length], [1, 2, 3, 3]);
      expect([for (final u in updates) u.done], [false, false, false, true]);
      for (final request in core.requests) {
        expect(request.uri.scheme, 'http');
        expect(request.uri.port, 80);
      }
    });

    test('an appliance found on two addresses is listed once, under the '
        'remembered one', () async {
      final last = await ladder(
        FakeHostResolver({'gi-home.local': resolvesTo('gi-home.local')}),
      ).search(rememberedHosts: ['http://192.168.1.20']).last;

      expect(hosts(last), ['http://192.168.1.20']);
    });

    test(
      'an address that answers as something else is not a candidate',
      () async {
        core.routes['GET /api/v1/health/live'] = (request) =>
            request.uri.host == 'gi-home.local'
            ? htmlReply('<html>router</html>')
            : jsonReply({'status': 'ok'});

        final last = await ladder(
          FakeHostResolver({
            'gi-home.local': resolvesTo('gi-home.local'),
            'gi-home-2.local': resolvesTo('gi-home-2.local'),
          }),
        ).search().last;

        expect(hosts(last), ['http://gi-home-2.local']);
        expect(last.failure, isNull);
      },
    );

    test('a resolver that throws counts as "not found"', () async {
      final last = await ladder(
        FakeHostResolver({
          'gi-home.local': () async =>
              throw const SocketException('Failed host lookup'),
          'gi-home-2.local': () async => throw StateError('broken resolver'),
          'gi-home-3.local': resolvesTo('gi-home-3.local'),
          'gi-home-4.local': resolvesTo('not a host!'),
        }),
      ).search().last;

      expect(last.done, isTrue);
      expect(hosts(last), ['http://gi-home-3.local']);
    });

    test('nothing found is done without a failure', () async {
      final last = await ladder(FakeHostResolver()).search().last;

      expect(last, const ApplianceSearch(done: true));
      expect(core.requests, isEmpty);
    });
  });

  test('every probe failing with local network access denied explains '
      'why nothing was found', () async {
    core.routes['GET /api/v1/health/live'] = (request) =>
        throw DioException.connectionError(
          requestOptions: request,
          reason: 'denied',
          error: SocketException(
            'Connection failed',
            osError: const OSError('Permission denied', 13),
            address: InternetAddress('192.168.1.20'),
          ),
        );

    final last = await ladder(FakeHostResolver())
        .search(rememberedHosts: ['http://192.168.1.20'])
        .last;

    expect(last.done, isTrue);
    expect(last.candidates, isEmpty);
    expect(last.failure, isA<LocalNetworkDeniedFailure>());
  });

  test('never more than 4 probes in flight (plan §11)', () async {
    var inFlight = 0;
    var peak = 0;
    core.routes['GET /api/v1/health/live'] = (_) async {
      inFlight++;
      peak = inFlight > peak ? inFlight : peak;
      await Future<void>.delayed(const Duration(milliseconds: 5));
      inFlight--;
      return jsonReply({'status': 'ok'});
    };
    final last =
        await ladder(
              FakeHostResolver({
                for (final name in ConnectionLadder.defaultLocalNames)
                  name: resolvesTo(name),
              }),
            )
            .search(
              rememberedHosts: [
                'http://192.168.1.20',
                'http://192.168.1.21',
                'http://192.168.1.22',
              ],
            )
            .last;

    expect(last.done, isTrue);
    expect(peak, lessThanOrEqualTo(ConcurrencyLimiter.perApplianceRequests));
  });

  group('rebinding (plan §9.3)', () {
    test('the saved appliance under gi-home.local is found when its IP '
        'fails', () async {
      downHosts.add('192.168.1.20');

      final moved = await ladder(
        FakeHostResolver({'gi-home.local': resolvesTo('gi-home.local')}),
      ).findMoved(savedProfile());

      expect(moved?.host, 'http://gi-home.local');
      expect(moved?.fingerprint, devFingerprint);
      // The saved address is tried once more, and still fails.
      expect(core.requests.map((r) => r.uri.host).toSet(), {
        '192.168.1.20',
        'gi-home.local',
      });

      final rebound = savedProfile().movedTo(moved!.host);
      expect(rebound.profileId, savedProfile().profileId);
      expect(rebound.initializedAt, devFingerprint);
      expect(rebound.baseUrl, 'http://gi-home.local');
      expect(rebound.hosts, ['http://gi-home.local', 'http://192.168.1.20']);
    });

    test('another appliance under a .local name is never taken for the '
        'saved one', () async {
      setupByHost['gi-home.local'] = otherSetup(
        'Sąsiad',
        DateTime.utc(2025, 5, 5),
      );

      final moved = await ladder(
        FakeHostResolver({'gi-home.local': resolvesTo('gi-home.local')}),
      ).findMoved(savedProfile());

      expect(moved, isNull);
    });

    test('a profile without a fingerprint is never rebound', () async {
      final moved = await ladder(
        FakeHostResolver({'gi-home.local': resolvesTo('gi-home.local')}),
      ).findMoved(savedProfile().asReset());

      expect(moved, isNull);
      expect(core.requests, isEmpty);
    });

    test('an appliance that answers on its saved address and on '
        'gi-home.local stays where it is', () async {
      final moved = await ladder(
        FakeHostResolver({'gi-home.local': resolvesTo('gi-home.local')}),
      ).findMoved(savedProfile());

      expect(moved, isNull);
      expect(core.requests.map((r) => r.uri.host), contains('192.168.1.20'));
    });

    test('a slow saved address is waited for, even when gi-home.local '
        'answers first', () {
      fakeAsync((async) {
        core.routes['GET /api/v1/health/live'] = (request) async {
          // Slower than the 1.5 s a remembered host gets on the connect
          // screen, as on a cold start of the Pi.
          if (request.uri.host == '192.168.1.20') {
            await Future<void>.delayed(const Duration(seconds: 3));
          }
          return jsonReply({'status': 'ok'});
        };
        ApplianceCandidate? moved;
        var done = false;
        unawaited(
          ladder(
            FakeHostResolver({'gi-home.local': resolvesTo('gi-home.local')}),
          ).findMoved(savedProfile()).then((value) {
            moved = value;
            done = true;
          }),
        );

        async.elapse(const Duration(seconds: 1));
        expect(done, isFalse, reason: 'gi-home.local alone does not decide');

        async.elapse(const Duration(seconds: 5));
        expect(done, isTrue);
        expect(moved, isNull);
      });
    });

    test('an https profile is never moved to http://gi-home.local', () async {
      final resolver = FakeHostResolver({
        'gi-home.local': resolvesTo('gi-home.local'),
      });
      final https = savedProfile(baseUrl: 'https://gi.instalator.pl');

      expect(await ladder(resolver).findMoved(https), isNull);
      expect(core.requests, isEmpty);

      // Also when such a candidate is found by a full search.
      final last = await ladder(resolver).search().last;
      expect(hosts(last), ['http://gi-home.local']);
      expect(rebindTarget(https, last.candidates), isNull);
    });

    test('rebindTarget stays put while the saved address answers', () async {
      final last = await ladder(
        FakeHostResolver({'gi-home.local': resolvesTo('gi-home.local')}),
      ).search(rememberedHosts: ['http://192.168.1.20']).last;
      final profile = savedProfile();

      // Listed once, under the remembered (saved) address.
      expect(rebindTarget(profile, last.candidates), isNull);
    });

    test('rebindTarget ignores remembered hosts', () async {
      final last = await ladder(FakeHostResolver())
          .search(rememberedHosts: ['http://192.168.1.30'])
          .last;

      expect(rebindTarget(savedProfile(), last.candidates), isNull);
    });
  });

  group('SystemHostResolver', () {
    test('a name that resolves is probed by name', () async {
      final resolver = SystemHostResolver(
        lookup: (host) async => [InternetAddress('192.168.1.20')],
      );

      expect(await resolver.resolve('gi-home.local'), 'gi-home.local');
    });

    test('a failed or empty lookup is "not found"', () async {
      expect(
        await SystemHostResolver(
          lookup: (host) async => throw const SocketException('no'),
        ).resolve('gi-home.local'),
        isNull,
      );
      expect(
        await SystemHostResolver(lookup: (host) async => []).resolve('x'),
        isNull,
      );
    });

    test('an unanswered lookup gives up after its timeout', () {
      fakeAsync((async) {
        String? result = 'pending';
        unawaited(
          SystemHostResolver(
            lookup: (host) => Completer<List<InternetAddress>>().future,
          ).resolve('gi-home.local').then((r) => result = r),
        );
        async.elapse(const Duration(milliseconds: 1999));
        expect(result, 'pending');
        async.elapse(const Duration(milliseconds: 2));
        expect(result, isNull);
      });
    });

    test('FirstHostResolver falls through to the next resolver (the '
        'multicast_dns extension point)', () async {
      final resolver = FirstHostResolver([
        FakeHostResolver({'gi-home.local': () async => throw StateError('x')}),
        FakeHostResolver({'gi-home.local': resolvesTo('192.168.1.20')}),
      ]);

      expect(await resolver.resolve('gi-home.local'), '192.168.1.20');
      expect(await resolver.resolve('gi-home-2.local'), isNull);
    });
  });
}
