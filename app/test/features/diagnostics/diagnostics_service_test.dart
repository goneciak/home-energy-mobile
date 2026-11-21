import 'dart:convert';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/data/diagnostics_store.dart';
import 'package:gi_home/src/features/diagnostics/domain/diagnostic_counters.dart';
import 'package:gi_home/src/features/diagnostics/domain/diagnostic_report.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';

void main() {
  final now = DateTime.utc(2026, 11, 18, 9, 30);
  const environment = ReportEnvironment(
    appVersion: '0.1.0',
    buildNumber: '7',
    platform: 'android',
    osVersion: 'Android 16 (BP2A.250605.031)',
    locale: 'pl (system pl-PL)',
    applianceConnected: true,
    applianceCleartext: true,
  );
  const jwt =
      'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1LTEiLCJzaWQiOiJzLTEifQ.'
      'c2lnbmF0dXJlLXNpZ25hdHVyZQ';
  const refreshValue =
      '22222222-2222-4222-8222-222222222222.'
      'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';

  DiagnosticsService service({DiagnosticsStore? store}) =>
      DiagnosticsService(store: store, now: () => now);

  group('counters', () {
    test('count the tracked failures and ignore the rest', () {
      final diagnostics = service()
        ..recordFailure(
          const ApiFailure.unexpectedShape(
            endpointId: 'DevicesController_list',
            fieldPath: 'DeviceListItem.dryRun',
          ),
        )
        ..recordFailure(
          const ApiFailure.unexpectedShape(
            endpointId: 'DevicesController_list',
          ),
        )
        ..recordFailure(
          const ApiFailure.unexpectedShape(endpointId: 'RoomsController_list'),
        )
        // Counted per vault read instead (recordVaultUnavailable).
        ..recordFailure(const ApiFailure.vaultUnavailable())
        ..recordVaultUnavailable()
        ..recordFailure(
          const ApiFailure.tlsUntrusted(host: 'gi.example.com', reason: 'x'),
        )
        ..recordFailure(const ApiFailure.unreachable())
        ..recordFailure(const ApiFailure.server(statusCode: 500));

      final counters = diagnostics.counters;
      expect(counters.unexpectedShape, {
        'DevicesController_list': 2,
        'RoomsController_list': 1,
      });
      expect(counters.vaultUnavailable, 1);
      expect(counters.tlsUntrusted, 1);
      expect(counters.localNetworkDenied, 0);
      // Shape mismatches are also logged, with endpoint and field.
      expect(diagnostics.errors.map((e) => e.kind), [
        ErrorKind.unexpectedShape,
        ErrorKind.unexpectedShape,
        ErrorKind.unexpectedShape,
      ]);
      expect(diagnostics.errors.first.message, contains('dryRun'));
    });

    test('count forced logouts by reason, cold starts and local network', () {
      final diagnostics = service()
        ..recordSessionLost(SessionLostReason.refreshTokenReused)
        ..recordSessionLost(SessionLostReason.refreshTokenReused)
        ..recordSessionLost(SessionLostReason.sessionRevoked)
        ..recordLocalNetworkDenied()
        ..recordColdStart(const Duration(milliseconds: 812));

      expect(diagnostics.counters.sessionLost, {
        SessionLostReason.refreshTokenReused: 2,
        SessionLostReason.sessionRevoked: 1,
      });
      expect(diagnostics.counters.localNetworkDenied, 1);
      expect(diagnostics.counters.coldStartMs, [812]);
      expect(diagnostics.counters.coldStarts, 1);
    });

    test('a LocalNetworkDenied failure feeds the local-network counter', () {
      final diagnostics = service()
        ..recordFailure(const ApiFailure.localNetworkDenied(reason: 'EPERM'))
        ..recordFailure(const ApiFailure.localNetworkDenied())
        ..recordFailure(const ApiFailure.unreachable());

      expect(diagnostics.counters.localNetworkDenied, 2);
      expect(diagnostics.counters.toJson()['localNetworkDenied'], 2);
      expect(diagnostics.errors, isEmpty);
    });

    test('keep only the last cold-start samples but count them all', () {
      final counters = DiagnosticCounters(since: now);
      for (var i = 0; i < 25; i++) {
        counters.recordColdStart(Duration(milliseconds: i));
      }

      expect(counters.coldStarts, 25);
      expect(counters.coldStartMs, hasLength(20));
      expect(counters.coldStartMs.first, 5);
    });

    test('round-trip through JSON and drop malformed values', () {
      final counters = DiagnosticCounters(since: now)
        ..recordSessionLost(SessionLostReason.protocol)
        ..recordFailure(const ApiFailure.unexpectedShape(endpointId: 'E'))
        ..vaultUnavailable = 2
        ..recordColdStart(const Duration(seconds: 1));

      final restored = DiagnosticCounters.fromJson(
        jsonDecode(jsonEncode(counters.toJson())),
        fallbackSince: DateTime.utc(2000),
      );
      expect(restored.toJson(), counters.toJson());

      final broken = DiagnosticCounters.fromJson({
        'since': 'never',
        'sessionLost': {'nope': 3, 'noToken': -1, 'expired': 'x'},
        'unexpectedShape': {'E': 'x'},
        'tlsUntrusted': -4,
        'coldStartMs': [-1, 'x', 5],
      }, fallbackSince: now);
      expect(broken.since, now);
      expect(broken.sessionLost, isEmpty);
      expect(broken.unexpectedShape, isEmpty);
      expect(broken.tlsUntrusted, 0);
      expect(broken.coldStartMs, [5]);
      expect(
        DiagnosticCounters.fromJson('x', fallbackSince: now).toJson(),
        DiagnosticCounters(since: now).toJson(),
      );
    });
  });

  group('errors', () {
    test('are redacted when recorded, with the context appended', () {
      final diagnostics = service()
        ..recordError(
          ErrorKind.flutter,
          StateError('token $jwt for owner@example.com'),
          StackTrace.fromString('#0 f (http://10.0.0.5:3000/a)'),
          'while building HomeScreen',
        )
        ..recordError(ErrorKind.zone, 'plain', StackTrace.empty);

      final [first, second] = diagnostics.errors;
      expect(
        first.message,
        'Bad state: token <jwt> for <email> (while building HomeScreen)',
      );
      expect(first.stack, '#0 f (http://<host>:3000/a)');
      expect(first.time, now);
      expect(second.stack, isNull);
    });

    test('an error whose toString throws is ignored', () {
      final diagnostics = service()..recordError(ErrorKind.zone, _Throwing());

      expect(diagnostics.errors, isEmpty);
    });
  });

  group('http log', () {
    test('keeps redacted request lines apart from the errors', () {
      final diagnostics = service()
        ..recordError(ErrorKind.zone, 'boom')
        ..recordHttp(
          '-> POST /api/v1/auth/refresh {cookie: gi_refresh_token=$refreshValue, '
          'authorization: Bearer $jwt}',
        )
        ..recordHttp(
          '<- 200 POST /api/v1/auth/login 12ms {set-cookie: '
          '[gi_refresh_token=$refreshValue; Path=/api/v1/auth/refresh]}',
        )
        ..recordHttp('-> POST /api/v1/auth/login {"password": "hunter2 x"}');

      final lines = diagnostics.httpLog;
      expect(lines.map((e) => e.kind), everyElement(ErrorKind.http));
      expect(lines, hasLength(3));
      final text = lines.map((e) => e.message).join(' | ');
      for (final secret in [refreshValue, jwt, 'hunter2', 'Bearer ey']) {
        expect(text, isNot(contains(secret)), reason: secret);
      }
      expect(text, contains('POST /api/v1/auth/refresh'));
      expect(diagnostics.errors.single.message, 'boom');
    });

    test('schedules no write of its own', () {
      fakeAsync((async) {
        final store = MemoryDiagnosticsStore();
        final diagnostics = service(store: store);
        for (var i = 0; i < 20; i++) {
          diagnostics.recordHttp('-> GET /api/v1/devices');
          async.elapse(const Duration(seconds: 1));
        }

        expect(store.saves, 0);
        diagnostics.dispose();
      });
    });

    test('is bounded and never pushes errors out', () {
      final diagnostics = DiagnosticsService(
        now: () => now,
        capacity: 3,
        httpCapacity: 5,
      )..recordError(ErrorKind.zone, 'kept');
      for (var i = 0; i < 50; i++) {
        diagnostics.recordHttp('-> GET /api/v1/devices #$i');
      }

      expect(diagnostics.httpLog, hasLength(5));
      expect(diagnostics.httpLog.last.message, contains('#49'));
      expect(diagnostics.errors.single.message, 'kept');
    });

    test('is not written to disk, but reported and cleared', () async {
      final store = MemoryDiagnosticsStore();
      final diagnostics = service(store: store)
        ..recordHttp('-> GET /api/v1/devices {}');
      await diagnostics.flush();

      expect(store.errors, isEmpty, reason: 'request lines stay in memory');
      final report = diagnostics.buildReport(environment);
      expect(report['http'], [
        {
          'time': now.toIso8601String(),
          'kind': 'http',
          'message': '-> GET /api/v1/devices {}',
        },
      ]);

      await diagnostics.clear();
      expect(diagnostics.httpLog, isEmpty);
    });
  });

  group('persistence', () {
    test('writes once, the delay after the first unsaved change', () {
      fakeAsync((async) {
        final store = MemoryDiagnosticsStore();
        final diagnostics = service(store: store)
          ..recordError(ErrorKind.zone, 'a')
          ..recordVaultUnavailable();
        async.elapse(const Duration(seconds: 1));
        diagnostics.recordError(ErrorKind.zone, 'b');
        async.elapse(const Duration(milliseconds: 999));
        expect(store.saves, 0);

        // The later change did not push the write back.
        async.elapse(const Duration(milliseconds: 2));
        expect(store.saves, 1);
        expect(store.errors, hasLength(2));
        expect((store.counters! as Map)['vaultUnavailable'], 1);

        async.elapse(const Duration(minutes: 1));
        expect(store.saves, 1, reason: 'nothing changed since');
        diagnostics.dispose();
      });
    });

    test('an error repeated every frame is still written', () {
      fakeAsync((async) {
        final store = MemoryDiagnosticsStore();
        final diagnostics = service(store: store);
        // About 60 reports a second for 10 s, as from a broken build method.
        for (var frame = 0; frame < 600; frame++) {
          diagnostics.recordError(ErrorKind.flutter, 'build failed');
          async.elapse(const Duration(milliseconds: 16));
        }

        expect(store.saves, greaterThanOrEqualTo(4));
        final [entry] = store.errors! as List<Object?>;
        expect((entry! as Map<String, Object?>)['count'], greaterThan(1));
        diagnostics.dispose();
      });
    });

    test('nothing is scheduled before a store is attached', () {
      fakeAsync((async) {
        final store = MemoryDiagnosticsStore();
        final diagnostics = service()..recordError(ErrorKind.zone, 'early');
        expect(async.pendingTimers, isEmpty);

        diagnostics.attach(store).ignore();
        async.flushMicrotasks();
        async.elapse(diagnostics.writeDelay);

        expect(store.saves, 1);
        expect(store.errors, hasLength(1));
        diagnostics.dispose();
      });
    });

    test('attach loads stored data and merges what came before it', () async {
      final store = MemoryDiagnosticsStore()
        ..errors = [
          {'time': now.toIso8601String(), 'kind': 'zone', 'message': 'old'},
          'garbage',
        ]
        ..counters = {
          'since': '2026-11-01T00:00:00.000Z',
          'tlsUntrusted': 2,
          'sessionLost': {'refreshTokenReused': 1},
        };
      final diagnostics = service()
        ..recordError(ErrorKind.zone, 'early')
        ..recordSessionLost(SessionLostReason.refreshTokenReused);

      await diagnostics.attach(store);
      await diagnostics.flush();

      expect(diagnostics.errors.map((e) => e.message), ['old', 'early']);
      expect(diagnostics.counters.tlsUntrusted, 2);
      expect(diagnostics.counters.sessionLost, {
        SessionLostReason.refreshTokenReused: 2,
      });
      expect(diagnostics.counters.since, DateTime.utc(2026, 11));
      expect(store.errors, hasLength(2));
      diagnostics.dispose();
    });

    test('clear forgets everything in memory and on disk', () async {
      final store = MemoryDiagnosticsStore();
      final diagnostics = service(store: store)
        ..recordError(ErrorKind.zone, 'a')
        ..recordSessionLost(SessionLostReason.sessionRevoked);
      await diagnostics.flush();
      expect(store.errors, isNotNull);

      diagnostics.recordError(ErrorKind.zone, 'pending');
      await diagnostics.clear();

      expect(diagnostics.errors, isEmpty);
      expect(diagnostics.counters.sessionLost, isEmpty);
      expect(store.errors, isNull);
      expect(store.counters, isNull);
      diagnostics.dispose();
    });

    test('a failing store never surfaces', () async {
      final diagnostics = service(store: _BrokenStore())
        ..recordError(ErrorKind.zone, 'a');

      await expectLater(diagnostics.flush(), completes);
      await expectLater(diagnostics.clear(), completes);
      await expectLater(diagnostics.attach(_BrokenStore()), completes);
      diagnostics.dispose();
    });

    test(
      'FileDiagnosticsStore keeps two JSON files under diagnostics/',
      () async {
        final root = await Directory.systemTemp.createTemp('gi-diag-');
        addTearDown(() => root.delete(recursive: true));
        final store = FileDiagnosticsStore(root);

        expect(await store.load(), (errors: null, counters: null));
        await store.save(
          errors: [
            {'a': 1},
          ],
          counters: {'b': 2},
        );
        expect(store.errorsFile.existsSync(), isTrue);
        expect(store.countersFile.existsSync(), isTrue);
        final loaded = await store.load();
        expect(loaded.errors, [
          {'a': 1},
        ]);
        expect(loaded.counters, {'b': 2});

        store.countersFile.writeAsStringSync('{truncated');
        expect((await store.load()).counters, isNull);

        await store.clear();
        expect(store.directory.existsSync(), isFalse);
        await store.clear();
      },
    );
  });

  group('report', () {
    test('has the environment, counters and errors', () {
      final diagnostics = service()
        ..recordSessionLost(SessionLostReason.refreshTokenReused)
        ..recordColdStart(const Duration(milliseconds: 640))
        ..recordError(ErrorKind.platform, 'boom');

      final report = diagnostics.buildReport(environment);

      expect(report['schema'], DiagnosticReport.schemaVersion);
      expect(report['generatedAt'], now.toIso8601String());
      expect(report['app'], {'version': '0.1.0', 'build': '7'});
      expect(report['device'], {
        'platform': 'android',
        'osVersion': 'Android 16 (BP2A.250605.031)',
        'locale': 'pl (system pl-PL)',
      });
      expect(report['appliance'], {
        'connected': true,
        'cleartext': true,
        'coreVersion': null,
      });
      final counters = report['counters']! as Map<String, Object?>;
      expect(counters['sessionLost'], {'refreshTokenReused': 1});
      expect(counters['coldStartMs'], [640]);
      expect(report['errors'], [
        {'time': now.toIso8601String(), 'kind': 'platform', 'message': 'boom'},
      ]);
      // Encodable as the shared file.
      expect(
        jsonDecode(DiagnosticReport.encode(report)),
        jsonDecode(jsonEncode(report)),
      );
    });

    test('contains no token, cookie, e-mail, recovery code or address', () {
      const secrets = [
        'eyJhbGciOiJIUzI1NiJ9',
        'c2lnbmF0dXJl',
        '22222222-2222',
        'BBBBBBBBBB',
        'owner@example.com',
        'A1B2-C3D4',
        '192.168.1.10',
        'fe80::1',
        'gi-home.local',
        'gi.example.com',
        'hunter2',
      ];
      final diagnostics = service()
        ..recordError(
          ErrorKind.zone,
          'DioException: GET http://192.168.1.10:3000/api/v1/auth/me '
          'authorization: Bearer $jwt cookie: gi_refresh_token=$refreshValue',
          StackTrace.fromString(
            '#0 login owner@example.com password=hunter2\n'
            '#1 resolve gi-home.local [fe80::1]\n'
            '#2 recovery A1B2-C3D4-E5F6-0718-293A-4B5C-6D7E-8F90',
          ),
        )
        ..recordFailure(
          const ApiFailure.unexpectedShape(
            endpointId: 'AuthController_me',
            message: 'unexpected value owner@example.com',
          ),
        );
      const leakyEnvironment = ReportEnvironment(
        appVersion: '0.1.0',
        buildNumber: '7',
        platform: 'ios',
        osVersion: 'Version 18.1 (host https://gi.example.com/x)',
        locale: 'pl',
      );

      final json = DiagnosticReport.encode(
        diagnostics.buildReport(leakyEnvironment),
      );

      for (final secret in secrets) {
        expect(json, isNot(contains(secret)), reason: secret);
      }
      expect(json, contains('/api/v1/auth/me'));
      expect(json, contains('AuthController_me'));
    });
  });
}

final class _Throwing {
  @override
  String toString() => throw StateError('no');
}

final class _BrokenStore implements DiagnosticsStore {
  @override
  Future<({Object? errors, Object? counters})> load() =>
      Future.error(const FileSystemException('load'));

  @override
  Future<void> save({required Object? errors, required Object? counters}) =>
      Future.error(const FileSystemException('save'));

  @override
  Future<void> clear() => Future.error(const FileSystemException('clear'));
}
