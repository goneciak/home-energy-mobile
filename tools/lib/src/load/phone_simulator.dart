import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:gi_tools/src/load/container_sampler.dart';
import 'package:gi_tools/src/load/load_stats.dart';

/// What to simulate.
final class LoadConfig {
  const new({
    required this.baseUrl,
    required this.token,
    required this.deviceListInterval,
    required this.cardInterval,
    this.clients = 3,
    this.cards = 2,
    this.duration = const Duration(seconds: 600),
    this.timeScale = 1,
    this.sampleEvery = const Duration(seconds: 5),
    this.seed = 1,
  });

  /// GI Core's origin, without `/api/v1`.
  final Uri baseUrl;

  /// Access token every simulated phone uses (one login serves all).
  final String token;

  /// Cadence of `GET /devices`: the app's `PollingBudget.deviceList`, passed
  /// in so the tool reads the app's constants and does not copy them.
  final Duration deviceListInterval;

  /// Cadence of each heating card when [cards] are shown: the app's
  /// `PollingBudget.heatingCardInterval`.
  final Duration Function(int cards) cardInterval;

  /// Phones with Home open.
  final int clients;

  /// Heating cards on each phone's Home.
  final int cards;

  /// How long the phones run, in run time.
  final Duration duration;

  /// Run time per real time: `30` replays the cadences 30 times faster
  /// (for `--dry-run` and tests; against a real GI Core it stays `1`).
  final double timeScale;

  /// Real time between two container samples.
  final Duration sampleEvery;

  /// Seed of the start offsets, so a run can be repeated.
  final int seed;
}

/// Everything a run measured.
final class LoadRun {
  const new({
    required this.config,
    required this.startedAt,
    required this.clients,
    required this.samples,
    required this.warnings,
  });

  final LoadConfig config;
  final DateTime startedAt;
  final List<ClientStats> clients;
  final List<ContainerSample> samples;
  final List<String> warnings;
}

/// Logs in once and returns the access token: the only request that is not
/// a GET, and the only one that changes anything (it opens a session).
Future<String> loginForToken(
  Uri baseUrl, {
  required String email,
  required String password,
}) async {
  final http = HttpClient();
  try {
    final request = await http.postUrl(
      baseUrl.replace(path: '/api/v1/auth/login'),
    );
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'email': email, 'password': password}));
    final response = await request.close();
    final body = await utf8.decodeStream(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw StateError('login answered ${response.statusCode}');
    }
    final json = jsonDecode(body);
    final token = json is Map ? json['accessToken'] : null;
    if (token is! String) throw StateError('login returned no accessToken');
    return token;
  } finally {
    http.close(force: true);
  }
}

/// Runs `config.clients` phones with Home open, each polling like the app
/// does (GET only), and samples the container meanwhile.
Future<LoadRun> runLoad(LoadConfig config, {ContainerSampler? sampler}) async {
  final warnings = <String>[];
  final startedAt = DateTime.now();
  final clock = Stopwatch()..start();
  Duration runTime() => clock.elapsed * config.timeScale;

  final ids = await _heatingDeviceIds(config, warnings);

  final stop = Completer<void>();
  final realDuration = Duration(
    microseconds: (config.duration.inMicroseconds / config.timeScale).round(),
  );
  final stopTimer = Timer(realDuration, stop.complete);

  final samples = <ContainerSample>[];
  var sampling = true;
  Future<void> sampleLoop() async {
    if (sampler == null) return;
    final problem = await sampler.prepare();
    if (problem != null) {
      warnings.add(problem);
      return;
    }
    while (sampling && !stop.isCompleted) {
      final sample = await sampler.sample(runTime());
      if (sample != null) samples.add(sample);
      await Future.any([Future<void>.delayed(config.sampleEvery), stop.future]);
    }
  }

  final random = Random(config.seed);
  final phones = <Future<ClientStats>>[
    for (var i = 0; i < config.clients; i++)
      _Phone(
        index: i,
        config: config,
        cardIds: [
          for (var c = 0; c < config.cards; c++) ids[(i + c) % ids.length],
        ],
        stop: stop.future,
        runTime: runTime,
        startOffset: Duration(milliseconds: random.nextInt(5000)),
      ).run(),
  ];
  final sampling0 = sampleLoop();
  final clients = await Future.wait(phones);
  await stop.future;
  sampling = false;
  stopTimer.cancel();
  await sampling0;

  return LoadRun(
    config: config,
    startedAt: startedAt,
    clients: clients,
    samples: samples,
    warnings: warnings,
  );
}

