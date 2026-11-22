import 'package:dio/dio.dart';

import 'package:gi_core_api/src/catalog/endpoint.dart';
import 'package:gi_core_api/src/catalog/endpoints.dart';
import 'package:gi_core_api/src/http/interceptors.dart';

/// One response remembered for a conditional GET: its weak ETag and the
/// decoded body it stands for.
final class EtagEntry {
  const new(this.etag, this.body);

  final String etag;
  final Object? body;
}

/// In-memory cache of the ETags of `GET /devices` and `GET /devices/:id`
/// (plan §6.5 pt 4, spike S4).
///
/// GI Core's ETag is Express's default weak ETag and does not depend on the
/// `Authorization` header, so every key carries the scope it was stored
/// under (profile and user, see [ConditionalGetInterceptor]). It only saves
/// bandwidth: a 304 replays the exact body that came with the ETag, and an
/// empty cache only means a full response. Nothing depends on it for
/// correctness.
final class EtagCache {
  /// At most [maxEntries] responses are kept; the oldest goes first.
  new({this.maxEntries = 64});

  final int maxEntries;
  final _entries = <String, EtagEntry>{};

  /// Number of responses served from the cache after a 304 (diagnostics,
  /// tests).
  int hits = 0;

  int get length => _entries.length;

  EtagEntry? lookup(String key) => _entries[key];

  void store(String key, EtagEntry entry) {
    _entries
      ..remove(key)
      ..[key] = entry;
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void remove(String key) => _entries.remove(key);

  /// Forgets every entry, e.g. when the session ends (logout, logout-all,
  /// revoked session) or the user changes.
  void clear() => _entries.clear();
}

/// Sends `If-None-Match` for the cached ETag of [endpointIds] and answers a
/// 304 with the cached body, as if the server had sent it again with 200.
///
/// The scope callback names the profile and user the request runs for;
/// without a scope (no signed-in user) nothing is cached or sent. A 304
/// without a cached body (it was cleared in between) is passed on as an
/// error, so the read fails like any unexpected status and its retry
/// policy applies.
final class ConditionalGetInterceptor extends Interceptor {
  new(this.cache, {required this._scope, Set<String>? endpointIds})
    : endpointIds = endpointIds ?? defaultEndpointIds;

  /// The two reads S4 confirmed (`GET /devices`, `GET /devices/:id`).
  static final Set<String> defaultEndpointIds = {
    GiEndpoints.devicesList.id,
    GiEndpoints.devicesDetail.id,
  };

  static const _keyExtra = 'gi.etagKey';

  final EtagCache cache;
  final String? Function() _scope;
  final Set<String> endpointIds;

  /// Cache key of [options] under [scope]: method, path and query.
  static String keyOf(String scope, RequestOptions options) =>
      '$scope ${options.method} ${options.uri.path}?${options.uri.query}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final endpoint = options.endpoint;
    final scope = _scope();
    if (endpoint == null ||
        endpoint.method != HttpMethod.get ||
        !endpointIds.contains(endpoint.id) ||
        scope == null) {
      handler.next(options);
      return;
    }
    final key = keyOf(scope, options);
    options.extra[_keyExtra] = key;
    final cached = cache.lookup(key);
    if (cached != null) {
      options.headers['if-none-match'] = cached.etag;
      final accepts = options.validateStatus;
      options.validateStatus = (status) => status == 304 || accepts(status);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    final key = response.requestOptions.extra[_keyExtra] as String?;
    if (key == null) {
      handler.next(response);
      return;
    }
    if (response.statusCode == 304) {
      final cached = cache.lookup(key);
      if (cached == null) {
        handler.reject(
          DioException.badResponse(
            statusCode: 304,
            requestOptions: response.requestOptions,
            response: response,
          ),
          true,
        );
        return;
      }
      cache.hits++;
      handler.next(
        Response<Object?>(
          requestOptions: response.requestOptions,
          data: cached.body,
          statusCode: 200,
          statusMessage: 'OK (not modified)',
          headers: response.headers,
          extra: {...response.extra, notModifiedExtraKey: true},
        ),
      );
      return;
    }
    final etag = response.headers.value('etag');
    if (etag != null && etag.isNotEmpty && response.statusCode == 200) {
      cache.store(key, EtagEntry(etag, response.data));
    } else {
      cache.remove(key);
    }
    handler.next(response);
  }
}

/// `Response.extra` key set to `true` on a response replayed from the
/// [EtagCache] after a 304.
const notModifiedExtraKey = 'gi.notModified';
