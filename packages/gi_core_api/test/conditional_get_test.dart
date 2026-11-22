import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

/// Conditional GET of `GET /devices` and `GET /devices/:id` (plan §6.5
/// pt 4, spike S4).
void main() {
  const etag = 'W/"f22-abc"';
  late FakeCore core;
  late EtagCache cache;
  late GiCoreClient client;
  late Map<String, Object?> devicesBody;

  void stubLogin({String userId = 'user-1'}) =>
      core.on('POST', '/auth/login', (_) {
        final body = loginBody();
        return FakeResponse.json(
          {
            ...body,
            'user': {...body['user']! as Map<String, Object?>, 'id': userId},
          },
          headers: {
            'set-cookie': [setCookieFor(testCookieValue1)],
          },
        );
      });

  setUp(() {
    core = FakeCore();
    cache = EtagCache();
    client = testClient(core, etagCache: cache);
    devicesBody = fixtureObject('DevicesController_list/seeded.json');
    stubLogin();
    core
      ..on('POST', '/auth/logout', (_) => FakeResponse.empty())
      ..on('POST', '/auth/logout-all', (_) => FakeResponse.empty())
      ..on('GET', '/devices', (request) {
        if (request.header('if-none-match') == etag) {
          return FakeResponse.empty(status: 304);
        }
        return FakeResponse.json(
          devicesBody,
          headers: {
            'etag': [etag],
          },
        );
      });
  });

  tearDown(() => client.close());

  Future<void> login() => client.login(email: 'a@b.c', password: 'pw');

  test('first GET stores the ETag, the second sends If-None-Match and a '
      '304 is served from the cache', () async {
    await login();

    final first = await client.devices();
    final second = await client.devices();

    final requests = core.requestsTo('GET', '/devices');
    expect(requests.first.header('if-none-match'), isNull);
    expect(requests.last.header('if-none-match'), etag);
    expect(cache.hits, 1);
    expect(second, first);
  });

  test('a 200 with a new ETag replaces the cached body', () async {
    await login();
    await client.devices();
    core.on(
      'GET',
      '/devices',
      (_) => FakeResponse.json(
        {...devicesBody, 'total': 99},
        headers: {
          'etag': ['W/"f22-new"'],
        },
      ),
    );

    final page = await client.devices();

    expect(page.total, 99);
    expect(cache.hits, 0);
  });

  test('the cache key includes the user: another user never gets a '
      'conditional request for the body of the first user', () async {
    await login();
    await client.devices();
    await client.logout();
    await pumpEventQueue();
    expect(cache.length, 0, reason: 'cleared on logout');

    stubLogin(userId: 'user-2');
    await login();
    await client.devices();

    final requests = core.requestsTo('GET', '/devices');
    expect(requests.last.header('if-none-match'), isNull);
    expect(cache.hits, 0);
  });

  test('keys differ per user even without a logout in between', () {
    final options = RequestOptions(path: 'http://h/api/v1/devices');
    expect(
      ConditionalGetInterceptor.keyOf('p/user-1', options),
      isNot(ConditionalGetInterceptor.keyOf('p/user-2', options)),
    );
  });

  test('logout-all clears the cache', () async {
    await login();
    await client.devices();
    expect(cache.length, 1);

    await client.logoutAll();
    await pumpEventQueue();

    expect(cache.length, 0);
  });

  test(
    'a revoked session (401 AUTH_SESSION_REVOKED) clears the cache',
    () async {
      await login();
      await client.devices();
      core.on(
        'GET',
        '/devices',
        (_) => FakeResponse.error(401, 'AUTH_SESSION_REVOKED'),
      );

      await expectLater(client.devices(), throwsA(isA<ApiFailure>()));
      await pumpEventQueue();

      expect(cache.length, 0);
    },
  );

  test('other endpoints are never conditional', () async {
    await login();
    core.on(
      'GET',
      '/rooms',
      (_) => FakeResponse.json(
        <Object?>[],
        headers: {
          'etag': ['W/"2-x"'],
        },
      ),
    );

    await client.rooms();
    await client.rooms();

    expect(
      core.requestsTo('GET', '/rooms').last.header('if-none-match'),
      isNull,
    );
    expect(cache.length, 0);
  });

  test('without a cache the client never sends If-None-Match', () async {
    final plain = testClient(core);
    addTearDown(plain.close);
    await plain.login(email: 'a@b.c', password: 'pw');
    await plain.devices();
    await plain.devices();

    expect(
      core.requestsTo('GET', '/devices').map((r) => r.header('if-none-match')),
      everyElement(isNull),
    );
  });

  test('the cache keeps at most maxEntries responses', () {
    final small = EtagCache(maxEntries: 2)
      ..store('a', const EtagEntry('1', null))
      ..store('b', const EtagEntry('2', null))
      ..store('c', const EtagEntry('3', null));
    expect(small.lookup('a'), isNull);
    expect(small.length, 2);
  });
}