/// Ids of the heating devices to put on the cards, discovered with one GET
/// that is not counted in the report.
Future<List<String>> _heatingDeviceIds(
  LoadConfig config,
  List<String> warnings,
) async {
  final http = HttpClient();
  try {
    final request = await http.getUrl(
      config.baseUrl.replace(path: '/api/v1/devices', query: 'limit=100'),
    );
    request.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer ${config.token}',
    );
    final response = await request.close();
    final body = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      warnings.add('device list answered ${response.statusCode}');
      return ['unknown'];
    }
    final json = jsonDecode(body);
    final items = switch (json) {
      final List<Object?> list => list,
      {'items': final List<Object?> list} => list,
      {'data': final List<Object?> list} => list,
      _ => const <Object?>[],
    };
    final devices = items.whereType<Map<String, Object?>>().toList();
    final heating = [
      for (final d in devices)
        if (d['heatingRelayEntityId'] != null) '${d['id']}',
    ];
    if (heating.isNotEmpty) return heating;
    if (devices.isNotEmpty) {
      warnings.add(
        'no heating device in the stack: the cards poll ordinary devices',
      );
      return [for (final d in devices) '${d['id']}'];
    }
    warnings.add('the stack has no devices: card requests will answer 404');
    return ['unknown'];
  } on Object catch (error) {
    warnings.add('could not read the device list: $error');
    return ['unknown'];
  } finally {
    http.close(force: true);
  }
}

/// One phone with Home open: the device list, one poller per heating card
/// and the one-off room list, on the app's cadences.
final class _Phone {
  new({
    required this.index,
    required this.config,
    required this.cardIds,
    required this.stop,
    required this.runTime,
    required this.startOffset,
  });

  final int index;
  final LoadConfig config;
  final List<String> cardIds;
  final Future<void> stop;
  final Duration Function() runTime;
  final Duration startOffset;

  final _http = HttpClient();
  final _etags = <String, String>{};
  final _records = <RequestRecord>[];
  var _stopped = false;

  Duration _real(Duration run) =>
      Duration(microseconds: (run.inMicroseconds / config.timeScale).round());

  Future<void> _sleep(Duration run) =>
      Future.any([Future<void>.delayed(_real(run)), stop]);

  Future<ClientStats> run() async {
    unawaited(stop.then((_) => _stopped = true));
    await _sleep(startOffset);
    final cardInterval = config.cardInterval(cardIds.length);
    await Future.wait([
      _request('/api/v1/rooms', startup: true),
      _poll(
        '/api/v1/devices?limit=100',
        config.deviceListInterval,
        Duration.zero,
      ),
      for (var i = 0; i < cardIds.length; i++)
        _poll(
          '/api/v1/devices/${cardIds[i]}',
          cardInterval,
          cardInterval * i ~/ cardIds.length,
        ),
    ]);
    _http.close(force: true);
    return ClientStats(index, _records, config.duration);
  }

  Future<void> _poll(String path, Duration interval, Duration phase) async {
    var first = true;
    var wait = interval + phase;
    while (!_stopped) {
      await _request(path, startup: first);
      first = false;
      if (_stopped) break;
      await _sleep(wait);
      wait = interval;
    }
  }

  Future<void> _request(String path, {bool startup = false}) async {
    if (_stopped) return;
    final at = runTime();
    final timer = Stopwatch()..start();
    var status = 0;
    var notModified = false;
    try {
      final request = await _http.getUrl(config.baseUrl.resolve(path));
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${config.token}',
      );
      final etag = _etags[path];
      if (etag != null) {
        request.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
      }
      final response = await request.close();
      await response.drain<void>();
      status = response.statusCode;
      notModified = status == HttpStatus.notModified;
      if (response.headers.value(HttpHeaders.etagHeader) case final tag?) {
        _etags[path] = tag;
      }
    } on Object {
      status = 0;
    }
    _records.add(
      RequestRecord(
        at: at,
        status: status,
        latency: timer.elapsed,
        notModified: notModified,
        startup: startup,
      ),
    );
  }
}
