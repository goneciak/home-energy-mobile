import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

const String _device = CapabilityProbe.placeholderDeviceId;
const String _entity = CapabilityProbe.placeholderEntityId;

void main() {
  group('classifyProbeOutcome', () {
    final table = <String, (Object?, CapabilityStatus)>{
      'success': (null, CapabilityStatus.present),
      'HTTP_404 (no route)': (
        const ApiFailure.routeAbsent(),
        CapabilityStatus.absent,
      ),
      'DEVICE_NOT_FOUND': (
        const ApiFailure.notFound(code: GiErrorCodes.deviceNotFound),
        CapabilityStatus.present,
      ),
      'DEVICE_ENTITY_NOT_FOUND': (
        const ApiFailure.notFound(code: GiErrorCodes.deviceEntityNotFound),
        CapabilityStatus.present,
      ),
      'HEATING_SCHEDULE_NOT_FOUND': (
        const ApiFailure.notFound(code: GiErrorCodes.heatingScheduleNotFound),
        CapabilityStatus.present,
      ),
      'RESOURCE_NOT_FOUND': (
        const ApiFailure.notFound(code: 'RESOURCE_NOT_FOUND'),
        CapabilityStatus.present,
      ),
      'VALIDATION_FAILED': (
        const ApiFailure.validation(details: {}),
        CapabilityStatus.present,
      ),
      'HTTP_400 of a path pipe': (
        const ApiFailure.domain(statusCode: 400, code: 'HTTP_400'),
        CapabilityStatus.present,
      ),
      'HTTP_403': (
        const ApiFailure.forbidden(code: 'HTTP_403'),
        CapabilityStatus.unknown,
      ),
      '500': (
        const ApiFailure.server(statusCode: 500),
        CapabilityStatus.unknown,
      ),
      'offline': (const ApiFailure.unreachable(), CapabilityStatus.unknown),
      'timeout': (const ApiFailure.timeout(), CapabilityStatus.unknown),
      'non-API error': (StateError('x'), CapabilityStatus.unknown),
    };
    for (final MapEntry(key: name, value: (error, expected)) in table.entries) {
      test('$name -> ${expected.name}', () {
        expect(classifyProbeOutcome(error), expected);
      });
    }
  });

  group('CoreCapabilities', () {
    test('only a proven absent route hides a feature', () {
      final caps = CoreCapabilities(const {
        CoreCapability.schedules: CapabilityStatus.absent,
        CoreCapability.history: CapabilityStatus.present,
      });
      expect(caps.isAvailable(CoreCapability.schedules), isFalse);
      expect(caps.isAvailable(CoreCapability.history), isTrue);
      expect(caps.isAvailable(CoreCapability.sessions), isTrue);
      expect(caps[CoreCapability.sessions], CapabilityStatus.unknown);
      expect(caps.hasUnknown, isTrue);
      expect(
        CoreCapabilities.unprobed.isAvailable(CoreCapability.pvPlan),
        isTrue,
      );
    });

    test('value equality', () {
      expect(
        CoreCapabilities(const {
          CoreCapability.pvPlan: CapabilityStatus.absent,
        }),
        CoreCapabilities(const {
          CoreCapability.pvPlan: CapabilityStatus.absent,
        }),
      );
    });

    test('no probe targets weather or the PV forecast', () {
      final probed = {for (final c in CoreCapability.values) c.endpoint};
      expect(probed, isNot(contains(GiEndpoints.weatherCurrent)));
      expect(probed, isNot(contains(GiEndpoints.pvForecast)));
      for (final endpoint in probed) {
        expect(endpoint.method, HttpMethod.get);
      }
    });
  });

  group('CapabilityProbe over HTTP', () {
    late FakeCore core;
    late GiCoreClient client;

    setUp(() async {
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
        );
      client = testClient(core);
      await client.login(email: 'a@b.c', password: 'pw');
    });

    tearDown(() => client.close());

    test('domain 404s mean present, unrouted paths mean absent', () async {
      core
        ..on(
          'GET',
          '/devices/$_device/schedules',
          (_) => FakeResponse.error(404, 'DEVICE_NOT_FOUND'),
        )
        ..on(
          'GET',
          '/devices/$_device/entities/$_entity/history',
          (_) => FakeResponse.error(404, 'DEVICE_ENTITY_NOT_FOUND'),
        )
        ..on('GET', '/auth/sessions', (_) => FakeResponse.json(<Object>[]));
      // pv-heating-plan is not routed: FakeCore answers HTTP_404.

      final caps = await CapabilityProbe(client).probe(UserRole.user);

      expect(caps[CoreCapability.schedules], CapabilityStatus.present);
      expect(caps[CoreCapability.history], CapabilityStatus.present);
      expect(caps[CoreCapability.sessions], CapabilityStatus.present);
      expect(caps[CoreCapability.pvPlan], CapabilityStatus.absent);
      final history = core.requestsTo(
        'GET',
        '/devices/$_device/entities/$_entity/history',
      );
      expect(history.single.options.uri.queryParameters['limit'], '1');
    });

    test('a role the catalog does not allow is never probed', () async {
      var calls = 0;
      final probe = CapabilityProbe.withChecks({
        for (final c in CoreCapability.values) c: () async => calls++,
      });
      final caps = await probe.probe(UserRole.unknown);
      expect(calls, 0);
      expect(caps, CoreCapabilities.unprobed);
    });
  });
}
