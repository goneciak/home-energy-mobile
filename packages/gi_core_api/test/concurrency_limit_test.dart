import 'dart:async';

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

void main() {
  group('ConcurrencyLimiter', () {
    test('hands slots over in arrival order', () async {
      final limiter = ConcurrencyLimiter(2);
      final gates = List.generate(4, (_) => Completer<void>());
      final started = <int>[];
      final done = [
        for (var i = 0; i < 4; i++)
          limiter.run(() async {
            started.add(i);
            await gates[i].future;
            return i;
          }),
      ];
      await pumpEventQueue();
      expect(started, [0, 1]);
      expect((limiter.running, limiter.waiting), (2, 2));

      gates[1].complete();
      await pumpEventQueue();
      expect(started, [0, 1, 2]);

      for (final gate in gates) {
        if (!gate.isCompleted) gate.complete();
      }
      expect(await Future.wait(done), [0, 1, 2, 3]);
      expect((limiter.running, limiter.waiting), (0, 0));
    });

    test(
      'a cancelled wait takes no slot and a release is idempotent',
      () async {
        final limiter = ConcurrencyLimiter(1);
        final release = await limiter.acquire();
        final cancel = Completer<void>();
        final waiter = limiter.acquire(cancel: cancel.future);
        await pumpEventQueue();
        expect(limiter.waiting, 1);

        cancel.complete();
        await expectLater(waiter, throwsA(isA<ConcurrencyWaitCancelled>()));
        expect((limiter.running, limiter.waiting), (1, 0));

        release();
        release();
        expect(limiter.running, 0);
        final next = await limiter.acquire();
        expect(limiter.running, 1);
        next();
      },
    );
  });

  group('per-appliance cap', () {
    late FakeCore core;
    late GiCoreClient client;
    var inFlight = 0;
    var maxInFlight = 0;

    Future<FakeResponse> tracked(
      FutureOr<FakeResponse> Function() respond, {
      Duration delay = const Duration(milliseconds: 5),
    }) async {
      inFlight++;
      if (inFlight > maxInFlight) maxInFlight = inFlight;
      try {
        await Future<void>.delayed(delay);
        return await respond();
      } finally {
        inFlight--;
      }
    }

    setUp(() {
      inFlight = 0;
      maxInFlight = 0;
      core = FakeCore();
      core.on(
        'POST',
        '/auth/login',
        (_) => FakeResponse.json(
          loginBody(),
          headers: {
            'set-cookie': [setCookieFor(testCookieValue1)],
          },
        ),
      );
    });

    tearDown(() => client.close());

    test('10 parallel calls never have more than 4 in flight', () async {
      client = testClient(core);
      core.on(
        'GET',
        '/rooms',
        (_) => tracked(
          () => FakeResponse.json(
            fixtureJson('RoomsController_list/seeded.json'),
          ),
        ),
      );
      await client.login(email: 'a@b.c', password: 'pw');

      final results = await Future.wait([
        for (var i = 0; i < 10; i++) client.rooms(),
      ]);

      expect(results, hasLength(10));
      expect(core.requestsTo('GET', '/rooms'), hasLength(10));
      expect(maxInFlight, ConcurrencyLimiter.perApplianceRequests);
      expect(client.requestLimiter.running, 0);
    });

    test(
      'a 401 that needs a refresh while 4 requests are in flight completes',
      () async {
        final initializedAt = DateTime.utc(2026, 11, 17, 22, 6, 20, 184);
        client = testClient(core, expectedInitializedAt: initializedAt);
        core
          ..on(
            'GET',
            '/devices',
            (request) => tracked(
              () => request.header('authorization') == 'Bearer access-2'
                  ? FakeResponse.json(
                      fixtureJson('DevicesController_list/seeded.json'),
                    )
                  : FakeResponse.error(401, 'AUTH_ACCESS_TOKEN_EXPIRED'),
            ),
          )
          // The fingerprint check and the refresh need slots of their own.
          ..on(
            'GET',
            '/setup/status',
            (_) => tracked(
              () => FakeResponse.json(
                fixtureObject('SetupController_getStatus/initialized.json'),
              ),
            ),
          )
          ..on(
            'POST',
            '/auth/refresh',
            (_) => tracked(
              () => FakeResponse.json(
                refreshBody('access-2'),
                headers: {
                  'set-cookie': [setCookieFor(testCookieValue2)],
                },
              ),
              delay: const Duration(milliseconds: 20),
            ),
          );
        await client.login(email: 'a@b.c', password: 'pw');

        final pages = await Future.wait([
          for (var i = 0; i < 8; i++) client.devices(),
        ]).timeout(const Duration(seconds: 5));

        expect(pages.map((p) => p.total), everyElement(3));
        expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
        expect(core.requestsTo('GET', '/setup/status'), hasLength(1));
        // The first four were in flight together when their 401s arrived.
        expect(maxInFlight, 4);
        expect(client.requestLimiter.running, 0);
      },
    );

    test('cancelling frees the slot, waiting or in flight', () async {
      final limiter = ConcurrencyLimiter(1);
      final hang = Completer<FakeResponse>();
      core.on('GET', '/health/live', (_) => hang.future);
      final dio = Dio(BaseOptions(baseUrl: testAddress.apiBaseUrl.toString()))
        ..httpClientAdapter = ConcurrencyLimitedAdapter(core, limiter);
      addTearDown(dio.close);
      client = testClient(core);

      final inFlightToken = CancelToken();
      final waitingToken = CancelToken();
      final first = dio.get<Object?>(
        '/health/live',
        cancelToken: inFlightToken,
      );
      final second = dio.get<Object?>(
        '/health/live',
        cancelToken: waitingToken,
      );
      await pumpEventQueue();
      expect((limiter.running, limiter.waiting), (1, 1));

      waitingToken.cancel();
      await expectLater(
        second,
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
      expect((limiter.running, limiter.waiting), (1, 0));
      // Only the first request reached the adapter.
      expect(core.requestsTo('GET', '/health/live'), hasLength(1));

      // FakeCore ignores cancellation, like a stuck adapter would.
      inFlightToken.cancel();
      await expectLater(first, throwsA(isA<DioException>()));
      await pumpEventQueue();
      expect(limiter.running, 0);

      hang.complete(FakeResponse.json({'status': 'ok'}));
      core.on(
        'GET',
        '/health/live',
        (_) => FakeResponse.json({'status': 'ok'}),
      );
      final third = await dio.get<Object?>('/health/live');
      expect(third.statusCode, 200);
      expect(limiter.running, 0);
    });

    test('a failed send frees its slot', () async {
      client = testClient(core, requestLimiter: ConcurrencyLimiter(1));
      var calls = 0;
      core.on('GET', '/health/live', (request) {
        if (++calls == 1) throw refused(request);
        return FakeResponse.json({'status': 'ok'});
      });

      await expectLater(
        client.healthLive(),
        throwsA(isA<UnreachableFailure>()),
      );
      expect(client.requestLimiter.running, 0);
      expect((await client.healthLive()).isLive, isTrue);
      expect(calls, 2);
      expect(client.requestLimiter.running, 0);
    });
  });
}
