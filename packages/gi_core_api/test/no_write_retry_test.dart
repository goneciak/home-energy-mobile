import 'dart:io';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

/// A write (`PUT`, `PATCH`, `POST`, `DELETE`) is sent once per user action.
/// Heating control is safety-critical: a request that failed on the way may
/// well have been executed, so repeating it could act twice. These checks
/// fail when something that could repeat a write is added.
void main() {
  test('only reads are ever retried automatically', () {
    for (final endpoint in GiEndpoints.all) {
      if (endpoint.method != HttpMethod.get) {
        expect(endpoint.maxRetries, 0, reason: '${endpoint.id} is a write');
      }
    }
  });

  test('the HTTP layer has no retry interceptor', () {
    final files = Directory('lib/src/http')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    expect(files, isNotEmpty);
    // Re-sending a request means calling `fetch` / `request` again, or a
    // retry package. These are the only places the HTTP layer sends.
    const allowedSends = {
      // The single send of every call (`GiClient` -> Dio).
      'dio_factory.dart': 1,
      // The adapter wrapper: passes the one request on to the real adapter.
      'concurrency_limiter.dart': 1,
      // The replay of a request the server rejected with 401 (below).
      'interceptors.dart': 1,
    };
    final send = RegExp(
      r'RetryInterceptor|dio_smart_retry|\.fetch<|\.fetch\(|\.request<|'
      r'\.request\(',
    );
    for (final file in files) {
      final name = file.uri.pathSegments.last;
      expect(
        send.allMatches(file.readAsStringSync()),
        hasLength(allowedSends[name] ?? 0),
        reason: '$name may re-send a request',
      );
    }
  });

  test('the one replay is of a request the server rejected with 401, once', () {
    // A 401 comes from the AuthGuard before the handler ran, so nothing was
    // executed; any other status, a lost connection or a second 401 never
    // replays (docs/decisions: network change handling).
    final source = File('lib/src/http/interceptors.dart').readAsStringSync();
    expect(
      source,
      contains('status != 401 || options.extra[_replayedKey] == true'),
    );
    expect(RegExp(r'_replayedKey\] = true').allMatches(source), hasLength(1));
  });

  test('retries live in one place, the client, and are bounded by the '
      'endpoint catalog', () {
    final source = File('lib/src/gi_core_client.dart').readAsStringSync();
    expect(
      RegExp(r'attempt >= endpoint\.maxRetries').allMatches(source),
      hasLength(1),
    );
  });
}
