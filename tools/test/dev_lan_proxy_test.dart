import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:gi_tools/dev_lan_proxy.dart';
import 'package:test/test.dart';

/// An echo server on an ephemeral loopback port.
Future<ServerSocket> _echoServer() async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((socket) => socket.cast<List<int>>().pipe(socket));
  return server;
}

/// Writes [bytes], half-closes and collects everything until the peer
/// closes.
Future<List<int>> _roundTrip(int port, List<int> bytes) async {
  final socket = await Socket.connect(InternetAddress.loopbackIPv4, port);
  final received = BytesBuilder(copy: false);
  // A proxy that drops the connection may reset it (Linux does), which
  // surfaces as a SocketException: nothing was delivered in that case.
  final done = socket
      .listen(received.add)
      .asFuture<void>()
      .catchError((Object _) {});
  try {
    socket.add(bytes);
    await socket.flush();
    await socket.close();
  } on SocketException {
    // Reset before the write finished.
  }
  await done.timeout(const Duration(seconds: 10));
  socket.destroy();
  return received.takeBytes();
}

void main() {
  late ServerSocket echo;
  late DevLanProxy proxy;
  late List<String> log;

  setUp(() async {
    echo = await _echoServer();
    log = [];
    proxy = await DevLanProxy.start(
      listen: (host: '127.0.0.1', port: 0),
      target: (host: '127.0.0.1', port: echo.port),
      log: log.add,
    );
  });

  tearDown(() async {
    await proxy.close();
    await echo.close();
  });

  test('bytes make the round trip through the proxy', () async {
    final reply = await _roundTrip(proxy.port, 'GET /health'.codeUnits);

    expect(String.fromCharCodes(reply), 'GET /health');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(log.first, matches(RegExp(r'^#1 127\.0\.0\.1:\d+ -> .* open$')));
    expect(log.last, contains('closed after'));
    expect(log.last, contains('sent 11 B, received 11 B'));
  });

  test('a large payload and parallel connections arrive intact', () async {
    final payload = Uint8List.fromList([
      for (var i = 0; i < 2 * 1024 * 1024; i++) i % 251,
    ]);

    final replies = await Future.wait([
      for (var i = 0; i < 4; i++) _roundTrip(proxy.port, payload),
    ]);

    for (final reply in replies) {
      expect(reply, hasLength(payload.length));
      expect(reply, payload);
    }
  });

  test('an unreachable target closes the client and is logged', () async {
    final unused = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final deadPort = unused.port;
    await unused.close();
    final dead = await DevLanProxy.start(
      listen: (host: '127.0.0.1', port: 0),
      target: (host: '127.0.0.1', port: deadPort),
      log: log.add,
    );
    addTearDown(dead.close);

    final reply = await _roundTrip(dead.port, [1, 2, 3]);

    expect(reply, isEmpty);
    expect(log.single, contains('failed'));
  });

  test('close() drops open connections and stops accepting', () async {
    final client = await Socket.connect(
      InternetAddress.loopbackIPv4,
      proxy.port,
    );
    final done = client.listen((_) {}).asFuture<void>().catchError((_) {});
    client.add([42]);
    await client.flush();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(proxy.openConnections, 1);

    await proxy.close();

    await done.timeout(const Duration(seconds: 5));
    expect(proxy.openConnections, 0);
    client.destroy();
    await expectLater(
      Socket.connect(InternetAddress.loopbackIPv4, proxy.port),
      throwsA(isA<SocketException>()),
    );
  });

  group('parseHostPort', () {
    test('accepts host:port, :port, a bare port and [ipv6]:port', () {
      expect(parseHostPort('0.0.0.0:8080'), (host: '0.0.0.0', port: 8080));
      expect(parseHostPort(':8080'), (host: '0.0.0.0', port: 8080));
      expect(parseHostPort('3000'), (host: '127.0.0.1', port: 3000));
      expect(parseHostPort('[::1]:3000'), (host: '::1', port: 3000));
    });

    test('rejects a bad port', () {
      expect(() => parseHostPort('host:x'), throwsFormatException);
      expect(() => parseHostPort('host:70000'), throwsFormatException);
      expect(() => parseHostPort('[::1]3000'), throwsFormatException);
    });
  });
}
