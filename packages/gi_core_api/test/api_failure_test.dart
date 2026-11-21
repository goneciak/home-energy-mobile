import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_core_api/src/failures/failure_mapping.dart'
    show parseRetryAfter;
import 'package:test/test.dart';

import 'support/fake_core.dart';

Headers _headers(Map<String, List<String>> map) => Headers.fromMap(map);

void main() {
  group('ApiErrorEnvelope.tryParse', () {
    test('parses every recorded error fixture', () {
      for (final name in [
        'AuthController_login/error_invalid_credentials.json',
        '_unrouted/error_route_not_found.json',
        'AuthController_getMe/error_unauthorized.json',
        'AuthController_login/error_validation.json',
      ]) {
        final json = fixtureObject(name);
        final envelope = ApiErrorEnvelope.tryParse(json)!;
        expect(envelope.code, json['code'], reason: name);
        expect(envelope.statusCode, json['statusCode'], reason: name);
        expect(envelope.requestId, json['requestId'], reason: name);
        expect(envelope.path, json['path'], reason: name);
        expect(envelope.message, json['message'], reason: name);
        expect(envelope.timestamp, json['timestamp'], reason: name);
      }
    });

    test('keeps validation details keyed by field path', () {
      final envelope = ApiErrorEnvelope.tryParse(
        fixtureObject('AuthController_login/error_validation.json'),
      )!;

      expect(envelope.details, {
        'extra': ['property extra should not exist'],
      });
    });

    test('is tolerant of odd types and rejects non-envelopes', () {
      final envelope = ApiErrorEnvelope.tryParse({
        'code': 'X',
        'statusCode': '409',
        'message': 42,
        'details': {
          'a.b': 'single message',
          'c': ['one', 2, null],
          'd': 7,
        },
        'unknown': true,
      })!;

      expect(envelope.statusCode, 409);
      expect(envelope.message, isNull);
      expect(envelope.details, {
        'a.b': ['single message'],
        'c': ['one'],
        'd': <String>[],
      });
      expect(ApiErrorEnvelope.tryParse('<html></html>'), isNull);
      expect(ApiErrorEnvelope.tryParse({'message': 'no code'}), isNull);
      expect(ApiErrorEnvelope.tryParse(null), isNull);
    });
  });

  group('failureFromResponse', () {
    ApiFailure map(int status, Object? data, [Headers? headers]) =>
        failureFromResponse(statusCode: status, data: data, headers: headers);

    test('maps recorded error fixtures', () {
      expect(
        map(
          401,
          fixtureObject('AuthController_login/error_invalid_credentials.json'),
        ),
        isA<UnauthorizedFailure>().having(
          (f) => f.code,
          'code',
          'AUTH_INVALID_CREDENTIALS',
        ),
      );
      expect(
        map(
          401,
          fixtureObject('AuthController_getMe/error_unauthorized.json'),
        ).code,
        'AUTH_UNAUTHORIZED',
      );
      final routeAbsent = map(
        404,
        fixtureObject('_unrouted/error_route_not_found.json'),
      );
      expect(routeAbsent, isA<RouteAbsentFailure>());
      expect(routeAbsent.requestId, '71687d21-8eb0-4fbd-ba2f-bf0c386094b5');
      expect(
        map(400, fixtureObject('AuthController_login/error_validation.json')),
        isA<ValidationFailure>().having((f) => f.details.keys, 'keys', [
          'extra',
        ]),
      );
    });

    test('distinguishes domain 404 from a missing route', () {
      final failure = map(404, {'code': 'DEVICE_NOT_FOUND', 'statusCode': 404});

      expect(failure, isA<NotFoundFailure>());
      expect(failure.code, 'DEVICE_NOT_FOUND');
    });

    test('maps forbidden, conflicts and server errors', () {
      expect(map(403, {'code': 'HTTP_403'}), isA<ForbiddenFailure>());
      expect(
        map(409, {'code': 'HEATING_SUSPENDED'}),
        isA<DomainFailure>()
            .having((f) => f.statusCode, 'status', 409)
            .having((f) => f.code, 'code', 'HEATING_SUSPENDED'),
      );
      expect(
        map(500, {'code': 'INTERNAL_SERVER_ERROR'}),
        isA<ServerFailure>().having(
          (f) => f.errorCode,
          'code',
          'INTERNAL_SERVER_ERROR',
        ),
      );
      expect(
        map(502, '<html>Bad gateway</html>'),
        isA<ServerFailure>().having((f) => f.errorCode, 'code', isNull),
      );
      expect(map(502, '<html/>').code, 'INTERNAL_SERVER_ERROR');
    });

    test('reads Retry-After for rate limiting', () {
      final failure = map(
        429,
        {'code': 'HTTP_429'},
        _headers({
          'retry-after': ['42'],
        }),
      );

      expect(
        failure,
        isA<RateLimitedFailure>().having(
          (f) => f.retryAfter,
          'retryAfter',
          const Duration(seconds: 42),
        ),
      );
      expect((map(429, null) as RateLimitedFailure).retryAfter, isNull);
      expect(
        parseRetryAfter(
          _headers({
            'retry-after': ['Thu, 17 Dec 2026 22:07:20 GMT'],
          }),
          now: DateTime.utc(2026, 12, 17, 22, 6, 20),
        ),
        const Duration(minutes: 1),
      );
    });

    test('reports non-JSON 4xx as an unexpected response', () {
      final failure = map(
        400,
        '<html/>',
        _headers({
          'content-type': ['text/html'],
        }),
      );

      expect(
        failure,
        isA<UnexpectedResponseFailure>().having(
          (f) => f.contentType,
          'contentType',
          'text/html',
        ),
      );
    });
  });

  group('mapDioException', () {
    final options = RequestOptions(path: 'https://gi-home.local/api/v1/x');

    test('separates not-sent from ambiguous transport errors', () {
      expect(
        mapDioException(
          DioException.connectionTimeout(
            requestOptions: options,
            timeout: const Duration(seconds: 4),
          ),
        ),
        isA<UnreachableFailure>(),
      );
      expect(
        mapDioException(
          DioException.connectionError(
            requestOptions: options,
            reason: 'refused',
            error: const SocketException('refused'),
          ),
        ),
        isA<UnreachableFailure>(),
      );
      expect(
        mapDioException(
          DioException.connectionError(
            requestOptions: options,
            reason: 'closed',
            error: const HttpException(
              'Connection closed before full header was received',
            ),
          ),
        ),
        isA<TimeoutFailure>(),
      );
      expect(
        mapDioException(
          DioException.receiveTimeout(
            timeout: const Duration(seconds: 10),
            requestOptions: options,
          ),
        ),
        isA<TimeoutFailure>(),
      );
      expect(
        mapDioException(
          DioException(
            requestOptions: options,
            error: const SocketException('reset'),
          ),
        ),
        isA<TimeoutFailure>(),
      );
    });

    test('maps TLS failures without downgrading', () {
      expect(
        mapDioException(
          DioException(
            requestOptions: options,
            error: const HandshakeException('bad cert'),
          ),
        ),
        isA<TlsUntrustedFailure>().having(
          (f) => f.host,
          'host',
          'gi-home.local',
        ),
      );
      expect(
        mapDioException(DioException.badCertificate(requestOptions: options)),
        isA<TlsUntrustedFailure>(),
      );
    });

    group('local network denied', () {
      final lan = RequestOptions(path: 'http://192.168.1.10:3000/api/v1/x');

      DioException connectError(RequestOptions options, OSError osError) =>
          DioException.connectionError(
            requestOptions: options,
            reason: 'denied',
            error: SocketException(
              'Connection failed',
              osError: osError,
              address: InternetAddress(options.uri.host),
              port: options.uri.port,
            ),
          );

      test('EPERM or EACCES to a home-network host is mapped', () {
        for (final osError in const [
          OSError('Operation not permitted', 1),
          OSError('Permission denied', 13),
        ]) {
          expect(
            mapDioException(connectError(lan, osError)),
            isA<LocalNetworkDeniedFailure>(),
            reason: osError.message,
          );
        }
        final local = RequestOptions(path: 'http://gi-home.local/api/v1/x');
        expect(
          mapDioException(
            DioException.connectionError(
              requestOptions: local,
              reason: 'denied',
              error: const SocketException(
                'Connection failed',
                osError: OSError('Operation not permitted', 1),
              ),
            ),
          ),
          isA<LocalNetworkDeniedFailure>(),
        );
      });

      test('a refused connection stays unreachable', () {
        expect(
          mapDioException(
            connectError(lan, const OSError('Connection refused', 111)),
          ),
          isA<UnreachableFailure>(),
        );
        expect(
          mapDioException(
            DioException.connectionError(
              requestOptions: lan,
              reason: 'refused',
              error: const SocketException('Connection refused'),
            ),
          ),
          isA<UnreachableFailure>(),
        );
      });

      test('EPERM to a public host is not a local-network denial', () {
        final public = RequestOptions(path: 'https://8.8.8.8/api/v1/x');
        expect(
          mapDioException(
            connectError(public, const OSError('Operation not permitted', 1)),
          ),
          isA<UnreachableFailure>(),
        );
      });

      test('the detector is injectable and a throwing one is ignored', () {
        final noRoute = connectError(
          lan,
          const OSError('No route to host', 65),
        );
        expect(
          mapDioException(
            noRoute,
            isLocalNetworkDenied: (error, uri) =>
                error is SocketException && error.osError?.errorCode == 65,
          ),
          isA<LocalNetworkDeniedFailure>(),
        );
        expect(
          mapDioException(
            noRoute,
            isLocalNetworkDenied: (_, _) => throw StateError('broken'),
          ),
          isA<UnreachableFailure>(),
        );
      });
    });

    test('passes an existing ApiFailure through and maps cancellation', () {
      const failure = ApiFailure.vaultUnavailable();

      expect(
        mapDioException(DioException(requestOptions: options, error: failure)),
        same(failure),
      );
      expect(
        mapDioException(
          DioException.requestCancelled(requestOptions: options, reason: null),
        ),
        isA<CancelledFailure>(),
      );
    });
  });

  test('client codes and transience', () {
    expect(const ApiFailure.unreachable().code, 'BACKEND_UNREACHABLE');
    expect(const ApiFailure.timeout().code, 'REQUEST_TIMEOUT');
    expect(
      const ApiFailure.refreshCookieMissing().code,
      'REFRESH_COOKIE_MISSING',
    );
    expect(const ApiFailure.differentAppliance().code, 'DIFFERENT_APPLIANCE');
    expect(const ApiFailure.applianceReset().code, 'APPLIANCE_RESET');
    expect(const ApiFailure.localNetworkDenied().code, 'LOCAL_NETWORK_DENIED');
    expect(const ApiFailure.localNetworkDenied().isTransient, isFalse);
    expect(const ApiFailure.unreachable().isTransient, isTrue);
    expect(const ApiFailure.server(statusCode: 503).isTransient, isTrue);
    expect(const ApiFailure.server(statusCode: 500).isTransient, isFalse);
    expect(const ApiFailure.unauthorized(code: 'X').isTransient, isFalse);
  });
}
