import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:gi_home/src/features/appliance/data/host_resolver.dart';
import 'package:gi_home/src/features/appliance/data/multicast_dns_host_resolver.dart';

import '../../support/test_app.dart';

/// Answers from a table, like the network would; records what was asked.
final class FakeMdnsLookup implements MdnsAddressLookup {
  new([this.answers = const {}]);

  final Map<String, String> answers;
  Object? failure;
  Completer<String?>? never;
  final asked = <String>[];

  @override
  Future<String?> lookupIpv4(String name, {required Duration timeout}) {
    asked.add(name);
    if (failure case final failure?) return Future.error(failure);
    if (never case final never?) return never.future;
    return Future.value(answers[name]);
  }
}

final class _SystemCannotResolve implements HostResolver {
  const new();

  @override
  Future<String?> resolve(String name) async => null;
}

void main() {
  group('MulticastDnsHostResolver', () {
    test('returns the IP address the name answered with', () async {
      final resolver = MulticastDnsHostResolver(
        lookup: FakeMdnsLookup({'gi-home.local': '192.168.1.42'}),
      );

      expect(await resolver.resolve('gi-home.local'), '192.168.1.42');
    });

    test('an answer outside the local network is dropped', () async {
      for (final address in [
        '8.8.8.8',
        '127.0.0.1',
        '172.32.0.1',
        '192.169.1.1',
        'not-an-ip',
      ]) {
        final resolver = MulticastDnsHostResolver(
          lookup: FakeMdnsLookup({'gi-home.local': address}),
        );

        expect(
          await resolver.resolve('gi-home.local'),
          isNull,
          reason: address,
        );
      }
    });

    test('private and link-local answers are kept', () async {
      for (final address in [
        '10.0.0.5',
        '172.16.0.5',
        '172.31.255.1',
        '192.168.0.9',
        '169.254.1.1',
      ]) {
        final resolver = MulticastDnsHostResolver(
          lookup: FakeMdnsLookup({'gi-home.local': address}),
        );

        expect(await resolver.resolve('gi-home.local'), address);
      }
    });

    test('an unanswered name is not resolved', () async {
      final resolver = MulticastDnsHostResolver(lookup: FakeMdnsLookup());

      expect(await resolver.resolve('gi-home-2.local'), isNull);
    });

    test('only .local names are asked about', () async {
      final lookup = FakeMdnsLookup({'example.com': '1.2.3.4'});

      expect(
        await MulticastDnsHostResolver(lookup: lookup).resolve('example.com'),
        isNull,
      );
      expect(lookup.asked, isEmpty);
    });

    test('a client that never answers gives up', () {
      fakeAsync((async) {
        final lookup = FakeMdnsLookup()..never = Completer<String?>();
        String? answer = 'unset';
        unawaited(
          MulticastDnsHostResolver(lookup: lookup)
              .resolve('gi-home.local')
              .then((value) => answer = value),
        );

        async.elapse(const Duration(seconds: 4));

        expect(answer, isNull);
      });
    });

    test(
      'a failing client throws, which the chain counts as not found',
      () async {
        final lookup = FakeMdnsLookup()..failure = StateError('no multicast');
        final chain = FirstHostResolver([
          const _SystemCannotResolve(),
          MulticastDnsHostResolver(lookup: lookup),
          const StaticHostResolver({'gi-home.local'}),
        ]);

        expect(await chain.resolve('gi-home.local'), 'gi-home.local');
      },
    );

    test('is consulted only after the system resolver gave up', () async {
      final lookup = FakeMdnsLookup({'gi-home.local': '192.168.1.42'});
      final systemAnswers = FirstHostResolver([
        const StaticHostResolver({'gi-home.local'}),
        MulticastDnsHostResolver(lookup: lookup),
      ]);

      expect(await systemAnswers.resolve('gi-home.local'), 'gi-home.local');
      expect(lookup.asked, isEmpty);

      final systemFails = FirstHostResolver([
        const _SystemCannotResolve(),
        MulticastDnsHostResolver(lookup: lookup),
      ]);
      expect(await systemFails.resolve('gi-home.local'), '192.168.1.42');
    });
  });

  group('the fallback is off unless the flag is on, and Android only', () {
    HostResolver resolverFor({
      required bool flag,
      required TargetPlatform platform,
    }) {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(
              AppFlavor.prod,
              flagDefaults: {FeatureFlag.mdnsFallback: flag},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container.read(hostResolverProvider);
    }

    test('every flavor ships with the flag off', () {
      for (final flavor in AppFlavor.values) {
        expect(
          testConfig(flavor).flagDefaults.mdnsFallback,
          isFalse,
          reason: flavor.name,
        );
      }
    });

    test('flag off: the system resolver alone', () {
      final resolver = resolverFor(
        flag: false,
        platform: TargetPlatform.android,
      );

      expect(resolver, isA<SystemHostResolver>());
    });

    test('flag on, Android: the system resolver, then multicast DNS', () {
      final resolver = resolverFor(
        flag: true,
        platform: TargetPlatform.android,
      );

      expect(resolver, isA<FirstHostResolver>());
      expect(
        (resolver as FirstHostResolver).resolvers.map((r) => r.runtimeType),
        [SystemHostResolver, MulticastDnsHostResolver],
      );
    });

    test('flag on, iOS: the system resolves .local names itself', () {
      final resolver = resolverFor(flag: true, platform: TargetPlatform.iOS);

      expect(resolver, isA<SystemHostResolver>());
    });
  });
}
