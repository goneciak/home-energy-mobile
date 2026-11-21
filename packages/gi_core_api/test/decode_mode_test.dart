import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

void main() {
  late FakeCore core;

  Map<String, dynamic> devicesWithUnknownField() {
    final page = fixtureObject('DevicesController_list/seeded.json');
    final items = (page['items'] as List<Object?>).cast<Map<String, dynamic>>();
    return {
      ...page,
      'items': [
        {...items.first, 'brandNewField': true},
        ...items.skip(1),
      ],
    };
  }

  setUp(() {
    core = FakeCore()
      ..on(
        'POST',
        '/auth/login',
        (_) => FakeResponse.json(
          loginBody(),
          headers: {
            'set-cookie': [setCookieFor(testCookieValue1)],
          },
        ),
      )
      ..on('GET', '/health/live', (_) => FakeResponse.json({'status': 'ok'}))
      ..on(
        'GET',
        '/setup/status',
        (_) => FakeResponse.json(
          fixtureObject('SetupController_getStatus/initialized.json'),
        ),
      )
      ..on(
        'GET',
        '/auth/me',
        (_) =>
            FakeResponse.json(fixtureObject('AuthController_getMe/owner.json')),
      )
      ..on(
        'GET',
        '/users/me/profile',
        (_) => FakeResponse.json(
          fixtureObject('UsersController_getProfile/owner.json'),
        ),
      )
      ..on(
        'GET',
        '/rooms',
        (_) =>
            FakeResponse.json(fixtureJson('RoomsController_list/seeded.json')),
      )
      ..on(
        'GET',
        '/devices',
        (_) => FakeResponse.json(
          fixtureJson('DevicesController_list/seeded.json'),
        ),
      )
      ..on(
        'GET',
        '/devices/dev-1',
        (_) => FakeResponse.json(
          fixtureObject('DevicesController_get/no_room_no_entities.json'),
        ),
      );
  });

  test('tolerant mode (the default) ignores unknown fields', () async {
    final client = testClient(core);
    addTearDown(client.close);
    core.on(
      'GET',
      '/devices',
      (_) => FakeResponse.json(devicesWithUnknownField()),
    );
    await client.login(email: 'a@b.c', password: 'pw');

    expect((await client.devices()).total, 3);
  });

  test('strict mode names the endpoint and the unknown field', () async {
    final failures = <ApiFailure>[];
    final client = testClient(
      core,
      decodeMode: DecodeMode.strict,
      onFailure: failures.add,
    );
    addTearDown(client.close);
    core.on(
      'GET',
      '/devices',
      (_) => FakeResponse.json(devicesWithUnknownField()),
    );
    await client.login(email: 'a@b.c', password: 'pw');

    await expectLater(
      client.devices(),
      throwsA(
        isA<UnexpectedShapeFailure>()
            .having((f) => f.endpointId, 'endpointId', 'DevicesController_list')
            .having(
              (f) => f.fieldPath,
              'fieldPath',
              r'$.items[0].brandNewField',
            )
            .having(
              (f) => f.message,
              'message',
              allOf(contains('GET /devices'), contains('brandNewField')),
            ),
      ),
    );
    // Not retried: a shape problem is not transient.
    expect(core.requestsTo('GET', '/devices'), hasLength(1));
    expect(failures.single, isA<UnexpectedShapeFailure>());
  });

  test('every recorded fixture passes strict mode', () async {
    final client = testClient(core, decodeMode: DecodeMode.strict);
    addTearDown(client.close);

    await client.login(email: 'a@b.c', password: 'pw');
    await client.healthLive();
    await client.setupStatus();
    await client.me();
    await client.profile();
    await client.rooms();
    await client.devices();
    await client.device('dev-1');
  });

  test('strict mode also covers the session manager', () async {
    final client = testClient(core, decodeMode: DecodeMode.strict);
    addTearDown(client.close);
    core.on(
      'POST',
      '/auth/login',
      (_) => FakeResponse.json(
        {...loginBody(), 'sessionHint': 'x'},
        headers: {
          'set-cookie': [setCookieFor(testCookieValue1)],
        },
      ),
    );

    await expectLater(
      client.login(email: 'a@b.c', password: 'pw'),
      throwsA(
        isA<UnexpectedShapeFailure>().having(
          (f) => f.fieldPath,
          'fieldPath',
          r'$.sessionHint',
        ),
      ),
    );
  });

  group('unknownJsonFields', () {
    test('walks nested objects and lists of the same length', () {
      expect(
        unknownJsonFields(
          {
            'a': 1,
            'b': {'c': 2, 'd': 3},
            'e': [
              {'f': 1},
              {'f': 1, 'g': 2},
            ],
            'x': 0,
          },
          {
            'a': 1,
            'b': {'c': 2},
            'e': [
              {'f': 1},
              {'f': 1},
            ],
          },
        ),
        [r'$.b.d', r'$.e[1].g', r'$.x'],
      );
    });

    test('does not descend where the model dropped a blob', () {
      expect(
        unknownJsonFields(
          {
            'blob': {'any': 1},
            'list': [1, 2],
          },
          {'blob': null, 'list': <Object?>[]},
        ),
        isEmpty,
      );
    });
  });

  test('DecodeMode.fromEnvironment', () {
    expect(DecodeMode.fromEnvironment(const {}), DecodeMode.tolerant);
    for (final on in ['1', 'true', ' TRUE ']) {
      expect(
        DecodeMode.fromEnvironment({DecodeMode.environmentVariable: on}),
        DecodeMode.strict,
      );
    }
    expect(
      DecodeMode.fromEnvironment({DecodeMode.environmentVariable: '0'}),
      DecodeMode.tolerant,
    );
  });
}
