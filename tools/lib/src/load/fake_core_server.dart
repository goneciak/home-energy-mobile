import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A GI Core stand-in for `--dry-run` and the tool's tests: login, the device
/// list, device details and rooms, with ETags. Not a model of the real
/// backend, only enough for the cadence and the report to be exercised.
final class FakeCoreServer {
  new _(this._server, this.heatingDevices);

  static Future<FakeCoreServer> start({int heatingDevices = 3}) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = FakeCoreServer._(server, heatingDevices);
    server.listen(fake._handle);
    return fake;
  }

  final HttpServer _server;
  final int heatingDevices;

  /// `METHOD path` of every request, in arrival order.
  final List<String> requests = [];
  final Map<String, int> _hits = {};

  Uri get baseUrl => Uri.parse('http://127.0.0.1:${_server.port}');

  Future<void> close() => _server.close(force: true);

  void _handle(HttpRequest request) {
    final path = request.uri.path;
    requests.add('${request.method} $path');
    if (request.method == 'POST' && path == '/api/v1/auth/login') {
      _json(request, {'accessToken': 'fake-token', 'expiresIn': 900});
      return;
    }
    if (request.method != 'GET') {
      request.response.statusCode = HttpStatus.methodNotAllowed;
      unawaited(request.response.close());
      return;
    }
    final hits = _hits[path] = (_hits[path] ?? 0) + 1;
    // The data changes every fourth read, so conditional reads both hit
    // and miss.
    final etag = '"$path-${hits ~/ 4}"';
    if (request.headers.value(HttpHeaders.ifNoneMatchHeader) == etag) {
      request.response
        ..statusCode = HttpStatus.notModified
        ..headers.set(HttpHeaders.etagHeader, etag);
      unawaited(request.response.close());
      return;
    }
    request.response.headers.set(HttpHeaders.etagHeader, etag);
    switch (path) {
      case '/api/v1/devices':
        _json(request, {'items': _deviceList()});
      case '/api/v1/rooms':
        _json(request, {'items': <Object>[]});
      default:
        final id = path.split('/').last;
        _json(request, {'id': id, 'name': id});
    }
  }

  List<Map<String, Object?>> _deviceList() => [
    for (var i = 1; i <= heatingDevices; i++)
      {'id': 'heat-$i', 'name': 'heat-$i', 'heatingRelayEntityId': 'relay'},
  ];

  void _json(HttpRequest request, Object body) {
    request.response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    unawaited(request.response.close());
  }
}
