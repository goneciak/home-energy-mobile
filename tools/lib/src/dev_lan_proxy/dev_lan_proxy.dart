import 'dart:async';
import 'dart:io';

/// `host:port` as given on the command line (`0.0.0.0:8080`, `[::]:8080`,
/// `:8080` for every IPv4 interface, or a bare port).
typedef HostPort = ({String host, int port});

HostPort parseHostPort(String text, {String defaultHost = '127.0.0.1'}) {
  final value = text.trim();
  String host;
  String portText;
  if (value.startsWith('[')) {
    final end = value.indexOf(']');
    if (end < 0 || end + 1 >= value.length || value[end + 1] != ':') {
      throw FormatException('Expected [ipv6]:port', text);
    }
    host = value.substring(1, end);
    portText = value.substring(end + 2);
  } else {
    final colon = value.lastIndexOf(':');
    host = colon < 0 ? defaultHost : value.substring(0, colon);
    portText = colon < 0 ? value : value.substring(colon + 1);
    if (host.isEmpty) host = '0.0.0.0';
  }
  final port = int.tryParse(portText);
  if (port == null || port < 0 || port > 65535) {
    throw FormatException('Invalid port', text);
  }
  return (host: host, port: port);
}

/// A plain TCP forwarder for development (plan §9.6): a phone in the LAN
/// reaches a GI Core that stays published on the PC's loopback
/// (`0.0.0.0:8080 -> 127.0.0.1:3000`). Every accepted connection gets its
/// own upstream connection; bytes are piped both ways, half-closes are
/// passed on, and an error on either side tears down both. Nothing is
/// inspected or changed (HTTP keep-alive, cookies and `Host` pass through).
final class DevLanProxy {
  new _(this._server, this.target, this._log, this._connectTimeout) {
    _server.listen(_accept);
  }

  /// Binds [listen] and forwards every connection to [target].
  static Future<DevLanProxy> start({
    required HostPort listen,
    required HostPort target,
    void Function(String line)? log,
    Duration connectTimeout = const Duration(seconds: 5),
  }) async {
    final server = await ServerSocket.bind(listen.host, listen.port);
    return DevLanProxy._(server, target, log ?? (_) {}, connectTimeout);
  }

  final ServerSocket _server;
  final HostPort target;
  final void Function(String line) _log;
  final Duration _connectTimeout;
  final Set<Socket> _open = {};
  final Set<Future<void>> _running = {};
  var _sequence = 0;
  var _closed = false;

  /// The bound address (the real port when listening on port 0).
  InternetAddress get address => _server.address;
  int get port => _server.port;

  /// Connections currently being forwarded.
  int get openConnections => _running.length;

  void _accept(Socket client) {
    if (_closed) {
      client.destroy();
      return;
    }
    final done = _forward(client, ++_sequence);
    _running.add(done);
    unawaited(done.whenComplete(() => _running.remove(done)));
  }

  Future<void> _forward(Socket client, int id) async {
    final peer = '${client.remoteAddress.address}:${client.remotePort}';
    final upstreamName = '${target.host}:${target.port}';
    final opened = DateTime.now();
    _open.add(client);
    final Socket upstream;
    try {
      upstream = await Socket.connect(
        target.host,
        target.port,
        timeout: _connectTimeout,
      );
    } on Object catch (e) {
      _log('#$id $peer -> $upstreamName failed: ${_describe(e)}');
      _open.remove(client);
      client.destroy();
      return;
    }
    if (_closed) {
      upstream.destroy();
      client.destroy();
      _open.remove(client);
      return;
    }
    _open.add(upstream);
    _log('#$id $peer -> $upstreamName open');

    var sent = 0;
    var received = 0;
    Object? failure;
    Future<void> pipe(Socket from, Socket to, void Function(int) count) => from
        .map<List<int>>((chunk) {
          count(chunk.length);
          return chunk;
        })
        .pipe(to)
        .catchError((Object e) {
          failure ??= e;
          // One side failed: nothing more can be delivered either way.
          client.destroy();
          upstream.destroy();
        });

    await Future.wait([
      pipe(client, upstream, (n) => sent += n),
      pipe(upstream, client, (n) => received += n),
    ]);
    client.destroy();
    upstream.destroy();
    _open
      ..remove(client)
      ..remove(upstream);
    final ms = DateTime.now().difference(opened).inMilliseconds;
    final error = failure == null ? '' : ', ${_describe(failure!)}';
    _log(
      '#$id $peer closed after $ms ms '
      '(sent $sent B, received $received B$error)',
    );
  }

  /// Stops accepting, drops every open connection and waits until the
  /// forwarding of each one has finished.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _server.close();
    for (final socket in _open.toList()) {
      socket.destroy();
    }
    await Future.wait(_running.toList());
  }

  static String _describe(Object error) => switch (error) {
    SocketException(:final message, :final osError) =>
      osError == null ? message : '$message (${osError.message.trim()})',
    _ => '$error',
  };
}
